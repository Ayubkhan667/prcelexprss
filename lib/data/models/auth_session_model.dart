import 'staff_model.dart';
import 'user_model.dart';

class AuthSession {
  final UserModel user;
  final StaffModel? staffProfile;
  final String accessToken;
  final DateTime issuedAt;

  const AuthSession({
    required this.user,
    required this.staffProfile,
    required this.accessToken,
    required this.issuedAt,
  });
}

class StoredAuthSession {
  final String userId;
  final String role;
  final String accessToken;
  final DateTime issuedAt;

  const StoredAuthSession({
    required this.userId,
    required this.role,
    required this.accessToken,
    required this.issuedAt,
  });

  factory StoredAuthSession.fromSession(AuthSession session) {
    return StoredAuthSession(
      userId: session.user.id,
      role: session.user.role,
      accessToken: session.accessToken,
      issuedAt: session.issuedAt,
    );
  }
}
