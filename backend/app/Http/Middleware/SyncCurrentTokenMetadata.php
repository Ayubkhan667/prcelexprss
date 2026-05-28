<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SyncCurrentTokenMetadata
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $token = $request->user()?->currentAccessToken();
        if (! $token || ! $token->exists) {
            return $response;
        }

        $token->forceFill([
            'last_used_ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ])->save();

        return $response;
    }
}
