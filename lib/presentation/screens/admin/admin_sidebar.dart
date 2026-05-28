import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/api_config_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/locale_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../widgets/common/account_actions.dart';
import 'admin_audit_log_screen.dart';
import 'announcement_management_screen.dart';
import 'attendance_edit_log_screen.dart';
import 'backup_export_screen.dart';
import 'branch_management_screen.dart';
import 'document_alert_screen.dart';
import 'holiday_calendar_screen.dart';
import 'manual_attendance_screen.dart';
import 'overtime_approval_screen.dart';
import 'shift_management_screen.dart';
import 'supervisor_permissions_screen.dart';
import 'task_management_screen.dart';
import '../shared/expense_approval_screen.dart';
import '../shared/helpdesk_screen.dart';
import '../shared/notification_screen.dart';
import '../shared/shift_roster_screen.dart';

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(hrSettingsProvider);
    final notifier = ref.read(hrSettingsProvider.notifier);
    final apiConfig = ref.watch(apiConfigProvider);
    final isAdmin = user?.role == AppConstants.roleAdmin;
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final isArabic = locale.languageCode == 'ar';
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    void push(Widget screen) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: Text(
                          AppUtils.getInitials(user?.name ?? 'A'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Admin',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (user?.role ?? 'admin').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // ── Quick Access ─────────────────────────────────────
                  _label('Quick Access'),
                  _navTile(context,
                    icon: Icons.notifications_outlined,
                    label: context.tr('notifications'),
                    color: AppColors.primary,
                    badge: unreadCount,
                    onTap: () => push(const NotificationScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.edit_calendar_outlined,
                    label: context.tr('manual_attendance_entry'),
                    color: AppColors.accent,
                    onTap: () => push(const ManualAttendanceScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.history_edu_outlined,
                    label: context.tr('attendance_edit_logs'),
                    color: AppColors.warning,
                    onTap: () => push(const AttendanceEditLogScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.receipt_long_outlined,
                    label: 'Expense Approvals',
                    color: const Color(0xFF00695C),
                    onTap: () => push(const ExpenseApprovalScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.assignment_outlined,
                    label: context.tr('task_cards'),
                    color: AppColors.primaryDark,
                    onTap: () => push(const TaskManagementScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.more_time_outlined,
                    label: context.tr('overtime_approval'),
                    color: AppColors.success,
                    onTap: () => push(const OvertimeApprovalScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.calendar_month_outlined,
                    label: 'Roster & Swaps',
                    color: const Color(0xFF0E7490),
                    onTap: () => push(const ShiftRosterScreen(adminMode: true)),
                  ),
                  _navTile(context,
                    icon: Icons.event_outlined,
                    label: context.tr('holiday_calendar'),
                    color: const Color(0xFF6A1B9A),
                    onTap: () => push(const HolidayCalendarScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.badge_outlined,
                    label: 'Document Alerts',
                    color: AppColors.warning,
                    onTap: () => push(const DocumentAlertScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.campaign_outlined,
                    label: 'Announcements',
                    color: AppColors.primaryDark,
                    onTap: () => push(const AnnouncementManagementScreen()),
                  ),
                  _navTile(context,
                    icon: Icons.support_agent_outlined,
                    label: 'Helpdesk',
                    color: const Color(0xFFCC5500),
                    onTap: () => push(const HelpdeskScreen(adminMode: true)),
                  ),

                  const _SectionDivider(),

                  // ── HR Configuration ─────────────────────────────────
                  if (isAdmin) ...[
                    _label(context.tr('hr_configuration')),
                    _settingsTile(context,
                      icon: Icons.business,
                      title: context.tr('company_settings'),
                      subtitle: settings.companyName,
                      onTap: () {
                        Navigator.pop(context);
                        _showCompanySheet(context, settings, notifier);
                      },
                    ),
                    _divider(),
                    _settingsTile(context,
                      icon: Icons.schedule,
                      title: context.tr('shift_management'),
                      subtitle: context.tr('create_edit_shifts'),
                      onTap: () => push(const ShiftManagementScreen()),
                    ),
                    _divider(),
                    _settingsTile(context,
                      icon: Icons.location_on_outlined,
                      title: context.tr('branch_management'),
                      subtitle: context.tr('manage_branches_geofences'),
                      onTap: () => push(const BranchManagementScreen()),
                    ),
                    _divider(),
                    _settingsTile(context,
                      icon: Icons.category_outlined,
                      title: context.tr('departments'),
                      subtitle:
                          '${settings.departments.length} ${context.tr('departments').toLowerCase()}',
                      onTap: () {
                        Navigator.pop(context);
                        _showDepartmentsSheet(context, settings, notifier);
                      },
                    ),
                    _divider(),
                    _settingsTile(context,
                      icon: Icons.admin_panel_settings_outlined,
                      title: context.tr('supervisor_permissions'),
                      subtitle: context.tr('control_supervisor_access'),
                      onTap: () => push(const SupervisorPermissionsScreen()),
                    ),
                    const _SectionDivider(),
                  ],

                  // ── Attendance Rules ──────────────────────────────────
                  if (isAdmin) ...[
                    _label(context.tr('attendance_rules')),
                    _settingsTile(context,
                      icon: Icons.access_time,
                      title: context.tr('grace_period'),
                      subtitle:
                          '${settings.gracePeriodMinutes} ${context.tr('minutes_unit')}',
                      onTap: () {
                        Navigator.pop(context);
                        _showPickerSheet(
                          context: context,
                          title: context.tr('grace_period'),
                          icon: Icons.access_time,
                          unit: context.tr('minutes_unit'),
                          options: [5, 10, 15, 20, 30, 45, 60],
                          current: settings.gracePeriodMinutes,
                          onSelect: (v) => notifier
                              .update((s) => s.copyWith(gracePeriodMinutes: v)),
                        );
                      },
                    ),
                    _divider(),
                    _settingsTile(context,
                      icon: Icons.timer_outlined,
                      title: context.tr('standard_hours_title'),
                      subtitle:
                          '${settings.standardHours.toStringAsFixed(0)} ${context.tr('hours_per_day_unit')}',
                      onTap: () {
                        Navigator.pop(context);
                        _showPickerSheet(
                          context: context,
                          title: context.tr('standard_working_hours'),
                          icon: Icons.timer_outlined,
                          unit: context.tr('hours_per_day_unit'),
                          options: [6, 7, 8, 9, 10, 12],
                          current: settings.standardHours.toInt(),
                          onSelect: (v) => notifier.update(
                              (s) => s.copyWith(standardHours: v.toDouble())),
                        );
                      },
                    ),
                    _divider(),
                    _toggleTile(context,
                      icon: Icons.gps_fixed,
                      title: context.tr('gps_enforcement'),
                      subtitle: context.tr('managed_backend_security'),
                      value: settings.gpsEnforcement,
                      onChanged: null,
                    ),
                    _divider(),
                    _toggleTile(context,
                      icon: Icons.camera_alt_outlined,
                      title: context.tr('selfie_requirement'),
                      subtitle: settings.selfieRequired
                          ? context.tr('selfie_required_subtitle')
                          : context.tr('selfie_not_required'),
                      value: settings.selfieRequired,
                      onChanged: (v) =>
                          notifier.update((s) => s.copyWith(selfieRequired: v)),
                    ),
                    const _SectionDivider(),
                  ],

                  // ── Salary & Payroll ──────────────────────────────────
                  if (isAdmin) ...[
                    _label(context.tr('salary_payroll')),
                    _settingsTile(context,
                      icon: Icons.payments,
                      title: context.tr('salary_cycle'),
                      subtitle: '${_ordinal(settings.salaryCycleDay)} of every month',
                      onTap: () {
                        Navigator.pop(context);
                        _showPickerSheet(
                          context: context,
                          title: context.tr('salary_cycle_day'),
                          icon: Icons.payments,
                          unit: 'of each month',
                          options: List.generate(28, (i) => i + 1),
                          current: settings.salaryCycleDay,
                          onSelect: (v) => notifier
                              .update((s) => s.copyWith(salaryCycleDay: v)),
                        );
                      },
                    ),
                    _divider(),
                    _settingsTile(context,
                      icon: Icons.account_balance,
                      title: context.tr('overtime_policy'),
                      subtitle:
                          'After ${settings.overtimeAfterHours.toStringAsFixed(0)} ${context.tr('hours_unit')}',
                      onTap: () {
                        Navigator.pop(context);
                        _showPickerSheet(
                          context: context,
                          title: context.tr('overtime_starts_after'),
                          icon: Icons.account_balance,
                          unit: context.tr('hours_unit'),
                          options: [6, 7, 8, 9, 10],
                          current: settings.overtimeAfterHours.toInt(),
                          onSelect: (v) => notifier.update(
                              (s) => s.copyWith(overtimeAfterHours: v.toDouble())),
                        );
                      },
                    ),
                    _divider(),
                    _settingsTile(context,
                      icon: Icons.remove_circle_outline,
                      title: context.tr('deduction_rules'),
                      subtitle:
                          '${settings.absenceDeductionPercent.toStringAsFixed(0)}% ${context.tr('percent_per_absent')}',
                      onTap: () {
                        Navigator.pop(context);
                        _showPickerSheet(
                          context: context,
                          title: context.tr('absence_deduction'),
                          icon: Icons.remove_circle_outline,
                          unit: context.tr('percent_per_absent'),
                          options: [25, 50, 75, 100],
                          current: settings.absenceDeductionPercent.toInt(),
                          onSelect: (v) => notifier.update((s) =>
                              s.copyWith(absenceDeductionPercent: v.toDouble())),
                        );
                      },
                    ),
                    const _SectionDivider(),
                  ],

                  // ── Notifications ─────────────────────────────────────
                  _label(context.tr('notifications')),
                  _toggleTile(context,
                    icon: Icons.notifications_outlined,
                    title: context.tr('push_notifications_title'),
                    subtitle: settings.pushNotifications
                        ? context.tr('notifications_enabled_subtitle')
                        : context.tr('notifications_disabled_subtitle'),
                    value: settings.pushNotifications,
                    onChanged: (v) =>
                        notifier.update((s) => s.copyWith(pushNotifications: v)),
                  ),
                  _divider(),
                  _toggleTile(context,
                    icon: Icons.volume_up_outlined,
                    title: context.tr('app_sounds'),
                    subtitle: settings.soundEnabled
                        ? context.tr('sounds_on_subtitle')
                        : context.tr('sounds_off_subtitle'),
                    value: settings.soundEnabled,
                    onChanged: (v) =>
                        notifier.update((s) => s.copyWith(soundEnabled: v)),
                  ),
                  _divider(),
                  _toggleTile(context,
                    icon: Icons.sms_outlined,
                    title: context.tr('sms_alerts'),
                    subtitle: context.tr('sms_gateway_required'),
                    value: settings.smsAlerts,
                    onChanged: null,
                  ),

                  const _SectionDivider(),

                  // ── Backend ───────────────────────────────────────────
                  _label(context.tr('backend_configuration')),
                  _settingsTile(context,
                    icon: Icons.dns_outlined,
                    title: context.tr('api_server_url'),
                    subtitle: apiConfig.apiUrl.isEmpty
                        ? context.tr('api_url_required')
                        : apiConfig.apiUrl,
                    onTap: () {
                      final notifier = ref.read(apiConfigProvider.notifier);
                      final currentUrl = apiConfig.apiUrl;
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _ApiUrlSheet(
                          currentUrl: currentUrl,
                          onSave: (url) => notifier.setApiUrl(url),
                        ),
                      );
                    },
                  ),

                  const _SectionDivider(),

                  // ── Security ──────────────────────────────────────────
                  _label(context.tr('security')),
                  _toggleTile(context,
                    icon: Icons.phone_android,
                    title: context.tr('device_binding'),
                    subtitle: context.tr('enforced_backend_signin'),
                    value: settings.deviceBinding,
                    onChanged: null,
                  ),
                  _divider(),
                  _toggleTile(context,
                    icon: Icons.location_off,
                    title: context.tr('mock_gps_detection'),
                    subtitle: settings.mockGpsDetection
                        ? context.tr('fake_location_blocked')
                        : context.tr('mock_gps_off'),
                    value: settings.mockGpsDetection,
                    onChanged: (v) =>
                        notifier.update((s) => s.copyWith(mockGpsDetection: v)),
                  ),
                  _divider(),
                  _settingsTile(context,
                    icon: Icons.lock_outline,
                    title: context.tr('change_password'),
                    subtitle: context.tr('update_password'),
                    onTap: () {
                      Navigator.pop(context);
                      showChangePasswordSheet(context);
                    },
                  ),
                  _divider(),
                  _settingsTile(context,
                    icon: Icons.devices_outlined,
                    title: context.tr('logout_all_devices'),
                    subtitle: context.tr('sign_out_all_sessions'),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogoutAll(context, ref);
                    },
                  ),

                  const _SectionDivider(),

                  // ── Language ──────────────────────────────────────────
                  _label(context.tr('language')),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.language,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? context.tr('arabic')
                                  : context.tr('english'),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            children: [
                              _langChip('EN', !isArabic, () => localeNotifier.setLocale(const Locale('en'))),
                              const SizedBox(width: 8),
                              _langChip('عر', isArabic, () => localeNotifier.setLocale(const Locale('ar'))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const _SectionDivider(),

                  // ── Reports & Export ──────────────────────────────────
                  _label(context.tr('reports_export')),
                  if (isAdmin) ...[
                    _settingsTile(context,
                      icon: Icons.backup_outlined,
                      title: context.tr('backup_export'),
                      subtitle: context.tr('staff_data_export_desc'),
                      onTap: () => push(const BackupExportScreen()),
                    ),
                    _divider(),
                  ],
                  _settingsTile(context,
                    icon: Icons.file_download_outlined,
                    title: context.tr('export_formats'),
                    subtitle:
                        '${settings.exportPdf ? 'PDF' : ''}${settings.exportPdf && settings.exportExcel ? ' & ' : ''}${settings.exportExcel ? 'Excel' : ''} enabled',
                    onTap: () {
                      Navigator.pop(context);
                      _showExportFormatsSheet(context, settings, notifier);
                    },
                  ),
                  _divider(),
                  _settingsTile(context,
                    icon: Icons.history,
                    title: context.tr('admin_audit_logs'),
                    subtitle: isAdmin
                        ? 'Staff edits, range changes, tasks, overtime'
                        : 'View local audit trail',
                    onTap: () => push(const AdminAuditLogScreen()),
                  ),

                  const _SectionDivider(),

                  // ── Account Actions ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('account_actions').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AccountActionButtons(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      context.tr('app_version'),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────────────────────

  Widget _label(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      title: Text(label,
          style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      trailing: badge > 0
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$badge',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            )
          : const Icon(Icons.chevron_right,
              color: AppColors.textHint, size: 16),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 17),
      ),
      title: Text(title,
          style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textHint, size: 16),
    );
  }

  Widget _toggleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 17),
      ),
      title: Text(title,
          style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, indent: 54, endIndent: 14, color: Color(0xFFF0F0F0));

  Widget _langChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ── Sheets ────────────────────────────────────────────────────────────

  void _showPickerSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String unit,
    required List<int> options,
    required int current,
    required ValueChanged<int> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SidebarPickerSheet(
        title: title,
        icon: icon,
        unit: unit,
        options: options,
        current: current,
        onSelect: onSelect,
      ),
    );
  }

  void _showCompanySheet(
    BuildContext context,
    HrSettings settings,
    HrSettingsNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _SidebarCompanySheet(settings: settings, notifier: notifier),
    );
  }

  void _showDepartmentsSheet(
    BuildContext context,
    HrSettings settings,
    HrSettingsNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _SidebarDepartmentsSheet(settings: settings, notifier: notifier),
    );
  }

  void _showExportFormatsSheet(
    BuildContext context,
    HrSettings settings,
    HrSettingsNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SidebarExportFormatsSheet(
          settings: settings, notifier: notifier),
    );
  }

  void _confirmLogoutAll(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authControllerProvider.notifier);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('logout_all_title_dialog')),
        content: Text(context.tr('logout_all_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authNotifier.logoutAll();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.tr('logout_all_btn')),
          ),
        ],
      ),
    );
  }

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}

