class AuthFailure implements Exception {
  final String code;
  final String message;

  const AuthFailure({
    required this.code,
    required this.message,
  });

  const AuthFailure.invalidCredentials()
      : code = 'invalid_credentials',
        message = 'Invalid email or password';

  const AuthFailure.deviceNotAllowed(String details)
      : code = 'device_not_allowed',
        message = details;

  const AuthFailure.sessionExpired()
      : code = 'session_expired',
        message = 'Your session has expired. Please sign in again.';

  const AuthFailure.backendUnavailable([String? details])
      : code = 'backend_unavailable',
        message = details ??
            'Backend is not reachable. Check API_BASE_URL or disable remote mode.';

  const AuthFailure.invalidResponse([String? details])
      : code = 'invalid_backend_response',
        message = details ??
            'Backend response format is invalid. Check the auth API response.';

  const AuthFailure.unknown()
      : code = 'unknown',
        message = 'Something went wrong. Please try again.';

  @override
  String toString() => 'AuthFailure($code, $message)';
}
