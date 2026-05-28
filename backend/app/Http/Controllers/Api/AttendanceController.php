<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\ResolvesCurrentStaff;
use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Branch;
use App\Models\Shift;
use App\Models\Staff;
use App\Support\AuditLogger;
use App\Support\SmartHrPayloads;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AttendanceController extends Controller
{
    use ResolvesCurrentStaff;

    public function index(Request $request)
    {
        if ($response = $this->ensureScopedContext($request)) {
            return $response;
        }

        $query = Attendance::query()->orderByDesc('date');

        if ($this->isStaffRequest($request)) {
            if ($response = $this->ensureOwnStaffId($request, $request->input('staff_id'))) {
                return $response;
            }
        } elseif ($this->isSupervisorRequest($request) && $request->filled('staff_id')) {
            if ($response = $this->ensureAccessibleStaffId($request, $request->string('staff_id'))) {
                return $response;
            }
        }

        if ($request->filled('staff_id')) {
            $query->where('staff_id', $request->string('staff_id'));
        }

        if ($response = $this->applyStaffScope($request, $query)) {
            return $response;
        }

        if ($request->filled('date')) {
            $targetDate = Carbon::parse($request->string('date'));
            $query->whereDate('date', $targetDate->toDateString());
        }

        if ($request->filled('from_date')) {
            $query->whereDate('date', '>=', Carbon::parse($request->string('from_date'))->toDateString());
        }

        if ($request->filled('to_date')) {
            $query->whereDate('date', '<=', Carbon::parse($request->string('to_date'))->toDateString());
        }

        return response()->json(
            $query->get()->map(fn (Attendance $attendance) => SmartHrPayloads::attendance($attendance))->values()
        );
    }

    public function today(Request $request)
    {
        $request->validate([
            'staff_id' => ['required', 'string'],
            'date' => ['nullable', 'date'],
        ]);

        $date = $request->filled('date')
            ? Carbon::parse($request->string('date'))
            : now();

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $request->string('staff_id'),
            'You can only access attendance within your assigned branch.',
        )) {
            return $response;
        }

        $attendance = Attendance::query()
            ->where('staff_id', $request->string('staff_id'))
            ->whereDate('date', $date->toDateString())
            ->first();

        if (! $attendance) {
            return response()->json(['message' => 'Attendance not found.'], 404);
        }

        return response()->json(SmartHrPayloads::attendance($attendance));
    }

    public function store(Request $request)
    {
        $payload = $this->validateManualAttendancePayload($request);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $payload['staff_id'],
            'You can only manage attendance within your assigned branch.',
        )) {
            return $response;
        }

        $staff = Staff::query()->findOrFail($payload['staff_id']);
        $attendance = new Attendance($this->manualAttendancePayload($payload, $staff));
        $attendance->save();
        $this->syncStaffSnapshot($attendance);

        return response()->json(SmartHrPayloads::attendance($attendance), 201);
    }

    public function update(Request $request, string $id)
    {
        $attendance = Attendance::query()->findOrFail($id);
        $payload = $this->validateManualAttendancePayload($request, $attendance);
        $targetStaffId = $payload['staff_id'] ?? $attendance->staff_id;

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $targetStaffId,
            'You can only manage attendance within your assigned branch.',
        )) {
            return $response;
        }

        $staff = Staff::query()->findOrFail($targetStaffId);
        $attendance->fill($this->manualAttendancePayload($payload, $staff, $attendance));
        $attendance->save();
        $this->syncStaffSnapshot($attendance);

        return response()->json(SmartHrPayloads::attendance($attendance));
    }

    public function checkIn(Request $request)
    {
        $request->validate([
            'staff_id' => ['required', 'string'],
            'shift_id' => ['required', 'string'],
            'event_time' => ['required', 'date'],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
            'device_id' => ['required', 'string'],
            'wifi_ssid' => ['required', 'string'],
            'selfie' => ['nullable', 'image', 'max:4096'],
        ]);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $request->string('staff_id'),
            'You can only manage attendance within your assigned branch.',
        )) {
            return $response;
        }

        $staff = Staff::query()->findOrFail($request->string('staff_id'));
        $branch = Branch::query()->findOrFail($staff->branch_id);
        $shift = Shift::query()->findOrFail($request->string('shift_id'));
        $checkInTime = Carbon::parse($request->string('event_time'));
        $existing = $this->findAttendanceForDate($staff->id, $checkInTime);

        if ($existing?->check_in_time) {
            $message = $existing->check_out_time
                ? 'Attendance is already completed for today.'
                : 'You are already checked in today.';

            return response()->json(['message' => $message], 409);
        }

        if ($response = $this->ensureAttendanceAccess($request, $branch)) {
            return $response;
        }

        $shiftStart = $this->mergeDateWithTime($checkInTime, $shift->start_time);
        $lateMinutes = max(0, $shiftStart->diffInMinutes($checkInTime, false));
        $status = $lateMinutes > (int) $shift->grace_minutes ? 'Late' : 'Present';
        $selfieUrl = $this->storeSelfie($request);

        $attendance = $existing ?? new Attendance;
        $attendance->fill([
            'id' => $existing?->id ?? 'att_'.$staff->id.'_'.$checkInTime->timestamp,
            'staff_id' => $staff->id,
            'staff_name' => $staff->name,
            'staff_code' => $staff->staff_code,
            'date' => $checkInTime->copy()->startOfDay(),
            'check_in_time' => $checkInTime,
            'check_out_time' => null,
            'check_in_latitude' => (float) $request->input('latitude'),
            'check_in_longitude' => (float) $request->input('longitude'),
            'check_out_latitude' => null,
            'check_out_longitude' => null,
            'working_hours' => 0,
            'overtime_hours' => 0,
            'late_minutes' => $lateMinutes,
            'early_checkout_minutes' => 0,
            'status' => $status,
            'selfie_check_in_url' => $selfieUrl,
            'selfie_check_out_url' => null,
            'device_id' => $request->string('device_id'),
            'required_wifi_ssid' => $this->normalizeWifiSsid($branch->wifi_ssid),
            'check_in_wifi_ssid' => $this->normalizeWifiSsid($request->input('wifi_ssid')),
            'check_out_wifi_ssid' => null,
            'is_location_valid' => true,
            'is_mock_gps' => false,
            'paused_minutes' => 0,
            'pause_started_at' => null,
            'duty_status' => 'Active',
            'approval_status' => 'Auto',
            'notes' => $this->combineNotes($request->input('notes')),
        ]);
        $attendance->save();
        $this->syncStaffSnapshot($attendance);

        return response()->json(SmartHrPayloads::attendance($attendance));
    }

    public function checkOut(Request $request)
    {
        $request->validate([
            'staff_id' => ['required', 'string'],
            'shift_id' => ['required', 'string'],
            'event_time' => ['required', 'date'],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
            'device_id' => ['required', 'string'],
            'wifi_ssid' => ['required', 'string'],
            'selfie' => ['nullable', 'image', 'max:4096'],
        ]);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $request->string('staff_id'),
            'You can only manage attendance within your assigned branch.',
        )) {
            return $response;
        }

        $staff = Staff::query()->findOrFail($request->string('staff_id'));
        $branch = Branch::query()->findOrFail($staff->branch_id);
        $shift = Shift::query()->findOrFail($request->string('shift_id'));
        $checkOutTime = Carbon::parse($request->string('event_time'));
        $attendance = $this->findAttendanceForDate($staff->id, $checkOutTime);

        if (! $attendance || ! $attendance->check_in_time) {
            return response()->json(['message' => 'Attendance not found.'], 404);
        }

        if ($attendance->check_out_time) {
            return response()->json(['message' => 'You are already checked out for today.'], 409);
        }

        if ($response = $this->ensureAttendanceAccess($request, $branch)) {
            return $response;
        }

        $livePausedMinutes = 0;
        if ($attendance->pause_started_at instanceof Carbon && $checkOutTime->greaterThan($attendance->pause_started_at)) {
            $livePausedMinutes = $attendance->pause_started_at->diffInMinutes($checkOutTime);
        }

        $pausedMinutes = (int) $attendance->paused_minutes + $livePausedMinutes;
        $workedMinutes = max(0, Carbon::parse($attendance->check_in_time)->diffInMinutes($checkOutTime) - $pausedMinutes);
        $workingHours = round($workedMinutes / 60, 2);
        $overtimeHours = max(0, round($workingHours - (float) $shift->standard_hours, 2));
        $shiftEnd = $this->mergeDateWithTime($checkOutTime, $shift->end_time);
        $earlyCheckoutMinutes = $shiftEnd->greaterThan($checkOutTime)
            ? $shiftEnd->diffInMinutes($checkOutTime)
            : 0;

        if ($attendance->late_minutes > (int) $shift->grace_minutes) {
            $status = 'Late';
        } elseif ($earlyCheckoutMinutes > 0) {
            $status = 'Early Out';
        } elseif ($overtimeHours > 0) {
            $status = 'Overtime';
        } else {
            $status = 'Present';
        }

        $attendance->fill([
            'check_out_time' => $checkOutTime,
            'check_out_latitude' => (float) $request->input('latitude'),
            'check_out_longitude' => (float) $request->input('longitude'),
            'working_hours' => $workingHours,
            'overtime_hours' => $overtimeHours,
            'early_checkout_minutes' => $earlyCheckoutMinutes,
            'status' => $status,
            'selfie_check_out_url' => $this->storeSelfie($request),
            'device_id' => $request->string('device_id'),
            'required_wifi_ssid' => $this->normalizeWifiSsid($branch->wifi_ssid),
            'check_out_wifi_ssid' => $this->normalizeWifiSsid($request->input('wifi_ssid')),
            'is_location_valid' => true,
            'is_mock_gps' => false,
            'paused_minutes' => $pausedMinutes,
            'pause_started_at' => null,
            'duty_status' => 'Completed',
            'approval_status' => 'Auto',
            'notes' => $this->combineNotes($attendance->notes, $request->input('notes')),
        ]);
        $attendance->save();
        $this->syncStaffSnapshot($attendance);

        return response()->json(SmartHrPayloads::attendance($attendance));
    }

    public function pauseDuty(Request $request, string $id)
    {
        $request->validate([
            'event_time' => ['required', 'date'],
            'reason' => ['nullable', 'string'],
        ]);

        $attendance = Attendance::query()->findOrFail($id);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $attendance->staff_id,
            'You can only manage attendance within your assigned branch.',
        )) {
            return $response;
        }

        if (! $attendance->check_in_time || $attendance->check_out_time) {
            return response()->json(['message' => 'Only active duty can be paused.'], 422);
        }

        if ($attendance->duty_status === 'Paused' && $attendance->pause_started_at !== null) {
            return response()->json(SmartHrPayloads::attendance($attendance));
        }

        $pausedAt = Carbon::parse($request->string('event_time'));
        if ($pausedAt->lessThan(Carbon::parse($attendance->check_in_time))) {
            return response()->json(['message' => 'Pause time cannot be before check-in time.'], 422);
        }

        $attendance->fill([
            'duty_status' => 'Paused',
            'pause_started_at' => $pausedAt,
            'notes' => $this->combineNotes($attendance->notes, $request->input('reason')),
        ]);
        $attendance->save();
        $this->syncStaffSnapshot($attendance);

        return response()->json(SmartHrPayloads::attendance($attendance));
    }

    public function resumeDuty(Request $request, string $id)
    {
        $request->validate([
            'event_time' => ['required', 'date'],
            'reason' => ['nullable', 'string'],
        ]);

        $attendance = Attendance::query()->findOrFail($id);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $attendance->staff_id,
            'You can only manage attendance within your assigned branch.',
        )) {
            return $response;
        }

        if (! $attendance->check_in_time || $attendance->check_out_time) {
            return response()->json(['message' => 'Only active duty can be resumed.'], 422);
        }

        if ($attendance->pause_started_at === null || $attendance->duty_status !== 'Paused') {
            return response()->json(SmartHrPayloads::attendance($attendance));
        }

        $resumedAt = Carbon::parse($request->string('event_time'));
        if ($resumedAt->lessThan($attendance->pause_started_at)) {
            return response()->json(['message' => 'Resume time cannot be before pause time.'], 422);
        }

        $pausedMinutes = (int) $attendance->paused_minutes
            + $attendance->pause_started_at->diffInMinutes($resumedAt);

        $attendance->fill([
            'paused_minutes' => $pausedMinutes,
            'pause_started_at' => null,
            'duty_status' => 'Active',
            'notes' => $this->combineNotes($attendance->notes, $request->input('reason')),
        ]);
        $attendance->save();
        $this->syncStaffSnapshot($attendance);

        return response()->json(SmartHrPayloads::attendance($attendance));
    }

    public function updateOvertimeApproval(string $id, Request $request)
    {
        $request->validate([
            'status' => ['required', Rule::in(['Pending', 'Approved', 'Rejected'])],
        ]);

        $attendance = Attendance::query()->findOrFail($id);

        if ($response = $this->ensureAccessibleStaffId(
            $request,
            $attendance->staff_id,
            'You can only approve overtime within your assigned branch.',
        )) {
            return $response;
        }

        $attendance->approval_status = $request->string('status');
        $attendance->save();
        $auditAction = match ($attendance->approval_status) {
            'Approved' => 'overtime_approve',
            'Rejected' => 'overtime_reject',
            default => 'overtime_pending',
        };

        AuditLogger::record($request, [
            'action' => $auditAction,
            'title' => 'Overtime '.$attendance->approval_status,
            'description' => $attendance->overtime_hours.'h overtime '.$attendance->approval_status.' for '.$attendance->staff_name.'.',
            'target_type' => 'attendance',
            'target_id' => $attendance->id,
            'target_name' => $attendance->staff_name,
            'metadata' => [
                'staff_id' => $attendance->staff_id,
                'date' => $attendance->date,
                'overtime_hours' => $attendance->overtime_hours,
                'approval_status' => $attendance->approval_status,
            ],
        ]);

        return response()->json(SmartHrPayloads::attendance($attendance));
    }

    private function ensureAttendanceAccess(Request $request, Branch $branch)
    {
        $requiredWifi = $this->normalizeWifiSsid($branch->wifi_ssid);
        $currentWifi = $this->normalizeWifiSsid($request->input('wifi_ssid'));

        if ($requiredWifi === null) {
            return response()->json([
                'message' => "Office Wi-Fi is not configured for {$branch->branch_name}.",
            ], 422);
        }

        if ($currentWifi === null || ! $this->wifiMatches($requiredWifi, $currentWifi)) {
            return response()->json([
                'message' => $currentWifi === null
                    ? "Connect to {$requiredWifi} to continue."
                    : "Connected Wi-Fi does not match {$requiredWifi}.",
            ], 422);
        }

        if ($this->boolean($request->input('is_mock_gps', false))) {
            return response()->json([
                'message' => 'Mock GPS detected. Attendance is blocked on spoofed location.',
            ], 422);
        }

        $distance = $this->distanceMeters(
            (float) $request->input('latitude'),
            (float) $request->input('longitude'),
            (float) $branch->latitude,
            (float) $branch->longitude,
        );

        $isInsideGeofence = $distance <= (float) $branch->allowed_radius;
        $clientLocationValid = $this->boolean($request->input('is_location_valid', true));

        if (! $clientLocationValid || ! $isInsideGeofence) {
            return response()->json([
                'message' => "You are outside {$branch->branch_name} geofence ({$distance}m away).",
            ], 422);
        }

        return null;
    }

    private function findAttendanceForDate(string $staffId, Carbon $date): ?Attendance
    {
        return Attendance::query()
            ->where('staff_id', $staffId)
            ->whereDate('date', $date->toDateString())
            ->first();
    }

    private function mergeDateWithTime(Carbon $date, string $time): Carbon
    {
        [$hours, $minutes] = array_pad(explode(':', $time), 2, '0');

        return $date->copy()->setTime((int) $hours, (int) $minutes);
    }

    private function boolean(mixed $value): bool
    {
        return filter_var($value, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? false;
    }

    private function storeSelfie(Request $request): ?string
    {
        if (! $request->hasFile('selfie')) {
            return null;
        }

        $path = $request->file('selfie')->store('selfies', 'public');

        return url(Storage::url($path));
    }

    private function syncStaffSnapshot(Attendance $attendance): void
    {
        $staff = Staff::query()->find($attendance->staff_id);

        if (! $staff) {
            return;
        }

        $todayStatus = $attendance->status;
        if ($attendance->check_in_time && ! $attendance->check_out_time && $attendance->duty_status === 'Paused') {
            $todayStatus = 'Duty Paused';
        }

        $staff->update([
            'today_check_in' => $attendance->check_in_time?->format('H:i'),
            'today_check_out' => $attendance->check_out_time?->format('H:i'),
            'today_status' => $todayStatus,
        ]);
    }

    private function normalizeWifiSsid(mixed $value): ?string
    {
        if (! is_string($value)) {
            return null;
        }

        $normalized = trim($value);
        if ($normalized === '' || strtolower($normalized) === '<unknown ssid>') {
            return null;
        }

        if (
            (str_starts_with($normalized, '"') && str_ends_with($normalized, '"'))
            || (str_starts_with($normalized, "'") && str_ends_with($normalized, "'"))
        ) {
            $normalized = substr($normalized, 1, -1);
        }

        $normalized = trim($normalized);

        return $normalized === '' ? null : $normalized;
    }

    private function wifiMatches(string $requiredWifi, string $currentWifi): bool
    {
        return mb_strtolower($requiredWifi) === mb_strtolower($currentWifi);
    }

    private function distanceMeters(float $latitudeA, float $longitudeA, float $latitudeB, float $longitudeB): int
    {
        $earthRadius = 6371000.0;
        $deltaLatitude = deg2rad($latitudeB - $latitudeA);
        $deltaLongitude = deg2rad($longitudeB - $longitudeA);

        $a = sin($deltaLatitude / 2) ** 2
            + cos(deg2rad($latitudeA)) * cos(deg2rad($latitudeB)) * sin($deltaLongitude / 2) ** 2;
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return (int) round($earthRadius * $c);
    }

    private function combineNotes(?string ...$notes): ?string
    {
        $segments = array_values(array_filter(array_map(
            static fn (?string $note) => $note !== null && trim($note) !== '' ? trim($note) : null,
            $notes,
        )));

        return $segments === [] ? null : implode("\n", $segments);
    }

    private function validateManualAttendancePayload(Request $request, ?Attendance $existing = null): array
    {
        $rules = [
            'id' => [$existing ? 'sometimes' : 'nullable', 'string', 'max:255'],
            'staff_id' => [$existing ? 'sometimes' : 'required', 'string', 'exists:staff,id'],
            'date' => [$existing ? 'sometimes' : 'required', 'date'],
            'check_in_time' => ['nullable', 'date'],
            'check_out_time' => ['nullable', 'date'],
            'check_in_latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'check_in_longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'check_out_latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'check_out_longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'working_hours' => ['nullable', 'numeric', 'min:0'],
            'overtime_hours' => ['nullable', 'numeric', 'min:0'],
            'late_minutes' => ['nullable', 'integer', 'min:0'],
            'early_checkout_minutes' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', Rule::in([
                'Present',
                'Absent',
                'Late',
                'On Leave',
                'Half Day',
                'Holiday',
                'Early Out',
                'Overtime',
            ])],
            'selfie_check_in_url' => ['nullable', 'string', 'max:2048'],
            'selfie_check_out_url' => ['nullable', 'string', 'max:2048'],
            'device_id' => ['nullable', 'string', 'max:255'],
            'required_wifi_ssid' => ['nullable', 'string', 'max:255'],
            'check_in_wifi_ssid' => ['nullable', 'string', 'max:255'],
            'check_out_wifi_ssid' => ['nullable', 'string', 'max:255'],
            'is_location_valid' => ['nullable', 'boolean'],
            'is_mock_gps' => ['nullable', 'boolean'],
            'paused_minutes' => ['nullable', 'integer', 'min:0'],
            'pause_started_at' => ['nullable', 'date'],
            'duty_status' => ['nullable', Rule::in(['Active', 'Paused', 'Completed'])],
            'approval_status' => ['nullable', Rule::in(['Auto', 'Pending', 'Approved', 'Rejected'])],
            'notes' => ['nullable', 'string'],
        ];

        $validator = Validator::make($request->all(), $rules);
        $validator->after(function ($validator) use ($request, $existing) {
            if (
                $validator->errors()->has('check_in_time')
                || $validator->errors()->has('check_out_time')
                || $validator->errors()->has('pause_started_at')
            ) {
                return;
            }

            $checkInTime = $request->exists('check_in_time')
                ? $this->parseOptionalCarbon($request->input('check_in_time'))
                : $existing?->check_in_time;
            $checkOutTime = $request->exists('check_out_time')
                ? $this->parseOptionalCarbon($request->input('check_out_time'))
                : $existing?->check_out_time;
            $pauseStartedAt = $request->exists('pause_started_at')
                ? $this->parseOptionalCarbon($request->input('pause_started_at'))
                : $existing?->pause_started_at;
            $dutyStatus = $request->input('duty_status', $existing?->duty_status);

            if ($checkInTime && $checkOutTime && $checkOutTime->lessThan($checkInTime)) {
                $validator->errors()->add('check_out_time', 'Check-out time cannot be before check-in time.');
            }

            if ($pauseStartedAt && ! $checkInTime) {
                $validator->errors()->add('pause_started_at', 'Pause time requires an active check-in record.');
            }

            if ($pauseStartedAt && $checkInTime && $pauseStartedAt->lessThan($checkInTime)) {
                $validator->errors()->add('pause_started_at', 'Pause time cannot be before check-in time.');
            }

            if ($dutyStatus === 'Paused' && $pauseStartedAt === null) {
                $validator->errors()->add('pause_started_at', 'Paused duty requires a pause start time.');
            }
        });

        return $validator->validate();
    }

    private function manualAttendancePayload(
        array $payload,
        Staff $staff,
        ?Attendance $existing = null,
    ): array {
        $date = array_key_exists('date', $payload)
            ? Carbon::parse($payload['date'])->startOfDay()
            : $existing?->date;
        $checkInTime = array_key_exists('check_in_time', $payload)
            ? $this->parseOptionalCarbon($payload['check_in_time'])
            : $existing?->check_in_time;
        $checkOutTime = array_key_exists('check_out_time', $payload)
            ? $this->parseOptionalCarbon($payload['check_out_time'])
            : $existing?->check_out_time;
        $pauseStartedAt = array_key_exists('pause_started_at', $payload)
            ? $this->parseOptionalCarbon($payload['pause_started_at'])
            : $existing?->pause_started_at;
        $dutyStatus = $payload['duty_status']
            ?? $this->inferDutyStatus($checkInTime, $checkOutTime, $pauseStartedAt, $existing?->duty_status);

        return [
            'id' => $existing?->id
                ?? (trim((string) ($payload['id'] ?? '')) !== '' ? trim((string) $payload['id']) : 'att_'.Str::uuid()),
            'staff_id' => $staff->id,
            'staff_name' => $staff->name,
            'staff_code' => $staff->staff_code,
            'date' => $date,
            'check_in_time' => $checkInTime,
            'check_out_time' => $checkOutTime,
            'check_in_latitude' => $this->pickValue($payload, 'check_in_latitude', $existing?->check_in_latitude),
            'check_in_longitude' => $this->pickValue($payload, 'check_in_longitude', $existing?->check_in_longitude),
            'check_out_latitude' => $this->pickValue($payload, 'check_out_latitude', $existing?->check_out_latitude),
            'check_out_longitude' => $this->pickValue($payload, 'check_out_longitude', $existing?->check_out_longitude),
            'working_hours' => $this->pickValue($payload, 'working_hours', $existing?->working_hours, 0),
            'overtime_hours' => $this->pickValue($payload, 'overtime_hours', $existing?->overtime_hours, 0),
            'late_minutes' => $this->pickValue($payload, 'late_minutes', $existing?->late_minutes, 0),
            'early_checkout_minutes' => $this->pickValue($payload, 'early_checkout_minutes', $existing?->early_checkout_minutes, 0),
            'status' => $payload['status'] ?? $existing?->status ?? 'Absent',
            'selfie_check_in_url' => $this->pickValue($payload, 'selfie_check_in_url', $existing?->selfie_check_in_url),
            'selfie_check_out_url' => $this->pickValue($payload, 'selfie_check_out_url', $existing?->selfie_check_out_url),
            'device_id' => $this->pickValue($payload, 'device_id', $existing?->device_id),
            'required_wifi_ssid' => $this->pickValue($payload, 'required_wifi_ssid', $existing?->required_wifi_ssid),
            'check_in_wifi_ssid' => $this->pickValue($payload, 'check_in_wifi_ssid', $existing?->check_in_wifi_ssid),
            'check_out_wifi_ssid' => $this->pickValue($payload, 'check_out_wifi_ssid', $existing?->check_out_wifi_ssid),
            'is_location_valid' => $this->pickValue($payload, 'is_location_valid', $existing?->is_location_valid, true),
            'is_mock_gps' => $this->pickValue($payload, 'is_mock_gps', $existing?->is_mock_gps, false),
            'paused_minutes' => $this->pickValue($payload, 'paused_minutes', $existing?->paused_minutes, 0),
            'pause_started_at' => $pauseStartedAt,
            'duty_status' => $dutyStatus,
            'approval_status' => $payload['approval_status'] ?? $existing?->approval_status ?? 'Auto',
            'notes' => $this->pickValue($payload, 'notes', $existing?->notes),
        ];
    }

    private function inferDutyStatus(
        ?Carbon $checkInTime,
        ?Carbon $checkOutTime,
        ?Carbon $pauseStartedAt,
        ?string $existingDutyStatus = null,
    ): string {
        if ($pauseStartedAt !== null && $checkOutTime === null) {
            return 'Paused';
        }

        if ($checkInTime !== null && $checkOutTime === null) {
            return 'Active';
        }

        if ($checkOutTime !== null) {
            return 'Completed';
        }

        return $existingDutyStatus ?? 'Completed';
    }

    private function pickValue(array $payload, string $key, mixed $existing = null, mixed $default = null): mixed
    {
        if (array_key_exists($key, $payload)) {
            return $payload[$key];
        }

        if ($existing !== null) {
            return $existing;
        }

        return $default;
    }

    private function parseOptionalCarbon(mixed $value): ?Carbon
    {
        if ($value === null || $value === '') {
            return null;
        }

        return Carbon::parse($value);
    }
}
