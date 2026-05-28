import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/services/audit_log_service.dart';

class SupervisorPermissionsScreen extends ConsumerWidget {
  const SupervisorPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(hrSettingsProvider);
    final notifier = ref.read(hrSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('supervisor_permissions'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _introCard(),
          const SizedBox(height: 14),
          _permissionTile(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            subtitle: 'Supervisor dashboard and branch summary',
            value: settings.supervisorDashboardAccess,
            onChanged: (value) => _update(
              context,
              ref,
              'dashboard',
              () => notifier
                  .update((s) => s.copyWith(supervisorDashboardAccess: value)),
            ),
          ),
          _permissionTile(
            icon: Icons.people_outline,
            title: 'Team / Staff',
            subtitle: 'View scoped employees',
            value: settings.supervisorStaffAccess,
            onChanged: (value) => _update(
              context,
              ref,
              'staff',
              () => notifier
                  .update((s) => s.copyWith(supervisorStaffAccess: value)),
            ),
          ),
          _permissionTile(
            icon: Icons.event_note_outlined,
            title: 'Attendance',
            subtitle: 'View attendance for assigned scope',
            value: settings.supervisorAttendanceAccess,
            onChanged: (value) => _update(
              context,
              ref,
              'attendance',
              () => notifier
                  .update((s) => s.copyWith(supervisorAttendanceAccess: value)),
            ),
          ),
          _permissionTile(
            icon: Icons.approval_outlined,
            title: 'Leave Approval',
            subtitle: 'Approve or reject leave requests',
            value: settings.supervisorLeaveAccess,
            onChanged: (value) => _update(
              context,
              ref,
              'leaves',
              () => notifier
                  .update((s) => s.copyWith(supervisorLeaveAccess: value)),
            ),
          ),
          _permissionTile(
            icon: Icons.assignment_outlined,
            title: 'Task Cards',
            subtitle: 'Allow supervisor task module access',
            value: settings.supervisorTaskAccess,
            onChanged: (value) => _update(
              context,
              ref,
              'tasks',
              () => notifier
                  .update((s) => s.copyWith(supervisorTaskAccess: value)),
            ),
          ),
          _permissionTile(
            icon: Icons.insights_outlined,
            title: 'Reports',
            subtitle: 'Scoped reports and KPI visibility',
            value: settings.supervisorReportsAccess,
            onChanged: (value) => _update(
              context,
              ref,
              'reports',
              () => notifier
                  .update((s) => s.copyWith(supervisorReportsAccess: value)),
            ),
          ),
          _permissionTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Scoped alert visibility',
            value: settings.supervisorNotificationsAccess,
            onChanged: (value) => _update(
              context,
              ref,
              'notifications',
              () => notifier.update(
                  (s) => s.copyWith(supervisorNotificationsAccess: value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Admin yahan decide karega ke supervisor ko kaun se modules access hon. Settings tab supervisor ke liye hamesha visible rahega.',
        style: TextStyle(color: Colors.white, height: 1.35),
      ),
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile.adaptive(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  void _update(
    BuildContext context,
    WidgetRef ref,
    String module,
    VoidCallback apply,
  ) {
    apply();
    unawaited(
      AuditLogService.record(
        action: 'role_permission_update',
        title: 'Supervisor permission updated',
        description: 'Supervisor $module permission changed.',
        targetType: 'role_permission',
        targetName: module,
        actor: ref.read(currentUserProvider),
      ),
    );
    AppUtils.showSnackBar(
      context,
      'Supervisor permission updated',
    );
  }
}
