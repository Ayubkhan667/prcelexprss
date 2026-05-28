<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\ResolvesCurrentStaff;
use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Shift;
use App\Models\Staff;
use App\Models\User;
use App\Support\SmartHrPayloads;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class StaffController extends Controller
{
    use ResolvesCurrentStaff;

    public function index(Request $request)
    {
        $query = Staff::query()->orderBy('name');

        if ($this->isSupervisorRequest($request)) {
            if ($response = $this->ensureScopedContext($request)) {
                return $response;
            }

            if ($request->filled('branch_id') && $request->string('branch_id') !== $this->currentScopeBranchId($request)) {
                return response()->json([
                    'message' => 'You can only access staff within your assigned branch.',
                ], 403);
            }

            if (
                $request->filled('department')
                && $this->currentScopeDepartment($request) !== null
                && $request->string('department') !== $this->currentScopeDepartment($request)
            ) {
                return response()->json([
                    'message' => 'You can only access staff within your assigned team.',
                ], 403);
            }

            $query->where('branch_id', $this->currentScopeBranchId($request));

            if (($department = $this->currentScopeDepartment($request)) !== null) {
                $query->where('department', $department);
            }
        }

        if ($request->filled('branch_id')) {
            $query->where('branch_id', $request->string('branch_id'));
        }

        if ($request->filled('department')) {
            $query->where('department', $request->string('department'));
        }

        if ($request->filled('category')) {
            $query->where('category', $request->string('category'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('user_id')) {
            $query->where('user_id', (int) $request->string('user_id'));
        }

        if ($request->filled('search')) {
            $search = '%'.$request->string('search').'%';
            $query->where(function ($builder) use ($search) {
                $builder
                    ->where('name', 'like', $search)
                    ->orWhere('staff_code', 'like', $search)
                    ->orWhere('email', 'like', $search)
                    ->orWhere('mobile', 'like', $search);
            });
        }

        return response()->json(
            $query->get()->map(fn (Staff $staff) => SmartHrPayloads::staff($staff))->values()
        );
    }

    public function show(Request $request, string $id)
    {
        if ($response = $this->ensureAccessibleStaffId($request, $id)) {
            return $response;
        }

        return response()->json(
            SmartHrPayloads::staff(Staff::query()->findOrFail($id))
        );
    }

    public function byUser(Request $request, string $userId)
    {
        if ($this->isStaffRequest($request) && (string) $request->user()->id !== $userId) {
            return response()->json([
                'message' => 'You can only access your own staff profile.',
            ], 403);
        }

        $staff = Staff::query()->where('user_id', (int) $userId)->firstOrFail();

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $staff->id,
            'You can only access staff within your assigned branch.',
        )) {
            return $response;
        }

        return response()->json(SmartHrPayloads::staff($staff));
    }

    public function store(Request $request)
    {
        return DB::transaction(function () use ($request) {
            $this->validateStaffRequest($request);
            [$staffPayload, $userPayload] = $this->prepareStaffAndUserPayloads($request);
            $generatedPassword = null;
            $password = $this->normalizeOptionalString($userPayload['password'] ?? null);
            if ($password === null) {
                $generatedPassword = $this->generateTemporaryPassword();
                $password = $generatedPassword;
            }

            $user = User::query()->create([
                'name' => $userPayload['name'] ?? $userPayload['email'] ?? 'User',
                'email' => $userPayload['email'],
                'mobile' => $userPayload['mobile'] ?? null,
                'role' => $userPayload['role'] ?? 'staff',
                'scope_branch_id' => $userPayload['scope_branch_id'] ?? null,
                'scope_department' => $userPayload['scope_department'] ?? null,
                'status' => $userPayload['status'] ?? 'Active',
                'device_id' => $userPayload['device_id'] ?? null,
                'profile_image_url' => $userPayload['profile_image_url'] ?? null,
                'password' => $password,
            ]);

            $staffPayload['id'] = $this->normalizeOptionalString($staffPayload['id'] ?? null)
                ?? (string) Str::uuid();
            $staffPayload['staff_code'] = $this->normalizeOptionalString($staffPayload['staff_code'] ?? null)
                ?? $this->nextStaffCode();

            $staff = new Staff($staffPayload);
            $staff->user_id = $user->id;
            $staff->save();

            $response = SmartHrPayloads::staff($staff);
            if ($generatedPassword !== null) {
                $response['temporary_password'] = $generatedPassword;
            }

            return response()->json($response, 201);
        });
    }

    public function update(Request $request, string $id)
    {
        return DB::transaction(function () use ($request, $id) {
            $staff = Staff::query()->findOrFail($id);
            $this->validateStaffRequest($request, $staff);
            [$staffPayload, $userPayload] = $this->prepareStaffAndUserPayloads($request, $staff);

            $staff->fill($staffPayload);
            $staff->save();

            if ($staff->user_id) {
                $staff->user()->update([
                    'name' => $userPayload['name'] ?? $staff->name,
                    'email' => $userPayload['email'] ?? $staff->email,
                    'mobile' => $userPayload['mobile'] ?? $staff->mobile,
                    'role' => $userPayload['role'] ?? 'staff',
                    'scope_branch_id' => $userPayload['scope_branch_id'] ?? null,
                    'scope_department' => $userPayload['scope_department'] ?? null,
                    'status' => $userPayload['status'] ?? $staff->status,
                    'device_id' => $userPayload['device_id'] ?? null,
                    'profile_image_url' => $userPayload['profile_image_url'] ?? null,
                ]);

                if (! empty($userPayload['password'])) {
                    $staff->user()->update([
                        'password' => Hash::make($userPayload['password']),
                    ]);
                }
            }

            return response()->json(SmartHrPayloads::staff($staff->fresh()));
        });
    }

    public function resetDeviceBinding(string $id)
    {
        return DB::transaction(function () use ($id) {
            $staff = Staff::query()->findOrFail($id);
            $user = $staff->user;

            if (! $user) {
                return response()->json([
                    'message' => 'No linked user account was found for this staff profile.',
                ], 422);
            }

            $user->forceFill([
                'device_id' => null,
            ])->save();
            $user->tokens()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Device binding reset. The staff member must sign in again on the new device.',
            ]);
        });
    }

    private function normalizeStaffPayload(array $payload): array
    {
        unset($payload['user_id']);

        // Columns with NOT NULL constraints that may arrive as null from the app.
        $payload['job_title'] = $payload['job_title'] ?? '';
        $payload['branch_name'] = $payload['branch_name'] ?? '';
        $payload['shift_name'] = $payload['shift_name'] ?? '';

        return $payload;
    }

    private function sanitizeStaffPayload(Request $request): array
    {
        $payload = $request->input('staff', []);

        return is_array($payload)
            ? Arr::only($payload, $this->staffWritableFields())
            : [];
    }

    private function sanitizeUserPayload(Request $request): array
    {
        $payload = $request->input('user', []);

        return is_array($payload)
            ? Arr::only($payload, [
                'name',
                'email',
                'mobile',
                'role',
                'scope_branch_id',
                'scope_department',
                'status',
                'device_id',
                'profile_image_url',
                'password',
            ])
            : [];
    }

    private function validateStaffRequest(Request $request, ?Staff $staff = null): void
    {
        $userId = $staff?->user_id;

        $request->validate([
            'staff' => ['required', 'array'],
            'user' => ['required', 'array'],
            'staff.id' => [
                'nullable',
                'string',
                'max:255',
                $staff
                    ? Rule::in([$staff->id])
                    : Rule::unique('staff', 'id'),
            ],
            'staff.staff_code' => [
                'nullable',
                'string',
                'max:255',
                Rule::unique('staff', 'staff_code')->ignore($staff?->id),
            ],
            'staff.name' => ['required', 'string', 'max:255'],
            'staff.email' => [
                'required',
                'email',
                'max:255',
                Rule::unique('staff', 'email')->ignore($staff?->id),
            ],
            'staff.mobile' => ['required', 'string', 'max:255'],
            'staff.id_card_number' => ['nullable', 'string', 'max:255'],
            'staff.job_title' => ['required', 'string', 'max:255'],
            'staff.category' => ['required', 'string', 'max:255'],
            'staff.department' => ['required', 'string', 'max:255'],
            'staff.branch_id' => ['required', 'string', 'exists:branches,id'],
            'staff.branch_name' => ['nullable', 'string', 'max:255'],
            'staff.shift_id' => ['required', 'string', 'exists:shifts,id'],
            'staff.shift_name' => ['nullable', 'string', 'max:255'],
            'staff.joining_date' => ['required', 'date'],
            'staff.basic_salary' => ['nullable', 'numeric', 'min:0'],
            'staff.overtime_rate' => ['nullable', 'numeric', 'min:0'],
            'staff.weekly_off_day' => ['nullable', 'string', 'max:255'],
            'staff.status' => ['nullable', Rule::in(['Active', 'Inactive', 'Suspended'])],
            'staff.profile_image_url' => ['nullable', 'string', 'max:2048'],
            'staff.kpi_score' => ['nullable', 'numeric', 'min:0'],
            'staff.kpi_rating' => ['nullable', 'string', 'max:255'],
            'staff.loan_balance' => ['nullable', 'numeric', 'min:0'],
            'staff.overtime_hours' => ['nullable', 'numeric', 'min:0'],
            'staff.today_check_in' => ['nullable', 'string', 'max:255'],
            'staff.today_check_out' => ['nullable', 'string', 'max:255'],
            'staff.today_status' => ['nullable', 'string', 'max:255'],
            'staff.preferred_name' => ['nullable', 'string', 'max:255'],
            'staff.first_name' => ['nullable', 'string', 'max:255'],
            'staff.last_name' => ['nullable', 'string', 'max:255'],
            'staff.date_of_birth' => ['nullable', 'date'],
            'staff.nationality' => ['nullable', 'string', 'max:255'],
            'staff.gender' => ['nullable', 'string', 'max:255'],
            'staff.marital_status' => ['nullable', 'string', 'max:255'],
            'staff.personal_email' => ['nullable', 'email', 'max:255'],
            'staff.work_phone' => ['nullable', 'string', 'max:255'],
            'staff.personal_address' => ['nullable', 'string'],
            'staff.about_me' => ['nullable', 'string'],
            'staff.what_i_do' => ['nullable', 'string'],
            'staff.skills' => ['nullable', 'array'],
            'staff.skills.*' => ['string'],
            'staff.social_media' => ['nullable', 'array'],
            'staff.hobbies' => ['nullable', 'array'],
            'staff.hobbies.*' => ['string'],
            'staff.sponsor_name' => ['nullable', 'string', 'max:255'],
            'staff.civil_id' => ['nullable', 'string', 'max:255'],
            'staff.civil_id_expire_date' => ['nullable', 'date'],
            'staff.passport_number' => ['nullable', 'string', 'max:255'],
            'staff.passport_expire_date' => ['nullable', 'date'],
            'staff.passport_status' => ['nullable', 'string', 'max:255'],
            'staff.contract_type' => ['nullable', 'string', 'max:255'],
            'staff.contract_terms' => ['nullable', 'string', 'max:255'],
            'staff.contract_start_date' => ['nullable', 'date'],
            'staff.contract_expire_date' => ['nullable', 'date'],
            'staff.salary_type' => ['nullable', 'string', 'max:255'],
            'staff.name_as_per_bank' => ['nullable', 'string', 'max:255'],
            'staff.bank_name' => ['nullable', 'string', 'max:255'],
            'staff.swift_code' => ['nullable', 'string', 'max:255'],
            'staff.account_number' => ['nullable', 'string', 'max:255'],
            'staff.emergency_contact_name' => ['nullable', 'string', 'max:255'],
            'staff.emergency_contact_relation' => ['nullable', 'string', 'max:255'],
            'staff.emergency_contact_phone' => ['nullable', 'string', 'max:255'],
            'staff.passport_submission_status' => ['nullable', 'string', 'max:255'],
            'staff.passport_collection_status' => ['nullable', 'string', 'max:255'],
            'user.name' => ['required', 'string', 'max:255'],
            'user.email' => [
                'required',
                'email',
                'max:255',
                Rule::unique('users', 'email')->ignore($userId),
            ],
            'user.mobile' => ['nullable', 'string', 'max:255'],
            'user.role' => ['nullable', Rule::in(['admin', 'supervisor', 'staff'])],
            'user.scope_branch_id' => ['nullable', 'string', 'exists:branches,id'],
            'user.scope_department' => ['nullable', 'string', 'max:255'],
            'user.status' => ['nullable', Rule::in(['Active', 'Inactive', 'Suspended'])],
            'user.device_id' => ['nullable', 'string', 'max:255'],
            'user.profile_image_url' => ['nullable', 'string', 'max:2048'],
            'user.password' => ['nullable', 'string', Password::defaults()],
        ]);
    }

    private function prepareStaffAndUserPayloads(Request $request, ?Staff $staff = null): array
    {
        $staffPayload = $this->normalizeStaffPayload(
            $this->sanitizeStaffPayload($request)
        );
        $userPayload = $this->sanitizeUserPayload($request);

        $branch = Branch::query()->findOrFail($staffPayload['branch_id']);
        $shift = Shift::query()->findOrFail($staffPayload['shift_id']);

        $staffPayload['branch_name'] = $branch->branch_name;
        $staffPayload['shift_name'] = $shift->shift_name;

        $resolvedRole = strtolower(
            $this->normalizeOptionalString($userPayload['role'] ?? null)
            ?? $staff?->user?->role
            ?? 'staff'
        );
        $resolvedStatus = $this->normalizeOptionalString($userPayload['status'] ?? null)
            ?? $this->normalizeOptionalString($staffPayload['status'] ?? null)
            ?? $staff?->status
            ?? 'Active';

        $staffPayload['email'] = $userPayload['email'] ?? $staffPayload['email'];
        $staffPayload['mobile'] = $userPayload['mobile'] ?? $staffPayload['mobile'];
        $staffPayload['status'] = $resolvedStatus;

        $userPayload['name'] = $userPayload['name'] ?? $staffPayload['name'];
        $userPayload['email'] = $userPayload['email'] ?? $staffPayload['email'];
        $userPayload['mobile'] = $userPayload['mobile'] ?? $staffPayload['mobile'];
        $userPayload['role'] = $resolvedRole;
        $userPayload['status'] = $resolvedStatus;

        if ($resolvedRole === 'supervisor') {
            $userPayload['scope_branch_id'] = $staffPayload['branch_id'];
            $userPayload['scope_department'] = $staffPayload['department'];
        } else {
            $userPayload['scope_branch_id'] = null;
            $userPayload['scope_department'] = null;
        }

        return [$staffPayload, $userPayload];
    }

    private function normalizeOptionalString(mixed $value): ?string
    {
        $normalized = trim((string) ($value ?? ''));

        return $normalized !== '' ? $normalized : null;
    }

    private function generateTemporaryPassword(): string
    {
        return Str::upper(Str::random(4))
            .random_int(1000, 9999)
            .Str::lower(Str::random(4));
    }

    private function nextStaffCode(): string
    {
        $seed = Staff::query()->count() + 1;

        do {
            $candidate = 'SHR-'.str_pad((string) $seed, 3, '0', STR_PAD_LEFT);
            $seed++;
        } while (Staff::query()->where('staff_code', $candidate)->exists());

        return $candidate;
    }

    private function staffWritableFields(): array
    {
        return array_values(
            array_diff((new Staff)->getFillable(), ['user_id'])
        );
    }
}
