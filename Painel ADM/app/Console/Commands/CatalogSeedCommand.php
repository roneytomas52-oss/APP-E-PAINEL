<?php

namespace App\Console\Commands;

use App\CentralLogics\Helpers;
use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Models\Category;
use App\Models\Module;
use Illuminate\Console\Command;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class CatalogSeedCommand extends Command
{
    private const SUPPORTED_MODULES = ['food', 'grocery', 'pharmacy', 'parcel', 'ecommerce'];

    protected $signature = 'catalog:seed
                            {--module-ids= : Comma separated module IDs}
                            {--module-types= : Comma separated module types}
                            {--default-image=def.png : Ultimate fallback image filename}
                            {--fill-missing-images : Fill only missing images on existing main categories}
                            {--refresh-images : Refresh images for all existing main categories}
                            {--with-images : Try to fetch category images from external API}
                            {--image-source=auto : auto|pexels|unsplash|none}
                            {--pexels-api-key= : Pexels API key (optional, fallback ENV PEXELS_API_KEY)}
                            {--unsplash-access-key= : Unsplash Access Key (optional, fallback ENV UNSPLASH_ACCESS_KEY)}
                            {--economical-threshold=30 : Value used in "Econômicos (até R$X)" category}
                            {--dry-run : Show what would be created without writing}';

    protected $description = 'Seed production-grade categories/subcategories per supported module (idempotent + offline-safe)';

    public function __construct(
        protected CategoryRepositoryInterface $categoryRepo
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $modules = $this->resolveModules();
        if ($modules->isEmpty()) {
            $this->warn('No supported modules found for the given filters.');
            return self::SUCCESS;
        }

        $dryRun = (bool)$this->option('dry-run');
        $withImages = (bool)$this->option('with-images');
        $fillMissingImages = (bool)$this->option('fill-missing-images');
        $refreshImages = (bool)$this->option('refresh-images');
        $imageSource = strtolower((string)$this->option('image-source'));
        $defaultImage = (string)$this->option('default-image');
        $economicalThreshold = max(1, (int)$this->option('economical-threshold'));
        $template = $this->catalogTemplate($economicalThreshold);

        if (!in_array($imageSource, ['auto', 'pexels', 'unsplash', 'none'], true)) {
            $this->error("Invalid --image-source={$imageSource}. Use: auto|pexels|unsplash|none");
            return self::FAILURE;
        }

        $stats = [
            'created_main' => 0,
            'created_sub' => 0,
            'found_main' => 0,
            'found_sub' => 0,
            'images_from_api' => 0,
            'images_refreshed' => 0,
            'images_from_fallback' => 0,
            'images_from_local_map' => 0,
        ];

        foreach ($modules as $module) {
            $moduleType = $module->module_type;
            $moduleCatalog = $template[$moduleType] ?? [];

            if (empty($moduleCatalog)) {
                $this->warn("Module #{$module->id} ({$moduleType}) skipped: no catalog template.");
                continue;
            }

            $this->line("Module #{$module->id} ({$moduleType}): processing " . count($moduleCatalog) . ' main categories');

            foreach ($moduleCatalog as $mainCategoryData) {
                $mainCategory = $this->upsertCategory(
                    moduleId: (int)$module->id,
                    moduleType: $moduleType,
                    payload: $mainCategoryData,
                    parentId: 0,
                    position: 0,
                    withImages: $withImages,
                    fillMissingImages: $fillMissingImages,
                    refreshImages: $refreshImages,
                    imageSource: $imageSource,
                    defaultImage: $defaultImage,
                    dryRun: $dryRun,
                    stats: $stats
                );

                foreach ($mainCategoryData['children'] as $subCategoryData) {
                    $this->upsertCategory(
                        moduleId: (int)$module->id,
                        moduleType: $moduleType,
                        payload: $subCategoryData,
                        parentId: $mainCategory?->id ?? 0,
                        position: 1,
                        withImages: $withImages,
                        fillMissingImages: $fillMissingImages,
                        refreshImages: $refreshImages,
                        imageSource: $imageSource,
                        defaultImage: $defaultImage,
                        dryRun: $dryRun,
                        stats: $stats
                    );
                }
            }
        }

        $this->info('catalog:seed finished');
        $this->line("Main categories created: {$stats['created_main']}");
        $this->line("Subcategories created: {$stats['created_sub']}");
        $this->line("Main categories already existing: {$stats['found_main']}");
        $this->line("Subcategories already existing: {$stats['found_sub']}");
        $this->line("Images from API: {$stats['images_from_api']}");
        $this->line("Images from local map: {$stats['images_from_local_map']}");
        $this->line("Images from fallback/local: {$stats['images_from_fallback']}");
        $this->line("Existing images refreshed: {$stats['images_refreshed']}");

        return self::SUCCESS;
    }

    private function upsertCategory(
        int $moduleId,
        string $moduleType,
        array $payload,
        int $parentId,
        int $position,
        bool $withImages,
        bool $fillMissingImages,
        bool $refreshImages,
        string $imageSource,
        string $defaultImage,
        bool $dryRun,
        array &$stats
    ): ?Category {
        $name = $payload['name'];

        $existing = Category::withoutGlobalScopes()
            ->where('module_id', $moduleId)
            ->where('parent_id', $parentId)
            ->where('position', $position)
            ->where('name', $name)
            ->first();

        $hasExistingImage = $existing && !empty($existing->image);

        if ($existing) {
            $stats[$position === 0 ? 'found_main' : 'found_sub']++;

            if (!$dryRun && $position === 0) {
                $shouldFillMissing = $fillMissingImages && !$hasExistingImage;
                $shouldRefresh = $refreshImages;

                if ($shouldFillMissing || $shouldRefresh) {
                    $resolvedMainImage = $this->resolveMainCategoryImage(
                        moduleType: $moduleType,
                        categoryName: $name,
                        withImages: $withImages,
                        imageSource: $imageSource,
                        defaultImage: $defaultImage,
                        countApiHit: $stats
                    );

                    if ($existing->image !== $resolvedMainImage) {
                        $this->categoryRepo->update((string)$existing->id, ['image' => $resolvedMainImage]);
                        $stats['images_refreshed']++;
                    }
                }
            }

            if (!$dryRun && ($payload['special'] ?? false)) {
                $specialSlug = $payload['special_slug'] ?? null;
                if ($specialSlug && $existing->slug !== $specialSlug) {
                    $this->categoryRepo->update((string)$existing->id, [
                        'slug' => $this->buildUniqueSlug($moduleId, $specialSlug, (int)$existing->id),
                        'featured' => 1,
                    ]);
                }
            }

            return $existing;
        }

        if ($dryRun) {
            $level = $position === 0 ? 'main' : 'sub';
            $this->line("  [dry-run] create {$level}: {$name}");
            $stats[$position === 0 ? 'created_main' : 'created_sub']++;
            return null;
        }

        $resolvedImage = $position === 0
            ? $this->resolveMainCategoryImage(
                moduleType: $moduleType,
                categoryName: $name,
                withImages: $withImages,
                imageSource: $imageSource,
                defaultImage: $defaultImage,
                countApiHit: $stats
            )
            : $this->resolveSubCategoryImage(
                categoryName: $name,
                withImages: $withImages,
                imageSource: $imageSource
            );

        $created = $this->categoryRepo->add([
            'name' => $name,
            'image' => $resolvedImage,
            'parent_id' => $parentId,
            'position' => $position,
            'priority' => $payload['priority'] ?? 0,
            'status' => 1,
            'module_id' => $moduleId,
            'featured' => ($payload['special'] ?? false) ? 1 : 0,
        ]);

        if ($payload['special'] ?? false) {
            $specialSlug = $payload['special_slug'] ?? null;
            if ($specialSlug) {
                $this->categoryRepo->update((string)$created->id, [
                    'slug' => $this->buildUniqueSlug($moduleId, $specialSlug, (int)$created->id),
                ]);
            }
        }

        $stats[$position === 0 ? 'created_main' : 'created_sub']++;

        return $created;
    }

    private function resolveMainCategoryImage(
        string $moduleType,
        string $categoryName,
        bool $withImages,
        string $imageSource,
        string $defaultImage,
        array &$countApiHit
    ): string {
        $localMappedImage = $this->resolveMainCategoryLocalImage($moduleType, $categoryName);
        if ($localMappedImage) {
            $countApiHit['images_from_local_map']++;
            return $localMappedImage;
        }

        if ($withImages && $imageSource !== 'none') {
            $downloaded = $this->downloadCategoryImage($categoryName, $imageSource);
            if ($downloaded) {
                $countApiHit['images_from_api']++;
                return $downloaded;
            }
        }

        $countApiHit['images_from_fallback']++;
        return $this->resolveFallbackImage($moduleType, $defaultImage, true);
    }

    private function resolveSubCategoryImage(string $categoryName, bool $withImages, string $imageSource): ?string
    {
        if ($withImages && $imageSource !== 'none') {
            return $this->downloadCategoryImage($categoryName, $imageSource);
        }

        return null;
    }

    private function resolveMainCategoryLocalImage(string $moduleType, string $categoryName): ?string
    {
        $disk = Storage::disk(Helpers::getDisk());
        $targetDir = 'category';
        $categoryKey = $this->normalizeCategoryKey($categoryName);
        $map = $this->mainCategoryImageMap();
        $mapped = $map[$moduleType][$categoryKey] ?? $map['*'][$categoryKey] ?? null;

        if (!$mapped) {
            $mapped = [
                'file' => "main-{$moduleType}-{$categoryKey}.svg",
                'icon' => 'bag',
                'bg' => '#F3F4F6',
            ];
        }

        $this->ensureLocalSeedSvg($mapped);
        $publicAssetPath = public_path('assets/admin/img/category-seed/' . $mapped['file']);
        if (!is_file($publicAssetPath)) {
            return null;
        }

        if (!$disk->exists($targetDir)) {
            $disk->makeDirectory($targetDir);
        }
        if (!$disk->exists("{$targetDir}/{$mapped['file']}")) {
            $disk->put("{$targetDir}/{$mapped['file']}", file_get_contents($publicAssetPath));
        }

        return $mapped['file'];
    }

    private function ensureLocalSeedSvg(array $mapped): void
    {
        $seedDir = public_path('assets/admin/img/category-seed');
        if (!is_dir($seedDir)) {
            @mkdir($seedDir, 0755, true);
        }

        $filePath = $seedDir . DIRECTORY_SEPARATOR . $mapped['file'];
        if (is_file($filePath)) {
            return;
        }

        $background = e($mapped['bg'] ?? '#F3F4F6');
        $iconName = (string)($mapped['icon'] ?? 'bag');
        $icon = $this->minimalIconSvg($iconName);

        $svg = <<<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="96" fill="{$background}"/>
  <rect x="96" y="96" width="320" height="320" rx="80" fill="#FFFFFF"/>
  {$icon}
</svg>
SVG;

        file_put_contents($filePath, $svg);
    }

    private function normalizeCategoryKey(string $value): string
    {
        return Str::of($value)
            ->ascii()
            ->lower()
            ->replaceMatches('/[^a-z0-9]+/', '-')
            ->trim('-')
            ->toString();
    }

    private function mainCategoryImageMap(): array
    {
        return [
            '*' => [
                'hamburguer' => ['file' => 'main-hamburguer.svg', 'icon' => 'burger', 'bg' => '#FDEBD2'],
                'pizza' => ['file' => 'main-pizza.svg', 'icon' => 'pizza', 'bg' => '#FEE2E2'],
                'japonesa' => ['file' => 'main-japonesa.svg', 'icon' => 'sushi', 'bg' => '#EDE9FE'],
                'acai' => ['file' => 'main-acai.svg', 'icon' => 'cup', 'bg' => '#E9D5FF'],
                'hortifruti' => ['file' => 'main-hortifruti.svg', 'icon' => 'leaf', 'bg' => '#DCFCE7'],
                'medicamentos' => ['file' => 'main-medicamentos.svg', 'icon' => 'pill', 'bg' => '#DBEAFE'],
                'documentos' => ['file' => 'main-documentos.svg', 'icon' => 'document', 'bg' => '#E5E7EB'],
                'moda' => ['file' => 'main-moda.svg', 'icon' => 'shirt', 'bg' => '#FCE7F3'],
            ],
            'food' => [
                'promocoes' => ['file' => 'main-promocoes.svg', 'icon' => 'tag', 'bg' => '#FFEDD5'],
                'mais-vendidos' => ['file' => 'main-mais-vendidos.svg', 'icon' => 'star', 'bg' => '#FEF3C7'],
                'combos' => ['file' => 'main-combos.svg', 'icon' => 'combo', 'bg' => '#FFE4E6'],
                'entrega-rapida' => ['file' => 'main-entrega-rapida.svg', 'icon' => 'delivery', 'bg' => '#D1FAE5'],
                'economicos-ate-r-30' => ['file' => 'main-economicos.svg', 'icon' => 'money', 'bg' => '#CCFBF1'],
                'lanches' => ['file' => 'main-lanches.svg', 'icon' => 'burger', 'bg' => '#FDEBD2'],
                'comida-brasileira' => ['file' => 'main-comida-brasileira.svg', 'icon' => 'plate', 'bg' => '#FCE7F3'],
                'bebidas' => ['file' => 'main-bebidas.svg', 'icon' => 'drink', 'bg' => '#DBEAFE'],
            ],
            'grocery' => [
                'mercearia' => ['file' => 'main-mercearia.svg', 'icon' => 'basket', 'bg' => '#E0F2FE'],
                'limpeza' => ['file' => 'main-limpeza.svg', 'icon' => 'spray', 'bg' => '#E0E7FF'],
            ],
            'pharmacy' => [
                'higiene-pessoal' => ['file' => 'main-higiene-pessoal.svg', 'icon' => 'bottle', 'bg' => '#ECFEFF'],
                'vitaminas' => ['file' => 'main-vitaminas.svg', 'icon' => 'capsule', 'bg' => '#E0F2FE'],
                'infantil' => ['file' => 'main-infantil.svg', 'icon' => 'baby', 'bg' => '#FCE7F3'],
            ],
            'ecommerce' => [
                'eletronicos' => ['file' => 'main-eletronicos.svg', 'icon' => 'device', 'bg' => '#EDE9FE'],
                'casa-e-cozinha' => ['file' => 'main-casa-cozinha.svg', 'icon' => 'home', 'bg' => '#F3F4F6'],
                'beleza' => ['file' => 'main-beleza.svg', 'icon' => 'spark', 'bg' => '#FCE7F3'],
            ],
            'parcel' => [
                'pacotes' => ['file' => 'main-pacotes.svg', 'icon' => 'box', 'bg' => '#E5E7EB'],
            ],
        ];
    }

    private function minimalIconSvg(string $icon): string
    {
        return match ($icon) {
            'burger' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M180 232h152"/><path d="M168 264h176"/><path d="M188 296h136"/><path d="M176 216c8-28 32-44 80-44s72 16 80 44"/></g>',
            'pizza' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M172 324l84-176 84 176z"/><circle cx="256" cy="232" r="8" fill="#111827" stroke="none"/><circle cx="224" cy="274" r="8" fill="#111827" stroke="none"/><circle cx="288" cy="274" r="8" fill="#111827" stroke="none"/></g>',
            'sushi' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><rect x="176" y="216" width="160" height="96" rx="24"/><path d="M208 216v96M304 216v96"/></g>',
            'cup' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M196 196h120l-20 124h-80z"/><path d="M224 176l12 20M256 168l8 28M288 176l-10 20"/></g>',
            'leaf' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M180 280c0-68 56-116 132-116-2 74-50 132-116 132"/><path d="M212 256c24-12 56-34 84-68"/></g>',
            'pill', 'capsule' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><rect x="176" y="216" width="160" height="80" rx="40"/><path d="M256 216v80"/></g>',
            'document' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M208 164h96l40 40v144a20 20 0 0 1-20 20H208a20 20 0 0 1-20-20V184a20 20 0 0 1 20-20z"/><path d="M304 164v48h48"/><path d="M224 272h96M224 312h72"/></g>',
            'shirt' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M208 192l48 24 48-24 44 40-32 40v96H196v-96l-32-40z"/></g>',
            'tag' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M188 220h108l44 44-88 88-64-64z"/><circle cx="236" cy="252" r="8" fill="#111827" stroke="none"/></g>',
            'star' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M256 172l26 54 60 8-44 42 10 60-52-28-52 28 10-60-44-42 60-8z"/></g>',
            'combo' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><circle cx="220" cy="256" r="46"/><rect x="268" y="220" width="56" height="72" rx="12"/></g>',
            'delivery' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><rect x="176" y="228" width="120" height="72" rx="14"/><path d="M296 244h30l18 20v36h-48"/><circle cx="220" cy="316" r="14"/><circle cx="308" cy="316" r="14"/></g>',
            'money' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><rect x="172" y="212" width="168" height="100" rx="16"/><circle cx="256" cy="262" r="24"/><path d="M190 236h12M310 288h12"/></g>',
            'plate' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><circle cx="256" cy="256" r="84"/><circle cx="256" cy="256" r="38"/></g>',
            'drink' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M220 180h72l-12 152h-48z"/><path d="M236 180l-16-24"/><path d="M286 208h28"/></g>',
            'basket' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M180 224h152l-16 104H196z"/><path d="M216 224l40-44 40 44"/></g>',
            'spray' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><rect x="220" y="212" width="72" height="132" rx="16"/><path d="M236 212v-32h40v32"/><path d="M292 232h24"/></g>',
            'bottle' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M236 176h40v36l16 28v92a20 20 0 0 1-20 20h-32a20 20 0 0 1-20-20v-92l16-28z"/></g>',
            'baby' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><circle cx="256" cy="230" r="36"/><path d="M196 320c8-36 34-56 60-56s52 20 60 56"/><circle cx="242" cy="228" r="4" fill="#111827" stroke="none"/><circle cx="270" cy="228" r="4" fill="#111827" stroke="none"/></g>',
            'device' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><rect x="212" y="164" width="88" height="184" rx="16"/><path d="M242 332h28"/></g>',
            'home' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M176 248l80-68 80 68"/><path d="M204 244v104h104V244"/></g>',
            'spark' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M256 176l18 42 42 18-42 18-18 42-18-42-42-18 42-18z"/></g>',
            'box' => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M180 224l76-36 76 36-76 36z"/><path d="M180 224v88l76 36 76-36v-88"/></g>',
            default => '<g fill="none" stroke="#111827" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"><path d="M196 220h120l20 112H176z"/><path d="M220 220a36 36 0 0 1 72 0"/></g>',
        };
    }

    private function resolveFallbackImage(string $moduleType, string $defaultImage, bool $ensure): string
    {
        $moduleFallback = 'default-' . Str::slug($moduleType) . '.png';
        $disk = Storage::disk(Helpers::getDisk());
        $targetDir = 'category';

        if ($ensure && !$disk->exists("{$targetDir}/{$moduleFallback}")) {
            $baseAsset = public_path('assets/admin/img/category.png');
            if (is_file($baseAsset)) {
                if (!$disk->exists($targetDir)) {
                    $disk->makeDirectory($targetDir);
                }
                $disk->put("{$targetDir}/{$moduleFallback}", file_get_contents($baseAsset));
            }
        }

        if ($disk->exists("{$targetDir}/{$moduleFallback}")) {
            return $moduleFallback;
        }

        return $defaultImage;
    }

    private function downloadCategoryImage(string $categoryName, string $source): ?string
    {
        $orderedSources = $source === 'auto' ? ['pexels', 'unsplash'] : [$source];

        foreach ($orderedSources as $provider) {
            $url = $provider === 'pexels'
                ? $this->fetchPexelsImageUrl($categoryName)
                : $this->fetchUnsplashImageUrl($categoryName);

            if (!$url) {
                continue;
            }

            $saved = $this->persistRemoteImage($url);
            if ($saved) {
                return $saved;
            }
        }

        return null;
    }

    private function fetchPexelsImageUrl(string $query): ?string
    {
        $apiKey = (string)$this->option('pexels-api-key');
        $apiKey = $apiKey !== '' ? $apiKey : (string)env('PEXELS_API_KEY', '');
        if ($apiKey === '') {
            return null;
        }

        $response = Http::timeout(8)
            ->withHeaders(['Authorization' => $apiKey])
            ->get('https://api.pexels.com/v1/search', [
                'query' => $query . ' food product category',
                'per_page' => 1,
                'orientation' => 'landscape',
            ]);

        if (!$response->successful()) {
            return null;
        }

        return data_get($response->json(), 'photos.0.src.large')
            ?? data_get($response->json(), 'photos.0.src.medium');
    }

    private function fetchUnsplashImageUrl(string $query): ?string
    {
        $accessKey = (string)$this->option('unsplash-access-key');
        $accessKey = $accessKey !== '' ? $accessKey : (string)env('UNSPLASH_ACCESS_KEY', '');
        if ($accessKey === '') {
            return null;
        }

        $response = Http::timeout(8)
            ->get('https://api.unsplash.com/search/photos', [
                'query' => $query . ' product category',
                'per_page' => 1,
                'orientation' => 'landscape',
                'client_id' => $accessKey,
            ]);

        if (!$response->successful()) {
            return null;
        }

        return data_get($response->json(), 'results.0.urls.regular')
            ?? data_get($response->json(), 'results.0.urls.small');
    }

    private function persistRemoteImage(string $url): ?string
    {
        try {
            $binary = Http::timeout(10)->get($url);
            if (!$binary->successful()) {
                return null;
            }

            $disk = Storage::disk(Helpers::getDisk());
            $dir = 'category';
            if (!$disk->exists($dir)) {
                $disk->makeDirectory($dir);
            }

            $filename = now()->format('YmdHis') . '-' . Str::random(16) . '.jpg';
            $disk->put("{$dir}/{$filename}", $binary->body());

            return $filename;
        } catch (\Throwable) {
            return null;
        }
    }

    private function buildUniqueSlug(int $moduleId, string $slug, ?int $exceptId = null): string
    {
        $candidate = Str::slug($slug);
        $index = 2;

        while (Category::withoutGlobalScopes()
            ->where('module_id', $moduleId)
            ->where('slug', $candidate)
            ->when($exceptId, fn ($query) => $query->where('id', '!=', $exceptId))
            ->exists()) {
            $candidate = Str::slug($slug) . '-' . $index;
            $index++;
        }

        return $candidate;
    }

    private function resolveModules(): Collection
    {
        $moduleIds = $this->parseIntList((string)$this->option('module-ids'));
        if ($moduleIds === false) {
            return collect();
        }

        $moduleTypes = $this->parseStringList((string)$this->option('module-types'));
        if ($moduleTypes === false) {
            return collect();
        }

        if (!empty($moduleTypes)) {
            $moduleTypes = array_values(array_intersect($moduleTypes, self::SUPPORTED_MODULES));
        }

        return Module::withoutGlobalScopes()
            ->select(['id', 'module_type', 'module_name'])
            ->whereIn('module_type', self::SUPPORTED_MODULES)
            ->when(!empty($moduleIds), fn($query) => $query->whereIn('id', $moduleIds))
            ->when(!empty($moduleTypes), fn($query) => $query->whereIn('module_type', $moduleTypes))
            ->orderBy('id')
            ->get();
    }

    private function parseIntList(string $value): array|bool
    {
        if ($value === '') {
            return [];
        }

        $parts = array_values(array_unique(array_filter(array_map('trim', explode(',', $value)))));
        foreach ($parts as $part) {
            if (!ctype_digit($part)) {
                $this->error("Invalid integer list value: {$part}");
                return false;
            }
        }

        return array_map('intval', $parts);
    }

    private function parseStringList(string $value): array|bool
    {
        if ($value === '') {
            return [];
        }

        return array_values(array_unique(array_filter(array_map('trim', explode(',', $value)))));
    }

    private function catalogTemplate(int $economicalThreshold): array
    {
        $foodCommercial = [
            [
                'name' => 'Promoções',
                'special' => true,
                'special_slug' => 'special-food-promocoes',
                'children' => [
                    ['name' => 'Ofertas do Dia', 'special' => true, 'special_slug' => 'special-food-ofertas-dia'],
                    ['name' => 'Leve 2 Pague 1', 'special' => true, 'special_slug' => 'special-food-leve-2-pague-1'],
                ],
            ],
            [
                'name' => 'Mais vendidos',
                'special' => true,
                'special_slug' => 'special-food-mais-vendidos',
                'children' => [
                    ['name' => 'Top da Semana', 'special' => true, 'special_slug' => 'special-food-top-semana'],
                    ['name' => 'Favoritos', 'special' => true, 'special_slug' => 'special-food-favoritos'],
                ],
            ],
            [
                'name' => 'Combos',
                'special' => true,
                'special_slug' => 'special-food-combos',
                'children' => [
                    ['name' => 'Individual', 'special' => true, 'special_slug' => 'special-food-combo-individual'],
                    ['name' => 'Família', 'special' => true, 'special_slug' => 'special-food-combo-familia'],
                ],
            ],
            [
                'name' => 'Entrega rápida',
                'special' => true,
                'special_slug' => 'special-food-entrega-rapida',
                'children' => [
                    ['name' => 'Até 20 minutos', 'special' => true, 'special_slug' => 'special-food-ate-20-min'],
                    ['name' => 'Pronto para envio', 'special' => true, 'special_slug' => 'special-food-pronto-envio'],
                ],
            ],
            [
                'name' => "Econômicos (até R\${$economicalThreshold})",
                'special' => true,
                'special_slug' => 'special-food-economicos',
                'children' => [
                    ['name' => "Até R\${$economicalThreshold}", 'special' => true, 'special_slug' => 'special-food-economicos-faixa'],
                ],
            ],
        ];

        return [
            'food' => array_merge($foodCommercial, [
                [
                    'name' => 'Lanches',
                    'children' => [
                        ['name' => 'Hambúrguer'],
                        ['name' => 'Hot Dog'],
                        ['name' => 'Sanduíches'],
                    ],
                ],
                [
                    'name' => 'Pizza',
                    'children' => [
                        ['name' => 'Tradicional'],
                        ['name' => 'Especial'],
                        ['name' => 'Doce'],
                    ],
                ],
                [
                    'name' => 'Comida Brasileira',
                    'children' => [
                        ['name' => 'Pratos Feitos'],
                        ['name' => 'Marmitas'],
                        ['name' => 'Executivos'],
                    ],
                ],
                [
                    'name' => 'Bebidas',
                    'children' => [
                        ['name' => 'Refrigerantes'],
                        ['name' => 'Sucos'],
                        ['name' => 'Água'],
                    ],
                ],
            ]),
            'grocery' => [
                ['name' => 'Hortifruti', 'children' => [['name' => 'Frutas'], ['name' => 'Verduras'], ['name' => 'Legumes']]],
                ['name' => 'Mercearia', 'children' => [['name' => 'Arroz e Feijão'], ['name' => 'Massas'], ['name' => 'Enlatados']]],
                ['name' => 'Bebidas', 'children' => [['name' => 'Água'], ['name' => 'Refrigerante'], ['name' => 'Suco']]],
                ['name' => 'Limpeza', 'children' => [['name' => 'Casa'], ['name' => 'Roupas'], ['name' => 'Utilidades']]],
            ],
            'pharmacy' => [
                ['name' => 'Medicamentos', 'children' => [['name' => 'Genéricos'], ['name' => 'Referência'], ['name' => 'Similares']]],
                ['name' => 'Higiene Pessoal', 'children' => [['name' => 'Sabonetes'], ['name' => 'Cuidados Bucais'], ['name' => 'Cuidados Íntimos']]],
                ['name' => 'Vitaminas', 'children' => [['name' => 'Polivitamínicos'], ['name' => 'Imunidade'], ['name' => 'Esportes']]],
                ['name' => 'Infantil', 'children' => [['name' => 'Fraldas'], ['name' => 'Lenços'], ['name' => 'Cuidados com o bebê']]],
            ],
            'ecommerce' => [
                ['name' => 'Eletrônicos', 'children' => [['name' => 'Celulares'], ['name' => 'Acessórios'], ['name' => 'Informática']]],
                ['name' => 'Casa e Cozinha', 'children' => [['name' => 'Utilidades'], ['name' => 'Organização'], ['name' => 'Decoração']]],
                ['name' => 'Moda', 'children' => [['name' => 'Masculino'], ['name' => 'Feminino'], ['name' => 'Infantil']]],
                ['name' => 'Beleza', 'children' => [['name' => 'Maquiagem'], ['name' => 'Cabelo'], ['name' => 'Skincare']]],
            ],
            'parcel' => [
                ['name' => 'Documentos', 'children' => [['name' => 'Envelope'], ['name' => 'Contrato'], ['name' => 'Fatura']]],
                ['name' => 'Pacotes', 'children' => [['name' => 'Pequeno'], ['name' => 'Médio'], ['name' => 'Grande']]],
            ],
        ];
    }
}
