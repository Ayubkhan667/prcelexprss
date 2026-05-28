<?php

namespace Tests\Feature;

use App\Models\Attendance;
use App\Models\Branch;
use App\Models\Shift;
use App\Models\Staff;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BackendDataIntegrityTest extends TestCase
{
    use RefreshDatabase;

    public function test_staff_update_requires_real_branch_shift_ids_and_derives_supervisor_scope(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'status' => 'Active',
        ]);
        $session = $admin->createToken('desktop');
        [$branchA, $shiftA] = $this->seedBranchAndShift('branch-a', 'shift-a', 'Muscat HQ', 'Morning Shift');
        [$branchB, $shiftB] = $this->seedBranchAndShift('branch-b', 'shift-b', 'Sohar Hub', 'Night Shift');
        $staffUser = User::factory()->create([
            'email' => 'team.lead@example.com',
            'role' => 'staff',
            'status' => 'Active',
        ]);
        $staff = $this->createStaffProfile(
            user: $staffUser,
            branch: $branchA,
            shift: $shiftA,
            overrides: [
                'name' => 'Team Lead',
                'email' => 'team.lead@example.com',
                'department' => 'Operations',
            ],
        );

        $this->withToken($session->plainTextToken)
            ->putJson("/api/staff/{$staff->id}", [
                'staff' => [
                    ...$this->staffPayload($staff),
                    'branch_id' => 'missing-branch',
                ],
                'user' => [
                    'name' => 'Team Lead',
                    'email' => 'team.lead@example.com',
                    'mobile' => $staff->mobile,
                    'role' => 'supervisor',
                    'status' => 'Active',
                ],
            ])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['staff.branch_id']);

        $this->withToken($session->plainTextToken)
            ->putJson("/api/staff/{$staff->id}", [
                'staff' => [
                    ...$this->staffPayload($staff),
                    'branch_id' => $branchB->id,
                    'branch_name' => 'Tampered Branch',
                    'shift_id' => $shiftB->id,
                    'shift_name' => 'Tampered Shift',
                    'department' => 'Dispatch',
                ],
                'user' => [
                    'name' => 'Team Lead',
                    'email' => 'team.lead@example.com',
                    'mobile' => $staff->mobile,
                    'role' => 'supervisor',
                    'status' => 'Active',
                    'scope_branch_id' => $branchA->id,
                    'scope_department' => 'Tampered Department',
                ],
            ])
            ->assertOk()
            ->assertJsonPath('branch_name', $branchB->branch_name)
            ->assertJsonPath('shift_name', $shiftB->shift_name);

        $staffUser->refresh();
        $staff->refresh();

        $this->assertSame('supervisor', $staffUser->role);
        $this->assertSame($branchB->id, $staffUser->scope_branch_id);
        $this->assertSame('Dispatch', $staffUser->scope_department);
        $this->assertSame($branchB->branch_name, $staff->branch_name);
        $this->assertSame($shiftB->shift_name, $staff->shift_name);
    }

    public function test_manual_attendance_store_derives_staff_snapshot_and_rejects_invalid_time_updates(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'status' => 'Active',
        ]);
        $session = $admin->createToken('desktop');
        [$branch, $shift] = $this->seedBranchAndShift();
        $staff = $this->createStaffProfile(branch: $branch, shift: $shift);

        $this->withToken($session->plainTextToken)
            ->postJson('/api/attendance', [
                'id' => 'manual-attendance',
                'staff_id' => $staff->id,
                'staff_name' => 'Tampered Name',
                'staff_code' => 'BAD-CODE',
                'date' => now()->startOfDay()->toIso8601String(),
                'check_in_time' => now()->setTime(8, 0)->toIso8601String(),
                'check_out_time' => now()->setTime(17, 0)->toIso8601String(),
                'working_hours' => 9,
                'status' => 'Present',
                'approval_status' => 'Pending',
            ])
            ->assertCreated()
            ->assertJsonPath('staff_name', $staff->name)
            ->assertJsonPath('staff_code', $staff->staff_code)
            ->assertJsonPath('approval_status', 'Pending');

        $this->withToken($session->plainTextToken)
            ->putJson('/api/attendance/manual-attendance', [
                'check_in_time' => now()->setTime(9, 0)->toIso8601String(),
                'check_out_time' => now()->setTime(8, 30)->toIso8601String(),
            ])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['check_out_time']);
    }

    public function test_staff_leave_and_expense_requests_force_pending_and_server_side_staff_metadata(): void
    {
        [$branch, $shift] = $this->seedBranchAndShift();
        $staffUser = User::factory()->create([
            'role' => 'staff',
            'status' => 'Active',
            'email' => 'staff.member@example.com',
        ]);
        $staff = $this->createStaffProfile(
            user: $staffUser,
            branch: $branch,
            shift: $shift,
            overrides: [
                'name' => 'Staff Member',
                'email' => 'staff.member@example.com',
            ],
        );
        $session = $staffUser->createToken('phone');

        $leaveResponse = $this->withToken($session->plainTextToken)
            ->postJson('/api/leaves', [
                'id' => 'client-leave-id',
                'staff_id' => $staff->id,
                'staff_name' => 'Tampered',
                'staff_code' => 'BAD',
                'leave_type' => 'Annual Leave',
                'from_date' => now()->addDay()->startOfDay()->toIso8601String(),
                'to_date' => now()->addDays(2)->startOfDay()->toIso8601String(),
                'reason' => 'Family travel',
                'status' => 'Approved',
                'approved_by' => 'Fake Approver',
            ])
            ->assertCreated()
            ->assertJsonPath('status', 'Pending')
            ->assertJsonPath('staff_name', $staff->name)
            ->assertJsonPath('staff_code', $staff->staff_code);

        $expenseResponse = $this->withToken($session->plainTextToken)
            ->postJson('/api/expenses', [
                'id' => 'client-expense-id',
                'staff_id' => $staff->id,
                'staff_name' => 'Tampered',
                'staff_code' => 'BAD',
                'expense_type' => 'Fuel',
                'amount' => 12.500,
                'expense_date' => now()->toIso8601String(),
                'description' => 'Delivery fuel top-up',
                'status' => 'Approved',
                'approved_by' => 'Fake Approver',
            ])
            ->assertCreated()
            ->assertJsonPath('status', 'Pending')
            ->assertJsonPath('staff_name', $staff->name)
            ->assertJsonPath('staff_code', $staff->staff_code);

        $this->assertNotSame('client-leave-id', $leaveResponse->json('id'));
        $this->assertNotSame('client-expense-id', $expenseResponse->json('id'));
    }

    public function test_admin_hr_writes_generate_server_ids_and_actor_metadata(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'status' => 'Active',
            'name' => 'Operations Admin',
        ]);
        $session = $admin->createToken('desktop');
        [$branch, $shift] = $this->seedBranchAndShift();
        $staff = $this->createStaffProfile(branch: $branch, shift: $shift);

        $loanResponse = $this->withToken($session->plainTextToken)
            ->postJson('/api/loans', [
                'id' => 'client-loan-id',
                'staff_id' => $staff->id,
                'staff_name' => 'Tampered',
                'staff_code' => 'BAD',
                'loan_amount' => 100,
                'paid_amount' => 10,
                'balance_amount' => 5,
                'monthly_deduction' => 20,
                'loan_date' => now()->toIso8601String(),
                'status' => 'Active',
            ])
            ->assertCreated()
            ->assertJsonPath('staff_name', $staff->name)
            ->assertJsonPath('staff_code', $staff->staff_code);

        $this->assertEquals(90.0, $loanResponse->json('balance_amount'));

        $taskResponse = $this->withToken($session->plainTextToken)
            ->postJson('/api/tasks/assign', [
                'title' => 'Warehouse Audit',
                'description' => 'Complete the end-of-day audit checklist.',
                'assigned_by' => 'Tampered Actor',
                'assigned_by_role' => 'fake-role',
                'assign_to_all' => false,
                'is_daily_task' => true,
                'due_date' => now()->addDay()->toIso8601String(),
                'assignees' => [[
                    'id' => $staff->id,
                    'name' => 'Tampered Assignee',
                    'staff_code' => 'BAD',
                ]],
            ])
            ->assertCreated()
            ->assertJsonPath('0.assigned_by', 'Operations Admin')
            ->assertJsonPath('0.assigned_by_role', 'admin')
            ->assertJsonPath('0.staff_name', $staff->name)
            ->assertJsonPath('0.staff_code', $staff->staff_code);

        $holidayResponse = $this->withToken($session->plainTextToken)
            ->postJson('/api/holidays', [
                'id' => 'client-holiday-id',
                'name' => 'National Day',
                'date' => now()->addMonth()->startOfDay()->toIso8601String(),
                'type' => 'Public',
                'ot_multiplier' => 2,
            ])
            ->assertCreated();

        $this->assertNotSame('client-loan-id', $loanResponse->json('id'));
        $this->assertNotSame('client-holiday-id', $holidayResponse->json('id'));
    }

    public function test_edit_logs_validate_attendance_ownership_and_use_authenticated_actor(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'status' => 'Active',
            'name' => 'Attendance Admin',
        ]);
        $session = $admin->createToken('desktop');
        [$branch, $shift] = $this->seedBranchAndShift();
        $staffA = $this->createStaffProfile(
            branch: $branch,
            shift: $shift,
            overrides: [
                'id' => 'staff-a',
                'staff_code' => 'SHR-010',
                'email' => 'staff.a@example.com',
            ],
        );
        $staffB = $this->createStaffProfile(
            branch: $branch,
            shift: $shift,
            overrides: [
                'id' => 'staff-b',
                'staff_code' => 'SHR-011',
                'email' => 'staff.b@example.com',
            ],
        );
        $attendance = Attendance::query()->create([
            'id' => 'att-1',
            'staff_id' => $staffA->id,
            'staff_name' => $staffA->name,
            'staff_code' => $staffA->staff_code,
            'date' => now()->startOfDay(),
            'check_in_time' => now()->setTime(8, 0),
            'check_out_time' => now()->setTime(17, 0),
            'working_hours' => 9,
            'overtime_hours' => 0,
            'late_minutes' => 0,
            'early_checkout_minutes' => 0,
            'status' => 'Present',
            'approval_status' => 'Auto',
            'is_location_valid' => true,
            'is_mock_gps' => false,
            'paused_minutes' => 0,
            'duty_status' => 'Completed',
        ]);

        $this->withToken($session->plainTextToken)
            ->postJson('/api/attendance-edit-logs', [
                'id' => 'client-log-id',
                'attendance_id' => $attendance->id,
                'staff_id' => $staffB->id,
                'field_changed' => 'status',
                'old_value' => 'Absent',
                'new_value' => 'Present',
                'reason' => 'Corrected after review',
                'approval_status' => 'Pending',
            ])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['staff_id']);

        $response = $this->withToken($session->plainTextToken)
            ->postJson('/api/attendance-edit-logs', [
                'id' => 'client-log-id',
                'attendance_id' => $attendance->id,
                'staff_id' => $staffA->id,
                'staff_name' => 'Tampered',
                'staff_code' => 'BAD',
                'edited_by' => 'Fake Actor',
                'edited_by_role' => 'fake-role',
                'field_changed' => 'status',
                'old_value' => 'Absent',
                'new_value' => 'Present',
                'reason' => 'Corrected after review',
                'approval_status' => 'Approved',
            ])
            ->assertCreated()
            ->assertJsonPath('staff_name', $staffA->name)
            ->assertJsonPath('staff_code', $staffA->staff_code)
            ->assertJsonPath('edited_by', 'Attendance Admin')
            ->assertJsonPath('edited_by_role', 'admin')
            ->assertJsonPath('approved_by', 'Attendance Admin')
            ->assertJsonPath('approval_status', 'Approved');

        $this->assertNotSame('client-log-id', $response->json('id'));
    }

    private function seedBranchAndShift(
        string $branchId = 'branch-1',
        string $shiftId = 'shift-1',
        string $branchName = 'Muscat HQ',
        string $shiftName = 'Morning Shift',
    ): array {
        $branch = Branch::query()->create([
            'id' => $branchId,
            'branch_name' => $branchName,
            'latitude' => 23.588,
            'longitude' => 58.3829,
            'allowed_radius' => 120,
            'status' => 'Active',
            'address' => $branchName.', Oman',
            'wifi_ssid' => 'Office-WiFi',
        ]);
        $shift = Shift::query()->create([
            'id' => $shiftId,
            'shift_name' => $shiftName,
            'start_time' => '08:00',
            'end_time' => '17:00',
            'standard_hours' => 8,
            'grace_minutes' => 15,
            'status' => 'Active',
        ]);

        return [$branch, $shift];
    }

    private function createStaffProfile(
        ?User $user = null,
        ?Branch $branch = null,
        ?Shift $shift = null,
        array $overrides = [],
    ): Staff {
        $branch ??= Branch::query()->firstOrFail();
        $shift ??= Shift::query()->firstOrFail();
        $user ??= User::factory()->create([
            'role' => 'staff',
            'status' => 'Active',
        ]);

        return Staff::query()->create([
            'id' => $overrides['id'] ?? (string) str()->uuid(),
            'user_id' => $user->id,
            'staff_code' => $overrides['staff_code'] ?? 'SHR-'.random_int(100, 999),
            'name' => $overrides['name'] ?? 'Staff Member',
            'email' => $overrides['email'] ?? $user->email,
            'mobile' => $overrides['mobile'] ?? '+96890000000',
            'job_title' => $overrides['job_title'] ?? 'Driver',
            'category' => $overrides['category'] ?? 'Operations',
            'department' => $overrides['department'] ?? 'Operations',
            'branch_id' => $overrides['branch_id'] ?? $branch->id,
            'branch_name' => $overrides['branch_name'] ?? $branch->branch_name,
            'shift_id' => $overrides['shift_id'] ?? $shift->id,
            'shift_name' => $overrides['shift_name'] ?? $shift->shift_name,
            'joining_date' => $overrides['joining_date'] ?? now(),
            'basic_salary' => $overrides['basic_salary'] ?? 300,
            'overtime_rate' => $overrides['overtime_rate'] ?? 2,
            'weekly_off_day' => $overrides['weekly_off_day'] ?? 'Friday',
            'status' => $overrides['status'] ?? 'Active',
        ]);
    }

    private function staffPayload(Staff $staff): array
    {
        return [
            'id' => $staff->id,
            'user_id' => (string) $staff->user_id,
            'staff_code' => $staff->staff_code,
            'name' => $staff->name,
            'email' => $staff->email,
            'mobile' => $staff->mobile,
            'job_title' => $staff->job_title,
            'category' => $staff->category,
            'department' => $staff->department,
            'branch_id' => $staff->branch_id,
            'branch_name' => $staff->branch_name,
            'shift_id' => $staff->shift_id,
            'shift_name' => $staff->shift_name,
            'joining_date' => $staff->joining_date?->toIso8601String(),
            'basic_salary' => $staff->basic_salary,
            'overtime_rate' => $staff->overtime_rate,
            'weekly_off_day' => $staff->weekly_off_day,
            'status' => $staff->status,
        ];
    }
}
