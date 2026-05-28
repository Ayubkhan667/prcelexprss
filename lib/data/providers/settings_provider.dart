import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/tap_effects.dart';
import '../local/hr_settings_storage.dart';

class HrSettings {
  final int gracePeriodMinutes;
  final double standardHours;
  final bool gpsEnforcement;
  final bool selfieRequired;
  final int salaryCycleDay;
  final double overtimeAfterHours;
  final double absenceDeductionPercent;
  final bool pushNotifications;
  final bool smsAlerts;
  final bool deviceBinding;
  final bool mockGpsDetection;
  final bool exportPdf;
  final bool exportExcel;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final List<String> departments;
  final bool supervisorDashboardAccess;
  final bool supervisorStaffAccess;
  final bool supervisorAttendanceAccess;
  final bool supervisorLeaveAccess;
  final bool supervisorTaskAccess;
  final bool supervisorReportsAccess;
  final bool supervisorNotificationsAccess;
  final bool soundEnabled;

  const HrSettings({
    this.gracePeriodMinutes = 15,
    this.standardHours = 8.0,
    this.gpsEnforcement = true,
    this.selfieRequired = true,
    this.salaryCycleDay = 1,
    this.overtimeAfterHours = 8.0,
    this.absenceDeductionPercent = 100.0,
    this.pushNotifications = true,
    this.smsAlerts = true,
    this.deviceBinding = true,
    this.mockGpsDetection = true,
    this.exportPdf = true,
    this.exportExcel = true,
    this.companyName = 'Parcel Express',
    this.companyAddress = 'Al Khuwair, Muscat, Oman',
    this.companyPhone = '+968 2412 3456',
    this.companyEmail = 'hr@parcelexpress.com',
    this.supervisorDashboardAccess = true,
    this.supervisorStaffAccess = true,
    this.supervisorAttendanceAccess = true,
    this.supervisorLeaveAccess = true,
    this.supervisorTaskAccess = false,
    this.supervisorReportsAccess = true,
    this.supervisorNotificationsAccess = true,
    this.soundEnabled = true,
    this.departments = const [
      'Operations',
      'HR & Admin',
      'Finance',
      'IT',
      'Sales',
      'Logistics',
    ],
  });

  HrSettings copyWith({
    int? gracePeriodMinutes,
    double? standardHours,
    bool? gpsEnforcement,
    bool? selfieRequired,
    int? salaryCycleDay,
    double? overtimeAfterHours,
    double? absenceDeductionPercent,
    bool? pushNotifications,
    bool? smsAlerts,
    bool? deviceBinding,
    bool? mockGpsDetection,
    bool? exportPdf,
    bool? exportExcel,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    List<String>? departments,
    bool? supervisorDashboardAccess,
    bool? supervisorStaffAccess,
    bool? supervisorAttendanceAccess,
    bool? supervisorLeaveAccess,
    bool? supervisorTaskAccess,
    bool? supervisorReportsAccess,
    bool? supervisorNotificationsAccess,
    bool? soundEnabled,
  }) =>
      HrSettings(
        gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
        standardHours: standardHours ?? this.standardHours,
        gpsEnforcement: gpsEnforcement ?? this.gpsEnforcement,
        selfieRequired: selfieRequired ?? this.selfieRequired,
        salaryCycleDay: salaryCycleDay ?? this.salaryCycleDay,
        overtimeAfterHours: overtimeAfterHours ?? this.overtimeAfterHours,
        absenceDeductionPercent:
            absenceDeductionPercent ?? this.absenceDeductionPercent,
        pushNotifications: pushNotifications ?? this.pushNotifications,
        smsAlerts: smsAlerts ?? this.smsAlerts,
        deviceBinding: deviceBinding ?? this.deviceBinding,
        mockGpsDetection: mockGpsDetection ?? this.mockGpsDetection,
        exportPdf: exportPdf ?? this.exportPdf,
        exportExcel: exportExcel ?? this.exportExcel,
        companyName: companyName ?? this.companyName,
        companyAddress: companyAddress ?? this.companyAddress,
        companyPhone: companyPhone ?? this.companyPhone,
        companyEmail: companyEmail ?? this.companyEmail,
        supervisorDashboardAccess:
            supervisorDashboardAccess ?? this.supervisorDashboardAccess,
        supervisorStaffAccess:
            supervisorStaffAccess ?? this.supervisorStaffAccess,
        supervisorAttendanceAccess:
            supervisorAttendanceAccess ?? this.supervisorAttendanceAccess,
        supervisorLeaveAccess:
            supervisorLeaveAccess ?? this.supervisorLeaveAccess,
        supervisorTaskAccess: supervisorTaskAccess ?? this.supervisorTaskAccess,
        supervisorReportsAccess:
            supervisorReportsAccess ?? this.supervisorReportsAccess,
        supervisorNotificationsAccess:
            supervisorNotificationsAccess ?? this.supervisorNotificationsAccess,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        departments: departments ?? this.departments,
      );

