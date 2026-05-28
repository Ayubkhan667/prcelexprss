class ShiftModel {
  final String id;
  final String shiftName;
  final String startTime;
  final String endTime;
  final double standardHours;
  final int graceMinutes;
  final String status;

  const ShiftModel({
    required this.id,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.standardHours,
    required this.graceMinutes,
    required this.status,
  });

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      id: map['id'] ?? '',
      shiftName: map['shift_name'] ?? '',
      startTime: map['start_time'] ?? '09:00',
      endTime: map['end_time'] ?? '17:00',
      standardHours: (map['standard_hours'] ?? 8).toDouble(),
      graceMinutes: map['grace_minutes'] ?? 15,
      status: map['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'shift_name': shiftName,
    'start_time': startTime,
    'end_time': endTime,
    'standard_hours': standardHours,
    'grace_minutes': graceMinutes,
    'status': status,
  };
}
