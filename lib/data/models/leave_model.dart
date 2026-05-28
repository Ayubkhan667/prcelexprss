class LeaveModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String? attachmentUrl;
  final String status;
  final String? approvedBy;
  final String? rejectionReason;
  final DateTime createdAt;

  const LeaveModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    this.approvedBy,
    this.rejectionReason,
    required this.createdAt,
  });

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      leaveType: map['leave_type'] ?? '',
      fromDate: DateTime.tryParse(map['from_date'] ?? '') ?? DateTime.now(),
      toDate: DateTime.tryParse(map['to_date'] ?? '') ?? DateTime.now(),
      reason: map['reason'] ?? '',
      attachmentUrl: map['attachment_url'],
      status: map['status'] ?? 'Pending',
      approvedBy: map['approved_by'],
      rejectionReason: map['rejection_reason'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'leave_type': leaveType,
        'from_date': fromDate.toIso8601String(),
        'to_date': toDate.toIso8601String(),
        'reason': reason,
        'attachment_url': attachmentUrl,
        'status': status,
        'approved_by': approvedBy,
        'rejection_reason': rejectionReason,
        'created_at': createdAt.toIso8601String(),
      };

  int get totalDays => toDate.difference(fromDate).inDays + 1;

  LeaveModel copyWith({
    String? status,
    String? approvedBy,
    String? rejectionReason,
  }) {
    return LeaveModel(
      id: id,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      leaveType: leaveType,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
      attachmentUrl: attachmentUrl,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
    );
  }
}
