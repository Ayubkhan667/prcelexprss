<?php

namespace App\Http\Controllers\Api\Concerns;

use App\Models\Staff;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

trait ResolvesCurrentStaff
{
    protected function isStaffRequest(Request $request): bool
    {
        return strtolower((string) $request->user()?->role) === 'staff';
    }

    protected function currentStaffProfile(Request $request): ?Staff
    {
        $user = $request->user();

        if (! $user) {
            return null;
        }

        $user->loadMissing('staffProfile');

        return $user->staffProfile;
    }

    protected function currentStaffId(Request $request): ?string
    {
        return $this->currentStaffProfile($request)?->id;
    }

    protected function isSupervisorRequest(Request $request): bool
    {
        return strtolower((string) $request->user()?->role) === 'supervisor';
    }

    protected function currentScopeBranchId(Request $request): ?string
    {
        $user = $request->user();
        if (! $user) {
            return null;
        }

        if ($this->isSupervisorRequest($request) && ! empty($user->scope_branch_id)) {
            return (string) $user->scope_branch_id;
        }

        return $this->currentStaffProfile($request)?->branch_id;
    }

    protected function currentScopeDepartment(Request $request): ?string
    {
        $user = $request->user();
        if (! $user) {
            return null;
        }

        if ($this->isSupervisorRequest($request) && ! empty($user->scope_department)) {
            return (string) $user->scope_department;
        }

        return $this->currentStaffProfile($request)?->department;
    }

    protected function ensureStaffProfile(Request $request): ?JsonResponse
    {
        if (! $this->isStaffRequest($request)) {
            return null;
        }

        if ($this->currentStaffProfile($request) !== null) {
            return null;
        }

        return response()->json([
            'message' => 'Staff profile not found for the current user.',
        ], 403);
    }

    protected function ensureScopedContext(Request $request): ?JsonResponse
    {
        if ($response = $this->ensureStaffProfile($request)) {
            return $response;
        }

        if (! $this->isSupervisorRequest($request)) {
            return null;
        }

        if ($this->currentScopeBranchId($request) !== null) {
            return null;
        }

        return response()->json([
            'message' => 'Supervisor branch scope is not configured.',
        ], 403);
    }

    protected function ensureOwnStaffId(Request $request, ?string $staffId): ?JsonResponse
    {
        if (! $this->isStaffRequest($request)) {
            return null;
        }

        $currentStaff = $this->currentStaffProfile($request);
        if (! $currentStaff) {
            return response()->json([
                'message' => 'Staff profile not found for the current user.',
            ], 403);
        }

        if ($staffId !== null && $staffId !== $currentStaff->id) {
            return response()->json([
                'message' => 'You can only access your own staff records.',
            ], 403);
        }

        return null;
    }

    protected function ensureAccessibleStaffId(
        Request $request,
        ?string $staffId,
        string $message = 'You can only access staff records within your assigned branch.',
    ): ?JsonResponse {
        if ($staffId === null || $staffId === '') {
            return $this->ensureScopedContext($request);
        }

        if ($response = $this->ensureOwnStaffId($request, $staffId)) {
            return $response;
        }

        if (! $this->isSupervisorRequest($request)) {
            return null;
        }

        if ($response = $this->ensureScopedContext($request)) {
            return $response;
        }

        if ($this->isStaffInSupervisorScope($request, $staffId)) {
            return null;
        }

        return response()->json([
            'message' => $message,
        ], 403);
    }

    protected function applyStaffScope(Request $request, mixed $query, string $column = 'staff_id'): ?JsonResponse
    {
        if ($response = $this->ensureScopedContext($request)) {
            return $response;
        }

        if ($this->isStaffRequest($request)) {
            $query->where($column, $this->currentStaffId($request));

            return null;
        }

        if ($this->isSupervisorRequest($request)) {
            $query->whereIn($column, $this->scopedStaffIdsQuery($request));
        }

        return null;
    }

    protected function isStaffInSupervisorScope(Request $request, string $staffId): bool
    {
        $branchId = $this->currentScopeBranchId($request);
        if ($branchId === null) {
            return false;
        }

        $query = Staff::query()
            ->whereKey($staffId)
            ->where('branch_id', $branchId);

        if (($department = $this->currentScopeDepartment($request)) !== null) {
            $query->where('department', $department);
        }

        return $query->exists();
    }

    protected function scopedStaffIdsQuery(Request $request)
    {
        $query = Staff::query()
            ->select('id')
            ->where('branch_id', $this->currentScopeBranchId($request));

        if (($department = $this->currentScopeDepartment($request)) !== null) {
            $query->where('department', $department);
        }

        return $query->toBase();
    }
}
