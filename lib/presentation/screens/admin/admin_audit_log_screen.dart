import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/local/audit_log_storage.dart';
import '../../../data/models/audit_log_model.dart';

class AdminAuditLogScreen extends StatefulWidget {
  const AdminAuditLogScreen({super.key});

  @override
  State<AdminAuditLogScreen> createState() => _AdminAuditLogScreenState();
}

class _AdminAuditLogScreenState extends State<AdminAuditLogScreen> {
  final AuditLogStorage _storage = AuditLogStorage();
  late Future<List<AuditLogModel>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _storage.readLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('admin_audit_logs')),
        actions: [
          IconButton(
            tooltip: 'Clear logs',
            onPressed: _confirmClear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<AuditLogModel>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? const [];
          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'No audit logs yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (_, index) => _logCard(logs[index]),
          );
        },
      ),
    );
  }

  Widget _logCard(AuditLogModel log) {
    final color = _colorForAction(log.action);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconForAction(log.action), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(Icons.person_outline, log.actorName),
                    _chip(Icons.verified_user_outlined, log.actorRole),
                    if (log.targetName != null)
                      _chip(Icons.flag_outlined, log.targetName!),
                    _chip(
                      Icons.schedule_outlined,
                      DateFormat('dd MMM yyyy, hh:mm a').format(log.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Clear Audit Logs',
      message: 'Clear locally stored admin audit logs from this device?',
      confirmText: 'Clear',
      isDangerous: true,
    );
    if (confirmed != true) {
      return;
    }

    await _storage.clear();
    if (!mounted) {
      return;
    }
    setState(() => _logsFuture = _storage.readLogs());
    AppUtils.showSnackBar(context, 'Audit logs cleared');
  }

  IconData _iconForAction(String action) {
    if (action.contains('staff')) return Icons.badge_outlined;
    if (action.contains('task')) return Icons.assignment_outlined;
    if (action.contains('overtime')) return Icons.more_time_outlined;
    if (action.contains('notification')) return Icons.notifications_outlined;
    if (action.contains('export')) return Icons.file_download_outlined;
    return Icons.history_outlined;
  }

  Color _colorForAction(String action) {
    if (action.contains('reject') || action.contains('terminate')) {
      return AppColors.error;
    }
    if (action.contains('approve') || action.contains('export')) {
      return AppColors.success;
    }
    if (action.contains('notification')) return AppColors.accent;
    return AppColors.primary;
  }
}
