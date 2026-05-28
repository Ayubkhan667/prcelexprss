<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\ResolvesCurrentStaff;
use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Support\SmartHrPayloads;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class BranchController extends Controller
{
    use ResolvesCurrentStaff;

    public function index(Request $request)
    {
        $query = Branch::query()->orderBy('branch_name');

        if ($this->isSupervisorRequest($request)) {
            if ($response = $this->ensureScopedContext($request)) {
                return $response;
            }

            $query->whereKey($this->currentScopeBranchId($request));
        }

        return response()->json($query->get()->map(
            fn (Branch $branch) => SmartHrPayloads::branch($branch)
        )->values());
    }

    public function show(Request $request, string $id)
    {
        if ($this->isSupervisorRequest($request)) {
            if ($response = $this->ensureScopedContext($request)) {
                return $response;
            }

            if ($id !== $this->currentScopeBranchId($request)) {
                return response()->json([
                    'message' => 'You can only access your assigned branch.',
                ], 403);
            }
        }

        $branch = Branch::query()->findOrFail($id);

        return response()->json(SmartHrPayloads::branch($branch));
    }

    public function store(Request $request)
    {
        $payload = $this->validateBranch($request);

        $payload['id'] = trim((string) ($payload['id'] ?? '')) !== ''
            ? trim((string) $payload['id'])
            : (string) Str::uuid();
        $branch = Branch::query()->create($payload);

        return response()->json(SmartHrPayloads::branch($branch), 201);
    }

    public function update(Request $request, string $id)
    {
        $branch = Branch::query()->findOrFail($id);
        $branch->fill($this->validateBranch($request, updating: true));
        $branch->save();

        return response()->json(SmartHrPayloads::branch($branch));
    }

    private function validateBranch(Request $request, bool $updating = false): array
    {
        return $request->validate([
            'id' => [$updating ? 'sometimes' : 'nullable', 'string', 'max:255'],
            'branch_name' => [$updating ? 'sometimes' : 'required', 'string', 'max:255'],
            'latitude' => [$updating ? 'sometimes' : 'required', 'numeric', 'between:-90,90'],
            'longitude' => [$updating ? 'sometimes' : 'required', 'numeric', 'between:-180,180'],
            'allowed_radius' => ['nullable', 'numeric', 'min:0'],
            'status' => ['nullable', Rule::in(['Active', 'Inactive'])],
            'address' => ['nullable', 'string'],
            'wifi_ssid' => ['nullable', 'string', 'max:255'],
            'staff_count' => ['nullable', 'integer', 'min:0'],
        ]);
    }
}
