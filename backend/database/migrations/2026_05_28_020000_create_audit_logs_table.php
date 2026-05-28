<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('action');
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('actor_id')->nullable();
            $table->string('actor_name')->nullable();
            $table->string('actor_role')->nullable();
            $table->string('target_type')->nullable();
            $table->string('target_id')->nullable();
            $table->string('target_name')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['action', 'created_at']);
            $table->index(['target_type', 'target_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
