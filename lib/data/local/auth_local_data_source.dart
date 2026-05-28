import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _keyUserId = 'auth.user_id';
  static const _keyUserRole = 'auth.user_role';
  static const _keyAccessToken = 'auth.access_token';
  static const _keyIssuedAt = 'auth.issued_at';

  final FlutterSecureStorage _storage;

  Future<StoredAuthSession?> readSession() async {
    try {
      final userId = await _storage.read(key: _keyUserId);
      final role = await _storage.read(key: _keyUserRole);
      final accessToken = await _storage.read(key: _keyAccessToken);
      final issuedAtRaw = await _storage.read(key: _keyIssuedAt);
      if (userId == null ||
          role == null ||
          accessToken == null ||
          issuedAtRaw == null) {
        return null;
      }

      final issuedAt = DateTime.tryParse(issuedAtRaw);
      if (issuedAt == null) {
        return null;
      }

      return StoredAuthSession(
        userId: userId,
        role: role,
        accessToken: accessToken,
        issuedAt: issuedAt,
      );
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(AuthSession session) async {
    final storedSession = StoredAuthSession.fromSession(session);

    try {
      await _storage.write(key: _keyUserId, value: storedSession.userId);
      await _storage.write(key: _keyUserRole, value: storedSession.role);
      await _storage.write(
        key: _keyAccessToken,
        value: storedSession.accessToken,
      );
      await _storage.write(
        key: _keyIssuedAt,
        value: storedSession.issuedAt.toIso8601String(),
      );
    } on MissingPluginException {
      return;
    } catch (_) {
      return;
    }
  }

  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserRole);
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyIssuedAt);
    } on MissingPluginException {
      return;
    } catch (_) {
      return;
    }
  }
}
