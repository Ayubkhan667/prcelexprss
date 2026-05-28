import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({
    required Future<String?> Function() readAccessToken,
    required String baseUrl,
    Dio? dio,
  })  : _readAccessToken = readAccessToken,
        client = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            ) {
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Future<String?> Function() _readAccessToken;
  final Dio client;
}
