<?php

namespace App\Console\Commands;

use App\Models\Module;
use App\Models\Zone;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;

class AttachModulesToZoneCommand extends Command
{
    protected $signature = 'zone:attach-modules
                            {zoneName? : Exact zone name}
                            {--all : Apply to all zones}
                            {--name-like= : SQL LIKE pattern for zone names}
                            {--modules= : Comma separated module IDs}
                            {--detach-missing : Use sync (detaching missing modules) instead of syncWithoutDetaching}
                            {--delivery-charge-type= : Optional pivot value (fixed|distance)}
                            {--fixed-shipping-charge= : Optional pivot fixed charge}
                            {--per-km-shipping-charge= : Optional pivot distance charge}
                            {--minimum-shipping-charge= : Optional pivot minimum charge}
                            {--maximum-shipping-charge= : Optional pivot maximum charge}
                            {--maximum-cod-order-amount= : Optional pivot COD max}';

    protected $description = 'Attach modules to zones in bulk using Eloquent belongsToMany relation';

    public function handle(): int
    {
        $moduleIds = $this->parseModuleIds((string)$this->option('modules'));
        if ($moduleIds === false) {
            return self::FAILURE;
        }

        if (empty($moduleIds)) {
            $this->error('You must provide --modules=1,2,3');
            return self::FAILURE;
        }

        $validModuleIds = Module::withoutGlobalScopes()->whereIn('id', $moduleIds)->pluck('id')->toArray();
        if (count($validModuleIds) !== count($moduleIds)) {
            $invalid = implode(',', array_diff($moduleIds, $validModuleIds));
            $this->error("Invalid module IDs: {$invalid}");
            return self::FAILURE;
        }

        $zones = $this->resolveZones();
        if ($zones === false) {
            return self::FAILURE;
        }

        if ($zones->isEmpty()) {
            $this->warn('No zones matched the given filters.');
            return self::SUCCESS;
        }

        $pivotData = $this->buildPivotData();
        $payload = !empty($pivotData)
            ? collect($validModuleIds)->mapWithKeys(fn ($id) => [$id => $pivotData])->toArray()
            : $validModuleIds;

        $detachMissing = (bool)$this->option('detach-missing');
        $affected = 0;

        foreach ($zones as $zone) {
            if ($detachMissing) {
                $zone->modules()->sync($payload);
            } else {
                $zone->modules()->syncWithoutDetaching($payload);
            }
            $affected++;
            $this->line("Zone #{$zone->id} - {$zone->name}: modules linked");
        }

        $this->info("Done. {$affected} zone(s) updated.");
        $this->line('Modules: '.implode(',', $validModuleIds));
        $this->line('Mode: '.($detachMissing ? 'sync (detach missing)' : 'syncWithoutDetaching (preserve existing)'));

        return self::SUCCESS;
    }

    private function resolveZones()
    {
        $all = (bool)$this->option('all');
        $nameLike = trim((string)$this->option('name-like'));
        $zoneName = trim((string)$this->argument('zoneName'));

        $query = Zone::withoutGlobalScopes()->orderBy('id');

        if ($all) {
            return $query->get();
        }

        if ($nameLike !== '') {
            return $query->where('name', 'like', $nameLike)->get();
        }

        if ($zoneName !== '') {
            return $query->where('name', $zoneName)->get();
        }

        $this->error('Provide one target selector: --all OR --name-like="..." OR "zoneName".');
        return false;
    }

    private function parseModuleIds(string $moduleInput): array|bool
    {
        $ids = array_values(array_unique(array_filter(array_map('trim', explode(',', $moduleInput)), fn ($value) => $value !== '')));
        foreach ($ids as $id) {
            if (!ctype_digit($id)) {
                $this->error("Invalid module id '{$id}'. Use comma-separated integer IDs.");
                return false;
            }
        }

        return array_map('intval', $ids);
    }

    private function buildPivotData(): array
    {
        $data = [];

        $map = [
            'delivery_charge_type' => ['option' => 'delivery-charge-type', 'numeric' => false],
            'fixed_shipping_charge' => ['option' => 'fixed-shipping-charge', 'numeric' => true],
            'per_km_shipping_charge' => ['option' => 'per-km-shipping-charge', 'numeric' => true],
            'minimum_shipping_charge' => ['option' => 'minimum-shipping-charge', 'numeric' => true],
            'maximum_shipping_charge' => ['option' => 'maximum-shipping-charge', 'numeric' => true],
            'maximum_cod_order_amount' => ['option' => 'maximum-cod-order-amount', 'numeric' => true],
        ];

        foreach ($map as $column => $meta) {
            if (!Schema::hasColumn('module_zone', $column)) {
                continue;
            }

            $value = $this->option($meta['option']);
            if ($value === null || $value === '') {
                continue;
            }

            if ($meta['numeric']) {
                if (!is_numeric($value)) {
                    $this->warn("Ignoring {$column}: non numeric value '{$value}'.");
                    continue;
                }
                $value = (float)$value;
            }

            $data[$column] = $value;
        }

        return $data;
    }
}
