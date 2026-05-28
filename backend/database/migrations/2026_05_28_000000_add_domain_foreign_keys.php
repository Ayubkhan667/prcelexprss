<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->assertReferentialIntegrity('staff', 'branch_id', 'branches');
        $this->assertReferentialIntegrity('staff', 'shift_id', 'shifts');
        $this->assertReferentialIntegrity('attendance', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('salaries', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('loans', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('leaves', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('expenses', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('tasks', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('kpis', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('attendance_edit_logs', 'staff_id', 'staff');
        $this->assertReferentialIntegrity('attendance_edit_logs', 'attendance_id', 'attendance');
        $this->assertReferentialIntegrity('notifications', 'staff_id', 'staff', nullable: true);

        Schema::table('staff', function (Blueprint $table) {
            $table->index('branch_id');
            $table->index('shift_id');
            $table->foreign('branch_id')->references('id')->on('branches')->cascadeOnUpdate()->restrictOnDelete();
            $table->foreign('shift_id')->references('id')->on('shifts')->cascadeOnUpdate()->restrictOnDelete();
        });

        Schema::table('attendance', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('salaries', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('loans', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('leaves', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('expenses', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('kpis', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('attendance_edit_logs', function (Blueprint $table) {
            $table->foreign('attendance_id')->references('id')->on('attendance')->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->cascadeOnDelete();
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->foreign('staff_id')->references('id')->on('staff')->cascadeOnUpdate()->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('attendance_edit_logs', function (Blueprint $table) {
            $table->dropForeign(['attendance_id']);
            $table->dropForeign(['staff_id']);
        });

        Schema::table('kpis', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('expenses', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('leaves', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('loans', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('salaries', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('attendance', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
        });

        Schema::table('staff', function (Blueprint $table) {
            $table->dropForeign(['branch_id']);
            $table->dropForeign(['shift_id']);
            $table->dropIndex(['branch_id']);
            $table->dropIndex(['shift_id']);
        });
    }

    private function assertReferentialIntegrity(
        string $table,
        string $column,
        string $parentTable,
        bool $nullable = false,
    ): void {
        $query = DB::table($table);

        if ($nullable) {
            $query->whereNotNull($column);
        }

        $count = $query
            ->whereNotExists(function ($builder) use ($table, $column, $parentTable) {
                $builder
                    ->select(DB::raw(1))
                    ->from($parentTable)
                    ->whereColumn("{$parentTable}.id", "{$table}.{$column}");
            })
            ->count();

        if ($count > 0) {
            throw new RuntimeException(
                "Cannot add foreign key for {$table}.{$column}: {$count} orphaned rows exist.",
            );
        }
    }
};
