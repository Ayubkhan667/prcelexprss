import '../models/attendance_model.dart';
import '../models/branch_model.dart';
import '../models/shift_model.dart';
import '../models/staff_model.dart';
import '../remote/attendance_remote_data_source.dart';
import '../services/mock_data_service.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceModel>> getAttendance({
    String? staffId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<AttendanceModel?> getTodayAttendanceForStaff(
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

class MockAttendanceRepository implements AttendanceRepository {
  MockAttendanceRepository({required MockDataService dataService})
      : _dataService = dataService;

  final MockDataService _dataService;

  @override
  Future<List<AttendanceModel>> getAttendance({
    String? staffId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return _dataService.getAttendance(
      staffId: staffId,
      date: date,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<AttendanceModel?> getTodayAttendanceForStaff(
    String staffId, {
    DateTime? date,
  }) async {
    return _dataService.getTodayAttendanceForStaff(staffId, date: date);
  }

  @override
  Future<AttendanceModel> saveAttendance({
    required AttendanceModel attendance,
    required bool isEdit,
  }) async {
    return _dataService.saveAttendance(attendance);
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
    return _dataService.recordCheckIn(
      staff: staff,
      branch: branch,
      shift: shift,
      checkInTime: checkInTime,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
      isLocationValid: isLocationValid,
      isMockGps: isMockGps,
      wifiSsid: wifiSsid,
      selfiePath: selfiePath,
      notes: notes,
    );
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
    return _dataService.recordCheckOut(
      staff: staff,
      branch: branch,
      shift: shift,
      checkOutTime: checkOutTime,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
      isLocationValid: isLocationValid,
      isMockGps: isMockGps,
      wifiSsid: wifiSsid,
      selfiePath: selfiePath,
      notes: notes,
    );
  }

  @override
  Future<AttendanceModel?> pauseDuty({
    required String attendanceId,
    required DateTime pausedAt,
    String? reason,
  }) async {
    return _dataService.pauseDuty(
      attendanceId: attendanceId,
      pausedAt: pausedAt,
      reason: reason,
    );
  }

  @override
  Future<AttendanceModel?> resumeDuty({
    required String attendanceId,
    required DateTime resumedAt,
    String? reason,
  }) async {
    return _dataService.resumeDuty(
      attendanceId: attendanceId,
      resumedAt: resumedAt,
      reason: reason,
    );
  }

  @override
  Future<AttendanceModel?> updateOvertimeApprovalStatus({
    required String attendanceId,
    required String status,
  }) async {
    return _dataService.updateOvertimeApprovalStatus(
      attendanceId: attendanceId,
      status: status,
    );
  }
}

class RemoteAttendanceRepository implements AttendanceRepository {
  RemoteAttendanceRepository({
    required AttendanceRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<List<AttendanceModel>> getAttendance({
    String? staffId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _remoteDataSource.fetchAttendance(
      staffId: staffId,
      date: date,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<AttendanceModel?> getTodayAttendanceForStaff(
    String staffId, {
    DateTime? date,
  }) {
    return _remoteDataSource.fetchTodayAttendanceForStaff(
      staffId,
      date: date,
    );
  }

  @override
  Future<AttendanceModel> saveAttendance({
    required AttendanceModel attendance,
    required bool isEdit,
  }) {
    return _remoteDataSource.saveAttendance(
      attendance: attendance,
      isEdit: isEdit,
    );
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
  }) {
    return _remoteDataSource.recordCheckIn(
      staff: staff,
      branch: branch,
      shift: shift,
      checkInTime: checkInTime,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
      isLocationValid: isLocationValid,
      isMockGps: isMockGps,
      wifiSsid: wifiSsid,
      selfiePath: selfiePath,
      notes: notes,
    );
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
  }) {
    return _remoteDataSource.recordCheckOut(
      staff: staff,
      branch: branch,
      shift: shift,
      checkOutTime: checkOutTime,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
      isLocationValid: isLocationValid,
      isMockGps: isMockGps,
      wifiSsid: wifiSsid,
      selfiePath: selfiePath,
      notes: notes,
    );
  }

  @override
  Future<AttendanceModel?> pauseDuty({
    required String attendanceId,
    required DateTime pausedAt,
    String? reason,
  }) {
    return _remoteDataSource.pauseDuty(
      attendanceId: attendanceId,
      pausedAt: pausedAt,
      reason: reason,
    );
  }

  @override
  Future<AttendanceModel?> resumeDuty({
    required String attendanceId,
    required DateTime resumedAt,
    String? reason,
  }) {
    return _remoteDataSource.resumeDuty(
      attendanceId: attendanceId,
      resumedAt: resumedAt,
      reason: reason,
    );
  }

  @override
  Future<AttendanceModel?> updateOvertimeApprovalStatus({
    required String attendanceId,
    required String status,
  }) {
    return _remoteDataSource.updateOvertimeApprovalStatus(
      attendanceId: attendanceId,
      status: status,
    );
  }
}
