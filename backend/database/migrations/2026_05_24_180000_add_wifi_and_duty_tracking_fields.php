<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('branches', function (Blueprint $table) {
            $table->string('wifi_ssid')->nullable()->after('address');
        });

        Schema::table('attendance', function (Blueprint $table) {
            $table->string('required_wifi_ssid')->nullable()->after('device_id');
            $table->string('check_in_wifi_ssid')->nullable()->after('required_wifi_ssid');
            $table->string('check_out_wifi_ssid')->nullable()->after('check_in_wifi_ssid');
            $table->unsignedInteger('paused_minutes')->default(0)->after('is_mock_gps');
            $table->dateTime('pause_started_at')->nullable()->after('paused_minutes');
            $table->string('duty_status')->default('Completed')->after('pause_started_at');
        });
    }

    public function down(): void
    {
        Schema::table('attendance', function (Blueprint $table) {
            $table->dropColumn([
                'required_wifi_ssid',
                'check_in_wifi_ssid',
                'check_out_wifi_ssid',
                'paused_minutes',
                'pause_started_at',
                'duty_status',
            ]);
        });

        Schema::table('branches', function (Blueprint $table) {
            $table->dropColumn('wifi_ssid');
        });
    }
};
