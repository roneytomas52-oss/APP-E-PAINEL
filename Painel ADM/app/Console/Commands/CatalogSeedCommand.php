<?php

namespace App\Console\Commands;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Models\Category;
use App\Models\Module;
use Illuminate\Console\Command;
use Illuminate\Support\Arr;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class CatalogSeedCommand extends Command
{
    protected $signature = 'catalog:seed
                            {--module-ids= : Comma separated module IDs}
                            {--module-types= : Comma separated module types}
                            {--default-image=def.png : Image filename for seeded categories}
                            {--image-source=local : local|internet}
                            {--pexels-api-key= : Pexels API key (required for image-source=internet)}
                            {--internet-timeout=10 : Timeout seconds for internet image requests}
                            {--include-non-launch-modules : Include ride-share/rental in main seed}
                            {--dry-run : Show what would be created without writing}';

    protected $description = 'Seed main categories and subcategories per module (idempotent)';

    public function __construct(
        protected CategoryRepositoryInterface $categoryRepo
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $modules = $this->resolveModules();
        if ($modules->isEmpty()) {
            $this->warn('No modules found for the given filters.');
            return self::SUCCESS;
        }

        $defaultImage = (string)$this->option('default-image');
        $dryRun = (bool)$this->option('dry-run');
        $template = $this->catalogTemplate();

        $createdMain = 0;
        $createdSub = 0;
        $foundMain = 0;
        $foundSub = 0;

        foreach ($modules as $module) {
            $moduleType = $module->module_type;
            $moduleCatalog = $template[$moduleType] ?? $template['default'];

            $this->line("Module #{$module->id} ({$moduleType}): processing ".count($moduleCatalog).' main categories');

            foreach ($moduleCatalog as $mainName => $subCategories) {
                $mainCategory = Category::withoutGlobalScopes()
                    ->where('module_id', $module->id)
                    ->where('name', $mainName)
                    ->where('position', 0)
                    ->first();

                if (!$mainCategory) {
                    if ($dryRun) {
                        $this->line("  [dry-run] create main: {$mainName}");
                    } else {
                        $imageName = $this->resolveMainCategoryImage(
                            moduleType: $moduleType,
                            categoryName: $mainName,
                            fallbackImage: $defaultImage
                        );
                        $mainCategory = $this->categoryRepo->add([
                            'name' => $mainName,
                            'image' => $imageName,
                            'parent_id' => 0,
                            'position' => 0,
                            'priority' => 0,
                            'status' => 1,
                            'module_id' => $module->id,
                        ]);
                    }
                    $createdMain++;
                } else {
                    $foundMain++;
                    if (!$dryRun && empty($mainCategory->image)) {
                        $imageName = $this->resolveMainCategoryImage(
                            moduleType: $moduleType,
                            categoryName: $mainName,
                            fallbackImage: $defaultImage
                        );
                        $this->categoryRepo->update((string)$mainCategory->id, ['image' => $imageName]);
                    }
                }

                foreach ($subCategories as $subName) {
                    $existingSub = Category::withoutGlobalScopes()
                        ->where('module_id', $module->id)
                        ->where('name', $subName)
                        ->where('position', 1)
                        ->where('parent_id', $mainCategory?->id ?? 0)
                        ->first();

                    if ($existingSub) {
                        $foundSub++;
                        continue;
                    }

                    if ($dryRun) {
                        $this->line("    [dry-run] create sub: {$subName}");
                    } else {
                        $this->categoryRepo->add([
                            'name' => $subName,
                            'image' => $defaultImage,
                            'parent_id' => $mainCategory->id,
                            'position' => 1,
                            'priority' => 0,
                            'status' => 1,
                            'module_id' => $module->id,
                        ]);
                    }
                    $createdSub++;
                }
            }
        }

        $this->info('catalog:seed finished');
        $this->line("Main categories created: {$createdMain}");
        $this->line("Subcategories created: {$createdSub}");
        $this->line("Main categories already existing: {$foundMain}");
        $this->line("Subcategories already existing: {$foundSub}");

        return self::SUCCESS;
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

        if (empty($moduleTypes) && empty($moduleIds) && ! $this->option('include-non-launch-modules')) {
            $moduleTypes = $this->launchModuleTypes();
        }

        return Module::withoutGlobalScopes()
            ->select(['id', 'module_type', 'module_name'])
            ->when(!empty($moduleIds), fn ($query) => $query->whereIn('id', $moduleIds))
            ->when(!empty($moduleTypes), fn ($query) => $query->whereIn('module_type', $moduleTypes))
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

        $parts = array_values(array_unique(array_filter(array_map('trim', explode(',', $value)))));
        if (empty($parts)) {
            return [];
        }

        return $parts;
    }

    private function catalogTemplate(): array
    {
        return [
            'food' => [
                'Hambúrguer' => ['Smash', 'Artesanal', 'Tradicional', 'Combo', 'Gourmet'],
                'Pizza' => ['Tradicional', 'Especial', 'Broto', 'Família', 'Doce'],
                'Japonesa' => ['Sushi', 'Temaki', 'Combinados', 'Hot Roll'],
                'Açaí' => ['Copo', 'Barca', 'Premium'],
                'Marmita' => ['Caseira', 'Fitness', 'Executiva'],
                'Comida Brasileira' => ['Prato Feito', 'Churrasco', 'Feijoada'],
                'Italiana' => ['Massas', 'Lasanha', 'Risoto'],
                'Chinesa' => ['Yakisoba', 'Frango Xadrez'],
                'Mexicana' => ['Tacos', 'Burritos'],
                'Padaria' => ['Pães', 'Doces', 'Café da Manhã'],
                'Lanches' => ['Sanduíches', 'Hot Dog', 'Wraps'],
                'Bebidas' => ['Refrigerantes', 'Sucos', 'Energéticos', 'Água'],
                'Sobremesas' => ['Bolos', 'Sorvetes', 'Doces'],
            ],
            'grocery' => [
                'Hortifruti' => ['Frutas', 'Verduras', 'Legumes', 'Orgânicos'],
                'Carnes e Aves' => ['Bovino', 'Frango', 'Suíno', 'Peixes'],
                'Bebidas' => ['Água', 'Refrigerantes', 'Sucos', 'Energéticos'],
                'Laticínios' => ['Leite', 'Queijos', 'Iogurtes', 'Manteiga'],
                'Mercearia' => ['Arroz e Feijão', 'Massas', 'Enlatados', 'Temperos'],
                'Limpeza' => ['Lavanderia', 'Cozinha', 'Casa', 'Desinfetantes'],
                'Higiene' => ['Banho', 'Cabelo', 'Bucal', 'Beleza'],
                'Congelados' => ['Pratos Prontos', 'Carnes Congeladas', 'Sorvetes', 'Legumes Congelados'],
                'Pet Shop' => ['Ração', 'Higiene', 'Acessórios'],
                'Bebê' => ['Fraldas', 'Lenços', 'Alimentação', 'Higiene'],
                'Saudáveis' => ['Diet', 'Zero', 'Integral', 'Suplementos'],
            ],
            'pharmacy' => [
                'Medicamentos' => ['Dor e Febre', 'Gripe', 'Digestão', 'Alergia'],
                'Genéricos' => ['Uso Contínuo', 'Controle Diário', 'Similar Terapêutico'],
                'Higiene Pessoal' => ['Sabonetes', 'Shampoo', 'Desodorante', 'Cuidados Bucais'],
                'Vitaminas' => ['Imunidade', 'Energia', 'Infantil', 'Mulher'],
                'Infantil' => ['Fraldas', 'Lenços', 'Cuidados', 'Alimentação'],
                'Dermocosméticos' => ['Rosto', 'Corpo', 'Protetor Solar', 'Acne'],
                'Primeiros Socorros' => ['Curativos', 'Antissépticos', 'Termômetro', 'Gaze e Esparadrapo'],
                'Sexualidade' => ['Preservativos', 'Lubrificantes', 'Testes'],
                'Fitness' => ['Proteína', 'Recuperação', 'Articulações'],
            ],
            'ecommerce' => [
                'Moda' => ['Feminino', 'Masculino', 'Infantil', 'Calçados'],
                'Eletrônicos' => ['Celulares', 'Informática', 'Acessórios', 'Games'],
                'Casa e Decoração' => ['Cozinha', 'Quarto', 'Organização', 'Decoração'],
                'Beleza' => ['Maquiagem', 'Cabelo', 'Perfumaria', 'Skincare'],
                'Infantil' => ['Brinquedos', 'Roupas', 'Escolar', 'Bebê'],
                'Esportes' => ['Fitness', 'Outdoor', 'Futebol', 'Ciclismo'],
                'Automotivo' => ['Peças', 'Acessórios', 'Cuidados'],
                'Papelaria' => ['Escritório', 'Escolar', 'Presentes'],
                'Acessórios' => ['Bolsas', 'Relógios', 'Bijuterias', 'Óculos'],
            ],
            'parcel' => [
                'Documentos' => ['Envelope', 'Contratos', 'Cartório', 'Escritório'],
                'Pacotes' => ['Pequeno', 'Médio', 'Grande', 'Frágil'],
                'Presentes' => ['Flores', 'Cestas', 'Kits', 'Datas Especiais'],
                'Eletrônicos' => ['Celulares', 'Acessórios', 'Informática'],
                'Roupas' => ['Feminino', 'Masculino', 'Infantil'],
                'Utilidades' => ['Papelaria', 'Objetos Pessoais', 'Casa', 'Escritório'],
            ],
            'rental' => [
                'Veículos' => ['Carros', 'Motos', 'Utilitários', 'Elétricos'],
                'Equipamentos' => ['Ferramentas', 'Som e Luz', 'Eventos', 'Construção'],
                'Imóveis por Temporada' => ['Casas', 'Apartamentos', 'Chácaras'],
            ],
            'ride-share' => [
                'Transporte Urbano' => ['Viagem curta', 'Viagem longa', 'Aeroporto', 'Corrida Programada'],
            ],
            'default' => [
                'Geral' => ['Destaques'],
            ],
        ];
    }

    private function launchModuleTypes(): array
    {
        return ['grocery', 'food', 'pharmacy', 'parcel', 'ecommerce'];
    }

    private function resolveMainCategoryImage(string $moduleType, string $categoryName, string $fallbackImage): string
    {
        $source = strtolower((string)$this->option('image-source'));
        if (!in_array($source, ['local', 'internet'], true)) {
            $source = 'local';
        }

        if ($source === 'internet') {
            $onlineImage = $this->fetchInternetImage(moduleType: $moduleType, categoryName: $categoryName);
            if ($onlineImage) {
                return $onlineImage;
            }
        }

        $localImage = $this->storeLocalFallbackImage(moduleType: $moduleType, categoryName: $categoryName);
        return $localImage ?: $fallbackImage;
    }

    private function fetchInternetImage(string $moduleType, string $categoryName): ?string
    {
        $apiKey = (string)$this->option('pexels-api-key');
        if ($apiKey === '') {
            return null;
        }

        $timeout = max((int)$this->option('internet-timeout'), 5);
        $query = urlencode(strtolower($categoryName.' '.$moduleType.' brazil food delivery category'));

        try {
            $search = Http::timeout($timeout)
                ->withHeaders(['Authorization' => $apiKey])
                ->get("https://api.pexels.com/v1/search?query={$query}&per_page=1&orientation=landscape");

            if (!$search->successful()) {
                return null;
            }

            $imageUrl = Arr::get($search->json(), 'photos.0.src.large');
            if (!$imageUrl) {
                return null;
            }

            $image = Http::timeout($timeout)->get($imageUrl);
            if (!$image->successful() || empty($image->body())) {
                return null;
            }

            $fileName = $this->predictableImageName($moduleType, $categoryName, 'jpg');
            Storage::disk($this->disk())->put("category/{$fileName}", $image->body());
            return $fileName;
        } catch (\Throwable) {
            return null;
        }
    }

    private function storeLocalFallbackImage(string $moduleType, string $categoryName): ?string
    {
        $sourceFile = public_path('assets/admin/img/category.png');
        if (!file_exists($sourceFile)) {
            return null;
        }

        $fileName = $this->predictableImageName($moduleType, $categoryName, 'png');
        $targetPath = "category/{$fileName}";
        if (!Storage::disk($this->disk())->exists($targetPath)) {
            Storage::disk($this->disk())->put($targetPath, file_get_contents($sourceFile));
        }

        return $fileName;
    }

    private function predictableImageName(string $moduleType, string $categoryName, string $extension): string
    {
        $module = Str::slug($moduleType);
        $category = Str::slug($categoryName);
        return "seed-{$module}-{$category}.{$extension}";
    }

    private function disk(): string
    {
        $config = getWebConfig('local_storage');
        return isset($config) ? ($config == 0 ? 's3' : 'public') : 'public';
    }
}
