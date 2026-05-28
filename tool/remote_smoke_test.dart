import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final baseUrl = _env('API_BASE_URL', 'http://127.0.0.1:8000/api')
      .replaceFirst(RegExp(r'/+$'), '');
  final identifier = _env('ADMIN_EMAIL', 'admin@smarthr.com');
  final password = _env('ADMIN_PASSWORD', 'password123');
  final deviceId = _env('DEVICE_ID', 'device_admin_001');

  final client = _ApiSmokeClient(baseUrl);

  await client.get('/health', authenticated: false);
  final login = await client.post(
    '/auth/login',
    authenticated: false,
    body: {
      'identifier': identifier,
      'password': password,
      'device_name': 'remote-smoke-test',
      'device_id': deviceId,
    },
  );
  client.token =
      login['access_token']?.toString() ?? login['token']?.toString();
  if (client.token == null || client.token!.isEmpty) {
    throw StateError('Login response did not include an access token.');
  }

  final staff =
      (await client.get('/staff') as List).cast<Map<String, dynamic>>();
  if (staff.isEmpty) {
    throw StateError('No staff records returned from API.');
  }
  final firstStaff = staff.first;
  final staffId = firstStaff['id'].toString();

  final updatedStaff = Map<String, dynamic>.from(firstStaff);
  updatedStaff['allowed_location_radius_meters'] = 145;
  updatedStaff['daily_break_minutes'] = 55;
  final saveResponse = await client.put('/staff/$staffId', body: {
    'staff': updatedStaff,
    'user': {
      'name': updatedStaff['name'],
      'email': updatedStaff['email'],
      'mobile': updatedStaff['mobile'],
      'role': 'staff',
      'status': updatedStaff['status'] ?? 'Active',
    },
  });
  _expect(saveResponse['allowed_location_radius_meters'] == 145 ||
      saveResponse['allowed_location_radius_meters'] == 145.0);
  _expect(saveResponse['daily_break_minutes'] == 55);

  final notifications =
      (await client.get('/notifications?target_role=admin') as List)
          .cast<Map<String, dynamic>>();
  if (notifications.isNotEmpty) {
    await client.patch('/notifications/${notifications.first['id']}/read');
  }
  await client.patch('/notifications/read-all', body: {'target_role': 'admin'});

  final auditLogs =
      (await client.get('/audit-logs') as List).cast<Map<String, dynamic>>();
  _expect(
    auditLogs.any((log) => log['action'] == 'staff_edit'),
    message: 'Expected staff_edit audit log after staff range/break update.',
  );

  final attendance = await client.get('/attendance?staff_id=$staffId');
  _expect(attendance is List,
      message: 'Attendance endpoint did not return list.');

  stdout.writeln(
      'Remote smoke test passed: staff range/break, attendance, notifications, audit logs.');
}

String _env(String key, String fallback) {
  final value = Platform.environment[key];
  return value == null || value.trim().isEmpty ? fallback : value.trim();
}

void _expect(bool condition,
    {String message = 'Smoke test assertion failed.'}) {
  if (!condition) {
    throw StateError(message);
  }
}

class _ApiSmokeClient {
  final String baseUrl;
  String? token;

  _ApiSmokeClient(this.baseUrl);

  Future<dynamic> get(String path, {bool authenticated = true}) {
    return _send('GET', path, authenticated: authenticated);
  }

  Future<dynamic> post(
    String path, {
    bool authenticated = true,
    Map<String, dynamic>? body,
  }) {
    return _send('POST', path, authenticated: authenticated, body: body);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) {
    return _send('PATCH', path, body: body);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    bool authenticated = true,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (authenticated) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          '$method $path failed with ${response.statusCode}: $responseBody',
          uri: uri,
        );
      }
      return decoded;
    } finally {
      client.close(force: true);
    }
  }
}
