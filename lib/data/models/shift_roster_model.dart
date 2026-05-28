class ShiftRosterModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final DateTime rosterDate;
  final String shiftId;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String status;
  final String? notes;
  final String assignedBy;
  final DateTime createdAt;

  const ShiftRosterModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.rosterDate,
    required this.shiftId,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.assignedBy,
    required this.createdAt,
  });

  factory ShiftRosterModel.fromMap(Map<String, dynamic> map) {
    return ShiftRosterModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      rosterDate: DateTime.tryParse(map['roster_date'] ?? '') ?? DateTime.now(),
      shiftId: map['shift_id'] ?? '',
      shiftName: map['shift_name'] ?? '',
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      status: map['status'] ?? 'Scheduled',
      notes: map['notes'],
      assignedBy: map['assigned_by'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'roster_date': rosterDate.toIso8601String(),
        'shift_id': shiftId,
        'shift_name': shiftName,
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'notes': notes,
        'assigned_by': assignedBy,
        'created_at': createdAt.toIso8601String(),
      };
}
