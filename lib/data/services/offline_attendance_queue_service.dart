import '../local/offline_attendance_queue_storage.dart';
import '../models/branch_model.dart';
import '../models/offline_attendance_queue_item.dart';
import '../models/shift_model.dart';
import '../models/staff_model.dart';
import '../repositories/attendance_repository.dart';

class OfflineAttendanceQueueService {
  static const checkIn = 'check_in';
  static const checkOut = 'check_out';

  final OfflineAttendanceQueueStorage _storage =
      OfflineAttendanceQueueStorage();

  Future<List<OfflineAttendanceQueueItem>> pendingItems() {
    return _storage.readItems();
  }

  Future<void> queue({
    required String eventType,
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required DateTime eventTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    String? wifiSsid,
    String? selfiePath,
    String? notes,
  }) {
    final createdAt = DateTime.now();
    return _storage.add(
      OfflineAttendanceQueueItem(
        id: 'offline_${eventType}_${createdAt.microsecondsSinceEpoch}',
        eventType: eventType,
        staffId: staff.id,
        staffName: staff.name,
        staffCode: staff.staffCode,
        branchId: branch.id,
        shiftId: shift.id,
        eventTime: eventTime,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        isLocationValid: isLocationValid,
        isMockGps: isMockGps,
        wifiSsid: wifiSsid,
        selfiePath: selfiePath,
        notes: notes,
        createdAt: createdAt,
      ),
    );
  }

  Future<OfflineAttendanceSyncResult> syncForStaff({
    required AttendanceRepository repository,
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
  }) async {
    final items = await _storage.readItems();
    var synced = 0;
    var skipped = 0;
    var failed = 0;

    for (final item in items) {
      if (item.staffId != staff.id ||
          item.branchId != branch.id ||
          item.shiftId != shift.id) {
        skipped++;
        continue;
      }

      try {
        if (item.eventType == checkIn) {
          await repository.recordCheckIn(
            staff: staff,
            branch: branch,
            shift: shift,
            checkInTime: item.eventTime,
            latitude: item.latitude,
            longitude: item.longitude,
            deviceId: item.deviceId,
            isLocationValid: item.isLocationValid,
            isMockGps: item.isMockGps,
            wifiSsid: item.wifiSsid,
            selfiePath: item.selfiePath,
            notes: item.notes,
          );
        } else if (item.eventType == checkOut) {
          await repository.recordCheckOut(
            staff: staff,
            branch: branch,
            shift: shift,
            checkOutTime: item.eventTime,
            latitude: item.latitude,
            longitude: item.longitude,
            deviceId: item.deviceId,
            isLocationValid: item.isLocationValid,
            isMockGps: item.isMockGps,
            wifiSsid: item.wifiSsid,
            selfiePath: item.selfiePath,
            notes: item.notes,
          );
        } else {
          skipped++;
          continue;
        }

        synced++;
        await _storage.remove(item.id);
      } catch (_) {
        failed++;
      }
    }

    return OfflineAttendanceSyncResult(
      synced: synced,
      skipped: skipped,
      failed: failed,
    );
  }
}

class OfflineAttendanceSyncResult {
  final int synced;
  final int skipped;
  final int failed;

  const OfflineAttendanceSyncResult({
    required this.synced,
    required this.skipped,
    required this.failed,
  });
}
