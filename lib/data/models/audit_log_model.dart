class AuditLogModel {
  final String id;
  final String action;
  final String title;
  final String description;
  final String actorName;
  final String actorRole;
  final String targetType;
  final String? targetId;
  final String? targetName;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.title,
    required this.description,
    required this.actorName,
    required this.actorRole,
    required this.targetType,
    this.targetId,
    this.targetName,
    required this.createdAt,
    this.metadata = const {},
  });

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      id: map['id'] ?? '',
      action: map['action'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      actorName: map['actor_name'] ?? 'System',
      actorRole: map['actor_role'] ?? 'system',
      targetType: map['target_type'] ?? 'system',
      targetId: map['target_id'],
      targetName: map['target_name'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? const {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'action': action,
        'title': title,
        'description': description,
        'actor_name': actorName,
        'actor_role': actorRole,
        'target_type': targetType,
        'target_id': targetId,
        'target_name': targetName,
        'created_at': createdAt.toIso8601String(),
        'metadata': metadata,
      };
}
