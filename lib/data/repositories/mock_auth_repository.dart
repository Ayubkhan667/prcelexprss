import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../dto/auth/login_request_dto.dart';
import '../local/auth_local_data_source.dart';
import '../models/auth_failure.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import '../remote/auth_remote_data_source.dart';
import '../services/device_binding_service.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    bool enforceLocalDeviceBinding = true,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _enforceLocalDeviceBinding = enforceLocalDeviceBinding;

  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final bool _enforceLocalDeviceBinding;

  @override
  Future<AuthSession> login(LoginRequestDto request) async {
    final session = await _remoteDataSource.login(
      request.copyWith(
        deviceId: await _resolveDeviceId(),
        deviceName: _resolveDeviceName(),
      ),
    );
    await _validateDeviceBinding(session.user);
    await _localDataSource.saveSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Local sign-out should still succeed even if token revocation fails.
    } finally {
      await _localDataSource.clearSession();
    }
  }

  @override
  Future<void> logoutAll() async {
    try {
      await _remoteDataSource.logoutAll();
    } catch (_) {
      // Still clear local session.
    } finally {
      await _localDataSource.clearSession();
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final storedSession = await _localDataSource.readSession();
    if (storedSession == null) {
      return null;
    }

    return _restoreAndPersistSession(
      storedSession,
      clearLocalSessionOnFailure: true,
    );
  }

  @override
  Future<AuthSession?> restoreStoredSession(StoredAuthSession session) {
    return _restoreAndPersistSession(
      session,
      clearLocalSessionOnFailure: false,
    );
  }

  @override
  Future<AuthSession> issueBiometricSession() async {
    final currentSession = await _localDataSource.readSession();
    if (currentSession == null) {
      throw const AuthFailure.sessionExpired();
    }

    final session =
        await _remoteDataSource.createBiometricSession(currentSession);
    await _validateDeviceBinding(session.user);
    return session;
  }

  @override
  Future<void> revokeBiometricSession() {
    return _remoteDataSource.revokeBiometricSession();
  }

  Future<void> _validateDeviceBinding(UserModel user) async {
    if (!_enforceLocalDeviceBinding) {
      return;
    }

    if (user.role != AppConstants.roleStaff) {
      return;
    }

    final binding = await DeviceBindingService.checkBinding(user.id);
    if (!binding.isAllowed) {
      throw AuthFailure.deviceNotAllowed(binding.message);
    }
  }

  Future<String?> _resolveDeviceId() async {
    final deviceId = await DeviceBindingService.getDeviceId();
    return deviceId == 'unknown_device' ? null : deviceId;
  }

  String _resolveDeviceName() {
    if (kIsWeb) {
      return 'web';
    }

    return defaultTargetPlatform.name;
  }

  Future<AuthSession?> _restoreAndPersistSession(
    StoredAuthSession storedSession, {
    required bool clearLocalSessionOnFailure,
  }) async {
    final session = await _remoteDataSource.restoreSession(storedSession);
    if (session == null) {
      if (clearLocalSessionOnFailure) {
        await _localDataSource.clearSession();
      }
      return null;
    }

    try {
      await _validateDeviceBinding(session.user);
      await _localDataSource.saveSession(session);
    } on AuthFailure {
      if (clearLocalSessionOnFailure) {
        await _localDataSource.clearSession();
      }
      rethrow;
    }

    return session;
  }
}
