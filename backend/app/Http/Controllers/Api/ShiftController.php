<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Shift;
use App\Support\SmartHrPayloads;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ShiftController extends Controller
{
    public function index()
    {
        return response()->json(
            Shift::query()
                ->orderBy('shift_name')
                ->get()
                ->map(fn (Shift $shift) => SmartHrPayloads::shift($shift))
                ->values()
        );
    }

    public function show(string $id)
    {
        $shift = Shift::query()->findOrFail($id);

        return response()->json(SmartHrPayloads::shift($shift));
    }

    public function store(Request $request)
    {
        $payload = $this->validateShift($request);

        $payload['id'] = trim((string) ($payload['id'] ?? '')) !== ''
            ? trim((string) $payload['id'])
            : (string) Str::uuid();
        $shift = Shift::query()->create($payload);

        return response()->json(SmartHrPayloads::shift($shift), 201);
    }

    public function update(Request $request, string $id)
    {
        $shift = Shift::query()->findOrFail($id);
        $shift->fill($this->validateShift($request, updating: true));
        $shift->save();

        return response()->json(SmartHrPayloads::shift($shift));
    }

    private function validateShift(Request $request, bool $updating = false): array
    {
        return $request->validate([
            'id' => [$updating ? 'sometimes' : 'nullable', 'string', 'max:255'],
            'shift_name' => [$updating ? 'sometimes' : 'required', 'string', 'max:255'],
            'start_time' => [$updating ? 'sometimes' : 'required', 'date_format:H:i'],
            'end_time' => [$updating ? 'sometimes' : 'required', 'date_format:H:i'],
            'standard_hours' => ['nullable', 'numeric', 'min:0', 'max:24'],
            'grace_minutes' => ['nullable', 'integer', 'min:0', 'max:1440'],
            'status' => ['nullable', Rule::in(['Active', 'Inactive'])],
        ]);
    }
}
