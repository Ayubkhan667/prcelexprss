import 'package:dio/dio.dart';

import '../models/attendance_model.dart';
import '../models/branch_model.dart';
import '../models/shift_model.dart';
import '../models/staff_model.dart';
import 'api_client.dart';
import 'remote_payload_parser.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceModel>> fetchAttendance({
    String? staffId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<AttendanceModel?> fetchTodayAttendanceForStaff(
    String staffId, {
    DateTime? date,
  });

  Future<AttendanceModel> saveAttendance({
    required AttendanceModel attendance,
    required bool isEdit,
  });

  Future<AttendanceModel> recordCheckIn({
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required DateTime checkInTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    required String? wifiSsid,
    String? selfiePath,
    String? notes,
  });

  Future<AttendanceModel?> recordCheckOut({
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required DateTime checkOutTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    required String? wifiSsid,
    String? selfiePath,
    String? notes,
  });

  Future<AttendanceModel?> pauseDuty({
    required String attendanceId,
    required DateTime pausedAt,
    String? reason,
  });

  Future<AttendanceModel?> resumeDuty({
    required String attendanceId,
    required DateTime resumedAt,
    String? reason,
  });

  Future<AttendanceModel?> updateOvertimeApprovalStatus({
    required String attendanceId,
    required String status,
  });
}

class ApiAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  ApiAttendanceRemoteDataSource({required ApiClient apiClient})
      : client = apiClient.client;

  final Dio client;

  @override
  Future<List<AttendanceModel>> fetchAttendance({
    String? staffId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await client.get(
      '/attendance',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (date != null) 'date': _serializeDate(date),
        if (fromDate != null) 'from_date': _serializeDate(fromDate),
        if (toDate != null) 'to_date': _serializeDate(toDate),
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(AttendanceModel.fromMap)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<AttendanceModel?> fetchTodayAttendanceForStaff(
    String staffId, {
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();

    try {
      final response = await client.get(
        '/attendance/today',
        queryParameters: {
          'staff_id': staffId,
          'date': _serializeDate(targetDate),
        },
      );
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : AttendanceModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) {
        rethrow;
      }
    }

    final records = await fetchAttendance(
      staffId: staffId,
      date: targetDate,
    );
    return records.isEmpty ? null : records.first;
  }

  @override
  Future<AttendanceModel> saveAttendance({
    required AttendanceModel attendance,
    required bool isEdit,
  }) async {
    final response = isEdit
        ? await client.put(
            '/attendance/${attendance.id}',
            data: attendance.toMap(),
          )
        : await client.post('/attendance', data: attendance.toMap());

    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? attendance : AttendanceModel.fromMap(payload);
  }

  @override
  Future<AttendanceModel> recordCheckIn({
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required DateTime checkInTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    required String? wifiSsid,
    String? selfiePath,
    String? notes,
  }) async {
    final response = await client.post(
      '/attendance/check-in',
      data: await _buildAttendanceFormData(
        staffId: staff.id,
        shiftId: shift.id,
        eventTime: checkInTime,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        isLocationValid: isLocationValid,
        isMockGps: isMockGps,
        wifiSsid: wifiSsid,
        selfiePath: selfiePath,
        notes: notes,
      ),
    );

    return AttendanceModel.fromMap(RemotePayloadParser.parseMap(response.data));
  }

  @override
  Future<AttendanceModel?> recordCheckOut({
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required DateTime checkOutTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    required String? wifiSsid,
    String? selfiePath,
    String? notes,
  }) async {
    try {
      final response = await client.post(
        '/attendance/check-out',
        data: await _buildAttendanceFormData(
          staffId: staff.id,
          shiftId: shift.id,
          eventTime: checkOutTime,
          latitude: latitude,
          longitude: longitude,
          deviceId: deviceId,
          isLocationValid: isLocationValid,
          isMockGps: isMockGps,
          wifiSsid: wifiSsid,
          selfiePath: selfiePath,
          notes: notes,
        ),
      );

      return AttendanceModel.fromMap(
        RemotePayloadParser.parseMap(response.data),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AttendanceModel?> updateOvertimeApprovalStatus({
    required String attendanceId,
    required String status,
  }) async {
    try {
      final response = await client.patch(
        '/attendance/$attendanceId/overtime-approval',
        data: {'status': status},
      );
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : AttendanceModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AttendanceModel?> pauseDuty({
    required String attendanceId,
    required DateTime pausedAt,
    String? reason,
  }) async {
    try {
      final response = await client.patch(
        '/attendance/$attendanceId/pause',
        data: {
          'event_time': pausedAt.toIso8601String(),
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : AttendanceModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AttendanceModel?> resumeDuty({
    required String attendanceId,
    required DateTime resumedAt,
    String? reason,
  }) async {
    try {
      final response = await client.patch(
        '/attendance/$attendanceId/resume',
        data: {
          'event_time': resumedAt.toIso8601String(),
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : AttendanceModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<FormData> _buildAttendanceFormData({
    required String staffId,
    required String shiftId,
    required DateTime eventTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    required String? wifiSsid,
    String? selfiePath,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'staff_id': staffId,
      'shift_id': shiftId,
      'event_time': eventTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'device_id': deviceId,
      'is_location_valid': isLocationValid,
      'is_mock_gps': isMockGps,
      if (wifiSsid != null && wifiSsid.isNotEmpty) 'wifi_ssid': wifiSsid,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    if (selfiePath != null && selfiePath.isNotEmpty) {
      payload['selfie'] = await MultipartFile.fromFile(selfiePath);
    }

    return FormData.fromMap(payload);
  }

  String _serializeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }
}
