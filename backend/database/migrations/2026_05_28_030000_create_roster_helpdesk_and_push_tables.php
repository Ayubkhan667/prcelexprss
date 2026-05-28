<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shift_rosters', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->date('roster_date')->index();
            $table->string('shift_id');
            $table->string('shift_name');
            $table->string('start_time');
            $table->string('end_time');
            $table->string('status')->default('Scheduled');
            $table->text('notes')->nullable();
            $table->string('assigned_by');
            $table->timestamps();

            $table->unique(['staff_id', 'roster_date'], 'shift_rosters_staff_date_unique');
        });

        Schema::create('shift_swap_requests', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('requester_staff_id')->index();
            $table->string('requester_name');
            $table->string('requester_code');
            $table->string('target_staff_id')->index();
            $table->string('target_name');
            $table->string('target_code');
            $table->date('roster_date')->index();
            $table->string('requester_shift_id');
            $table->string('requester_shift_name');
            $table->string('target_shift_id')->nullable();
            $table->string('target_shift_name')->nullable();
            $table->text('reason');
            $table->string('status')->default('Pending');
            $table->string('approved_by')->nullable();
            $table->dateTime('approved_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();
        });

        Schema::create('helpdesk_tickets', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->string('subject');
            $table->string('category');
            $table->text('message');
            $table->string('status')->default('Open');
            $table->text('response')->nullable();
            $table->string('responded_by')->nullable();
            $table->dateTime('responded_at')->nullable();
            $table->timestamps();
        });

        Schema::create('push_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('token')->unique();
            $table->string('platform')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('push_tokens');
        Schema::dropIfExists('helpdesk_tickets');
        Schema::dropIfExists('shift_swap_requests');
        Schema::dropIfExists('shift_rosters');
    }
};
