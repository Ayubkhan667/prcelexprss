import 'package:dio/dio.dart';

import '../models/staff_model.dart';
import '../models/staff_save_result.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'remote_payload_parser.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> fetchStaffList({
    String? branchId,
    String? department,
    String? category,
    String? status,
    String? searchQuery,
  });

  Future<StaffModel?> fetchStaffById(String id);

  Future<StaffModel?> fetchStaffByUserId(String userId);

  Future<StaffSaveResult> saveStaff({
    required StaffModel staff,
    required UserModel user,
    required bool isEdit,
  });

  Future<void> resetDeviceBinding(String staffId);
}

class ApiStaffRemoteDataSource implements StaffRemoteDataSource {
  ApiStaffRemoteDataSource({required ApiClient apiClient})
      : client = apiClient.client;

  final Dio client;

  @override
  Future<List<StaffModel>> fetchStaffList({
    String? branchId,
    String? department,
    String? category,
    String? status,
    String? searchQuery,
  }) async {
    final response = await client.get(
      '/staff',
      queryParameters: {
        if (branchId != null && branchId.isNotEmpty) 'branch_id': branchId,
        if (department != null && department.isNotEmpty)
          'department': department,
        if (category != null && category.isNotEmpty) 'category': category,
        if (status != null && status.isNotEmpty) 'status': status,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(StaffModel.fromMap)
        .toList();
  }

  @override
  Future<StaffModel?> fetchStaffById(String id) async {
    try {
      final response = await client.get('/staff/$id');
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : StaffModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<StaffModel?> fetchStaffByUserId(String userId) async {
    try {
      final response = await client.get('/staff/by-user/$userId');
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : StaffModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) {
        rethrow;
      }
    }

    final response = await client.get(
      '/staff',
      queryParameters: {'user_id': userId},
    );
    final records = RemotePayloadParser.parseList(response.data)
        .map(StaffModel.fromMap)
        .toList();
    return records.isEmpty ? null : records.first;
  }

  @override
  Future<StaffSaveResult> saveStaff({
    required StaffModel staff,
    required UserModel user,
    required bool isEdit,
  }) async {
    final staffPayload = staff.toMap();
    final userPayload = user.toMap();
    if (!isEdit) {
      _removeBlankValues(staffPayload, const ['id', 'user_id', 'staff_code']);
      _removeBlankValues(userPayload, const ['id']);
    }

    final payload = {
      'staff': staffPayload,
      'user': userPayload,
    };

    try {
      if (isEdit) {
        await client.put('/staff/${staff.id}', data: payload);
        return const StaffSaveResult();
      }
      final response = await client.post('/staff', data: payload);
      final responsePayload =
          RemotePayloadParser.parseOptionalMap(response.data);
      return StaffSaveResult(
        temporaryPassword: responsePayload?['temporary_password']?.toString(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data?['errors'] as Map?;
        final first = errors?.values
            .expand((v) => v is List ? v : [v])
            .firstOrNull
            ?.toString();
        throw Exception(
            first ?? e.response?.data?['message'] ?? 'Validation failed');
      }
      rethrow;
    }
  }

  @override
  Future<void> resetDeviceBinding(String staffId) async {
    try {
      await client.post('/staff/$staffId/reset-device-binding');
    } on DioException catch (e) {
      final message = e.response?.data?['message']?.toString();
      throw Exception(message ?? 'Unable to reset device binding.');
    }
  }

  void _removeBlankValues(
    Map<String, dynamic> payload,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = payload[key];
      if (value is String && value.trim().isEmpty) {
        payload.remove(key);
      }
    }
  }
}
