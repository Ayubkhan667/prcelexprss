<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Shift extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'shift_name',
        'start_time',
        'end_time',
        'standard_hours',
        'grace_minutes',
        'status',
    ];
}