  factory HrSettings.fromMap(Map<String, dynamic> map) {
    return HrSettings(
      gracePeriodMinutes: map['grace_period_minutes'] ?? 15,
      standardHours: (map['standard_hours'] ?? 8.0).toDouble(),
      gpsEnforcement: map['gps_enforcement'] ?? true,
      selfieRequired: map['selfie_required'] ?? true,
      salaryCycleDay: map['salary_cycle_day'] ?? 1,
      overtimeAfterHours: (map['overtime_after_hours'] ?? 8.0).toDouble(),
      absenceDeductionPercent:
          (map['absence_deduction_percent'] ?? 100.0).toDouble(),
      pushNotifications: map['push_notifications'] ?? true,
      smsAlerts: map['sms_alerts'] ?? true,
      deviceBinding: map['device_binding'] ?? true,
      mockGpsDetection: map['mock_gps_detection'] ?? true,
      exportPdf: map['export_pdf'] ?? true,
      exportExcel: map['export_excel'] ?? true,
      companyName: map['company_name'] ?? 'Parcel Express',
      companyAddress: map['company_address'] ?? 'Al Khuwair, Muscat, Oman',
      companyPhone: map['company_phone'] ?? '+968 2412 3456',
      companyEmail: map['company_email'] ?? 'hr@parcelexpress.com',
      supervisorDashboardAccess: map['supervisor_dashboard_access'] ?? true,
      supervisorStaffAccess: map['supervisor_staff_access'] ?? true,
      supervisorAttendanceAccess: map['supervisor_attendance_access'] ?? true,
      supervisorLeaveAccess: map['supervisor_leave_access'] ?? true,
      supervisorTaskAccess: map['supervisor_task_access'] ?? false,
      supervisorReportsAccess: map['supervisor_reports_access'] ?? true,
      supervisorNotificationsAccess:
          map['supervisor_notifications_access'] ?? true,
      soundEnabled: map['sound_enabled'] ?? true,
      departments: ((map['departments'] as List<dynamic>?)?.isNotEmpty ?? false)
          ? (map['departments'] as List<dynamic>)
              .map((department) => department.toString())
              .toList()
          : const [
              'Operations',
              'HR & Admin',
              'Finance',
              'IT',
              'Sales',
              'Logistics',
            ],
    );
  }

  Map<String, dynamic> toMap() => {
        'grace_period_minutes': gracePeriodMinutes,
        'standard_hours': standardHours,
        'gps_enforcement': gpsEnforcement,
        'selfie_required': selfieRequired,
        'salary_cycle_day': salaryCycleDay,
        'overtime_after_hours': overtimeAfterHours,
        'absence_deduction_percent': absenceDeductionPercent,
        'push_notifications': pushNotifications,
        'sms_alerts': smsAlerts,
        'device_binding': deviceBinding,
        'mock_gps_detection': mockGpsDetection,
        'export_pdf': exportPdf,
        'export_excel': exportExcel,
        'company_name': companyName,
        'company_address': companyAddress,
        'company_phone': companyPhone,
        'company_email': companyEmail,
        'supervisor_dashboard_access': supervisorDashboardAccess,
        'supervisor_staff_access': supervisorStaffAccess,
        'supervisor_attendance_access': supervisorAttendanceAccess,
        'supervisor_leave_access': supervisorLeaveAccess,
        'supervisor_task_access': supervisorTaskAccess,
        'supervisor_reports_access': supervisorReportsAccess,
        'supervisor_notifications_access': supervisorNotificationsAccess,
        'sound_enabled': soundEnabled,
        'departments': departments,
      };
}

class HrSettingsNotifier extends Notifier<HrSettings> {
  HrSettingsNotifier({required HrSettings initial}) : _initial = initial;

  final HrSettings _initial;

  @override
  HrSettings build() => _initial;

  void update(HrSettings Function(HrSettings) fn) {
    final next = fn(state);
    state = next;
    SoundService.instance.soundEnabled = next.soundEnabled;
    unawaited(HrSettingsStorage().saveSettingsMap(next.toMap()));
  }
}

final hrSettingsProvider = NotifierProvider<HrSettingsNotifier, HrSettings>(() {
  return HrSettingsNotifier(initial: const HrSettings());
});
