<?php

namespace App\Console\Commands;

use App\Models\Attribute;
use App\Models\Module;
use Illuminate\Console\Command;
use Illuminate\Support\Collection;

class AttributeSeedCommand extends Command
{
    private const SUPPORTED_MODULES = ['food', 'grocery', 'pharmacy', 'parcel', 'ecommerce'];

    protected $signature = 'attributes:seed
                            {--module-ids= : Comma separated module IDs}
                            {--module-types= : Comma separated module types}
                            {--dry-run : Show what would be created without writing data}';

    protected $description = 'Seed base product attributes for supported launch modules (idempotent)';

    public function handle(): int
    {
        $modules = $this->resolveModules();
        if ($modules->isEmpty()) {
            $this->warn('No active supported modules matched the provided filters.');
            return self::SUCCESS;
        }

        $dryRun = (bool)$this->option('dry-run');
        $requestedModuleTypes = $modules->pluck('module_type')->unique()->values()->all();

        $template = $this->attributeTemplate();
        $candidateAttributes = collect($requestedModuleTypes)
            ->flatMap(fn (string $moduleType) => $template[$moduleType] ?? [])
            ->map(fn (string $name) => trim($name))
            ->filter(fn (string $name) => $name !== '')
            ->unique(fn (string $name) => mb_strtolower($name))
            ->values();

        if ($candidateAttributes->isEmpty()) {
            $this->warn('No attribute candidates were generated.');
            return self::SUCCESS;
        }

        $existingByLowerName = Attribute::withoutGlobalScope('translate')
            ->get(['id', 'name'])
            ->mapWithKeys(fn (Attribute $attribute) => [mb_strtolower((string)$attribute->getRawOriginal('name')) => $attribute]);

        $created = 0;
        $found = 0;

        $this->line('Modules in scope: '.$modules->map(fn (Module $module) => "#{$module->id} ({$module->module_type})")->implode(', '));

        foreach ($candidateAttributes as $name) {
            $normalized = mb_strtolower($name);
            $existing = $existingByLowerName->get($normalized);

            if ($existing) {
                $found++;
                $this->line("[exists] {$existing->id} - {$existing->getRawOriginal('name')}");
                continue;
            }

            if ($dryRun) {
                $created++;
                $this->line("[dry-run] create: {$name}");
                continue;
            }

            $createdAttribute = Attribute::withoutGlobalScope('translate')->create([
                'name' => $name,
            ]);

            $existingByLowerName->put($normalized, $createdAttribute);
            $created++;
            $this->info("[created] {$createdAttribute->id} - {$name}");
        }

        $foodRequested = in_array('food', $requestedModuleTypes, true);
        if ($foodRequested) {
            $this->warn('Food module note: this platform uses food_variations for add-ons/options; attributes table is not consumed by food variation flow.');
        }

        $this->newLine();
        $this->info('attributes:seed finished.');
        $this->line("Candidates: {$candidateAttributes->count()}");
        $this->line("Created: {$created}");
        $this->line("Already existing: {$found}");
        $this->line('Mode: '.($dryRun ? 'dry-run (no writes)' : 'write'));

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

        if (!empty($moduleTypes)) {
            $moduleTypes = array_values(array_intersect($moduleTypes, self::SUPPORTED_MODULES));
        }

        return Module::withoutGlobalScopes()
            ->select(['id', 'module_type', 'status'])
            ->where('status', 1)
            ->whereIn('module_type', self::SUPPORTED_MODULES)
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

        return array_values(array_unique(array_filter(array_map(fn ($item) => strtolower(trim($item)), explode(',', $value)))));
    }

    private function attributeTemplate(): array
    {
        return [
            'food' => [],
            'grocery' => [
                'Peso',
                'Volume',
                'Unidade',
                'Marca',
                'Tipo de embalagem',
                'Validade',
                'Orgânico',
                'Sem açúcar',
                'Sem glúten',
            ],
            'pharmacy' => [
                'Dosagem',
                'Quantidade',
                'Forma farmacêutica',
                'Genérico ou referência',
                'Precisa de receita',
                'Marca',
            ],
            'parcel' => [
                'Tipo de item',
                'Peso',
                'Fragilidade',
                'Dimensão',
                'Precisa de assinatura',
            ],
            'ecommerce' => [
                'Tamanho',
                'Cor',
                'Material',
                'Marca',
                'Modelo',
                'Voltagem',
                'Garantia',
            ],
        ];
    }
}
