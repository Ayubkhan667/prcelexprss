<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $table = 'attendance';

    protected $fillable = [
        'id',
        'staff_id',
        'staff_name',
        'staff_code',
        'date',
        'check_in_time',
        'check_out_time',
        'check_in_latitude',
        'check_in_longitude',
        'check_out_latitude',
        'check_out_longitude',
        'working_hours',
        'overtime_hours',
        'late_minutes',
        'early_checkout_minutes',
        'status',
        'selfie_check_in_url',
        'selfie_check_out_url',
        'device_id',
        'required_wifi_ssid',
        'check_in_wifi_ssid',
        'check_out_wifi_ssid',
        'is_location_valid',
        'is_mock_gps',
        'paused_minutes',
        'pause_started_at',
        'duty_status',
        'approval_status',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'datetime',
            'check_in_time' => 'datetime',
            'check_out_time' => 'datetime',
            'check_in_latitude' => 'float',
            'check_in_longitude' => 'float',
            'check_out_latitude' => 'float',
            'check_out_longitude' => 'float',
            'working_hours' => 'float',
            'overtime_hours' => 'float',
            'late_minutes' => 'integer',
            'early_checkout_minutes' => 'integer',
            'is_location_valid' => 'boolean',
            'is_mock_gps' => 'boolean',
            'paused_minutes' => 'integer',
            'pause_started_at' => 'datetime',
        ];
    }
}
