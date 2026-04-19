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
                    ->where('position', 0)
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
                'Açaí' => ['Açaí Tradicional', 'Açaí com Frutas', 'Açaí Zero Açúcar', 'Açaí no Copo'],
                'Japonesa' => ['Sushi', 'Temaki', 'Combinados', 'Pratos Quentes'],
                'Padaria' => ['Pães', 'Salgados', 'Café da Manhã', 'Lanches de Padaria'],
                'Sobremesas' => ['Bolos', 'Tortas', 'Doces', 'Sorvetes'],
                'Lanches' => ['Hambúrguer', 'Smash Burger', 'Hot Dog', 'Sanduíches'],
                'Pizza' => ['Tradicional', 'Especial', 'Broto', 'Doce'],
                'Marmitas' => ['Caseira', 'Fitness', 'Executiva', 'Vegetariana'],
                'Brasileira' => ['Prato Feito', 'Churrasco', 'Feijoada', 'Regional'],
                'Italiana' => ['Massas', 'Lasanhas', 'Risotos', 'Nhoques'],
                'Churrasco' => ['Espetinhos', 'Parrilla', 'Porções', 'Carnes'],
                'Saudável' => ['Saladas', 'Low Carb', 'Vegano', 'Sem Glúten'],
                'Árabe' => ['Esfiha', 'Kibe', 'Shawarma', 'Pratos Árabes'],
                'Frango' => ['Frango Frito', 'Frango Assado', 'Baldes', 'Porções'],
                'Peixes e Frutos do Mar' => ['Peixes', 'Camarão', 'Moqueca', 'Combinados'],
                'Pastelaria' => ['Pastéis', 'Caldos', 'Porções', 'Combos'],
                'Bebidas' => ['Refrigerantes', 'Sucos', 'Água', 'Energéticos'],
            ],
            'grocery' => [
                'Hortifruti' => ['Frutas', 'Verduras', 'Legumes', 'Orgânicos'],
                'Mercearia' => ['Arroz e Feijão', 'Massas', 'Enlatados', 'Molhos e Temperos'],
                'Açougue e Peixaria' => ['Bovinos', 'Aves', 'Suínos', 'Peixes e Frutos do Mar'],
                'Frios e Laticínios' => ['Leites', 'Queijos', 'Iogurtes', 'Manteigas'],
                'Padaria e Matinais' => ['Pães', 'Biscoitos', 'Cereais', 'Café'],
                'Bebidas' => ['Água', 'Refrigerante', 'Suco', 'Cerveja e Destilados'],
                'Congelados' => ['Pratos Prontos', 'Carnes Congeladas', 'Sorvetes', 'Vegetais Congelados'],
                'Limpeza' => ['Casa', 'Roupas', 'Utilidades', 'Desinfecção'],
                'Higiene e Beleza' => ['Cabelo', 'Corpo e Banho', 'Cuidados Bucais', 'Papelaria Higiene'],
                'Pet Shop' => ['Ração', 'Areia e Tapetes', 'Petiscos', 'Acessórios'],
            ],
            'pharmacy' => [
                'Medicamentos' => ['Genéricos', 'Referência', 'Similares', 'Controlados'],
                'Dor e Febre' => ['Analgésicos', 'Antitérmicos', 'Enxaqueca', 'Anti-inflamatórios'],
                'Gripe e Resfriado' => ['Antigripais', 'Tosse', 'Garganta', 'Descongestionantes'],
                'Higiene Pessoal' => ['Sabonetes', 'Cuidados Bucais', 'Cuidados Íntimos', 'Absorventes'],
                'Dermocosméticos' => ['Rosto', 'Corpo', 'Protetor Solar', 'Anti-idade'],
                'Vitaminas e Suplementos' => ['Polivitamínicos', 'Imunidade', 'Esportes', 'Ômega 3'],
                'Infantil' => ['Fraldas', 'Lenços', 'Mamadeiras', 'Cuidados com o bebê'],
                'Primeiros Socorros' => ['Curativos', 'Antissépticos', 'Termômetros', 'Máscaras'],
                'Bem-estar Sexual' => ['Preservativos', 'Lubrificantes', 'Testes', 'Planejamento'],
            ],
            'ecommerce' => [
                'Eletrônicos' => ['Celulares', 'Acessórios', 'Informática', 'Áudio e Vídeo'],
                'Casa e Cozinha' => ['Utilidades', 'Organização', 'Decoração', 'Eletroportáteis'],
                'Moda' => ['Masculino', 'Feminino', 'Infantil', 'Esportivo'],
                'Beleza' => ['Maquiagem', 'Cabelo', 'Skincare', 'Perfumaria'],
                'Papelaria e Escritório' => ['Cadernos', 'Canetas', 'Impressão', 'Organização'],
                'Automotivo' => ['Acessórios', 'Limpeza Automotiva', 'Som Automotivo', 'Segurança'],
                'Ferramentas e Construção' => ['Manuais', 'Elétricas', 'Hidráulica', 'Iluminação'],
                'Games e Brinquedos' => ['Consoles', 'Jogos', 'Brinquedos', 'Colecionáveis'],
            ],
            'parcel' => [
                'Documentos' => ['Envelope', 'Contrato', 'Fatura', 'Malote'],
                'Pacotes' => ['Pequeno', 'Médio', 'Grande', 'Frágil'],
                'Serviços Especiais' => ['Entrega Expressa', 'Entrega Programada', 'Retirada e Entrega'],
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
}
