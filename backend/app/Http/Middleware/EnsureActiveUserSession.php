<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureActiveUserSession
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if (! $user) {
            return $next($request);
        }

        $currentToken = $user->currentAccessToken();

        if (strtolower((string) $user->status) !== 'active') {
            $currentToken?->delete();

            return response()->json([
                'message' => 'This account is not active. Contact your administrator.',
            ], 403);
        }

        if (strtolower((string) $user->role) === 'staff') {
            $boundDeviceId = trim((string) ($user->device_id ?? ''));
            $tokenDeviceId = trim((string) ($currentToken?->device_id ?? ''));

            if ($boundDeviceId !== '' && ($tokenDeviceId === '' || ! hash_equals($boundDeviceId, $tokenDeviceId))) {
                $currentToken?->delete();

                return response()->json([
                    'message' => 'Your session is no longer valid on this device. Please sign in again.',
                ], 401);
            }
        }

        return $next($request);
    }
}
