import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

import '../models/auth_session_model.dart';

class BiometricResult {
  final bool success;
  final String message;
  const BiometricResult({required this.success, required this.message});
}

class BiometricEnrollment {
  final String identifier;
  final StoredAuthSession session;

  const BiometricEnrollment({
    required this.identifier,
    required this.session,
  });
}

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const _identifierKey = 'biometric.identifier';
  static const _userIdKey = 'biometric.user_id';
  static const _roleKey = 'biometric.user_role';
  static const _accessTokenKey = 'biometric.access_token';
  static const _issuedAtKey = 'biometric.issued_at';
  static const _legacyPasswordKey = 'biometric.password';

  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isBiometricAvailable() async {
    return (await isDeviceSupported()) && (await canCheckBiometrics());
  }

  static Future<BiometricResult> authenticate({
    String reason = 'Verify your identity to continue',
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        return const BiometricResult(
            success: false, message: 'Biometrics not available on this device');
      }
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return BiometricResult(
        success: authenticated,
        message: authenticated ? 'Authenticated' : 'Authentication cancelled',
      );
    } catch (e) {
      return BiometricResult(success: false, message: e.toString());
    }
  }

  static Future<bool> isEnabled() async {
    return (await readEnrollment()) != null;
  }

  static Future<BiometricEnrollment?> readEnrollment() async {
    try {
      final identifier = await _secureStorage.read(key: _identifierKey);
      final userId = await _secureStorage.read(key: _userIdKey);
      final role = await _secureStorage.read(key: _roleKey);
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final issuedAtRaw = await _secureStorage.read(key: _issuedAtKey);
      final issuedAt =
          issuedAtRaw == null ? null : DateTime.tryParse(issuedAtRaw);
      if (identifier == null ||
          identifier.isEmpty ||
          userId == null ||
          userId.isEmpty ||
          role == null ||
          role.isEmpty ||
          accessToken == null ||
          accessToken.isEmpty ||
          issuedAt == null) {
        return null;
      }

      return BiometricEnrollment(
        identifier: identifier,
        session: StoredAuthSession(
          userId: userId,
          role: role,
          accessToken: accessToken,
          issuedAt: issuedAt,
        ),
      );
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> enrollSession({
    required String identifier,
    required StoredAuthSession session,
  }) async {
    try {
      await _secureStorage.write(key: _identifierKey, value: identifier);
      await _secureStorage.write(key: _userIdKey, value: session.userId);
      await _secureStorage.write(key: _roleKey, value: session.role);
      await _secureStorage.write(
        key: _accessTokenKey,
        value: session.accessToken,
      );
      await _secureStorage.write(
        key: _issuedAtKey,
        value: session.issuedAt.toIso8601String(),
      );
    } on MissingPluginException {
      return;
    } catch (_) {
      return;
    }
  }

  static Future<void> clearEnrollment() async {
    try {
      await _secureStorage.delete(key: _identifierKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _roleKey);
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _issuedAtKey);
      await _secureStorage.delete(key: _legacyPasswordKey);
    } on MissingPluginException {
      // Ignore secure storage failures while clearing local enrollment state.
    } catch (_) {
      // Ignore secure storage failures while clearing local enrollment state.
    }
  }

  static String getBiometricLabel(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
    return 'Biometrics';
  }

  static bool isFaceId(List<BiometricType> types) =>
      types.contains(BiometricType.face);
}
