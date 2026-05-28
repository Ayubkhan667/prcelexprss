<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\ResolvesCurrentStaff;
use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Staff;
use App\Support\AuditLogger;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class HrModuleController extends Controller
{
    use ResolvesCurrentStaff;

    public function salaries(Request $request)
    {
        $query = DB::table('salaries')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access salary records within your assigned branch.',
        )) {
            return $response;
        }

        if ($request->filled('month')) {
            $query->where('month', $request->string('month'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->salaryPayload($row))->all());
    }

    public function markSalaryPaid(string $id, Request $request)
    {
        $request->validate([
            'paid_date' => ['nullable', 'date'],
            'notes' => ['nullable', 'string'],
        ]);

        $paidDate = $request->input('paid_date') ?: now()->toIso8601String();
        DB::table('salaries')->where('id', $id)->update([
            'payment_status' => 'Paid',
            'paid_date' => $paidDate,
            'notes' => $request->input('notes'),
            'updated_at' => now(),
        ]);

        $salary = DB::table('salaries')->where('id', $id)->firstOrFail();
        $this->createNotification([
            'id' => 'notif_salary_'.$salary->id,
            'title' => 'Salary Paid',
            'body' => 'Your '.$salary->month.' salary of OMR '.number_format((float) $salary->net_salary, 0).' has been marked as paid.',
            'type' => 'salary',
            'staff_id' => $salary->staff_id,
            'staff_name' => $salary->staff_name,
            'target_role' => 'staff',
            'is_read' => false,
        ]);

        return response()->json($this->salaryPayload(DB::table('salaries')->where('id', $id)->firstOrFail()));
    }

    public function generateSalaries(Request $request)
    {
        $request->validate([
            'for_month' => ['nullable', 'date'],
        ]);

        $date = $request->filled('for_month')
            ? Carbon::parse($request->string('for_month'))
            : now();
        $monthLabel = $date->format('F Y');
        $staffRows = DB::table('staff')->where('status', 'Active')->get();
        $generated = 0;

        foreach ($staffRows as $staff) {
            $exists = DB::table('salaries')
                ->where('staff_id', $staff->id)
                ->where('month', $monthLabel)
                ->exists();

            if ($exists) {
                continue;
            }

            $loanDeduction = (float) DB::table('loans')
                ->where('staff_id', $staff->id)
                ->where('status', 'Active')
                ->sum('monthly_deduction');
            $overtimeAmount = round(((float) ($staff->overtime_hours ?? 0)) * ((float) ($staff->overtime_rate ?? 0)), 2);
            $allowance = round(((float) $staff->basic_salary) * 0.35, 2);
            $netSalary = round(((float) $staff->basic_salary) + $overtimeAmount + $allowance - $loanDeduction, 2);

            DB::table('salaries')->insert([
                'id' => 'sal_'.$staff->id.'_'.$date->format('Ym'),
                'staff_id' => $staff->id,
                'staff_name' => $staff->name,
                'staff_code' => $staff->staff_code,
                'month' => $monthLabel,
                'basic_salary' => $staff->basic_salary,
                'overtime_amount' => $overtimeAmount,
                'allowance' => $allowance,
                'deduction' => 0,
                'loan_deduction' => $loanDeduction,
                'absence_deduction' => 0,
                'penalty' => 0,
                'net_salary' => $netSalary,
                'payment_status' => 'Pending',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $generated++;
        }

        return response()->json(['generated' => $generated]);
    }

    public function loans(Request $request)
    {
        $query = DB::table('loans')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access loan records within your assigned branch.',
        )) {
            return $response;
        }

        return response()->json($query->get()->map(fn ($row) => $this->loanPayload($row))->all());
    }

    public function storeLoan(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id' => ['nullable', 'string'],
            'staff_id' => ['required', 'string', 'exists:staff,id'],
            'staff_name' => ['nullable', 'string'],
            'staff_code' => ['nullable', 'string'],
            'loan_amount' => ['required', 'numeric', 'gt:0'],
            'paid_amount' => ['nullable', 'numeric', 'min:0'],
            'balance_amount' => ['nullable', 'numeric', 'min:0'],
            'monthly_deduction' => ['required', 'numeric', 'gt:0'],
            'loan_date' => ['required', 'date'],
            'status' => ['nullable', 'string', 'max:255'],
            'purpose' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
            'created_at' => ['nullable', 'date'],
        ]);
        $validator->after(function ($validator) use ($request) {
            $loanAmount = (float) $request->input('loan_amount', 0);
            $paidAmount = (float) $request->input('paid_amount', 0);

            if ($paidAmount > $loanAmount) {
                $validator->errors()->add('paid_amount', 'Paid amount cannot exceed the total loan amount.');
            }
        });
        $payload = $validator->validate();
        $staff = $this->staffRecord($payload['staff_id']);
        $paidAmount = (float) ($payload['paid_amount'] ?? 0);
        $balanceAmount = max(0, round((float) $payload['loan_amount'] - $paidAmount, 2));

        $id = $this->generateId('loan');
        DB::table('loans')->insert([
            'id' => $id,
            ...$this->staffSnapshot($staff),
            'loan_amount' => $payload['loan_amount'],
            'paid_amount' => $paidAmount,
            'balance_amount' => $balanceAmount,
            'monthly_deduction' => $payload['monthly_deduction'],
            'loan_date' => $payload['loan_date'],
            'status' => $balanceAmount <= 0 ? 'Cleared' : ($payload['status'] ?? 'Active'),
            'purpose' => $payload['purpose'] ?? null,
            'notes' => $payload['notes'] ?? null,
            'created_at' => $payload['created_at'] ?? now(),
            'updated_at' => now(),
        ]);

        $loan = DB::table('loans')->where('id', $id)->firstOrFail();

        return response()->json($this->loanPayload($loan), 201);
    }

    public function leaves(Request $request)
    {
        $query = DB::table('leaves')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access leave records within your assigned branch.',
        )) {
            return $response;
        }
        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->leavePayload($row))->all());
    }

    public function storeLeave(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id' => ['nullable', 'string'],
            'staff_id' => ['required', 'string', 'exists:staff,id'],
            'staff_name' => ['nullable', 'string'],
            'staff_code' => ['nullable', 'string'],
            'leave_type' => ['required', 'string', 'max:255'],
            'from_date' => ['required', 'date'],
            'to_date' => ['required', 'date'],
            'reason' => ['required', 'string'],
            'attachment_url' => ['nullable', 'string', 'max:2048'],
            'attachment' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:8192'],
            'status' => ['nullable', Rule::in(['Pending', 'Approved', 'Rejected'])],
            'approved_by' => ['nullable', 'string'],
            'rejection_reason' => ['nullable', 'string'],
            'created_at' => ['nullable', 'date'],
        ]);
        $validator->after(function ($validator) use ($request) {
            if ($validator->errors()->has('from_date') || $validator->errors()->has('to_date')) {
                return;
            }

            $fromDate = Carbon::parse($request->input('from_date'));
            $toDate = Carbon::parse($request->input('to_date'));

            if ($toDate->lessThan($fromDate)) {
                $validator->errors()->add('to_date', 'Leave end date cannot be before the start date.');
            }
        });
        $payload = $validator->validate();

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $payload['staff_id'],
            'You can only create leave requests within your assigned branch.',
        )) {
            return $response;
        }

        $staff = $this->isStaffRequest($request)
            ? $this->currentStaffProfile($request)
            : $this->staffRecord($payload['staff_id']);
        $status = $this->isStaffRequest($request) ? 'Pending' : ($payload['status'] ?? 'Pending');
        $approvedBy = $status === 'Pending' ? null : $this->actorName($request);
        $rejectionReason = $status === 'Rejected' ? ($payload['rejection_reason'] ?? null) : null;

        $payload['attachment_url'] = $this->storePublicFile(
            $request,
            field: 'attachment',
            directory: 'leave-attachments',
            fallback: $payload['attachment_url'] ?? null,
        );

        $id = $this->generateId('leave');
        DB::table('leaves')->insert([
            'id' => $id,
            ...$this->staffSnapshot($staff),
            'leave_type' => $payload['leave_type'],
            'from_date' => $payload['from_date'],
            'to_date' => $payload['to_date'],
            'reason' => $payload['reason'],
            'attachment_url' => $payload['attachment_url'],
            'status' => $status,
            'approved_by' => $approvedBy,
            'rejection_reason' => $rejectionReason,
            'created_at' => $payload['created_at'] ?? now(),
            'updated_at' => now(),
        ]);

        return response()->json(
            $this->leavePayload(DB::table('leaves')->where('id', $id)->firstOrFail()),
            201,
        );
    }

    public function updateLeaveStatus(string $id, Request $request)
    {
        $request->validate([
            'status' => ['required', 'in:Pending,Approved,Rejected'],
            'rejection_reason' => ['nullable', 'string'],
        ]);
        $status = (string) $request->input('status', 'Pending');

        $leave = DB::table('leaves')->where('id', $id)->firstOrFail();
        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $leave->staff_id,
            'You can only approve leave requests within your assigned branch.',
        )) {
            return $response;
        }

        DB::table('leaves')->where('id', $id)->update([
            'status' => $status,
            'approved_by' => $status === 'Pending'
                ? null
                : $this->actorName($request),
            'rejection_reason' => $status === 'Rejected'
                ? $request->input('rejection_reason')
                : null,
            'updated_at' => now(),
        ]);

        $leave = DB::table('leaves')->where('id', $id)->firstOrFail();
        $status = (string) $leave->status;
        $this->createNotification([
            'id' => 'notif_leave_'.$leave->id.'_'.$status,
            'title' => $status === 'Approved' ? 'Leave Approved' : 'Leave Rejected',
            'body' => $status === 'Approved'
                ? 'Your '.$leave->leave_type.' request has been approved.'
                : 'Your '.$leave->leave_type.' request was rejected'.($leave->rejection_reason ? ': '.$leave->rejection_reason : '.'),
            'type' => 'leave',
            'staff_id' => $leave->staff_id,
            'staff_name' => $leave->staff_name,
            'target_role' => 'staff',
            'is_read' => false,
        ]);

        return response()->json($this->leavePayload($leave));
    }

    public function kpis(Request $request)
    {
        $query = DB::table('kpis')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access KPI records within your assigned branch.',
        )) {
            return $response;
        }
        if ($request->filled('month')) {
            $query->where('month', $request->string('month'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->kpiPayload($row))->all());
    }

    public function tasks(Request $request)
    {
        $query = DB::table('tasks')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access task records within your assigned branch.',
        )) {
            return $response;
        }
        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->taskPayload($row))->all());
    }

    public function assignTask(Request $request)
    {
        $payload = $request->validate([
            'title' => ['required', 'string'],
            'description' => ['required', 'string'],
            'assign_to_all' => ['required', 'boolean'],
            'is_daily_task' => ['required', 'boolean'],
            'due_date' => ['required', 'date'],
            'assignees' => ['required', 'array', 'min:1'],
            'assignees.*.id' => ['required', 'string'],
            'assignees.*.name' => ['nullable', 'string'],
            'assignees.*.staff_code' => ['nullable', 'string'],
        ]);

        $groupId = $this->generateId('task_group');
        $assignees = $this->taskAssignees($payload['assignees']);
        $assignedBy = $this->actorName($request);
        $assignedByRole = $this->actorRole($request);
        $created = [];

        foreach ($assignees as $assignee) {
            $task = [
                'id' => $this->generateId('task'),
                'group_id' => $groupId,
                'title' => $payload['title'],
                'description' => $payload['description'],
                'staff_id' => $assignee->id,
                'staff_name' => $assignee->name,
                'staff_code' => $assignee->staff_code,
                'assigned_by' => $assignedBy,
                'assigned_by_role' => $assignedByRole,
                'assigned_to_all' => $payload['assign_to_all'],
                'is_daily_task' => $payload['is_daily_task'],
                'due_date' => $payload['due_date'],
                'status' => 'Pending',
                'created_at' => now(),
                'completed_at' => null,
                'terminated_at' => null,
                'updated_at' => now(),
            ];
            DB::table('tasks')->insert($task);
            $created[] = $this->taskPayload((object) $task);

            $this->createNotification([
                'id' => 'notif_task_'.$task['id'],
                'title' => 'New Task Assigned',
                'body' => $payload['title'].' has been assigned.',
                'type' => 'task',
                'staff_id' => $assignee->id,
                'staff_name' => $assignee->name,
                'target_role' => 'staff',
                'is_read' => false,
            ]);
        }

        return response()->json($created, 201);
    }

    public function completeTask(string $id, Request $request)
    {
        $task = DB::table('tasks')->where('id', $id)->firstOrFail();
        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $task->staff_id,
            'You can only update task records within your assigned branch.',
        )) {
            return $response;
        }

        DB::table('tasks')->where('id', $id)->update([
            'status' => 'Completed',
            'completed_at' => now(),
            'updated_at' => now(),
        ]);

        $task = DB::table('tasks')->where('id', $id)->firstOrFail();
        $this->createNotification([
            'id' => 'notif_complete_'.$task->id,
            'title' => 'Task Completed',
            'body' => $task->staff_name.' completed "'.$task->title.'".',
            'type' => 'task',
            'staff_id' => $task->staff_id,
            'staff_name' => $task->staff_name,
            'target_role' => 'admin',
            'is_read' => false,
        ]);

        return response()->json($this->taskPayload($task));
    }

    public function terminateTask(string $id, Request $request)
    {
        DB::table('tasks')->where('id', $id)->update([
            'status' => 'Terminated',
            'terminated_at' => now(),
            'updated_at' => now(),
        ]);

        $task = DB::table('tasks')->where('id', $id)->firstOrFail();
        $this->createNotification([
            'id' => 'notif_terminate_'.$task->id,
            'title' => 'Task Closed',
            'body' => $task->title.' was closed by admin.',
            'type' => 'task',
            'staff_id' => $task->staff_id,
            'staff_name' => $task->staff_name,
            'target_role' => 'staff',
            'is_read' => false,
        ]);

        AuditLogger::record($request, [
            'action' => 'task_terminate',
            'title' => 'Task terminated',
            'description' => $task->title.' was closed for '.$task->staff_name.'.',
            'target_type' => 'task',
            'target_id' => $task->id,
            'target_name' => $task->title,
            'metadata' => [
                'staff_id' => $task->staff_id,
                'staff_code' => $task->staff_code,
                'is_daily_task' => (bool) $task->is_daily_task,
            ],
        ]);

        return response()->json($this->taskPayload($task));
    }

    public function auditLogs(Request $request)
    {
        $query = DB::table('audit_logs')->orderByDesc('created_at');

        if ($request->filled('action')) {
            $query->where('action', $request->string('action'));
        }

        if ($request->filled('target_type')) {
            $query->where('target_type', $request->string('target_type'));
        }

        return response()->json(
            $query->limit(500)->get()->map(fn ($row) => AuditLogger::payload($row))->all()
        );
    }

    public function notifications(Request $request)
    {
        if ($response = $this->ensureScopedContext($request)) {
            return $response;
        }

        $query = DB::table('notifications')->orderByDesc('created_at');

        if ($response = $this->applyNotificationScope($request, $query)) {
            return $response;
        }

        if ($request->filled('type')) {
            $query->where('type', $request->string('type'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->notificationPayload($row))->all());
    }

    public function markNotificationRead(string $id, Request $request)
    {
        $notification = DB::table('notifications')->where('id', $id)->firstOrFail();
        if (
            ($this->isStaffRequest($request) && ! $this->isNotificationVisibleToCurrentStaff($request, $notification))
            || ($this->isSupervisorRequest($request) && ! $this->isNotificationVisibleToCurrentSupervisor($request, $notification))
        ) {
            return response()->json([
                'message' => 'You can only update notifications within your scope.',
            ], 403);
        }

        DB::table('notifications')->where('id', $id)->update([
            'is_read' => true,
            'updated_at' => now(),
        ]);

        AuditLogger::record($request, [
            'action' => 'notification_read',
            'title' => 'Notification read',
            'description' => $notification->title,
            'target_type' => 'notification',
            'target_id' => $notification->id,
            'target_name' => $notification->type,
            'metadata' => [
                'staff_id' => $notification->staff_id,
                'target_role' => $notification->target_role,
            ],
        ]);

        return response()->json(['success' => true]);
    }

    public function markNotificationsRead(Request $request)
    {
        $query = DB::table('notifications');

        if ($response = $this->applyNotificationScope($request, $query)) {
            return $response;
        }

        if ($request->filled('type')) {
            $query->where('type', $request->string('type'));
        }
        $updated = $query->update([
            'is_read' => true,
            'updated_at' => now(),
        ]);

        AuditLogger::record($request, [
            'action' => 'notification_read_all',
            'title' => 'Notifications marked read',
            'description' => $updated.' notifications were marked as read.',
            'target_type' => 'notification',
            'target_name' => $request->input('type', 'all'),
            'metadata' => [
                'updated_count' => $updated,
                'target_role' => $request->input('target_role'),
                'staff_id' => $request->input('staff_id'),
                'type' => $request->input('type'),
            ],
        ]);

        return response()->json(['success' => true]);
    }

    public function expenses(Request $request)
    {
        $query = DB::table('expenses')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access expense records within your assigned branch.',
        )) {
            return $response;
        }
        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->expensePayload($row))->all());
    }

    public function storeExpense(Request $request)
    {
        $payload = $request->validate([
            'id' => ['nullable', 'string'],
            'staff_id' => ['required', 'string', 'exists:staff,id'],
            'staff_name' => ['nullable', 'string'],
            'staff_code' => ['nullable', 'string'],
            'expense_type' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'gt:0'],
            'expense_date' => ['required', 'date'],
            'description' => ['required', 'string'],
            'receipt_images' => ['nullable', 'array'],
            'receipt_images.*' => ['string'],
            'receipt_files' => ['nullable', 'array'],
            'receipt_files.*' => ['file', 'mimes:jpg,jpeg,png', 'max:4096'],
            'status' => ['nullable', Rule::in(['Pending', 'Approved', 'Rejected'])],
            'approved_by' => ['nullable', 'string'],
            'rejection_reason' => ['nullable', 'string'],
            'created_at' => ['nullable', 'date'],
        ]);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $payload['staff_id'],
            'You can only create expense records within your assigned branch.',
        )) {
            return $response;
        }

        $staff = $this->isStaffRequest($request)
            ? $this->currentStaffProfile($request)
            : $this->staffRecord($payload['staff_id']);
        $status = $this->isStaffRequest($request) ? 'Pending' : ($payload['status'] ?? 'Pending');
        $approvedBy = $status === 'Pending' ? null : $this->actorName($request);
        $rejectionReason = $status === 'Rejected' ? ($payload['rejection_reason'] ?? null) : null;

        $payload['receipt_images'] = $this->storePublicFiles(
            $request,
            field: 'receipt_files',
            directory: 'expense-receipts',
            fallback: $payload['receipt_images'] ?? [],
        );

        $id = $this->generateId('expense');
        DB::table('expenses')->insert([
            'id' => $id,
            ...$this->staffSnapshot($staff),
            'expense_type' => $payload['expense_type'],
            'amount' => $payload['amount'],
            'expense_date' => $payload['expense_date'],
            'description' => $payload['description'],
            'receipt_images' => json_encode($payload['receipt_images'] ?? [], JSON_THROW_ON_ERROR),
            'status' => $status,
            'approved_by' => $approvedBy,
            'rejection_reason' => $rejectionReason,
            'created_at' => $payload['created_at'] ?? now(),
            'updated_at' => now(),
        ]);

        return response()->json(
            $this->expensePayload(DB::table('expenses')->where('id', $id)->firstOrFail()),
            201,
        );
    }

    public function updateExpenseStatus(string $id, Request $request)
    {
        $request->validate([
            'status' => ['required', 'in:Pending,Approved,Rejected'],
            'rejection_reason' => ['nullable', 'string'],
        ]);
        $status = (string) $request->input('status', 'Pending');

        $expense = DB::table('expenses')->where('id', $id)->firstOrFail();
        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $expense->staff_id,
            'You can only approve expense records within your assigned branch.',
        )) {
            return $response;
        }

        DB::table('expenses')->where('id', $id)->update([
            'status' => $status,
            'approved_by' => $status === 'Pending'
                ? null
                : $this->actorName($request),
            'rejection_reason' => $status === 'Rejected'
                ? $request->input('rejection_reason')
                : null,
            'updated_at' => now(),
        ]);

        return response()->json($this->expensePayload(DB::table('expenses')->where('id', $id)->firstOrFail()));
    }

    public function shiftRosters(Request $request)
    {
        $query = DB::table('shift_rosters')
            ->orderByDesc('roster_date')
            ->orderBy('start_time');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access shift rosters within your assigned branch.',
        )) {
            return $response;
        }

        if ($request->filled('from_date')) {
            $query->whereDate('roster_date', '>=', Carbon::parse($request->string('from_date'))->toDateString());
        }
        if ($request->filled('to_date')) {
            $query->whereDate('roster_date', '<=', Carbon::parse($request->string('to_date'))->toDateString());
        }

        return response()->json($query->get()->map(fn ($row) => $this->shiftRosterPayload($row))->all());
    }

    public function storeShiftRoster(Request $request)
    {
        $payload = $request->validate([
            'id' => ['nullable', 'string'],
            'staff_id' => ['required', 'string', 'exists:staff,id'],
            'roster_date' => ['required', 'date'],
            'shift_id' => ['required', 'string', 'exists:shifts,id'],
            'status' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
            'created_at' => ['nullable', 'date'],
        ]);

        $staff = $this->staffRecord($payload['staff_id']);
        $shift = DB::table('shifts')->where('id', $payload['shift_id'])->firstOrFail();
        $rosterDate = Carbon::parse($payload['roster_date'])->toDateString();
        $existing = DB::table('shift_rosters')
            ->where('staff_id', $staff->id)
            ->whereDate('roster_date', $rosterDate)
            ->first();
        $id = $existing?->id ?? $this->generateId('roster');

        DB::table('shift_rosters')->updateOrInsert(
            [
                'staff_id' => $staff->id,
                'roster_date' => $rosterDate,
            ],
            [
                'id' => $id,
                ...$this->staffSnapshot($staff),
                'roster_date' => $rosterDate,
                'shift_id' => $shift->id,
                'shift_name' => $shift->shift_name,
                'start_time' => $shift->start_time,
                'end_time' => $shift->end_time,
                'status' => $payload['status'] ?? 'Scheduled',
                'notes' => $payload['notes'] ?? null,
                'assigned_by' => $this->actorName($request),
                'created_at' => $existing?->created_at ?? ($payload['created_at'] ?? now()),
                'updated_at' => now(),
            ],
        );

        $row = DB::table('shift_rosters')
            ->where('staff_id', $staff->id)
            ->whereDate('roster_date', $rosterDate)
            ->firstOrFail();

        return response()->json($this->shiftRosterPayload($row), 201);
    }

    public function updateShiftRoster(string $id, Request $request)
    {
        $payload = $request->validate([
            'shift_id' => ['required', 'string', 'exists:shifts,id'],
            'status' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
        ]);

        $row = DB::table('shift_rosters')->where('id', $id)->firstOrFail();
        $shift = DB::table('shifts')->where('id', $payload['shift_id'])->firstOrFail();

        DB::table('shift_rosters')->where('id', $id)->update([
            'shift_id' => $shift->id,
            'shift_name' => $shift->shift_name,
            'start_time' => $shift->start_time,
            'end_time' => $shift->end_time,
            'status' => $payload['status'] ?? $row->status,
            'notes' => $payload['notes'] ?? $row->notes,
            'updated_at' => now(),
        ]);

        return response()->json(
            $this->shiftRosterPayload(DB::table('shift_rosters')->where('id', $id)->firstOrFail())
        );
    }

    public function shiftSwapRequests(Request $request)
    {
        $query = DB::table('shift_swap_requests')->orderByDesc('created_at');

        if ($response = $this->ensureScopedContext($request)) {
            return $response;
        }

        if ($this->isStaffRequest($request)) {
            $currentStaffId = $this->currentStaffId($request);
            $query->where(function ($builder) use ($currentStaffId) {
                $builder->where('requester_staff_id', $currentStaffId)
                    ->orWhere('target_staff_id', $currentStaffId);
            });
        } elseif ($this->isSupervisorRequest($request)) {
            $query->whereIn('requester_staff_id', $this->scopedStaffIdsQuery($request));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->shiftSwapRequestPayload($row))->all());
    }

    public function storeShiftSwapRequest(Request $request)
    {
        $payload = $request->validate([
            'requester_staff_id' => ['required', 'string', 'exists:staff,id'],
            'target_staff_id' => ['required', 'string', 'exists:staff,id', 'different:requester_staff_id'],
            'roster_date' => ['required', 'date'],
            'reason' => ['required', 'string'],
            'created_at' => ['nullable', 'date'],
        ]);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $payload['requester_staff_id'],
            'You can only create shift swaps for your assigned team.',
        )) {
            return $response;
        }

        $requester = $this->staffRecord($payload['requester_staff_id']);
        $target = $this->staffRecord($payload['target_staff_id']);
        $rosterDate = Carbon::parse($payload['roster_date'])->toDateString();

        $requesterRoster = DB::table('shift_rosters')
            ->where('staff_id', $requester->id)
            ->whereDate('roster_date', $rosterDate)
            ->first();
        $targetRoster = DB::table('shift_rosters')
            ->where('staff_id', $target->id)
            ->whereDate('roster_date', $rosterDate)
            ->first();

        if (! $requesterRoster || ! $targetRoster) {
            throw ValidationException::withMessages([
                'roster_date' => ['Both employees must have an assigned roster for the selected date.'],
            ]);
        }

        $id = $this->generateId('swap');
        DB::table('shift_swap_requests')->insert([
            'id' => $id,
            'requester_staff_id' => $requester->id,
            'requester_name' => $requester->name,
            'requester_code' => $requester->staff_code,
            'target_staff_id' => $target->id,
            'target_name' => $target->name,
            'target_code' => $target->staff_code,
            'roster_date' => $rosterDate,
            'requester_shift_id' => $requesterRoster->shift_id,
            'requester_shift_name' => $requesterRoster->shift_name,
            'target_shift_id' => $targetRoster->shift_id,
            'target_shift_name' => $targetRoster->shift_name,
            'reason' => $payload['reason'],
            'status' => 'Pending',
            'created_at' => $payload['created_at'] ?? now(),
            'updated_at' => now(),
        ]);

        $this->createNotification([
            'id' => 'notif_swap_'.$id,
            'title' => 'Shift swap requested',
            'body' => $requester->name.' requested a shift swap with '.$target->name.'.',
            'type' => 'shift_swap',
            'staff_id' => $requester->id,
            'staff_name' => $requester->name,
            'target_role' => 'admin',
            'is_read' => false,
        ]);

        return response()->json(
            $this->shiftSwapRequestPayload(DB::table('shift_swap_requests')->where('id', $id)->firstOrFail()),
            201,
        );
    }

    public function updateShiftSwapRequestStatus(string $id, Request $request)
    {
        $payload = $request->validate([
            'status' => ['required', 'in:Pending,Approved,Rejected'],
            'rejection_reason' => ['nullable', 'string'],
        ]);

        $swap = DB::table('shift_swap_requests')->where('id', $id)->firstOrFail();
        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $swap->requester_staff_id,
            'You can only manage shift swaps within your assigned branch.',
        )) {
            return $response;
        }

        if ($payload['status'] === 'Approved') {
            $requesterRoster = DB::table('shift_rosters')
                ->where('staff_id', $swap->requester_staff_id)
                ->whereDate('roster_date', $swap->roster_date)
                ->firstOrFail();
            $targetRoster = DB::table('shift_rosters')
                ->where('staff_id', $swap->target_staff_id)
                ->whereDate('roster_date', $swap->roster_date)
                ->firstOrFail();

            DB::table('shift_rosters')->where('id', $requesterRoster->id)->update([
                'shift_id' => $targetRoster->shift_id,
                'shift_name' => $targetRoster->shift_name,
                'start_time' => $targetRoster->start_time,
                'end_time' => $targetRoster->end_time,
                'updated_at' => now(),
            ]);

            DB::table('shift_rosters')->where('id', $targetRoster->id)->update([
                'shift_id' => $requesterRoster->shift_id,
                'shift_name' => $requesterRoster->shift_name,
                'start_time' => $requesterRoster->start_time,
                'end_time' => $requesterRoster->end_time,
                'updated_at' => now(),
            ]);
        }

        DB::table('shift_swap_requests')->where('id', $id)->update([
            'status' => $payload['status'],
            'approved_by' => $payload['status'] === 'Pending' ? null : $this->actorName($request),
            'approved_at' => $payload['status'] === 'Pending' ? null : now(),
            'rejection_reason' => $payload['status'] === 'Rejected'
                ? ($payload['rejection_reason'] ?? null)
                : null,
            'updated_at' => now(),
        ]);

        $updated = DB::table('shift_swap_requests')->where('id', $id)->firstOrFail();
        $this->createNotification([
            'id' => 'notif_swap_status_'.$updated->id.'_'.$updated->status,
            'title' => 'Shift swap '.$updated->status,
            'body' => 'Your shift swap request is now '.$updated->status.'.',
            'type' => 'shift_swap',
            'staff_id' => $updated->requester_staff_id,
            'staff_name' => $updated->requester_name,
            'target_role' => 'staff',
            'is_read' => false,
        ]);

        return response()->json($this->shiftSwapRequestPayload($updated));
    }

    public function helpdeskTickets(Request $request)
    {
        $query = DB::table('helpdesk_tickets')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access helpdesk tickets within your assigned branch.',
        )) {
            return $response;
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->helpdeskTicketPayload($row))->all());
    }

    public function storeHelpdeskTicket(Request $request)
    {
        $payload = $request->validate([
            'staff_id' => ['required', 'string', 'exists:staff,id'],
            'subject' => ['required', 'string', 'max:255'],
            'category' => ['required', 'string', 'max:255'],
            'message' => ['required', 'string'],
            'created_at' => ['nullable', 'date'],
        ]);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $payload['staff_id'],
            'You can only create helpdesk tickets for your assigned team.',
        )) {
            return $response;
        }

        $staff = $this->isStaffRequest($request)
            ? $this->currentStaffProfile($request)
            : $this->staffRecord($payload['staff_id']);
        $id = $this->generateId('helpdesk');

        DB::table('helpdesk_tickets')->insert([
            'id' => $id,
            ...$this->staffSnapshot($staff),
            'subject' => $payload['subject'],
            'category' => $payload['category'],
            'message' => $payload['message'],
            'status' => 'Open',
            'created_at' => $payload['created_at'] ?? now(),
            'updated_at' => now(),
        ]);

        $this->createNotification([
            'id' => 'notif_helpdesk_'.$id,
            'title' => 'New helpdesk ticket',
            'body' => $staff->name.' submitted a helpdesk ticket: '.$payload['subject'],
            'type' => 'helpdesk',
            'staff_id' => $staff->id,
            'staff_name' => $staff->name,
            'target_role' => 'admin',
            'is_read' => false,
        ]);

        return response()->json(
            $this->helpdeskTicketPayload(DB::table('helpdesk_tickets')->where('id', $id)->firstOrFail()),
            201,
        );
    }

    public function updateHelpdeskTicketStatus(string $id, Request $request)
    {
        $payload = $request->validate([
            'status' => ['required', 'in:Open,In Progress,Resolved,Closed'],
            'response' => ['nullable', 'string'],
        ]);

        $ticket = DB::table('helpdesk_tickets')->where('id', $id)->firstOrFail();
        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $ticket->staff_id,
            'You can only manage helpdesk tickets within your assigned branch.',
        )) {
            return $response;
        }

        DB::table('helpdesk_tickets')->where('id', $id)->update([
            'status' => $payload['status'],
            'response' => $payload['response'] ?? $ticket->response,
            'responded_by' => $this->actorName($request),
            'responded_at' => now(),
            'updated_at' => now(),
        ]);

        $updated = DB::table('helpdesk_tickets')->where('id', $id)->firstOrFail();
        $this->createNotification([
            'id' => 'notif_helpdesk_status_'.$updated->id.'_'.$updated->status,
            'title' => 'Helpdesk ticket updated',
            'body' => $updated->subject.' is now '.$updated->status.'.',
            'type' => 'helpdesk',
            'staff_id' => $updated->staff_id,
            'staff_name' => $updated->staff_name,
            'target_role' => 'staff',
            'is_read' => false,
        ]);

        return response()->json($this->helpdeskTicketPayload($updated));
    }

    public function publishAnnouncement(Request $request)
    {
        $payload = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'body' => ['required', 'string'],
            'target_role' => ['required', Rule::in(['all', 'staff', 'supervisor', 'admin'])],
        ]);

        $id = $this->generateId('announcement');
        $this->createNotification([
            'id' => $id,
            'title' => $payload['title'],
            'body' => $payload['body'],
            'type' => 'announcement',
            'staff_id' => null,
            'staff_name' => null,
            'target_role' => $payload['target_role'],
            'is_read' => false,
        ]);

        return response()->json(
            $this->notificationPayload(DB::table('notifications')->where('id', $id)->firstOrFail()),
            201,
        );
    }

    public function storePushToken(Request $request)
    {
        $payload = $request->validate([
            'token' => ['required', 'string', 'max:4096'],
            'platform' => ['nullable', 'string', 'max:255'],
        ]);

        DB::table('push_tokens')->updateOrInsert(
            ['token' => $payload['token']],
            [
                'user_id' => $request->user()?->id,
                'platform' => $payload['platform'] ?? null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        );

        return response()->json(['success' => true]);
    }

    public function deletePushToken(Request $request)
    {
        $payload = $request->validate([
            'token' => ['nullable', 'string', 'max:4096'],
        ]);

        $query = DB::table('push_tokens');
        if (! empty($payload['token'])) {
            $query->where('token', $payload['token']);
        } else {
            $query->where('user_id', $request->user()?->id);
        }
        $query->delete();

        return response()->json(['success' => true]);
    }

    public function holidays(Request $request)
    {
        $query = DB::table('holidays')->orderBy('date');
        if ($request->filled('year')) {
            $query->whereYear('date', (int) $request->integer('year'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->holidayPayload($row))->all());
    }

    public function storeHoliday(Request $request)
    {
        $payload = $request->validate([
            'id' => ['nullable', 'string'],
            'name' => ['required', 'string', 'max:255'],
            'date' => ['required', 'date'],
            'type' => ['required', Rule::in(['Eid', 'Public', 'Weekly'])],
            'ot_multiplier' => ['required', 'numeric', 'min:0'],
        ]);

        $id = $this->generateId('holiday');
        DB::table('holidays')->insert([
            'id' => $id,
            'name' => $payload['name'],
            'date' => $payload['date'],
            'type' => $payload['type'],
            'ot_multiplier' => $payload['ot_multiplier'],
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(
            $this->holidayPayload(DB::table('holidays')->where('id', $id)->firstOrFail()),
            201,
        );
    }

    public function deleteHoliday(string $id)
    {
        DB::table('holidays')->where('id', $id)->delete();

        return response()->json(['success' => true]);
    }

    public function editLogs(Request $request)
    {
        $query = DB::table('attendance_edit_logs')->orderByDesc('created_at');

        if ($response = $this->applyScopedStaffTableFilters(
            $request,
            $query,
            'You can only access attendance edit logs within your assigned branch.',
        )) {
            return $response;
        }
        if ($request->filled('approval_status')) {
            $query->where('approval_status', $request->string('approval_status'));
        }

        return response()->json($query->get()->map(fn ($row) => $this->editLogPayload($row))->all());
    }

    public function storeEditLog(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id' => ['nullable', 'string'],
            'attendance_id' => ['required', 'string', 'exists:attendance,id'],
            'staff_id' => ['required', 'string', 'exists:staff,id'],
            'staff_name' => ['nullable', 'string'],
            'staff_code' => ['nullable', 'string'],
            'edited_by' => ['nullable', 'string'],
            'edited_by_role' => ['nullable', 'string'],
            'field_changed' => ['required', 'string', 'max:255'],
            'old_value' => ['required', 'string'],
            'new_value' => ['required', 'string'],
            'reason' => ['required', 'string'],
            'approval_status' => ['nullable', 'in:Pending,Approved,Rejected'],
            'approved_by' => ['nullable', 'string'],
            'approved_at' => ['nullable', 'date'],
            'created_at' => ['nullable', 'date'],
        ]);
        $validator->after(function ($validator) use ($request) {
            $attendance = Attendance::query()->find($request->input('attendance_id'));
            if ($attendance && $attendance->staff_id !== $request->input('staff_id')) {
                $validator->errors()->add('staff_id', 'Attendance record does not belong to the selected staff member.');
            }
        });
        $payload = $validator->validate();

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $payload['staff_id'],
            'You can only create attendance edit logs within your assigned branch.',
        )) {
            return $response;
        }

        $staff = $this->staffRecord($payload['staff_id']);
        $approvalStatus = $payload['approval_status'] ?? 'Pending';
        $approvedBy = $approvalStatus === 'Pending' ? null : $this->actorName($request);
        $approvedAt = $approvalStatus === 'Pending'
            ? null
            : ($payload['approved_at'] ?? now());
        $id = $this->generateId('edit');

        DB::table('attendance_edit_logs')->insert([
            'id' => $id,
            'attendance_id' => $payload['attendance_id'],
            ...$this->staffSnapshot($staff),
            'edited_by' => $this->actorName($request),
            'edited_by_role' => $this->actorRole($request),
            'field_changed' => $payload['field_changed'],
            'old_value' => $payload['old_value'],
            'new_value' => $payload['new_value'],
            'reason' => $payload['reason'],
            'approval_status' => $approvalStatus,
            'approved_by' => $approvedBy,
            'approved_at' => $approvedAt,
            'created_at' => $payload['created_at'] ?? now(),
            'updated_at' => now(),
        ]);

        return response()->json(
            $this->editLogPayload(DB::table('attendance_edit_logs')->where('id', $id)->firstOrFail()),
            201,
        );
    }

    public function updateEditLogStatus(string $id, Request $request)
    {
        $request->validate([
            'status' => ['required', 'in:Pending,Approved,Rejected'],
        ]);
        $status = (string) $request->input('status', 'Pending');

        $editLog = DB::table('attendance_edit_logs')->where('id', $id)->firstOrFail();
        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $editLog->staff_id,
            'You can only approve attendance edit logs within your assigned branch.',
        )) {
            return $response;
        }

        DB::table('attendance_edit_logs')->where('id', $id)->update([
            'approval_status' => $status,
            'approved_by' => $status === 'Pending'
                ? null
                : $this->actorName($request),
            'approved_at' => $status === 'Pending'
                ? null
                : now(),
            'updated_at' => now(),
        ]);

        return response()->json($this->editLogPayload(DB::table('attendance_edit_logs')->where('id', $id)->firstOrFail()));
    }

    public function dashboardStats(Request $request)
    {
        if ($response = $this->ensureScopedContext($request)) {
            return $response;
        }

        $date = $request->filled('date')
            ? Carbon::parse($request->string('date'))
            : now();
        $staffQuery = DB::table('staff');
        if ($this->isStaffRequest($request)) {
            $staffQuery->where('id', $this->currentStaffId($request));
        } elseif ($this->isSupervisorRequest($request)) {
            $staffQuery->where('branch_id', $this->currentScopeBranchId($request));
            if (($department = $this->currentScopeDepartment($request)) !== null) {
                $staffQuery->where('department', $department);
            }
        }
        $staff = $staffQuery->get();

        $attendanceQuery = DB::table('attendance')->whereDate('date', $date->toDateString());
        if ($response = $this->applyStaffScope($request, $attendanceQuery)) {
            return $response;
        }
        $attendance = $attendanceQuery->get();

        $monthlyAttendanceQuery = DB::table('attendance')
            ->whereYear('date', $date->year)
            ->whereMonth('date', $date->month);
        if ($response = $this->applyStaffScope($request, $monthlyAttendanceQuery)) {
            return $response;
        }
        $monthlyAttendance = $monthlyAttendanceQuery->get();

        $salariesQuery = DB::table('salaries');
        if ($response = $this->applyStaffScope($request, $salariesQuery)) {
            return $response;
        }
        $salaries = $salariesQuery->get();

        $loansQuery = DB::table('loans')->where('status', 'Active');
        if ($response = $this->applyStaffScope($request, $loansQuery)) {
            return $response;
        }
        $loans = $loansQuery->get();

        $kpisQuery = DB::table('kpis');
        if ($response = $this->applyStaffScope($request, $kpisQuery)) {
            return $response;
        }
        $kpis = $kpisQuery->get();

        $present = $attendance->where('status', 'Present')->count();
        $absent = $attendance->where('status', 'Absent')->count();
        $late = $attendance->where('status', 'Late')->count();
        $onLeave = $attendance->where('status', 'On Leave')->count();
        $overtimeCount = $attendance->where('status', 'Overtime')->count();
        $bestStaff = $staff->sortByDesc('kpi_score')->first();
        $lowestStaff = $staff->sortBy('kpi_score')->first();
        $highestOvertime = $staff->sortByDesc('overtime_hours')->first();
        $documentAlerts = collect();
        foreach ($staff as $staffRow) {
            foreach ([
                'passport_expire_date' => 'Passport',
                'civil_id_expire_date' => 'Civil ID',
                'contract_expire_date' => 'Contract',
            ] as $field => $label) {
                if (empty($staffRow->{$field})) {
                    continue;
                }
                $daysRemaining = $date->copy()
                    ->startOfDay()
                    ->diffInDays(Carbon::parse($staffRow->{$field})->startOfDay(), false);
                if ($daysRemaining <= 30) {
                    $documentAlerts->push([
                        'staff_id' => $staffRow->id,
                        'document_type' => $label,
                        'days_remaining' => $daysRemaining,
                    ]);
                }
            }
        }

        $mPresent = $monthlyAttendance->whereIn('status', ['Present', 'Late', 'Overtime', 'Missing Checkout'])->count();
        $mAbsent = $monthlyAttendance->where('status', 'Absent')->count();
        $mLate = $monthlyAttendance->where('status', 'Late')->count();
        $mOnLeave = $monthlyAttendance->where('status', 'On Leave')->count();
        $mOvertime = $monthlyAttendance->where('status', 'Overtime')->count();

        return response()->json([
            'total_staff' => $staff->count(),
            'present_today' => $present,
            'absent_today' => $absent,
            'late_today' => $late,
            'on_leave' => $onLeave,
            'overtime_count' => $overtimeCount,
            'monthly_present' => $mPresent,
            'monthly_absent' => $mAbsent,
            'monthly_late' => $mLate,
            'monthly_on_leave' => $mOnLeave,
            'monthly_overtime' => $mOvertime,
            'total_overtime_hours' => round((float) $attendance->sum('overtime_hours'), 2),
            'salary_pending' => $salaries->where('payment_status', 'Pending')->count(),
            'total_loan_balance' => round((float) $loans->sum('balance_amount'), 2),
            'kpi_average' => round((float) $kpis->avg('total_kpi_score'), 1),
            'best_staff' => $bestStaff?->name,
            'lowest_kpi_staff' => $lowestStaff?->name,
            'highest_overtime_staff' => $highestOvertime?->name,
            'expiring_documents' => $documentAlerts->where('days_remaining', '>=', 0)->count(),
            'expired_documents' => $documentAlerts->where('days_remaining', '<', 0)->count(),
        ]);
    }

    private function applyScopedStaffTableFilters(
        Request $request,
        mixed $query,
        string $message,
    ): ?JsonResponse {
        if (($this->isStaffRequest($request) || $this->isSupervisorRequest($request)) && $request->filled('staff_id')) {
            if ($response = $this->ensureAccessibleStaffId($request, $request->string('staff_id'), $message)) {
                return $response;
            }
        }

        if ($request->filled('staff_id')) {
            $query->where('staff_id', $request->string('staff_id'));
        }

        return $this->applyStaffScope($request, $query);
    }

    private function generateId(string $prefix): string
    {
        return $prefix.'_'.Str::uuid();
    }

    private function staffRecord(string $staffId): Staff
    {
        return Staff::query()->findOrFail($staffId);
    }

    private function staffSnapshot(object $staff): array
    {
        return [
            'staff_id' => $staff->id,
            'staff_name' => $staff->name,
            'staff_code' => $staff->staff_code,
        ];
    }

    private function actorName(Request $request): string
    {
        $name = trim((string) ($request->user()?->name ?? $request->user()?->email ?? 'System'));

        return $name !== '' ? $name : 'System';
    }

    private function actorRole(Request $request): string
    {
        $role = trim(strtolower((string) ($request->user()?->role ?? 'system')));

        return $role !== '' ? $role : 'system';
    }

    private function taskAssignees(array $assignees): Collection
    {
        $orderedIds = collect($assignees)
            ->pluck('id')
            ->map(fn ($id) => trim((string) $id))
            ->filter()
            ->unique()
            ->values();

        $records = Staff::query()
            ->whereIn('id', $orderedIds)
            ->get()
            ->keyBy('id');

        if ($records->count() !== $orderedIds->count()) {
            throw ValidationException::withMessages([
                'assignees' => ['One or more assignees no longer exist.'],
            ]);
        }

        return $orderedIds->map(fn (string $id) => $records->get($id));
    }

    private function createNotification(array $payload): void
    {
        try {
            DB::table('notifications')->updateOrInsert(
                ['id' => $payload['id']],
                [
                    ...$payload,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            );
        } catch (\Throwable) {
            // Notification creation is non-critical — never crash the main response
        }
    }

    private function applyNotificationScope(Request $request, mixed $query): ?JsonResponse
    {
        if ($response = $this->ensureScopedContext($request)) {
            return $response;
        }

        if ($this->isStaffRequest($request)) {
            if ($request->filled('staff_id') && $request->string('staff_id') !== $this->currentStaffId($request)) {
                return response()->json([
                    'message' => 'You can only access your own notifications.',
                ], 403);
            }
            if ($request->filled('target_role') && $request->string('target_role') !== 'staff') {
                return response()->json([
                    'message' => 'You can only access staff notifications.',
                ], 403);
            }

            $query->whereIn('target_role', ['staff', 'all']);
            $query->where(function ($builder) use ($request) {
                $builder->whereNull('staff_id')
                    ->orWhere('staff_id', $this->currentStaffId($request));
            });

            return null;
        }

        if ($this->isSupervisorRequest($request)) {
            if ($request->filled('staff_id')) {
                if ($response = $this->ensureAccessibleStaffId(
                    $request,
                    $request->string('staff_id'),
                    'You can only access notifications within your assigned branch.',
                )) {
                    return $response;
                }
            }

            $roles = $this->supervisorNotificationRoles(
                $request->filled('target_role') ? $request->string('target_role') : null
            );
            if ($roles === null) {
                return response()->json([
                    'message' => 'You can only access supervisor notifications within your scope.',
                ], 403);
            }

            $query->whereIn('target_role', $roles);
            $query->where(function ($builder) use ($request) {
                $builder->whereNull('staff_id')
                    ->orWhereIn('staff_id', $this->scopedStaffIdsQuery($request));
            });

            if ($request->filled('staff_id')) {
                $staffId = $request->string('staff_id');
                $query->where(function ($builder) use ($staffId) {
                    $builder->whereNull('staff_id')
                        ->orWhere('staff_id', $staffId);
                });
            }

            return null;
        }

        if ($request->filled('target_role')) {
            $targetRole = $request->string('target_role');
            $query->where(function ($builder) use ($targetRole) {
                $builder->where('target_role', $targetRole)
                    ->orWhere('target_role', 'all');
            });
        }

        if ($request->filled('staff_id')) {
            $staffId = $request->string('staff_id');
            $query->where(function ($builder) use ($staffId) {
                $builder->whereNull('staff_id')
                    ->orWhere('staff_id', $staffId);
            });
        }

        return null;
    }

    private function supervisorNotificationRoles(?string $requestedRole): ?array
    {
        return match ($requestedRole) {
            null, '', 'supervisor' => ['admin', 'supervisor', 'all'],
            'admin' => ['admin', 'all'],
            'all' => ['all'],
            default => null,
        };
    }

    private function isNotificationVisibleToCurrentStaff(Request $request, object $notification): bool
    {
        $staffId = $this->currentStaffId($request);

        if (! $staffId) {
            return false;
        }

        if (! in_array($notification->target_role, ['staff', 'all'], true)) {
            return false;
        }

        return $notification->staff_id === null || $notification->staff_id === $staffId;
    }

    private function isNotificationVisibleToCurrentSupervisor(Request $request, object $notification): bool
    {
        if (! in_array($notification->target_role, ['admin', 'supervisor', 'all'], true)) {
            return false;
        }

        return $notification->staff_id === null
            || $this->isStaffInSupervisorScope($request, $notification->staff_id);
    }

    private function salaryPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'month' => $row->month,
            'basic_salary' => (float) $row->basic_salary,
            'overtime_amount' => (float) $row->overtime_amount,
            'allowance' => (float) $row->allowance,
            'deduction' => (float) $row->deduction,
            'loan_deduction' => (float) $row->loan_deduction,
            'absence_deduction' => (float) $row->absence_deduction,
            'penalty' => (float) $row->penalty,
            'net_salary' => (float) $row->net_salary,
            'payment_status' => $row->payment_status,
            'paid_date' => $this->dateString($row->paid_date),
            'notes' => $row->notes,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function loanPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'loan_amount' => (float) $row->loan_amount,
            'paid_amount' => (float) $row->paid_amount,
            'balance_amount' => (float) $row->balance_amount,
            'monthly_deduction' => (float) $row->monthly_deduction,
            'loan_date' => $this->dateString($row->loan_date),
            'status' => $row->status,
            'purpose' => $row->purpose,
            'notes' => $row->notes,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function leavePayload(object $row): array
    {
        return [
            'id' => $row->id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'leave_type' => $row->leave_type,
            'from_date' => $this->dateString($row->from_date),
            'to_date' => $this->dateString($row->to_date),
            'reason' => $row->reason,
            'attachment_url' => $row->attachment_url,
            'status' => $row->status,
            'approved_by' => $row->approved_by,
            'rejection_reason' => $row->rejection_reason,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function kpiPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'month' => $row->month,
            'attendance_rate' => (float) $row->attendance_rate,
            'absence_rate' => (float) $row->absence_rate,
            'late_count' => (int) $row->late_count,
            'early_checkout_count' => (int) $row->early_checkout_count,
            'total_working_hours' => (float) $row->total_working_hours,
            'avg_daily_working_hours' => (float) $row->avg_daily_working_hours,
            'overtime_hours' => (float) $row->overtime_hours,
            'missing_checkout_count' => (int) $row->missing_checkout_count,
            'valid_location_count' => (int) $row->valid_location_count,
            'invalid_location_count' => (int) $row->invalid_location_count,
            'fake_gps_count' => (int) $row->fake_gps_count,
            'leave_count' => (int) $row->leave_count,
            'task_assigned_count' => (int) $row->task_assigned_count,
            'task_completed_count' => (int) $row->task_completed_count,
            'task_completion_rate' => (float) $row->task_completion_rate,
            'attendance_score' => (float) $row->attendance_score,
            'punctuality_score' => (float) $row->punctuality_score,
            'overtime_score' => (float) $row->overtime_score,
            'location_score' => (float) $row->location_score,
            'discipline_score' => (float) $row->discipline_score,
            'task_score' => (float) $row->task_score,
            'total_kpi_score' => (float) $row->total_kpi_score,
            'rating' => $row->rating,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function taskPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'group_id' => $row->group_id,
            'title' => $row->title,
            'description' => $row->description,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'assigned_by' => $row->assigned_by,
            'assigned_by_role' => $row->assigned_by_role,
            'assigned_to_all' => (bool) $row->assigned_to_all,
            'is_daily_task' => (bool) $row->is_daily_task,
            'due_date' => $this->dateString($row->due_date),
            'status' => $row->status,
            'created_at' => $this->dateString($row->created_at),
            'completed_at' => $this->dateString($row->completed_at),
            'terminated_at' => $this->dateString($row->terminated_at),
        ];
    }

    private function notificationPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'title' => $row->title,
            'body' => $row->body,
            'type' => $row->type,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'is_read' => (bool) $row->is_read,
            'target_role' => $row->target_role,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function expensePayload(object $row): array
    {
        return [
            'id' => $row->id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'expense_type' => $row->expense_type,
            'amount' => (float) $row->amount,
            'expense_date' => $this->dateString($row->expense_date),
            'description' => $row->description,
            'receipt_images' => $row->receipt_images ? json_decode($row->receipt_images, true, 512, JSON_THROW_ON_ERROR) : [],
            'status' => $row->status,
            'approved_by' => $row->approved_by,
            'rejection_reason' => $row->rejection_reason,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function shiftRosterPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'roster_date' => $this->dateString($row->roster_date),
            'shift_id' => $row->shift_id,
            'shift_name' => $row->shift_name,
            'start_time' => $row->start_time,
            'end_time' => $row->end_time,
            'status' => $row->status,
            'notes' => $row->notes,
            'assigned_by' => $row->assigned_by,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function shiftSwapRequestPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'requester_staff_id' => $row->requester_staff_id,
            'requester_name' => $row->requester_name,
            'requester_code' => $row->requester_code,
            'target_staff_id' => $row->target_staff_id,
            'target_name' => $row->target_name,
            'target_code' => $row->target_code,
            'roster_date' => $this->dateString($row->roster_date),
            'requester_shift_id' => $row->requester_shift_id,
            'requester_shift_name' => $row->requester_shift_name,
            'target_shift_id' => $row->target_shift_id,
            'target_shift_name' => $row->target_shift_name,
            'reason' => $row->reason,
            'status' => $row->status,
            'approved_by' => $row->approved_by,
            'approved_at' => $this->dateString($row->approved_at),
            'rejection_reason' => $row->rejection_reason,
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function helpdeskTicketPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'subject' => $row->subject,
            'category' => $row->category,
            'message' => $row->message,
            'status' => $row->status,
            'response' => $row->response,
            'responded_by' => $row->responded_by,
            'responded_at' => $this->dateString($row->responded_at),
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function storePublicFile(
        Request $request,
        string $field,
        string $directory,
        ?string $fallback = null,
    ): ?string {
        if (! $request->hasFile($field)) {
            return $fallback;
        }

        $path = $request->file($field)->store($directory, 'public');

        return url(Storage::url($path));
    }

    private function storePublicFiles(
        Request $request,
        string $field,
        string $directory,
        array $fallback = [],
    ): array {
        if (! $request->hasFile($field)) {
            return $fallback;
        }

        return collect($request->file($field))
            ->filter()
            ->map(function ($file) use ($directory) {
                $path = $file->store($directory, 'public');

                return url(Storage::url($path));
            })
            ->values()
            ->all();
    }

    private function holidayPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'name' => $row->name,
            'date' => $this->dateString($row->date),
            'type' => $row->type,
            'ot_multiplier' => (float) $row->ot_multiplier,
        ];
    }

    private function editLogPayload(object $row): array
    {
        return [
            'id' => $row->id,
            'attendance_id' => $row->attendance_id,
            'staff_id' => $row->staff_id,
            'staff_name' => $row->staff_name,
            'staff_code' => $row->staff_code,
            'edited_by' => $row->edited_by,
            'edited_by_role' => $row->edited_by_role,
            'field_changed' => $row->field_changed,
            'old_value' => $row->old_value,
            'new_value' => $row->new_value,
            'reason' => $row->reason,
            'approval_status' => $row->approval_status,
            'approved_by' => $row->approved_by,
            'approved_at' => $this->dateString($row->approved_at),
            'created_at' => $this->dateString($row->created_at),
        ];
    }

    private function dateString(mixed $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        return Carbon::parse($value)->toIso8601String();
    }
}
