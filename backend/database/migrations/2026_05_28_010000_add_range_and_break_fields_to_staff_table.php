<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('staff', function (Blueprint $table) {
            $table->decimal('allowed_location_radius_meters', 10, 2)
                ->nullable()
                ->after('shift_name');
            $table->unsignedSmallInteger('daily_break_minutes')
                ->default(60)
                ->after('allowed_location_radius_meters');
        });
    }

    public function down(): void
    {
        Schema::table('staff', function (Blueprint $table) {
            $table->dropColumn([
                'allowed_location_radius_meters',
                'daily_break_minutes',
            ]);
        });
    }
};
