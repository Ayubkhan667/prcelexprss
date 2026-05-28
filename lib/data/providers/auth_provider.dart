import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../dto/auth/login_request_dto.dart';
import '../local/auth_local_data_source.dart';
import '../models/auth_failure.dart';
import '../models/auth_session_model.dart';
import '../models/staff_model.dart';
import '../models/user_model.dart';
import '../remote/api_client.dart';
import '../remote/auth_remote_data_source.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../services/biometric_service.dart';
import '../services/mock_data_service.dart';
import 'api_config_provider.dart';

const _unset = Object();

class AuthState {
  final UserModel? user;
  final StaffModel? staffProfile;
  final String? accessToken;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.staffProfile,
    this.accessToken,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.isInitialized = false,
  });

  factory AuthState.authenticated(AuthSession session) {
    return AuthState(
      user: session.user,
      staffProfile: session.staffProfile,
      accessToken: session.accessToken,
      isLoading: false,
      error: null,
      isLoggedIn: true,
      isInitialized: true,
    );
  }

  AuthState copyWith({
    Object? user = _unset,
    Object? staffProfile = _unset,
    Object? accessToken = _unset,
    bool? isLoading,
    Object? error = _unset,
    bool? isLoggedIn,
    bool? isInitialized,
  }) =>
      AuthState(
        user: identical(user, _unset) ? this.user : user as UserModel?,
        staffProfile: identical(staffProfile, _unset)
            ? this.staffProfile
            : staffProfile as StaffModel?,
        accessToken: identical(accessToken, _unset)
            ? this.accessToken
            : accessToken as String?,
        isLoading: isLoading ?? this.isLoading,
        error: identical(error, _unset) ? this.error : error as String?,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        isInitialized: isInitialized ?? this.isInitialized,
      );
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final config = ref.watch(apiConfigProvider);
  return ApiClient(
    readAccessToken: localDataSource.readAccessToken,
    baseUrl: config.effectiveBaseUrl,
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final config = ref.watch(apiConfigProvider);
  if (!config.canUseRemote) {
    return MockAuthRemoteDataSource(
      dataService: MockDataService(),
    );
  }

  return ApiAuthRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    enforceLocalDeviceBinding: !ref.watch(apiConfigProvider).canUseRemote,
  );
});

class AuthController extends AsyncNotifier<AuthState> {
  static const _sessionRestoreError =
      'Unable to restore your session. Please sign in again.';
  static const _signInError = 'Unable to sign in right now. Please try again.';
  static const _changePasswordError =
      'Unable to change password. Please try again.';
  static const _logoutError = 'Unable to logout right now. Please try again.';
  static const _logoutAllError =
      'Unable to logout all sessions. Please try again.';
  static const _apiConfigurationError =
      'Set the API Server URL before signing in.';
  static const _biometricUnavailableError =
      'Biometric sign-in is not available. Sign in with your password first.';
  static const _biometricExpiredError =
      'Biometric sign-in expired. Sign in with your password again.';

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  AuthState get _currentState =>
      state.valueOrNull ?? const AuthState(isInitialized: true);

