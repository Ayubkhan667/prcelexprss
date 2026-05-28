<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Branch extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'branch_name',
        'latitude',
        'longitude',
        'allowed_radius',
        'status',
        'address',
        'wifi_ssid',
        'staff_count',
    ];
}
