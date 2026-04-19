<?php

namespace App\Console\Commands;

use App\CentralLogics\Helpers;
use App\Models\Module;
use App\Models\ParcelCategory;
use Illuminate\Console\Command;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ParcelCategorySeedCommand extends Command
{
    protected $signature = 'parcel-categories:seed
                            {--module-ids= : Comma separated parcel module IDs}
                            {--dry-run : Preview changes without writing data}
                            {--refresh-images : Force image update for existing categories}';

    protected $description = 'Seed base parcel categories with shipping charges in an idempotent production-safe way';

    public function handle(): int
    {
        $modules = $this->resolveModules();
        if ($modules->isEmpty()) {
            $this->warn('No active parcel modules matched the provided filters.');
            return self::SUCCESS;
        }

        $dryRun = (bool) $this->option('dry-run');
        $refreshImages = (bool) $this->option('refresh-images');

        $templates = $this->categoryTemplate();

        $stats = [
            'created' => 0,
            'updated' => 0,
            'unchanged' => 0,
            'images_refreshed' => 0,
        ];

        $this->line('Modules in scope: '.$modules->map(fn (Module $module) => "#{$module->id} ({$module->module_name})")->implode(', '));

        foreach ($modules as $module) {
            foreach ($templates as $template) {
                $this->upsertCategory(
                    moduleId: (int) $module->id,
                    payload: $template,
                    dryRun: $dryRun,
                    refreshImages: $refreshImages,
                    stats: $stats,
                );
            }
        }

        $this->newLine();
        $this->info('parcel-categories:seed finished');
        $this->line("Created: {$stats['created']}");
        $this->line("Updated: {$stats['updated']}");
        $this->line("Unchanged: {$stats['unchanged']}");
        $this->line("Images refreshed: {$stats['images_refreshed']}");
        $this->line('Mode: '.($dryRun ? 'dry-run (no writes)' : 'write'));

        return self::SUCCESS;
    }

    private function upsertCategory(
        int $moduleId,
        array $payload,
        bool $dryRun,
        bool $refreshImages,
        array &$stats
    ): void {
        $name = (string) $payload['name'];
        $normalizedName = Str::lower(trim($name));

        $existing = ParcelCategory::withoutGlobalScope('translate')
            ->where('module_id', $moduleId)
            ->get()
            ->first(function (ParcelCategory $category) use ($normalizedName) {
                return Str::lower(trim((string) $category->getRawOriginal('name'))) === $normalizedName;
            });

        $resolvedImage = $this->resolveCategoryImage($payload['image']);

        if (!$existing) {
            if ($dryRun) {
                $stats['created']++;
                $this->line("[dry-run] create module {$moduleId}: {$name}");
                return;
            }

            $created = new ParcelCategory();
            $created->module_id = $moduleId;
            $created->name = $name;
            $created->description = (string) $payload['description'];
            $created->status = 1;
            $created->parcel_per_km_shipping_charge = (float) $payload['parcel_per_km_shipping_charge'];
            $created->parcel_minimum_shipping_charge = (float) $payload['parcel_minimum_shipping_charge'];
            $created->image = $resolvedImage;
            $created->save();

            $stats['created']++;
            $this->info("[created] {$created->id} - {$name} (module {$moduleId})");
            return;
        }

        $changes = [];

        if ((string) $existing->getRawOriginal('description') !== (string) $payload['description']) {
            $changes['description'] = (string) $payload['description'];
        }

        if ((float) $existing->parcel_per_km_shipping_charge !== (float) $payload['parcel_per_km_shipping_charge']) {
            $changes['parcel_per_km_shipping_charge'] = (float) $payload['parcel_per_km_shipping_charge'];
        }

        if ((float) $existing->parcel_minimum_shipping_charge !== (float) $payload['parcel_minimum_shipping_charge']) {
            $changes['parcel_minimum_shipping_charge'] = (float) $payload['parcel_minimum_shipping_charge'];
        }

        if ((int) $existing->status !== 1) {
            $changes['status'] = 1;
        }

        if (($refreshImages || empty($existing->image)) && $existing->image !== $resolvedImage) {
            $changes['image'] = $resolvedImage;
            $stats['images_refreshed']++;
        }

        if (empty($changes)) {
            $stats['unchanged']++;
            $this->line("[exists] {$existing->id} - {$name} (module {$moduleId})");
            return;
        }

        if ($dryRun) {
            $stats['updated']++;
            $fields = implode(', ', array_keys($changes));
            $this->line("[dry-run] update {$existing->id} - {$name}: {$fields}");
            return;
        }

        $existing->fill($changes);
        $existing->save();
        $stats['updated']++;

        $fields = implode(', ', array_keys($changes));
        $this->info("[updated] {$existing->id} - {$name}: {$fields}");
    }

    private function resolveCategoryImage(string $imageFile): string
    {
        $disk = Storage::disk(Helpers::getDisk());
        $directory = 'parcel_category';

        if (!$disk->exists($directory)) {
            $disk->makeDirectory($directory);
        }

        $assetPath = public_path('assets/admin/img/parcel-category-seed/'.$imageFile);

        if (is_file($assetPath) && !$disk->exists("{$directory}/{$imageFile}")) {
            $disk->put("{$directory}/{$imageFile}", file_get_contents($assetPath));
        }

        if (is_file($assetPath)) {
            return $imageFile;
        }

        return 'def.png';
    }

    private function resolveModules(): Collection
    {
        $moduleIds = $this->parseIntList((string) $this->option('module-ids'));
        if ($moduleIds === false) {
            return collect();
        }

        return Module::withoutGlobalScopes()
            ->select(['id', 'module_name', 'module_type', 'status'])
            ->where('module_type', 'parcel')
            ->where('status', 1)
            ->when(!empty($moduleIds), fn ($query) => $query->whereIn('id', $moduleIds))
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

    private function categoryTemplate(): array
    {
        return [
            [
                'name' => 'Documento',
                'description' => 'Envelope, papéis, contratos e itens leves',
                'parcel_per_km_shipping_charge' => 2.5,
                'parcel_minimum_shipping_charge' => 8,
                'image' => 'parcel-documento.svg',
            ],
            [
                'name' => 'Pequeno',
                'description' => 'Pacote leve até 5kg',
                'parcel_per_km_shipping_charge' => 3,
                'parcel_minimum_shipping_charge' => 10,
                'image' => 'parcel-pequeno.svg',
            ],
            [
                'name' => 'Médio',
                'description' => 'Pacote padrão até 15kg',
                'parcel_per_km_shipping_charge' => 4,
                'parcel_minimum_shipping_charge' => 15,
                'image' => 'parcel-medio.svg',
            ],
            [
                'name' => 'Grande',
                'description' => 'Volume alto ou pacote pesado',
                'parcel_per_km_shipping_charge' => 5,
                'parcel_minimum_shipping_charge' => 20,
                'image' => 'parcel-grande.svg',
            ],
        ];
    }
}
