<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->string('device_name')->nullable()->after('name');
            $table->string('device_id')->nullable()->after('device_name')->index();
            $table->string('ip_address', 45)->nullable()->after('device_id');
            $table->string('last_used_ip_address', 45)->nullable()->after('ip_address');
            $table->text('user_agent')->nullable()->after('last_used_ip_address');
        });
    }

    public function down(): void
    {
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->dropColumn([
                'device_name',
                'device_id',
                'ip_address',
                'last_used_ip_address',
                'user_agent',
            ]);
        });
    }
};
