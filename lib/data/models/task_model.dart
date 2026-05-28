class TaskModel {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String assignedBy;
  final String assignedByRole;
  final bool assignedToAll;
  final bool isDailyTask;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? terminatedAt;

  const TaskModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.assignedBy,
    required this.assignedByRole,
    required this.assignedToAll,
    required this.isDailyTask,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.terminatedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      groupId: map['group_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      assignedBy: map['assigned_by'] ?? '',
      assignedByRole: map['assigned_by_role'] ?? '',
      assignedToAll: map['assigned_to_all'] ?? false,
      isDailyTask: map['is_daily_task'] ?? false,
      dueDate: DateTime.tryParse(map['due_date'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'])
          : null,
      terminatedAt: map['terminated_at'] != null
          ? DateTime.tryParse(map['terminated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'group_id': groupId,
        'title': title,
        'description': description,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'assigned_by': assignedBy,
        'assigned_by_role': assignedByRole,
        'assigned_to_all': assignedToAll,
        'is_daily_task': isDailyTask,
        'due_date': dueDate.toIso8601String(),
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'terminated_at': terminatedAt?.toIso8601String(),
      };

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    DateTime? completedAt,
    DateTime? terminatedAt,
  }) {
    return TaskModel(
      id: id,
      groupId: groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      assignedBy: assignedBy,
      assignedByRole: assignedByRole,
      assignedToAll: assignedToAll,
      isDailyTask: isDailyTask,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      terminatedAt: terminatedAt ?? this.terminatedAt,
    );
  }
}
