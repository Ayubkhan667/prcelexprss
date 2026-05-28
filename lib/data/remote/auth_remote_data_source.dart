import 'package:dio/dio.dart';

import '../dto/auth/login_request_dto.dart';
import '../models/auth_failure.dart';
import '../models/auth_session_model.dart';
import '../models/staff_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import 'api_client.dart';
import 'remote_payload_parser.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSession> login(LoginRequestDto request);

  Future<AuthSession?> restoreSession(StoredAuthSession session);

  Future<void> logout();

  Future<void> logoutAll();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AuthSession> createBiometricSession(StoredAuthSession currentSession);

  Future<void> revokeBiometricSession();
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  MockAuthRemoteDataSource({
    required MockDataService dataService,
  }) : _dataService = dataService;

  final MockDataService _dataService;

  @override
  Future<AuthSession> login(LoginRequestDto request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _dataService.loginUser(request.identifier, request.password);
    if (user == null) {
      throw const AuthFailure.invalidCredentials();
    }

    return AuthSession(
      user: user,
      staffProfile: _dataService.getStaffByUserId(user.id),
      accessToken: _issueAccessToken(user.id),
      issuedAt: DateTime.now(),
    );
  }

  @override
  Future<AuthSession?> restoreSession(StoredAuthSession session) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final user = _dataService.getUserById(session.userId);
    if (user == null) {
      return null;
    }

    return AuthSession(
      user: user,
      staffProfile: _dataService.getStaffByUserId(user.id),
      accessToken: session.accessToken,
      issuedAt: session.issuedAt,
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> logoutAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Mock: accept any password change without validation.
  }

  @override
  Future<AuthSession> createBiometricSession(
    StoredAuthSession currentSession,
  ) async {
    final restoredSession = await restoreSession(currentSession);
    if (restoredSession == null) {
      throw const AuthFailure.sessionExpired();
    }

    return AuthSession(
      user: restoredSession.user,
      staffProfile: restoredSession.staffProfile,
      accessToken: _issueAccessToken(restoredSession.user.id),
      issuedAt: DateTime.now(),
    );
  }

  @override
  Future<void> revokeBiometricSession() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  String _issueAccessToken(String userId) {
    return 'mock-token-$userId-${DateTime.now().millisecondsSinceEpoch}';
  }
}

class ApiAuthRemoteDataSource implements AuthRemoteDataSource {
  ApiAuthRemoteDataSource({required ApiClient apiClient})
      : client = apiClient.client;

  final Dio client;

  @override
  Future<AuthSession> login(LoginRequestDto request) async {
    try {
      final response = await client.post(
        '/auth/login',
        data: request.toMap(),
      );
      return _parseSession(response.data);
    } on DioException catch (error) {
      throw _mapAuthFailure(error);
    } on AuthFailure {
      rethrow;
    } on FormatException catch (error) {
      throw AuthFailure.invalidResponse(error.message);
    } catch (_) {
      throw const AuthFailure.invalidResponse();
    }
  }

  @override
  Future<AuthSession?> restoreSession(StoredAuthSession session) async {
    try {
      final response = await client.get('/auth/me');
      return await _parseSession(
        response.data,
        fallbackToken: session.accessToken,
        fallbackIssuedAt: session.issuedAt,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return null;
      }
      throw _mapAuthFailure(error);
    } on AuthFailure {
      rethrow;
    } on FormatException catch (error) {
      throw AuthFailure.invalidResponse(error.message);
    } catch (_) {
      throw const AuthFailure.invalidResponse();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post('/auth/logout');
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return;
      }
      throw _mapAuthFailure(error);
    }
  }

  @override
  Future<void> logoutAll() async {
    try {
      await client.post('/auth/logout-all');
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return;
      }
      throw _mapAuthFailure(error);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await client.post('/auth/change-password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
        'logout_other_devices': false,
      });
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 422) {
        final errors = error.response?.data?['errors'] as Map?;
        final msg = (errors?['current_password'] as List?)?.first as String? ??
            (errors?['password'] as List?)?.first as String? ??
            'Invalid password details.';
        throw AuthFailure(code: 'invalid_password', message: msg);
      }
      throw _mapAuthFailure(error);
    }
  }

  @override
  Future<AuthSession> createBiometricSession(
    StoredAuthSession _,
  ) async {
    try {
      final response = await client.post('/auth/biometric-token');
      return _parseSession(
        response.data,
        fallbackIssuedAt: DateTime.now(),
      );
    } on DioException catch (error) {
      throw _mapAuthFailure(error);
    } on AuthFailure {
      rethrow;
    } on FormatException catch (error) {
      throw AuthFailure.invalidResponse(error.message);
    } catch (_) {
      throw const AuthFailure.invalidResponse();
    }
  }

  @override
  Future<void> revokeBiometricSession() async {
    try {
      await client.delete('/auth/biometric-token');
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return;
      }
      throw _mapAuthFailure(error);
    }
  }

  Future<AuthSession> _parseSession(
    dynamic data, {
    String? fallbackToken,
    DateTime? fallbackIssuedAt,
  }) async {
    final payload = RemotePayloadParser.parseMap(data);
    final userMap = RemotePayloadParser.nestedMap(
          payload,
          const ['user', 'account'],
        ) ??
        payload;
    final user = UserModel.fromMap(userMap);
    StaffModel? staffProfile;

    final staffMap = RemotePayloadParser.nestedMap(
      payload,
      const ['staff', 'staff_profile', 'profile'],
    );
    if (staffMap != null) {
      staffProfile = StaffModel.fromMap(staffMap);
    } else if (user.role == 'staff') {
      staffProfile = await _fetchStaffProfile(user.id);
    }

    final accessToken = RemotePayloadParser.readString(
          payload,
          const ['access_token', 'token'],
        ) ??
        fallbackToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthFailure.sessionExpired();
    }

    return AuthSession(
      user: user,
      staffProfile: staffProfile,
      accessToken: accessToken,
      issuedAt: fallbackIssuedAt ?? DateTime.now(),
    );
  }

  Future<StaffModel?> _fetchStaffProfile(String userId) async {
    try {
      final response = await client.get('/staff/by-user/$userId');
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : StaffModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  AuthFailure _mapAuthFailure(DioException error) {
    final message = _extractErrorMessage(error.response?.data);

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown) {
      return const AuthFailure.backendUnavailable(
        'Backend is not reachable. Check your API URL in Settings.',
      );
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return const AuthFailure.invalidCredentials();
    }

    if (statusCode == 403) {
      if (message != null && message.toLowerCase().contains('device')) {
        return AuthFailure.deviceNotAllowed(message);
      }

      return AuthFailure(
        code: 'account_inactive',
        message: message ??
            'This account is not active. Contact your administrator.',
      );
    }

    if (statusCode == 422) {
      return AuthFailure(
        code: 'invalid_request',
        message: message ?? 'Please enter valid login details.',
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return const AuthFailure.backendUnavailable(
        'Backend returned a server error. Please try again later.',
      );
    }

    return const AuthFailure.invalidResponse();
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final directMessage = data['message']?.toString();
      if (directMessage != null && directMessage.isNotEmpty) {
        return directMessage;
      }

      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first?.toString();
            if (first != null && first.isNotEmpty) {
              return first;
            }
          } else if (value != null) {
            final text = value.toString();
            if (text.isNotEmpty) {
              return text;
            }
          }
        }
      }
    }

    return null;
  }
}
