<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\SmartHrPayloads;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\NewAccessToken;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'identifier' => ['nullable', 'string'],
            'email' => ['nullable', 'string'],
            'mobile' => ['nullable', 'string'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:255'],
            'device_id' => ['nullable', 'string', 'max:255'],
        ]);
        $identifier = trim((string) (
            $credentials['identifier']
            ?? $credentials['email']
            ?? $credentials['mobile']
            ?? ''
        ));

        if ($identifier === '') {
            return response()->json([
                'message' => 'The identifier field is required.',
                'errors' => [
                    'identifier' => ['The identifier field is required.'],
                ],
            ], 422);
        }

        $user = User::query()
            ->where('email', $identifier)
            ->orWhere('mobile', $identifier)
            ->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            return response()->json([
                'message' => 'Invalid credentials.',
            ], 401);
        }

        if (strtolower((string) $user->status) !== 'active') {
            return response()->json([
                'message' => 'This account is not active. Contact your administrator.',
            ], 403);
        }

        if ($response = $this->ensureDeviceBinding($user, $request)) {
            return $response;
        }

        $issuedToken = $this->issueAccessToken($user, $request);
        $user->load('staffProfile');
        $user->withAccessToken($issuedToken->accessToken);

        return response()->json($this->authPayload($user, $issuedToken->plainTextToken));
    }

    public function me(Request $request)
    {
        /** @var User $user */
        $user = $request->user();
        $user->load('staffProfile');

        return response()->json($this->authPayload($user));
    }

    public function sessions(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $currentTokenId = $request->user()?->currentAccessToken()?->getKey();

        return response()->json(
            $user->tokens()
                ->orderByDesc('last_used_at')
                ->orderByDesc('created_at')
                ->get()
                ->map(fn (PersonalAccessToken $token) => $this->sessionPayload($token, $currentTokenId))
                ->values()
        );
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json([
            'success' => true,
            'message' => 'Current session logged out.',
        ]);
    }

    public function logoutAll(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $deleted = $user->tokens()->count();
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'revoked_sessions' => $deleted,
            'message' => 'All sessions logged out.',
        ]);
    }

    public function destroySession(Request $request, string $tokenId): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $token = $user->tokens()->findOrFail($tokenId);
        $isCurrent = (string) $token->getKey() === (string) $request->user()?->currentAccessToken()?->getKey();
        $token->delete();

        return response()->json([
            'success' => true,
            'message' => $isCurrent ? 'Current session revoked.' : 'Session revoked.',
        ]);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'confirmed', Password::defaults()],
            'logout_other_devices' => ['nullable', 'boolean'],
        ]);

        /** @var User $user */
        $user = $request->user();
        if (! Hash::check($payload['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        if (Hash::check($payload['password'], $user->password)) {
            throw ValidationException::withMessages([
                'password' => ['The new password must be different from the current password.'],
            ]);
        }

        $user->forceFill([
            'password' => $payload['password'],
        ])->save();

        if ($request->boolean('logout_other_devices', true)) {
            $currentTokenId = $request->user()?->currentAccessToken()?->getKey();
            $user->tokens()
                ->when(
                    $currentTokenId !== null,
                    fn ($query) => $query->where('id', '!=', $currentTokenId)
                )
                ->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Password updated successfully.',
        ]);
    }

    public function createBiometricToken(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $issuedToken = $this->issueBiometricAccessToken($user, $request);
        $user->load('staffProfile');
        $user->withAccessToken($issuedToken->accessToken);

        return response()->json($this->authPayload($user, $issuedToken->plainTextToken));
    }

    public function destroyBiometricToken(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $deleted = $this->deleteBiometricTokensForDevice(
            $user,
            null,
            null,
        );

        return response()->json([
            'success' => true,
            'revoked_sessions' => $deleted,
            'message' => 'Biometric sign-in disabled.',
        ]);
    }

    private function authPayload(User $user, ?string $accessToken = null): array
    {
        return array_filter([
            'access_token' => $accessToken,
            'token_type' => $accessToken !== null ? 'Bearer' : null,
            'user' => SmartHrPayloads::user($user),
            'staff' => $user->staffProfile ? SmartHrPayloads::staff($user->staffProfile) : null,
            'session' => $this->sessionPayload($user->currentAccessToken(), $user->currentAccessToken()?->getKey()),
        ], static fn ($value) => $value !== null);
    }

    private function ensureDeviceBinding(User $user, Request $request): ?JsonResponse
    {
        if (strtolower((string) $user->role) !== 'staff') {
            return null;
        }

        $deviceId = trim((string) $request->input('device_id', ''));
        if ($deviceId === '') {
            return response()->json([
                'message' => 'A registered device is required to sign in to this staff account.',
                'errors' => [
                    'device_id' => ['A registered device is required to sign in to this staff account.'],
                ],
            ], 422);
        }

        $boundDeviceId = trim((string) ($user->device_id ?? ''));
        if ($boundDeviceId !== '' && ! hash_equals($boundDeviceId, $deviceId)) {
            return response()->json([
                'message' => 'Your account is bound to a different device. Contact admin to reset device binding.',
            ], 403);
        }

        if ($boundDeviceId === '') {
            $user->forceFill([
                'device_id' => $deviceId,
            ])->save();
        }

        return null;
    }

    private function issueAccessToken(User $user, Request $request): NewAccessToken
    {
        $deviceId = $this->resolveDeviceId($request, $user) ?? '';
        if ($deviceId !== '' && config('auth_sessions.revoke_same_device_tokens')) {
            $user->tokens()->where('device_id', $deviceId)->delete();
        }

        $deviceName = $this->resolveDeviceName($request);
        $expiresAt = config('sanctum.expiration')
            ? Carbon::now()->addMinutes((int) config('sanctum.expiration'))
            : null;
        $issuedToken = $user->createToken($deviceName, ['*'], $expiresAt);
        $issuedToken->accessToken->forceFill([
            'device_name' => $deviceName,
            'device_id' => $deviceId !== '' ? $deviceId : null,
            'ip_address' => $request->ip(),
            'last_used_ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ])->save();

        return $issuedToken;
    }

    private function issueBiometricAccessToken(User $user, Request $request): NewAccessToken
    {
        $deviceId = $this->resolveDeviceId($request, $user) ?? '';
        $deviceName = $this->resolveDeviceName($request);
        $currentTokenId = $request->user()?->currentAccessToken()?->getKey();

        $this->deleteBiometricTokensForDevice(
            $user,
            $deviceId !== '' ? $deviceId : null,
            $currentTokenId,
        );

        $expiresAt = Carbon::now()->addMinutes(
            max(1, (int) config('auth_sessions.biometric_token_expiration_minutes', 10080))
        );
        $issuedToken = $user->createToken("biometric:{$deviceName}", ['*'], $expiresAt);
        $issuedToken->accessToken->forceFill([
            'device_name' => $deviceName,
            'device_id' => $deviceId !== '' ? $deviceId : null,
            'ip_address' => $request->ip(),
            'last_used_ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ])->save();

        return $issuedToken;
    }

    private function deleteBiometricTokensForDevice(
        User $user,
        ?string $deviceId,
        mixed $excludeTokenId = null,
    ): int {
        $query = PersonalAccessToken::query()
            ->where('tokenable_id', $user->getKey())
            ->where('name', 'like', 'biometric:%');

        if ($deviceId !== null && $deviceId !== '') {
            $query->where('device_id', $deviceId);
        }

        if ($excludeTokenId !== null) {
            $query->where('id', '!=', $excludeTokenId);
        }

        return $query->delete();
    }

    private function resolveDeviceId(Request $request, User $user): ?string
    {
        $deviceId = trim((string) (
            $request->input('device_id')
            ?: $request->user()?->currentAccessToken()?->device_id
            ?: $user->device_id
            ?: ''
        ));

        return $deviceId !== '' ? $deviceId : null;
    }

    private function resolveDeviceName(Request $request): string
    {
        $deviceName = trim((string) (
            $request->input('device_name')
            ?: $request->header('X-Device-Name')
            ?: config('auth_sessions.default_device_name', 'mobile-app')
        ));

        return $deviceName !== '' ? $deviceName : 'mobile-app';
    }

    private function sessionPayload(
        ?PersonalAccessToken $token,
        mixed $currentTokenId = null,
    ): ?array {
        if (! $token) {
            return null;
        }

        return [
            'id' => (string) $token->getKey(),
            'name' => $token->name,
            'device_name' => $token->device_name,
            'device_id' => $token->device_id,
            'ip_address' => $token->ip_address,
            'last_used_ip_address' => $token->last_used_ip_address,
            'user_agent' => $token->user_agent,
            'last_used_at' => $token->last_used_at?->toIso8601String(),
            'expires_at' => $token->expires_at?->toIso8601String(),
            'created_at' => $token->created_at?->toIso8601String(),
            'is_current' => $currentTokenId !== null && (string) $token->getKey() === (string) $currentTokenId,
            'is_expired' => $token->expires_at?->isPast() ?? false,
        ];
    }
}
