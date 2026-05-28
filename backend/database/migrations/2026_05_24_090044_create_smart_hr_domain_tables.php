<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('branches', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('branch_name');
            $table->double('latitude');
            $table->double('longitude');
            $table->double('allowed_radius')->default(100);
            $table->string('status')->default('Active');
            $table->text('address')->nullable();
            $table->unsignedInteger('staff_count')->nullable();
            $table->timestamps();
        });

        Schema::create('shifts', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('shift_name');
            $table->string('start_time');
            $table->string('end_time');
            $table->decimal('standard_hours', 8, 2)->default(8);
            $table->unsignedInteger('grace_minutes')->default(15);
            $table->string('status')->default('Active');
            $table->timestamps();
        });

        Schema::create('staff', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('staff_code')->unique();
            $table->string('name');
            $table->string('email');
            $table->string('mobile');
            $table->string('id_card_number')->nullable();
            $table->string('job_title');
            $table->string('category');
            $table->string('department');
            $table->string('branch_id');
            $table->string('branch_name');
            $table->string('shift_id');
            $table->string('shift_name');
            $table->dateTime('joining_date');
            $table->decimal('basic_salary', 12, 2)->default(0);
            $table->decimal('overtime_rate', 12, 2)->default(0);
            $table->string('weekly_off_day')->default('Friday');
            $table->string('status')->default('Active');
            $table->string('profile_image_url')->nullable();
            $table->decimal('kpi_score', 8, 2)->nullable();
            $table->string('kpi_rating')->nullable();
            $table->decimal('loan_balance', 12, 2)->nullable();
            $table->decimal('overtime_hours', 12, 2)->nullable();
            $table->string('today_check_in')->nullable();
            $table->string('today_check_out')->nullable();
            $table->string('today_status')->nullable();
            $table->string('preferred_name')->nullable();
            $table->string('first_name')->nullable();
            $table->string('last_name')->nullable();
            $table->dateTime('date_of_birth')->nullable();
            $table->string('nationality')->nullable();
            $table->string('gender')->nullable();
            $table->string('marital_status')->nullable();
            $table->string('personal_email')->nullable();
            $table->string('work_phone')->nullable();
            $table->text('personal_address')->nullable();
            $table->text('about_me')->nullable();
            $table->text('what_i_do')->nullable();
            $table->json('skills')->nullable();
            $table->json('social_media')->nullable();
            $table->json('hobbies')->nullable();
            $table->string('sponsor_name')->nullable();
            $table->string('civil_id')->nullable();
            $table->dateTime('civil_id_expire_date')->nullable();
            $table->string('passport_number')->nullable();
            $table->dateTime('passport_expire_date')->nullable();
            $table->string('passport_status')->nullable();
            $table->string('contract_type')->nullable();
            $table->string('contract_terms')->nullable();
            $table->dateTime('contract_start_date')->nullable();
            $table->dateTime('contract_expire_date')->nullable();
            $table->string('salary_type')->nullable();
            $table->string('name_as_per_bank')->nullable();
            $table->string('bank_name')->nullable();
            $table->string('swift_code')->nullable();
            $table->string('account_number')->nullable();
            $table->string('emergency_contact_name')->nullable();
            $table->string('emergency_contact_relation')->nullable();
            $table->string('emergency_contact_phone')->nullable();
            $table->string('passport_submission_status')->nullable();
            $table->string('passport_collection_status')->nullable();
            $table->timestamps();
        });

        Schema::create('attendance', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->dateTime('date');
            $table->dateTime('check_in_time')->nullable();
            $table->dateTime('check_out_time')->nullable();
            $table->double('check_in_latitude')->nullable();
            $table->double('check_in_longitude')->nullable();
            $table->double('check_out_latitude')->nullable();
            $table->double('check_out_longitude')->nullable();
            $table->decimal('working_hours', 8, 2)->default(0);
            $table->decimal('overtime_hours', 8, 2)->default(0);
            $table->unsignedInteger('late_minutes')->default(0);
            $table->unsignedInteger('early_checkout_minutes')->default(0);
            $table->string('status')->default('Absent');
            $table->string('selfie_check_in_url')->nullable();
            $table->string('selfie_check_out_url')->nullable();
            $table->string('device_id')->nullable();
            $table->boolean('is_location_valid')->default(true);
            $table->boolean('is_mock_gps')->default(false);
            $table->string('approval_status')->default('Auto');
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('salaries', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->string('month');
            $table->decimal('basic_salary', 12, 2)->default(0);
            $table->decimal('overtime_amount', 12, 2)->default(0);
            $table->decimal('allowance', 12, 2)->default(0);
            $table->decimal('deduction', 12, 2)->default(0);
            $table->decimal('loan_deduction', 12, 2)->default(0);
            $table->decimal('absence_deduction', 12, 2)->default(0);
            $table->decimal('penalty', 12, 2)->default(0);
            $table->decimal('net_salary', 12, 2)->default(0);
            $table->string('payment_status')->default('Pending');
            $table->dateTime('paid_date')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('loans', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->decimal('loan_amount', 12, 2)->default(0);
            $table->decimal('paid_amount', 12, 2)->default(0);
            $table->decimal('balance_amount', 12, 2)->default(0);
            $table->decimal('monthly_deduction', 12, 2)->default(0);
            $table->dateTime('loan_date');
            $table->string('status')->default('Active');
            $table->text('purpose')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('leaves', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->string('leave_type');
            $table->dateTime('from_date');
            $table->dateTime('to_date');
            $table->text('reason');
            $table->string('attachment_url')->nullable();
            $table->string('status')->default('Pending');
            $table->string('approved_by')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();
        });

        Schema::create('expenses', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->string('expense_type');
            $table->decimal('amount', 12, 3)->default(0);
            $table->dateTime('expense_date');
            $table->text('description');
            $table->json('receipt_images')->nullable();
            $table->string('status')->default('Pending');
            $table->string('approved_by')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();
        });

        Schema::create('tasks', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('group_id');
            $table->string('title');
            $table->text('description');
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->string('assigned_by');
            $table->string('assigned_by_role');
            $table->boolean('assigned_to_all')->default(false);
            $table->boolean('is_daily_task')->default(false);
            $table->dateTime('due_date');
            $table->string('status')->default('Pending');
            $table->dateTime('completed_at')->nullable();
            $table->dateTime('terminated_at')->nullable();
            $table->timestamps();
        });

        Schema::create('kpis', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->string('month');
            $table->decimal('attendance_rate', 8, 2)->default(0);
            $table->decimal('absence_rate', 8, 2)->default(0);
            $table->unsignedInteger('late_count')->default(0);
            $table->unsignedInteger('early_checkout_count')->default(0);
            $table->decimal('total_working_hours', 12, 2)->default(0);
            $table->decimal('avg_daily_working_hours', 12, 2)->default(0);
            $table->decimal('overtime_hours', 12, 2)->default(0);
            $table->unsignedInteger('missing_checkout_count')->default(0);
            $table->unsignedInteger('valid_location_count')->default(0);
            $table->unsignedInteger('invalid_location_count')->default(0);
            $table->unsignedInteger('fake_gps_count')->default(0);
            $table->unsignedInteger('leave_count')->default(0);
            $table->unsignedInteger('task_assigned_count')->default(0);
            $table->unsignedInteger('task_completed_count')->default(0);
            $table->decimal('task_completion_rate', 8, 2)->default(0);
            $table->decimal('attendance_score', 8, 2)->default(0);
            $table->decimal('punctuality_score', 8, 2)->default(0);
            $table->decimal('overtime_score', 8, 2)->default(0);
            $table->decimal('location_score', 8, 2)->default(0);
            $table->decimal('discipline_score', 8, 2)->default(0);
            $table->decimal('task_score', 8, 2)->default(0);
            $table->decimal('total_kpi_score', 8, 2)->default(0);
            $table->string('rating');
            $table->timestamps();
        });

        Schema::create('attendance_edit_logs', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('attendance_id')->index();
            $table->string('staff_id')->index();
            $table->string('staff_name');
            $table->string('staff_code');
            $table->string('edited_by');
            $table->string('edited_by_role');
            $table->string('field_changed');
            $table->text('old_value');
            $table->text('new_value');
            $table->text('reason');
            $table->string('approval_status')->default('Pending');
            $table->string('approved_by')->nullable();
            $table->dateTime('approved_at')->nullable();
            $table->timestamps();
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('title');
            $table->text('body');
            $table->string('type');
            $table->string('staff_id')->nullable()->index();
            $table->string('staff_name')->nullable();
            $table->boolean('is_read')->default(false);
            $table->string('target_role')->default('all');
            $table->timestamps();
        });

        Schema::create('holidays', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('name');
            $table->dateTime('date');
            $table->string('type');
            $table->decimal('ot_multiplier', 5, 2)->default(1);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('holidays');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('attendance_edit_logs');
        Schema::dropIfExists('kpis');
        Schema::dropIfExists('tasks');
        Schema::dropIfExists('expenses');
        Schema::dropIfExists('leaves');
        Schema::dropIfExists('loans');
        Schema::dropIfExists('salaries');
        Schema::dropIfExists('attendance');
        Schema::dropIfExists('staff');
        Schema::dropIfExists('shifts');
        Schema::dropIfExists('branches');
    }
};
