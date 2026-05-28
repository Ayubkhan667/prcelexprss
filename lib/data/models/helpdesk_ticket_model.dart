class HelpdeskTicketModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String subject;
  final String category;
  final String message;
  final String status;
  final String? response;
  final String? respondedBy;
  final DateTime? respondedAt;
  final DateTime createdAt;

  const HelpdeskTicketModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.subject,
    required this.category,
    required this.message,
    required this.status,
    this.response,
    this.respondedBy,
    this.respondedAt,
    required this.createdAt,
  });

  factory HelpdeskTicketModel.fromMap(Map<String, dynamic> map) {
    return HelpdeskTicketModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      subject: map['subject'] ?? '',
      category: map['category'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'Open',
      response: map['response'],
      respondedBy: map['responded_by'],
      respondedAt: map['responded_at'] != null
          ? DateTime.tryParse(map['responded_at'])
          : null,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'subject': subject,
        'category': category,
        'message': message,
        'status': status,
        'response': response,
        'responded_by': respondedBy,
        'responded_at': respondedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
