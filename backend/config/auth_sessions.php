<?php

return [
    'revoke_same_device_tokens' => filter_var(
        env('AUTH_REVOKE_SAME_DEVICE_TOKENS', true),
        FILTER_VALIDATE_BOOLEAN
    ),
    'default_device_name' => env('AUTH_DEFAULT_DEVICE_NAME', 'mobile-app'),
    'biometric_token_expiration_minutes' => (int) env(
        'AUTH_BIOMETRIC_TOKEN_EXPIRATION_MINUTES',
        10080
    ),
    'login_throttle_max_attempts' => (int) env(
        'AUTH_LOGIN_THROTTLE_MAX_ATTEMPTS',
        5
    ),
];
