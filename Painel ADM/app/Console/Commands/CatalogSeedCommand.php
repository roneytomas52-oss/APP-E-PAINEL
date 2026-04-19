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
            'images_from_fallback' => 0,
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
        $this->line("Images from fallback/local: {$stats['images_from_fallback']}");

        return self::SUCCESS;
    }

    private function upsertCategory(
        int $moduleId,
        string $moduleType,
        array $payload,
        int $parentId,
        int $position,
        bool $withImages,
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

            if (!$dryRun && !$hasExistingImage) {
                $fallbackImage = $this->resolveFallbackImage($moduleType, $defaultImage, false);
                $this->categoryRepo->update((string)$existing->id, ['image' => $fallbackImage]);
                $stats['images_from_fallback']++;
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

        $resolvedImage = $this->resolveImage(
            moduleType: $moduleType,
            categoryName: $name,
            withImages: $withImages,
            imageSource: $imageSource,
            defaultImage: $defaultImage,
            countApiHit: $stats
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

    private function resolveImage(
        string $moduleType,
        string $categoryName,
        bool $withImages,
        string $imageSource,
        string $defaultImage,
        array &$countApiHit
    ): string {
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
