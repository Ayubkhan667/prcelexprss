<?php

namespace App\Support;

use App\Models\Attendance;
use App\Models\Branch;
use App\Models\Shift;
use App\Models\Staff;
use App\Models\User;
use Carbon\CarbonInterface;

class SmartHrPayloads
{
    public static function user(User $user): array
    {
        return [
            'id' => (string) $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'mobile' => $user->mobile,
            'role' => $user->role,
            'scope_branch_id' => $user->scope_branch_id,
            'scope_department' => $user->scope_department,
            'status' => $user->status,
            'device_id' => $user->device_id,
            'profile_image_url' => $user->profile_image_url,
            'created_at' => self::iso($user->created_at),
        ];
    }

    public static function branch(Branch $branch): array
    {
        return [
            'id' => $branch->id,
            'branch_name' => $branch->branch_name,
            'latitude' => (float) $branch->latitude,
            'longitude' => (float) $branch->longitude,
            'allowed_radius' => (float) $branch->allowed_radius,
            'status' => $branch->status,
            'address' => $branch->address,
            'wifi_ssid' => $branch->wifi_ssid,
            'staff_count' => $branch->staff_count,
        ];
    }

    public static function shift(Shift $shift): array
    {
        return [
            'id' => $shift->id,
            'shift_name' => $shift->shift_name,
            'start_time' => $shift->start_time,
            'end_time' => $shift->end_time,
            'standard_hours' => (float) $shift->standard_hours,
            'grace_minutes' => (int) $shift->grace_minutes,
            'status' => $shift->status,
        ];
    }

    public static function staff(Staff $staff): array
    {
        return [
            'id' => $staff->id,
            'user_id' => $staff->user_id !== null ? (string) $staff->user_id : '',
            'staff_code' => $staff->staff_code,
            'name' => $staff->name,
            'email' => $staff->email,
            'mobile' => $staff->mobile,
            'id_card_number' => $staff->id_card_number,
            'job_title' => $staff->job_title,
            'category' => $staff->category,
            'department' => $staff->department,
            'branch_id' => $staff->branch_id,
            'branch_name' => $staff->branch_name,
            'shift_id' => $staff->shift_id,
            'shift_name' => $staff->shift_name,
            'joining_date' => self::iso($staff->joining_date),
            'basic_salary' => (float) $staff->basic_salary,
            'overtime_rate' => (float) $staff->overtime_rate,
            'weekly_off_day' => $staff->weekly_off_day,
            'status' => $staff->status,
            'profile_image_url' => $staff->profile_image_url,
            'kpi_score' => $staff->kpi_score !== null ? (float) $staff->kpi_score : null,
            'kpi_rating' => $staff->kpi_rating,
            'loan_balance' => $staff->loan_balance !== null ? (float) $staff->loan_balance : null,
            'overtime_hours' => $staff->overtime_hours !== null ? (float) $staff->overtime_hours : null,
            'today_check_in' => $staff->today_check_in,
            'today_check_out' => $staff->today_check_out,
            'today_status' => $staff->today_status,
            'preferred_name' => $staff->preferred_name,
            'first_name' => $staff->first_name,
            'last_name' => $staff->last_name,
            'date_of_birth' => self::iso($staff->date_of_birth),
            'nationality' => $staff->nationality,
            'gender' => $staff->gender,
            'marital_status' => $staff->marital_status,
            'personal_email' => $staff->personal_email,
            'work_phone' => $staff->work_phone,
            'personal_address' => $staff->personal_address,
            'about_me' => $staff->about_me,
            'what_i_do' => $staff->what_i_do,
            'skills' => $staff->skills,
            'social_media' => $staff->social_media,
            'hobbies' => $staff->hobbies,
            'sponsor_name' => $staff->sponsor_name,
            'civil_id' => $staff->civil_id,
            'civil_id_expire_date' => self::iso($staff->civil_id_expire_date),
            'passport_number' => $staff->passport_number,
            'passport_expire_date' => self::iso($staff->passport_expire_date),
            'passport_status' => $staff->passport_status,
            'contract_type' => $staff->contract_type,
            'contract_terms' => $staff->contract_terms,
            'contract_start_date' => self::iso($staff->contract_start_date),
            'contract_expire_date' => self::iso($staff->contract_expire_date),
            'salary_type' => $staff->salary_type,
            'name_as_per_bank' => $staff->name_as_per_bank,
            'bank_name' => $staff->bank_name,
            'swift_code' => $staff->swift_code,
            'account_number' => $staff->account_number,
            'emergency_contact_name' => $staff->emergency_contact_name,
            'emergency_contact_relation' => $staff->emergency_contact_relation,
            'emergency_contact_phone' => $staff->emergency_contact_phone,
            'passport_submission_status' => $staff->passport_submission_status,
            'passport_collection_status' => $staff->passport_collection_status,
        ];
    }

    public static function attendance(Attendance $attendance): array
    {
        return [
            'id' => $attendance->id,
            'staff_id' => $attendance->staff_id,
            'staff_name' => $attendance->staff_name,
            'staff_code' => $attendance->staff_code,
            'date' => self::iso($attendance->date),
            'check_in_time' => self::iso($attendance->check_in_time),
            'check_out_time' => self::iso($attendance->check_out_time),
            'check_in_latitude' => $attendance->check_in_latitude !== null ? (float) $attendance->check_in_latitude : null,
            'check_in_longitude' => $attendance->check_in_longitude !== null ? (float) $attendance->check_in_longitude : null,
            'check_out_latitude' => $attendance->check_out_latitude !== null ? (float) $attendance->check_out_latitude : null,
            'check_out_longitude' => $attendance->check_out_longitude !== null ? (float) $attendance->check_out_longitude : null,
            'working_hours' => (float) $attendance->working_hours,
            'overtime_hours' => (float) $attendance->overtime_hours,
            'late_minutes' => (int) $attendance->late_minutes,
            'early_checkout_minutes' => (int) $attendance->early_checkout_minutes,
            'status' => $attendance->status,
            'selfie_check_in_url' => $attendance->selfie_check_in_url,
            'selfie_check_out_url' => $attendance->selfie_check_out_url,
            'device_id' => $attendance->device_id,
            'required_wifi_ssid' => $attendance->required_wifi_ssid,
            'check_in_wifi_ssid' => $attendance->check_in_wifi_ssid,
            'check_out_wifi_ssid' => $attendance->check_out_wifi_ssid,
            'is_location_valid' => (bool) $attendance->is_location_valid,
            'is_mock_gps' => (bool) $attendance->is_mock_gps,
            'paused_minutes' => (int) $attendance->paused_minutes,
            'pause_started_at' => self::iso($attendance->pause_started_at),
            'duty_status' => $attendance->duty_status,
            'approval_status' => $attendance->approval_status,
            'notes' => $attendance->notes,
            'created_at' => self::iso($attendance->created_at),
        ];
    }

    private static function iso(mixed $value): ?string
    {
        return $value instanceof CarbonInterface ? $value->toIso8601String() : null;
    }
}