  @override
  Future<AuthState> build() async {
    final config = ref.read(apiConfigProvider);
    if (config.useRemote && !config.isConfigured) {
      return const AuthState(isInitialized: true);
    }

    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        return const AuthState(isInitialized: true);
      }
      return AuthState.authenticated(session);
    } on AuthFailure catch (failure) {
      return AuthState(
        isInitialized: true,
        error: failure.message,
      );
    } catch (_) {
      return const AuthState(isInitialized: true, error: _sessionRestoreError);
    }
  }

  Future<bool> login(String email, String password) async {
    final current = _currentState;
    if (!await _ensureConfiguredForSignIn(current)) {
      return false;
    }

    _setLoading(current);

    try {
      final session = await _repository.login(
        LoginRequestDto(
          identifier: email,
          password: password,
        ),
      );
      state = AsyncData(AuthState.authenticated(session));
      await _refreshBiometricEnrollmentIfEnabled(
        identifier: session.user.email.isNotEmpty ? session.user.email : email,
      );
      return true;
    } on AuthFailure catch (failure) {
      _setError(current, failure.message);
      return false;
    } catch (_) {
      _setError(current, _signInError);
      return false;
    }
  }

  Future<bool> loginWithBiometric() async {
    final current = _currentState;
    if (!await _ensureConfiguredForSignIn(current)) {
      return false;
    }

    final enrollment = await BiometricService.readEnrollment();
    if (enrollment == null) {
      _setError(current, _biometricUnavailableError);
      return false;
    }

    _setLoading(current);

    try {
      final session =
          await _repository.restoreStoredSession(enrollment.session);
      if (session == null) {
        await BiometricService.clearEnrollment();
        _setError(current, _biometricExpiredError);
        return false;
      }

      state = AsyncData(AuthState.authenticated(session));
      await _refreshBiometricEnrollmentIfEnabled(
        identifier: enrollment.identifier,
      );
      return true;
    } on AuthFailure catch (failure) {
      if (failure.code == 'session_expired') {
        await BiometricService.clearEnrollment();
      }
      _setError(current, failure.message);
      return false;
    } catch (_) {
      _setError(current, _signInError);
      return false;
    }
  }

  Future<void> logout() async {
    final current = _currentState;
    _setLoading(current);

    try {
      await _repository.logout();
      state = const AsyncData(AuthState(isInitialized: true));
    } catch (_) {
      _setError(current, _logoutError);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final current = _currentState;
    _setLoading(current);

    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final userEmail = current.user?.email;
      if (userEmail != null && userEmail.isNotEmpty) {
        await _refreshBiometricEnrollmentIfEnabled(identifier: userEmail);
      }
      state = AsyncData(current.copyWith(isLoading: false, error: null));
    } on AuthFailure catch (failure) {
      _setError(current, failure.message, markInitialized: false);
      rethrow;
    } catch (_) {
      _setError(current, _changePasswordError, markInitialized: false);
      rethrow;
    }
  }

  Future<void> logoutAll() async {
    final current = _currentState;
    _setLoading(current);

    try {
      await _repository.logoutAll();
      await BiometricService.clearEnrollment();
      state = const AsyncData(AuthState(isInitialized: true));
    } catch (_) {
      _setError(current, _logoutAllError, markInitialized: false);
    }
  }

  Future<void> enableBiometricSignIn({required String identifier}) async {
    final normalizedIdentifier = identifier.trim();
    if (normalizedIdentifier.isEmpty) {
      throw const AuthFailure(
        code: 'invalid_identifier',
        message: 'A valid account email is required for biometric login.',
      );
    }

    final session = await _repository.issueBiometricSession();
    await BiometricService.enrollSession(
      identifier: normalizedIdentifier,
      session: StoredAuthSession.fromSession(session),
    );
  }

  Future<void> disableBiometricSignIn() async {
    final enrollment = await BiometricService.readEnrollment();
    final activeAccessToken = state.valueOrNull?.accessToken;

    try {
      await _repository.revokeBiometricSession();
    } finally {
      await BiometricService.clearEnrollment();
    }

    if (enrollment != null &&
        activeAccessToken != null &&
        activeAccessToken == enrollment.session.accessToken) {
      await _repository.logout();
      state = const AsyncData(AuthState(isInitialized: true));
    }
  }

  bool get isAdmin => state.valueOrNull?.user?.role == AppConstants.roleAdmin;
  bool get isSupervisor =>
      state.valueOrNull?.user?.role == AppConstants.roleSupervisor;
  bool get isStaff => state.valueOrNull?.user?.role == AppConstants.roleStaff;

  Future<bool> _ensureConfiguredForSignIn(AuthState current) async {
    final config = ref.read(apiConfigProvider);
    if (!config.useRemote || config.isConfigured) {
      return true;
    }

    _setError(current, _apiConfigurationError);
    return false;
  }

  Future<void> _refreshBiometricEnrollmentIfEnabled({
    required String identifier,
  }) async {
    final normalizedIdentifier = identifier.trim();
    if (normalizedIdentifier.isEmpty) {
      return;
    }

    final enrollment = await BiometricService.readEnrollment();
    if (enrollment == null || enrollment.identifier != normalizedIdentifier) {
      return;
    }

    try {
      final biometricSession = await _repository.issueBiometricSession();
      await BiometricService.enrollSession(
        identifier: normalizedIdentifier,
        session: StoredAuthSession.fromSession(biometricSession),
      );
    } catch (_) {
      // Keep the last known biometric enrollment if refresh fails.
    }
  }

  void _setLoading(AuthState current) {
    state = AsyncData(
      current.copyWith(
        isLoading: true,
        error: null,
        isInitialized: true,
      ),
    );
  }

  void _setError(
    AuthState current,
    String message, {
    bool markInitialized = true,
  }) {
    state = AsyncData(
      current.copyWith(
        isLoading: false,
        error: message,
        isInitialized: markInitialized ? true : current.isInitialized,
      ),
    );
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

final authProvider = Provider<AuthState>((ref) {
  final authAsync = ref.watch(authControllerProvider);
  return authAsync.when(
    data: (authState) => authState,
    loading: () => const AuthState(
      isLoading: true,
      isInitialized: false,
    ),
    error: (_, __) => const AuthState(
        isInitialized: true, error: AuthController._sessionRestoreError),
  );
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final currentStaffProvider = Provider<StaffModel?>((ref) {
  return ref.watch(authProvider).staffProfile;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == AppConstants.roleAdmin;
});
