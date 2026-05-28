class KpiModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String month;
  final double attendanceRate;
  final double absenceRate;
  final int lateCount;
  final int earlyCheckoutCount;
  final double totalWorkingHours;
  final double avgDailyWorkingHours;
  final double overtimeHours;
  final int missingCheckoutCount;
  final int validLocationCount;
  final int invalidLocationCount;
  final int fakeGpsCount;
  final int leaveCount;
  final int taskAssignedCount;
  final int taskCompletedCount;
  final double taskCompletionRate;
  final double attendanceScore;
  final double punctualityScore;
  final double overtimeScore;
  final double locationScore;
  final double disciplineScore;
  final double taskScore;
  final double totalKpiScore;
  final String rating;
  final DateTime createdAt;

  const KpiModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.month,
    required this.attendanceRate,
    required this.absenceRate,
    required this.lateCount,
    required this.earlyCheckoutCount,
    required this.totalWorkingHours,
    required this.avgDailyWorkingHours,
    required this.overtimeHours,
    required this.missingCheckoutCount,
    required this.validLocationCount,
    required this.invalidLocationCount,
    required this.fakeGpsCount,
    required this.leaveCount,
    required this.taskAssignedCount,
    required this.taskCompletedCount,
    required this.taskCompletionRate,
    required this.attendanceScore,
    required this.punctualityScore,
    required this.overtimeScore,
    required this.locationScore,
    required this.disciplineScore,
    required this.taskScore,
    required this.totalKpiScore,
    required this.rating,
    required this.createdAt,
  });

  factory KpiModel.fromMap(Map<String, dynamic> map) {
    return KpiModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      month: map['month'] ?? '',
      attendanceRate: (map['attendance_rate'] ?? 0).toDouble(),
      absenceRate: (map['absence_rate'] ?? 0).toDouble(),
      lateCount: map['late_count'] ?? 0,
      earlyCheckoutCount: map['early_checkout_count'] ?? 0,
      totalWorkingHours: (map['total_working_hours'] ?? 0).toDouble(),
      avgDailyWorkingHours: (map['avg_daily_working_hours'] ?? 0).toDouble(),
      overtimeHours: (map['overtime_hours'] ?? 0).toDouble(),
      missingCheckoutCount: map['missing_checkout_count'] ?? 0,
      validLocationCount: map['valid_location_count'] ?? 0,
      invalidLocationCount: map['invalid_location_count'] ?? 0,
      fakeGpsCount: map['fake_gps_count'] ?? 0,
      leaveCount: map['leave_count'] ?? 0,
      taskAssignedCount: map['task_assigned_count'] ?? 0,
      taskCompletedCount: map['task_completed_count'] ?? 0,
      taskCompletionRate: (map['task_completion_rate'] ?? 0).toDouble(),
      attendanceScore: (map['attendance_score'] ?? 0).toDouble(),
      punctualityScore: (map['punctuality_score'] ?? 0).toDouble(),
      overtimeScore: (map['overtime_score'] ?? 0).toDouble(),
      locationScore: (map['location_score'] ?? 0).toDouble(),
      disciplineScore: (map['discipline_score'] ?? 0).toDouble(),
      taskScore: (map['task_score'] ?? 0).toDouble(),
      totalKpiScore: (map['total_kpi_score'] ?? 0).toDouble(),
      rating: map['rating'] ?? 'Poor',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'month': month,
        'attendance_rate': attendanceRate,
        'absence_rate': absenceRate,
        'late_count': lateCount,
        'early_checkout_count': earlyCheckoutCount,
        'total_working_hours': totalWorkingHours,
        'avg_daily_working_hours': avgDailyWorkingHours,
        'overtime_hours': overtimeHours,
        'missing_checkout_count': missingCheckoutCount,
        'valid_location_count': validLocationCount,
        'invalid_location_count': invalidLocationCount,
        'fake_gps_count': fakeGpsCount,
        'leave_count': leaveCount,
        'task_assigned_count': taskAssignedCount,
        'task_completed_count': taskCompletedCount,
        'task_completion_rate': taskCompletionRate,
        'attendance_score': attendanceScore,
        'punctuality_score': punctualityScore,
        'overtime_score': overtimeScore,
        'location_score': locationScore,
        'discipline_score': disciplineScore,
        'task_score': taskScore,
        'total_kpi_score': totalKpiScore,
        'rating': rating,
        'created_at': createdAt.toIso8601String(),
      };

  KpiModel copyWith({
    double? attendanceScore,
    double? punctualityScore,
    double? overtimeScore,
    double? locationScore,
    double? disciplineScore,
    int? taskAssignedCount,
    int? taskCompletedCount,
    double? taskCompletionRate,
    double? taskScore,
    double? totalKpiScore,
    String? rating,
  }) {
    return KpiModel(
      id: id,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      month: month,
      attendanceRate: attendanceRate,
      absenceRate: absenceRate,
      lateCount: lateCount,
      earlyCheckoutCount: earlyCheckoutCount,
      totalWorkingHours: totalWorkingHours,
      avgDailyWorkingHours: avgDailyWorkingHours,
      overtimeHours: overtimeHours,
      missingCheckoutCount: missingCheckoutCount,
      validLocationCount: validLocationCount,
      invalidLocationCount: invalidLocationCount,
      fakeGpsCount: fakeGpsCount,
      leaveCount: leaveCount,
      taskAssignedCount: taskAssignedCount ?? this.taskAssignedCount,
      taskCompletedCount: taskCompletedCount ?? this.taskCompletedCount,
      taskCompletionRate: taskCompletionRate ?? this.taskCompletionRate,
      attendanceScore: attendanceScore ?? this.attendanceScore,
      punctualityScore: punctualityScore ?? this.punctualityScore,
      overtimeScore: overtimeScore ?? this.overtimeScore,
      locationScore: locationScore ?? this.locationScore,
      disciplineScore: disciplineScore ?? this.disciplineScore,
      taskScore: taskScore ?? this.taskScore,
      totalKpiScore: totalKpiScore ?? this.totalKpiScore,
      rating: rating ?? this.rating,
      createdAt: createdAt,
    );
  }
}
