<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Staff extends Model
{
    protected $table = 'staff';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'staff_code',
        'name',
        'email',
        'mobile',
        'id_card_number',
        'job_title',
        'category',
        'department',
        'branch_id',
        'branch_name',
        'shift_id',
        'shift_name',
        'allowed_location_radius_meters',
        'daily_break_minutes',
        'joining_date',
        'basic_salary',
        'overtime_rate',
        'weekly_off_day',
        'status',
        'profile_image_url',
        'kpi_score',
        'kpi_rating',
        'loan_balance',
        'overtime_hours',
        'today_check_in',
        'today_check_out',
        'today_status',
        'preferred_name',
        'first_name',
        'last_name',
        'date_of_birth',
        'nationality',
        'gender',
        'marital_status',
        'personal_email',
        'work_phone',
        'personal_address',
        'about_me',
        'what_i_do',
        'skills',
        'social_media',
        'hobbies',
        'sponsor_name',
        'civil_id',
        'civil_id_expire_date',
        'passport_number',
        'passport_expire_date',
        'passport_status',
        'contract_type',
        'contract_terms',
        'contract_start_date',
        'contract_expire_date',
        'salary_type',
        'name_as_per_bank',
        'bank_name',
        'swift_code',
        'account_number',
        'emergency_contact_name',
        'emergency_contact_relation',
        'emergency_contact_phone',
        'passport_submission_status',
        'passport_collection_status',
    ];

    protected function casts(): array
    {
        return [
            'joining_date' => 'datetime',
            'date_of_birth' => 'datetime',
            'civil_id_expire_date' => 'datetime',
            'passport_expire_date' => 'datetime',
            'contract_start_date' => 'datetime',
            'contract_expire_date' => 'datetime',
            'skills' => 'array',
            'social_media' => 'array',
            'hobbies' => 'array',
            'allowed_location_radius_meters' => 'float',
            'daily_break_minutes' => 'integer',
            'basic_salary' => 'float',
            'overtime_rate' => 'float',
            'kpi_score' => 'float',
            'loan_balance' => 'float',
            'overtime_hours' => 'float',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
