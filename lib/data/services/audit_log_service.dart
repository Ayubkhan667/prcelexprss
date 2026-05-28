import '../local/audit_log_storage.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';

class AuditLogService {
  static Future<void> record({
    required String action,
    required String title,
    required String description,
    required String targetType,
    UserModel? actor,
    String? targetId,
    String? targetName,
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    return AuditLogStorage().addLog(
      AuditLogModel(
        id: 'audit_${now.microsecondsSinceEpoch}',
        action: action,
        title: title,
        description: description,
        actorName: actor?.name ?? 'System',
        actorRole: actor?.role ?? 'system',
        targetType: targetType,
        targetId: targetId,
        targetName: targetName,
        createdAt: now,
        metadata: metadata,
      ),
    );
  }
}
