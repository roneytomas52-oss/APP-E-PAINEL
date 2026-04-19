<?php

namespace App\Console\Commands;

use App\Models\DMVehicle;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class SeedDmVehiclesCommand extends Command
{
    protected $signature = 'dm-vehicles:seed
                            {--dry-run : Simula o processo sem salvar no banco}
                            {--refresh : Força atualização dos veículos padrão já existentes}';

    protected $description = 'Cria e atualiza categorias padrão de veículos para onboarding de entregadores';

    public function handle(): int
    {
        $dryRun = (bool)$this->option('dry-run');
        $refresh = (bool)$this->option('refresh');

        $vehicles = $this->defaultVehicles();
        $summary = [
            'created' => 0,
            'updated' => 0,
            'unchanged' => 0,
        ];

        foreach ($vehicles as $vehicleData) {
            $imageName = $this->ensureIcon(
                slug: Str::slug($vehicleData['name']),
                label: $vehicleData['name'],
                dryRun: $dryRun,
                refresh: $refresh,
            );

            $payload = $vehicleData;
            $payload['image'] = $imageName;
            $payload['status'] = 1;
            $payload['is_delivery'] = 1;
            $payload['is_ride'] = 0;

            $existing = $this->findExistingVehicle($vehicleData['name'], $vehicleData['type']);

            if (!$existing) {
                $summary['created']++;
                $this->line("[CREATE] {$vehicleData['name']}");

                if (!$dryRun) {
                    DMVehicle::query()->create($payload);
                }
                continue;
            }

            $needsUpdate = $refresh || $this->hasChanges($existing, $payload);
            if ($needsUpdate) {
                $summary['updated']++;
                $this->line("[UPDATE] {$vehicleData['name']} (ID {$existing->id})");

                if (!$dryRun) {
                    $existing->fill($payload);
                    $existing->save();
                }
            } else {
                $summary['unchanged']++;
                $this->line("[OK] {$vehicleData['name']} (sem alterações)");
            }
        }

        $this->newLine();
        $this->info('Resumo:');
        $this->line(" - criados: {$summary['created']}");
        $this->line(" - atualizados: {$summary['updated']}");
        $this->line(" - sem alterações: {$summary['unchanged']}");

        if ($dryRun) {
            $this->warn('Execução em modo --dry-run. Nenhuma alteração foi persistida.');
        }

        return self::SUCCESS;
    }

    private function defaultVehicles(): array
    {
        return [
            [
                'name' => 'A pé',
                'type' => 'A pé - curtas distâncias',
                'description' => 'Entregas de curtíssima distância com baixo volume.',
                'starting_coverage_area' => 0,
                'maximum_coverage_area' => 1.99,
                'extra_charges' => 0,
            ],
            [
                'name' => 'Bicicleta',
                'type' => 'Bicicleta - entregas leves',
                'description' => 'Ideal para entregas leves e rápidas em áreas urbanas.',
                'starting_coverage_area' => 2,
                'maximum_coverage_area' => 4.99,
                'extra_charges' => 1.5,
            ],
            [
                'name' => 'Moto',
                'type' => 'Moto - padrão principal',
                'description' => 'Opção principal: rápida e com custo operacional baixo.',
                'starting_coverage_area' => 5,
                'maximum_coverage_area' => 11.99,
                'extra_charges' => 3,
            ],
            [
                'name' => 'Carro',
                'type' => 'Carro - médio porte',
                'description' => 'Capacidade intermediária para pedidos maiores.',
                'starting_coverage_area' => 12,
                'maximum_coverage_area' => 24.99,
                'extra_charges' => 6,
            ],
            [
                'name' => 'Utilitário / Van',
                'type' => 'Utilitário / Van - cargas grandes',
                'description' => 'Para cargas grandes, múltiplos volumes ou longa distância.',
                'starting_coverage_area' => 25,
                'maximum_coverage_area' => 200,
                'extra_charges' => 12,
            ],
        ];
    }

    private function findExistingVehicle(string $name, string $type): ?DMVehicle
    {
        return DMVehicle::query()
            ->withoutGlobalScopes()
            ->whereRaw('LOWER(name) = ?', [Str::lower($name)])
            ->orWhereRaw('LOWER(type) = ?', [Str::lower($type)])
            ->orderBy('id')
            ->first();
    }

    private function hasChanges(DMVehicle $vehicle, array $payload): bool
    {
        foreach ($payload as $column => $value) {
            $current = $vehicle->{$column};

            if (is_float($value) || is_int($value)) {
                if ((float)$current !== (float)$value) {
                    return true;
                }
                continue;
            }

            if ((string)$current !== (string)$value) {
                return true;
            }
        }

        return false;
    }

    private function ensureIcon(string $slug, string $label, bool $dryRun, bool $refresh): string
    {
        $filename = "dm-vehicle-{$slug}.svg";
        $directory = storage_path('app/public/vehicle/category');
        $fullPath = $directory . DIRECTORY_SEPARATOR . $filename;

        if ($dryRun) {
            return $filename;
        }

        if (!File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        if ($refresh || !File::exists($fullPath)) {
            File::put($fullPath, $this->buildSvgIcon($label));
        }

        return $filename;
    }

    private function buildSvgIcon(string $label): string
    {
        $safeLabel = e($label);

        return <<<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256" role="img" aria-label="{$safeLabel}">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#1f8fff"/>
      <stop offset="100%" stop-color="#3f51b5"/>
    </linearGradient>
  </defs>
  <rect x="8" y="8" width="240" height="240" rx="36" fill="url(#g)"/>
  <circle cx="128" cy="96" r="28" fill="white" opacity="0.95"/>
  <rect x="62" y="136" width="132" height="54" rx="16" fill="white" opacity="0.95"/>
  <text x="128" y="220" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" fill="white">{$safeLabel}</text>
</svg>
SVG;
    }
}
