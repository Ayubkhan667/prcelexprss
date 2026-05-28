import '../dto/auth/login_request_dto.dart';
import '../models/auth_session_model.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession?> restoreStoredSession(StoredAuthSession session);

  Future<AuthSession> login(LoginRequestDto request);

  Future<void> logout();

  Future<void> logoutAll();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AuthSession> issueBiometricSession();

  Future<void> revokeBiometricSession();
}
