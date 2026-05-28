<?php

use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BranchController;
use App\Http\Controllers\Api\HrModuleController;
use App\Http\Controllers\Api\ShiftController;
use App\Http\Controllers\Api\StaffController;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    try {
        DB::select('select 1');

        return response()->json([
            'status' => 'ok',
            'app' => config('app.name'),
            'environment' => app()->environment(),
            'time' => now()->toIso8601String(),
        ]);
    } catch (Throwable $exception) {
        return response()->json([
            'status' => 'error',
            'app' => config('app.name'),
            'environment' => app()->environment(),
            'time' => now()->toIso8601String(),
            'message' => 'Database is not reachable.',
        ], 503);
    }
});

Route::post('/auth/login', [AuthController::class, 'login'])
    ->middleware('throttle:auth-login');

Route::middleware(['auth:sanctum', 'active-user-session', 'track-token-metadata'])->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::get('/auth/sessions', [AuthController::class, 'sessions']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/logout-all', [AuthController::class, 'logoutAll']);
    Route::delete('/auth/sessions/{tokenId}', [AuthController::class, 'destroySession']);
    Route::post('/auth/change-password', [AuthController::class, 'changePassword']);
    Route::post('/auth/biometric-token', [AuthController::class, 'createBiometricToken']);
    Route::delete('/auth/biometric-token', [AuthController::class, 'destroyBiometricToken']);

    Route::get('/branches', [BranchController::class, 'index']);
    Route::get('/branches/{id}', [BranchController::class, 'show']);

    Route::get('/shifts', [ShiftController::class, 'index']);
    Route::get('/shifts/{id}', [ShiftController::class, 'show']);

    Route::get('/staff/by-user/{userId}', [StaffController::class, 'byUser']);

    Route::get('/attendance', [AttendanceController::class, 'index']);
    Route::get('/attendance/today', [AttendanceController::class, 'today']);
    Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']);
    Route::post('/attendance/check-out', [AttendanceController::class, 'checkOut']);
    Route::patch('/attendance/{id}/pause', [AttendanceController::class, 'pauseDuty']);
    Route::patch('/attendance/{id}/resume', [AttendanceController::class, 'resumeDuty']);

    Route::get('/salaries', [HrModuleController::class, 'salaries']);

    Route::get('/loans', [HrModuleController::class, 'loans']);

    Route::get('/leaves', [HrModuleController::class, 'leaves']);
    Route::post('/leaves', [HrModuleController::class, 'storeLeave']);

    Route::get('/kpis', [HrModuleController::class, 'kpis']);

    Route::get('/tasks', [HrModuleController::class, 'tasks']);
    Route::patch('/tasks/{id}/complete', [HrModuleController::class, 'completeTask']);

    Route::get('/notifications', [HrModuleController::class, 'notifications']);
    Route::patch('/notifications/{id}/read', [HrModuleController::class, 'markNotificationRead']);
    Route::patch('/notifications/read-all', [HrModuleController::class, 'markNotificationsRead']);
    Route::post('/push-tokens', [HrModuleController::class, 'storePushToken']);
    Route::delete('/push-tokens', [HrModuleController::class, 'deletePushToken']);

    Route::get('/expenses', [HrModuleController::class, 'expenses']);
    Route::post('/expenses', [HrModuleController::class, 'storeExpense']);

    Route::get('/holidays', [HrModuleController::class, 'holidays']);
    Route::get('/shift-rosters', [HrModuleController::class, 'shiftRosters']);
    Route::get('/shift-swap-requests', [HrModuleController::class, 'shiftSwapRequests']);
    Route::post('/shift-swap-requests', [HrModuleController::class, 'storeShiftSwapRequest']);
    Route::get('/helpdesk-tickets', [HrModuleController::class, 'helpdeskTickets']);
    Route::post('/helpdesk-tickets', [HrModuleController::class, 'storeHelpdeskTicket']);

    Route::middleware('role:admin,supervisor')->group(function () {
        Route::get('/staff', [StaffController::class, 'index']);
        Route::get('/staff/{id}', [StaffController::class, 'show']);

        Route::post('/attendance', [AttendanceController::class, 'store']);
        Route::put('/attendance/{id}', [AttendanceController::class, 'update']);
        Route::patch('/attendance/{id}/overtime-approval', [AttendanceController::class, 'updateOvertimeApproval']);

        Route::patch('/leaves/{id}/status', [HrModuleController::class, 'updateLeaveStatus']);
        Route::patch('/expenses/{id}/status', [HrModuleController::class, 'updateExpenseStatus']);
        Route::patch('/shift-swap-requests/{id}/status', [HrModuleController::class, 'updateShiftSwapRequestStatus']);
        Route::patch('/helpdesk-tickets/{id}/status', [HrModuleController::class, 'updateHelpdeskTicketStatus']);

        Route::get('/attendance-edit-logs', [HrModuleController::class, 'editLogs']);
        Route::post('/attendance-edit-logs', [HrModuleController::class, 'storeEditLog']);
        Route::patch('/attendance-edit-logs/{id}/status', [HrModuleController::class, 'updateEditLogStatus']);

        Route::get('/dashboard/stats', [HrModuleController::class, 'dashboardStats']);
    });

    Route::middleware('role:admin')->group(function () {
        Route::get('/audit-logs', [HrModuleController::class, 'auditLogs']);

        Route::post('/branches', [BranchController::class, 'store']);
        Route::put('/branches/{id}', [BranchController::class, 'update']);

        Route::post('/shifts', [ShiftController::class, 'store']);
        Route::put('/shifts/{id}', [ShiftController::class, 'update']);

        Route::post('/staff', [StaffController::class, 'store']);
        Route::put('/staff/{id}', [StaffController::class, 'update']);
        Route::post('/staff/{id}/reset-device-binding', [StaffController::class, 'resetDeviceBinding']);

        Route::patch('/salaries/{id}/mark-paid', [HrModuleController::class, 'markSalaryPaid']);
        Route::post('/salaries/generate', [HrModuleController::class, 'generateSalaries']);

        Route::post('/loans', [HrModuleController::class, 'storeLoan']);

        Route::post('/tasks/assign', [HrModuleController::class, 'assignTask']);
        Route::patch('/tasks/{id}/terminate', [HrModuleController::class, 'terminateTask']);

        Route::post('/holidays', [HrModuleController::class, 'storeHoliday']);
        Route::delete('/holidays/{id}', [HrModuleController::class, 'deleteHoliday']);
        Route::post('/shift-rosters', [HrModuleController::class, 'storeShiftRoster']);
        Route::put('/shift-rosters/{id}', [HrModuleController::class, 'updateShiftRoster']);
        Route::post('/announcements', [HrModuleController::class, 'publishAnnouncement']);
    });
});
