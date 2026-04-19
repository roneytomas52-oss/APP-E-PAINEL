<?php

namespace App\Console\Commands;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Models\Category;
use App\Models\Module;
use Illuminate\Console\Command;
use Illuminate\Support\Collection;

class CatalogSeedCommand extends Command
{
    protected $signature = 'catalog:seed
                            {--module-ids= : Comma separated module IDs}
                            {--module-types= : Comma separated module types}
                            {--default-image=def.png : Image filename for seeded categories}
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
                    ->first();

                if (!$mainCategory) {
                    $foundMain += 0;
                    if ($dryRun) {
                        $this->line("  [dry-run] create main: {$mainName}");
                    } else {
                        $mainCategory = $this->categoryRepo->add([
                            'name' => $mainName,
                            'image' => $defaultImage,
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
                        $this->categoryRepo->update((string)$mainCategory->id, ['image' => $defaultImage]);
                    }
                }

                foreach ($subCategories as $subName) {
                    $existingSub = Category::withoutGlobalScopes()
                        ->where('module_id', $module->id)
                        ->where('name', $subName)
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
                'Lanches' => ['Hambúrguer', 'Hot Dog', 'Sanduíches'],
                'Pizza' => ['Tradicional', 'Especial', 'Doce'],
                'Comida Brasileira' => ['Pratos Feitos', 'Marmitas', 'Executivos'],
                'Bebidas' => ['Refrigerantes', 'Sucos', 'Água'],
            ],
            'grocery' => [
                'Hortifruti' => ['Frutas', 'Verduras', 'Legumes'],
                'Mercearia' => ['Arroz e Feijão', 'Massas', 'Enlatados'],
                'Bebidas' => ['Água', 'Refrigerante', 'Suco'],
                'Limpeza' => ['Casa', 'Roupas', 'Utilidades'],
            ],
            'pharmacy' => [
                'Medicamentos' => ['Genéricos', 'Referência', 'Similares'],
                'Higiene Pessoal' => ['Sabonetes', 'Cuidados Bucais', 'Cuidados Íntimos'],
                'Vitaminas' => ['Polivitamínicos', 'Imunidade', 'Esportes'],
                'Infantil' => ['Fraldas', 'Lenços', 'Cuidados com o bebê'],
            ],
            'ecommerce' => [
                'Eletrônicos' => ['Celulares', 'Acessórios', 'Informática'],
                'Casa e Cozinha' => ['Utilidades', 'Organização', 'Decoração'],
                'Moda' => ['Masculino', 'Feminino', 'Infantil'],
                'Beleza' => ['Maquiagem', 'Cabelo', 'Skincare'],
            ],
            'parcel' => [
                'Documentos' => ['Envelope', 'Contrato', 'Fatura'],
                'Pacotes' => ['Pequeno', 'Médio', 'Grande'],
            ],
            'rental' => [
                'Veículos' => ['Carros', 'Motos', 'Utilitários'],
                'Equipamentos' => ['Ferramentas', 'Som e Luz', 'Eventos'],
            ],
            'ride-share' => [
                'Transporte Urbano' => ['Viagem curta', 'Viagem longa'],
            ],
            'default' => [
                'Geral' => ['Destaques'],
            ],
        ];
    }
}
