class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? staffId;
  final String? staffName;
  final bool isRead;
  final String targetRole;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.staffId,
    this.staffName,
    this.isRead = false,
    required this.targetRole,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      staffId: map['staff_id'],
      staffName: map['staff_name'],
      isRead: map['is_read'] ?? false,
      targetRole: map['target_role'] ?? 'all',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'staff_id': staffId,
        'staff_name': staffName,
        'is_read': isRead,
        'target_role': targetRole,
        'created_at': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        staffId: staffId,
        staffName: staffName,
        isRead: isRead ?? this.isRead,
        targetRole: targetRole,
        createdAt: createdAt,
      );

  static String iconForType(String type) {
    switch (type) {
      case 'checkin':
        return 'login';
      case 'checkout':
        return 'logout';
      case 'late':
        return 'alarm';
      case 'missing_checkout':
        return 'warning';
      case 'leave':
        return 'event_available';
      case 'overtime':
        return 'more_time';
      case 'salary':
        return 'payments';
      case 'loan':
        return 'account_balance';
      case 'task':
        return 'assignment';
      case 'location_alert':
        return 'location_off';
      case 'fake_gps':
        return 'gps_off';
      default:
        return 'notifications';
    }
  }
}
