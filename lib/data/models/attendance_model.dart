class AttendanceModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double workingHours;
  final double overtimeHours;
  final int lateMinutes;
  final int earlyCheckoutMinutes;
  final String status;
  final String? selfieCheckInUrl;
  final String? selfieCheckOutUrl;
  final String? deviceId;
  final String? requiredWifiSsid;
  final String? checkInWifiSsid;
  final String? checkOutWifiSsid;
  final bool isLocationValid;
  final bool isMockGps;
  final int pausedMinutes;
  final DateTime? pauseStartedAt;
  final String dutyStatus;
  final String approvalStatus;
  final String? notes;
  final DateTime createdAt;

  const AttendanceModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    required this.workingHours,
    required this.overtimeHours,
    required this.lateMinutes,
    required this.earlyCheckoutMinutes,
    required this.status,
    this.selfieCheckInUrl,
    this.selfieCheckOutUrl,
    this.deviceId,
    this.requiredWifiSsid,
    this.checkInWifiSsid,
    this.checkOutWifiSsid,
    required this.isLocationValid,
    required this.isMockGps,
    this.pausedMinutes = 0,
    this.pauseStartedAt,
    this.dutyStatus = 'Completed',
    required this.approvalStatus,
    this.notes,
    required this.createdAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      checkInTime: map['check_in_time'] != null
          ? DateTime.tryParse(map['check_in_time'])
          : null,
      checkOutTime: map['check_out_time'] != null
          ? DateTime.tryParse(map['check_out_time'])
          : null,
      checkInLatitude: (map['check_in_latitude'] as num?)?.toDouble(),
      checkInLongitude: (map['check_in_longitude'] as num?)?.toDouble(),
      checkOutLatitude: (map['check_out_latitude'] as num?)?.toDouble(),
      checkOutLongitude: (map['check_out_longitude'] as num?)?.toDouble(),
      workingHours: (map['working_hours'] ?? 0).toDouble(),
      overtimeHours: (map['overtime_hours'] ?? 0).toDouble(),
      lateMinutes: map['late_minutes'] ?? 0,
      earlyCheckoutMinutes: map['early_checkout_minutes'] ?? 0,
      status: map['status'] ?? 'Absent',
      selfieCheckInUrl: map['selfie_check_in_url'],
      selfieCheckOutUrl: map['selfie_check_out_url'],
      deviceId: map['device_id'],
      requiredWifiSsid: map['required_wifi_ssid'],
      checkInWifiSsid: map['check_in_wifi_ssid'],
      checkOutWifiSsid: map['check_out_wifi_ssid'],
      isLocationValid: map['is_location_valid'] ?? true,
      isMockGps: map['is_mock_gps'] ?? false,
      pausedMinutes: map['paused_minutes'] ?? 0,
      pauseStartedAt: map['pause_started_at'] != null
          ? DateTime.tryParse(map['pause_started_at'])
          : null,
      dutyStatus: map['duty_status'] ?? 'Completed',
      approvalStatus: map['approval_status'] ?? 'Auto',
      notes: map['notes'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'date': date.toIso8601String(),
        'check_in_time': checkInTime?.toIso8601String(),
        'check_out_time': checkOutTime?.toIso8601String(),
        'check_in_latitude': checkInLatitude,
        'check_in_longitude': checkInLongitude,
        'check_out_latitude': checkOutLatitude,
        'check_out_longitude': checkOutLongitude,
        'working_hours': workingHours,
        'overtime_hours': overtimeHours,
        'late_minutes': lateMinutes,
        'early_checkout_minutes': earlyCheckoutMinutes,
        'status': status,
        'selfie_check_in_url': selfieCheckInUrl,
        'selfie_check_out_url': selfieCheckOutUrl,
        'device_id': deviceId,
        'required_wifi_ssid': requiredWifiSsid,
        'check_in_wifi_ssid': checkInWifiSsid,
        'check_out_wifi_ssid': checkOutWifiSsid,
        'is_location_valid': isLocationValid,
        'is_mock_gps': isMockGps,
        'paused_minutes': pausedMinutes,
        'pause_started_at': pauseStartedAt?.toIso8601String(),
        'duty_status': dutyStatus,
        'approval_status': approvalStatus,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  AttendanceModel copyWith({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    double? workingHours,
    double? overtimeHours,
    int? lateMinutes,
    int? earlyCheckoutMinutes,
    String? status,
    String? selfieCheckInUrl,
    String? selfieCheckOutUrl,
    String? deviceId,
    String? requiredWifiSsid,
    String? checkInWifiSsid,
    String? checkOutWifiSsid,
    bool? isLocationValid,
    bool? isMockGps,
    int? pausedMinutes,
    Object? pauseStartedAt = _sentinel,
    String? dutyStatus,
    String? approvalStatus,
    String? notes,
  }) {
    return AttendanceModel(
      id: id,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      date: date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      workingHours: workingHours ?? this.workingHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      earlyCheckoutMinutes: earlyCheckoutMinutes ?? this.earlyCheckoutMinutes,
      status: status ?? this.status,
      selfieCheckInUrl: selfieCheckInUrl ?? this.selfieCheckInUrl,
      selfieCheckOutUrl: selfieCheckOutUrl ?? this.selfieCheckOutUrl,
      deviceId: deviceId ?? this.deviceId,
      requiredWifiSsid: requiredWifiSsid ?? this.requiredWifiSsid,
      checkInWifiSsid: checkInWifiSsid ?? this.checkInWifiSsid,
      checkOutWifiSsid: checkOutWifiSsid ?? this.checkOutWifiSsid,
      isLocationValid: isLocationValid ?? this.isLocationValid,
      isMockGps: isMockGps ?? this.isMockGps,
      pausedMinutes: pausedMinutes ?? this.pausedMinutes,
      pauseStartedAt: identical(pauseStartedAt, _sentinel)
          ? this.pauseStartedAt
          : pauseStartedAt as DateTime?,
      dutyStatus: dutyStatus ?? this.dutyStatus,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

const _sentinel = Object();
