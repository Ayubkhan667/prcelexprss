class ShiftSwapRequestModel {
  final String id;
  final String requesterStaffId;
  final String requesterName;
  final String requesterCode;
  final String targetStaffId;
  final String targetName;
  final String targetCode;
  final DateTime rosterDate;
  final String requesterShiftId;
  final String requesterShiftName;
  final String? targetShiftId;
  final String? targetShiftName;
  final String reason;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime createdAt;

  const ShiftSwapRequestModel({
    required this.id,
    required this.requesterStaffId,
    required this.requesterName,
    required this.requesterCode,
    required this.targetStaffId,
    required this.targetName,
    required this.targetCode,
    required this.rosterDate,
    required this.requesterShiftId,
    required this.requesterShiftName,
    this.targetShiftId,
    this.targetShiftName,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.createdAt,
  });

  factory ShiftSwapRequestModel.fromMap(Map<String, dynamic> map) {
    return ShiftSwapRequestModel(
      id: map['id'] ?? '',
      requesterStaffId: map['requester_staff_id'] ?? '',
      requesterName: map['requester_name'] ?? '',
      requesterCode: map['requester_code'] ?? '',
      targetStaffId: map['target_staff_id'] ?? '',
      targetName: map['target_name'] ?? '',
      targetCode: map['target_code'] ?? '',
      rosterDate: DateTime.tryParse(map['roster_date'] ?? '') ?? DateTime.now(),
      requesterShiftId: map['requester_shift_id'] ?? '',
      requesterShiftName: map['requester_shift_name'] ?? '',
      targetShiftId: map['target_shift_id'],
      targetShiftName: map['target_shift_name'],
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
      approvedBy: map['approved_by'],
      approvedAt: map['approved_at'] != null
          ? DateTime.tryParse(map['approved_at'])
          : null,
      rejectionReason: map['rejection_reason'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'requester_staff_id': requesterStaffId,
        'requester_name': requesterName,
        'requester_code': requesterCode,
        'target_staff_id': targetStaffId,
        'target_name': targetName,
        'target_code': targetCode,
        'roster_date': rosterDate.toIso8601String(),
        'requester_shift_id': requesterShiftId,
        'requester_shift_name': requesterShiftName,
        'target_shift_id': targetShiftId,
        'target_shift_name': targetShiftName,
        'reason': reason,
        'status': status,
        'approved_by': approvedBy,
        'approved_at': approvedAt?.toIso8601String(),
        'rejection_reason': rejectionReason,
        'created_at': createdAt.toIso8601String(),
      };
}
