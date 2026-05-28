class OfflineAttendanceQueueItem {
  final String id;
  final String eventType;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String branchId;
  final String shiftId;
  final DateTime eventTime;
  final double latitude;
  final double longitude;
  final String deviceId;
  final bool isLocationValid;
  final bool isMockGps;
  final String? wifiSsid;
  final String? selfiePath;
  final String? notes;
  final DateTime createdAt;

  const OfflineAttendanceQueueItem({
    required this.id,
    required this.eventType,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.branchId,
    required this.shiftId,
    required this.eventTime,
    required this.latitude,
    required this.longitude,
    required this.deviceId,
    required this.isLocationValid,
    required this.isMockGps,
    this.wifiSsid,
    this.selfiePath,
    this.notes,
    required this.createdAt,
  });

  factory OfflineAttendanceQueueItem.fromMap(Map<String, dynamic> map) {
    return OfflineAttendanceQueueItem(
      id: map['id'] ?? '',
      eventType: map['event_type'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      branchId: map['branch_id'] ?? '',
      shiftId: map['shift_id'] ?? '',
      eventTime: DateTime.tryParse(map['event_time'] ?? '') ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      deviceId: map['device_id'] ?? '',
      isLocationValid: map['is_location_valid'] ?? true,
      isMockGps: map['is_mock_gps'] ?? false,
      wifiSsid: map['wifi_ssid'],
      selfiePath: map['selfie_path'],
      notes: map['notes'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'event_type': eventType,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'branch_id': branchId,
        'shift_id': shiftId,
        'event_time': eventTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'device_id': deviceId,
        'is_location_valid': isLocationValid,
        'is_mock_gps': isMockGps,
        'wifi_ssid': wifiSsid,
        'selfie_path': selfiePath,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}
