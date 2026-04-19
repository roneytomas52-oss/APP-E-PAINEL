<?php

namespace App\Console\Commands;

use App\Models\Zone;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use MatanYadaev\EloquentSpatial\Objects\LineString;
use MatanYadaev\EloquentSpatial\Objects\Point;
use MatanYadaev\EloquentSpatial\Objects\Polygon;

class CreateZoneCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * Coordinates format accepted:
     * - 'Polygon [[[lat,lng],[lat,lng],...]]'
     * - '[[[lat,lng],[lat,lng],...]]'
     */
    protected $signature = 'zone:create
                            {name : Zone name}
                            {--display-name= : Display name (defaults to name)}
                            {--coordinates= : Polygon in app format}
                            {--cash-on-delivery=1 : 1 or 0}
                            {--digital-payment=1 : 1 or 0}
                            {--offline-payment=0 : 1 or 0}
                            {--set-default=0 : 1 or 0}
                            {--update-if-exists : Update zone if name already exists instead of failing}';

    /**
     * The console command description.
     */
    protected $description = 'Create a delivery zone from polygon coordinates (lat,lng format)';

    public function handle(): int
    {
        $name = trim((string)$this->argument('name'));
        $displayName = trim((string)($this->option('display-name') ?: $name));
        $coordinatesInput = trim((string)$this->option('coordinates'));

        if ($coordinatesInput === '') {
            $this->error('Missing --coordinates option.');
            $this->line('Expected format: Polygon [[[lat,lng],[lat,lng],[lat,lng]]]');
            return self::FAILURE;
        }

        $polygonPoints = $this->parseCoordinates($coordinatesInput);
        if ($polygonPoints === null) {
            return self::FAILURE;
        }

        $zone = DB::transaction(function () use ($name, $displayName, $polygonPoints) {
            $existingZone = Zone::withoutGlobalScopes()->where('name', $name)->first();
            $zone = $existingZone;

            if ($existingZone && !$this->option('update-if-exists')) {
                $this->error("Zone '{$name}' already exists (id: {$existingZone->id}). Use --update-if-exists to update.");
                return null;
            }

            if (!$zone) {
                $zone = new Zone();
                $nextZoneId = ((int)(Zone::withoutGlobalScopes()->max('id'))) + 1;
                $zone->store_wise_topic = 'zone_'.$nextZoneId.'_store';
                $zone->customer_wise_topic = 'zone_'.$nextZoneId.'_customer';
                $zone->deliveryman_wise_topic = 'zone_'.$nextZoneId.'_delivery_man';

                if (Schema::hasColumn('zones', 'rider_wise_topic')) {
                    $zone->rider_wise_topic = 'zone_'.$nextZoneId.'_rider';
                }
            }

            $zone->name = $name;
            if (Schema::hasColumn('zones', 'display_name')) {
                $zone->display_name = $displayName;
            }

            $zone->coordinates = $this->buildPolygon($polygonPoints);
            $zone->status = 1;
            $zone->cash_on_delivery = (int)$this->option('cash-on-delivery') ? 1 : 0;
            $zone->digital_payment = (int)$this->option('digital-payment') ? 1 : 0;

            if (Schema::hasColumn('zones', 'offline_payment')) {
                $zone->offline_payment = (int)$this->option('offline-payment') ? 1 : 0;
            }

            if (Schema::hasColumn('zones', 'is_default') && (int)$this->option('set-default') === 1) {
                Zone::withoutGlobalScopes()->where('id', '!=', $zone->id ?? 0)->update(['is_default' => 0]);
                $zone->is_default = 1;
            }

            $zone->save();

            return $zone;
        });

        if (!$zone) {
            return self::FAILURE;
        }

        $this->info("Zone saved successfully. ID: {$zone->id}");
        $this->line("Name: {$zone->name}");
        if (Schema::hasColumn('zones', 'display_name')) {
            $this->line("Display name: {$zone->display_name}");
        }
        $this->line('Polygon points: '.count($polygonPoints));

        return self::SUCCESS;
    }

    private function parseCoordinates(string $coordinatesInput): ?array
    {
        $normalized = preg_replace('/^Polygon\s*/i', '', $coordinatesInput);
        $decoded = json_decode($normalized, true);

        if (!is_array($decoded)) {
            $this->error('Invalid coordinates JSON.');
            return null;
        }

        $ring = $decoded[0] ?? null;
        if (!is_array($ring) || count($ring) < 3) {
            $this->error('Coordinates must include one polygon ring with at least 3 points.');
            return null;
        }

        foreach ($ring as $index => $point) {
            if (!is_array($point) || count($point) !== 2 || !is_numeric($point[0]) || !is_numeric($point[1])) {
                $this->error("Invalid point at index {$index}. Expected [lat,lng].");
                return null;
            }
        }

        return $ring;
    }

    private function buildPolygon(array $points): Polygon
    {
        $linePoints = [];
        foreach ($points as $point) {
            $linePoints[] = new Point((float)$point[0], (float)$point[1]);
        }

        $first = $points[0];
        $last = $points[count($points) - 1];
        if ((float)$first[0] !== (float)$last[0] || (float)$first[1] !== (float)$last[1]) {
            $linePoints[] = new Point((float)$first[0], (float)$first[1]);
        }

        return new Polygon([new LineString($linePoints)]);
    }
}
