<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Str;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('auth-login', function (Request $request) {
            $identifier = Str::lower(trim((string) (
                $request->input('identifier')
                ?? $request->input('email')
                ?? $request->input('mobile')
                ?? ''
            )));
            $deviceId = trim((string) $request->input('device_id', ''));
            $key = implode('|', array_filter([
                $identifier !== '' ? $identifier : 'unknown',
                $request->ip(),
                $deviceId !== '' ? $deviceId : null,
            ]));

            return Limit::perMinute(
                max(1, (int) config('auth_sessions.login_throttle_max_attempts', 5))
            )->by($key)->response(function (Request $request, array $headers) {
                $retryAfter = (int) ($headers['Retry-After'] ?? 60);

                return response()->json([
                    'message' => "Too many login attempts. Try again in {$retryAfter} seconds.",
                    'retry_after_seconds' => $retryAfter,
                ], 429, $headers);
            });
        });

        if (config('app.force_https')) {
            URL::forceScheme('https');
        }

        if (app()->environment('production') && filled(config('app.url'))) {
            URL::forceRootUrl(rtrim((string) config('app.url'), '/'));
        }
    }
}