// ── Section divider ───────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 10, thickness: 1, color: AppColors.divider);
  }
}

// ── Picker sheet ──────────────────────────────────────────────────────────────

class _SidebarPickerSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final String unit;
  final List<int> options;
  final int current;
  final ValueChanged<int> onSelect;

  const _SidebarPickerSheet({
    required this.title,
    required this.icon,
    required this.unit,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((opt) {
                  final selected = opt == current;
                  return GestureDetector(
                    onTap: () {
                      onSelect(opt);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient:
                            selected ? AppColors.primaryGradient : null,
                        color: selected ? null : AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent),
                      ),
                      child: Text(
                        '$opt $unit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Company sheet ─────────────────────────────────────────────────────────────

class _SidebarCompanySheet extends StatefulWidget {
  final HrSettings settings;
  final HrSettingsNotifier notifier;
  const _SidebarCompanySheet(
      {required this.settings, required this.notifier});

  @override
  State<_SidebarCompanySheet> createState() => _SidebarCompanySheetState();
}

class _SidebarCompanySheetState extends State<_SidebarCompanySheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.settings.companyName);
    _addressCtrl =
        TextEditingController(text: widget.settings.companyAddress);
    _phoneCtrl = TextEditingController(text: widget.settings.companyPhone);
    _emailCtrl = TextEditingController(text: widget.settings.companyEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    widget.notifier.update((s) => s.copyWith(
          companyName: _nameCtrl.text.trim(),
          companyAddress: _addressCtrl.text.trim(),
          companyPhone: _phoneCtrl.text.trim(),
          companyEmail: _emailCtrl.text.trim(),
        ));
    if (mounted) {
      Navigator.pop(context);
      AppUtils.showSnackBar(context, 'Company settings saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12)),
                child:
                    const Icon(Icons.business, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company Settings',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Update company information',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _field(_nameCtrl, 'Company Name', Icons.business_outlined),
          const SizedBox(height: 12),
          _field(_addressCtrl, 'Address', Icons.location_on_outlined),
          const SizedBox(height: 12),
          _field(_phoneCtrl, 'Phone', Icons.phone_outlined,
              keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _field(_emailCtrl, 'Email', Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboard}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        filled: true,
        fillColor: const Color(0xFFF6F8FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

// ── Departments sheet ─────────────────────────────────────────────────────────

class _SidebarDepartmentsSheet extends StatefulWidget {
  final HrSettings settings;
  final HrSettingsNotifier notifier;
  const _SidebarDepartmentsSheet(
      {required this.settings, required this.notifier});

  @override
  State<_SidebarDepartmentsSheet> createState() =>
      _SidebarDepartmentsSheetState();
}

class _SidebarDepartmentsSheetState
    extends State<_SidebarDepartmentsSheet> {
  late List<String> _departments;
  final _addCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _departments = List.from(widget.settings.departments);
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  void _add() {
    final name = _addCtrl.text.trim();
    if (name.isEmpty || _departments.contains(name)) return;
    setState(() => _departments.add(name));
    _addCtrl.clear();
    widget.notifier
        .update((s) => s.copyWith(departments: List.from(_departments)));
  }

  void _remove(String dept) {
    setState(() => _departments.remove(dept));
    widget.notifier
        .update((s) => s.copyWith(departments: List.from(_departments)));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.category_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Departments',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'New department name',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF6F8FF),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _add,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _departments.length,
              itemBuilder: (_, i) {
                final dept = _departments[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(dept,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ),
                      GestureDetector(
                        onTap: () => _remove(dept),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textHint),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── API URL sheet ─────────────────────────────────────────────────────────────

class _ApiUrlSheet extends StatefulWidget {
  final String currentUrl;
  final Future<void> Function(String) onSave;
  const _ApiUrlSheet({required this.currentUrl, required this.onSave});

  @override
  State<_ApiUrlSheet> createState() => _ApiUrlSheetState();
}

class _ApiUrlSheetState extends State<_ApiUrlSheet> {
  late TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(_ctrl.text.trim());
    if (mounted) {
      Navigator.pop(context);
      AppUtils.showSnackBar(context, 'API URL saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.dns_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('API Server URL',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('e.g. http://192.168.1.100:8000/api',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'http://192.168.1.100:8000/api',
              prefixIcon: const Icon(Icons.link,
                  size: 18, color: AppColors.primary),
              filled: true,
              fillColor: const Color(0xFFF6F8FF),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save URL',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Export formats sheet ──────────────────────────────────────────────────────

class _SidebarExportFormatsSheet extends StatefulWidget {
  final HrSettings settings;
  final HrSettingsNotifier notifier;
  const _SidebarExportFormatsSheet(
      {required this.settings, required this.notifier});

  @override
  State<_SidebarExportFormatsSheet> createState() =>
      _SidebarExportFormatsSheetState();
}

class _SidebarExportFormatsSheetState
    extends State<_SidebarExportFormatsSheet> {
  late bool _pdf;
  late bool _excel;

  @override
  void initState() {
    super.initState();
    _pdf = widget.settings.exportPdf;
    _excel = widget.settings.exportExcel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.file_download_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Export Formats',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          _formatTile(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF Export',
            color: const Color(0xFFD32F2F),
            value: _pdf,
            onChanged: (v) {
              setState(() => _pdf = v);
              widget.notifier.update((s) => s.copyWith(exportPdf: v));
            },
          ),
          const SizedBox(height: 12),
          _formatTile(
            icon: Icons.table_chart_outlined,
            label: 'Excel Export',
            color: const Color(0xFF1B5E20),
            value: _excel,
            onChanged: (v) {
              setState(() => _excel = v);
              widget.notifier.update((s) => s.copyWith(exportExcel: v));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _formatTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }
}
