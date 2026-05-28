import 'package:dio/dio.dart';

import '../models/shift_model.dart';
import 'api_client.dart';
import 'remote_payload_parser.dart';

abstract class ShiftRemoteDataSource {
  Future<List<ShiftModel>> fetchShifts();

  Future<ShiftModel?> fetchShiftById(String id);

  Future<void> saveShift({
    required ShiftModel shift,
    required bool isEdit,
  });
}

class ApiShiftRemoteDataSource implements ShiftRemoteDataSource {
  ApiShiftRemoteDataSource({required ApiClient apiClient})
      : client = apiClient.client;

  final Dio client;

  @override
  Future<List<ShiftModel>> fetchShifts() async {
    final response = await client.get('/shifts');
    return RemotePayloadParser.parseList(response.data)
        .map(ShiftModel.fromMap)
        .toList();
  }

  @override
  Future<ShiftModel?> fetchShiftById(String id) async {
    try {
      final response = await client.get('/shifts/$id');
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : ShiftModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> saveShift({
    required ShiftModel shift,
    required bool isEdit,
  }) async {
    if (isEdit) {
      await client.put('/shifts/${shift.id}', data: shift.toMap());
      return;
    }

    final payload = shift.toMap();
    if ((payload['id'] as String?)?.trim().isEmpty ?? false) {
      payload.remove('id');
    }

    await client.post('/shifts', data: payload);
  }
}
