<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json([
                'message' => 'Unauthenticated.',
            ], 401);
        }

        if ($roles === []) {
            return $next($request);
        }

        $allowedRoles = array_map('strtolower', $roles);
        $userRole = strtolower((string) $user->role);

        if (! in_array($userRole, $allowedRoles, true)) {
            return response()->json([
                'message' => 'You are not authorized to perform this action.',
                'required_roles' => $roles,
            ], 403);
        }

        return $next($request);
    }
}
