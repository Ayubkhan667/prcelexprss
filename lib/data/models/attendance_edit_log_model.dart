class AttendanceEditLogModel {
  final String id;
  final String attendanceId;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String editedBy;
  final String editedByRole;
  final String fieldChanged;
  final String oldValue;
  final String newValue;
  final String reason;
  final String approvalStatus;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;

  const AttendanceEditLogModel({
    required this.id,
    required this.attendanceId,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.editedBy,
    required this.editedByRole,
    required this.fieldChanged,
    required this.oldValue,
    required this.newValue,
    required this.reason,
    required this.approvalStatus,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
  });

  factory AttendanceEditLogModel.fromMap(Map<String, dynamic> map) {
    return AttendanceEditLogModel(
      id: map['id'] ?? '',
      attendanceId: map['attendance_id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      editedBy: map['edited_by'] ?? '',
      editedByRole: map['edited_by_role'] ?? '',
      fieldChanged: map['field_changed'] ?? '',
      oldValue: map['old_value'] ?? '',
      newValue: map['new_value'] ?? '',
      reason: map['reason'] ?? '',
      approvalStatus: map['approval_status'] ?? 'Pending',
      approvedBy: map['approved_by'],
      approvedAt: map['approved_at'] != null
          ? DateTime.tryParse(map['approved_at'])
          : null,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'attendance_id': attendanceId,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'edited_by': editedBy,
        'edited_by_role': editedByRole,
        'field_changed': fieldChanged,
        'old_value': oldValue,
        'new_value': newValue,
        'reason': reason,
        'approval_status': approvalStatus,
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  AttendanceEditLogModel copyWith({
    String? approvalStatus,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return AttendanceEditLogModel(
      id: id,
      attendanceId: attendanceId,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      editedBy: editedBy,
      editedByRole: editedByRole,
      fieldChanged: fieldChanged,
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt,
    );
  }
}
