import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/api_config_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/locale_provider.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/settings_provider.dart';
import '../../widgets/common/account_actions.dart';
import 'admin_audit_log_screen.dart';
import 'backup_export_screen.dart';
import 'branch_management_screen.dart';
import 'shift_management_screen.dart';
import 'supervisor_permissions_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(hrSettingsProvider);
    final notifier = ref.read(hrSettingsProvider.notifier);
    final apiConfig = ref.watch(apiConfigProvider);
    final isAdmin = user?.role == AppConstants.roleAdmin;
    final remoteModeLocked = AppConstants.canUseRemoteData;
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(AppUtils.getInitials(user?.name ?? 'A'),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Admin',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text(user?.email ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8))),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text((user?.role ?? 'admin').toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (isAdmin)
              _section('HR Configuration', [
                _navTile(
                  icon: Icons.business,
                  title: context.tr('company_settings'),
                  subtitle: settings.companyName,
                  onTap: () =>
                      _showCompanySheet(context, ref, settings, notifier),
                ),
                _divider(),
                _navTile(
                  icon: Icons.schedule,
                  title: context.tr('shift_management'),
                  subtitle: 'Create & edit shifts',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ShiftManagementScreen())),
                ),
                _divider(),
                _navTile(
                  icon: Icons.location_on_outlined,
                  title: context.tr('branch_management'),
                  subtitle: 'Manage branches & geofences',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BranchManagementScreen())),
                ),
                _divider(),
                _navTile(
                  icon: Icons.category_outlined,
                  title: context.tr('departments'),
                  subtitle: '${settings.departments.length} departments',
                  onTap: () =>
                      _showDepartmentsSheet(context, settings, notifier),
                ),
                _divider(),
                _navTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: context.tr('supervisor_permissions'),
                  subtitle: 'Control supervisor module access',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupervisorPermissionsScreen(),
                    ),
                  ),
                ),
              ]),

            if (isAdmin)
              _section('Attendance Rules', [
                _navTile(
                  icon: Icons.access_time,
                  title: 'Grace Period',
                  subtitle: '${settings.gracePeriodMinutes} minutes',
                  onTap: () => _showPickerSheet(
                    context: context,
                    title: 'Grace Period',
                    icon: Icons.access_time,
                    unit: 'minutes',
                    options: [5, 10, 15, 20, 30, 45, 60],
                    current: settings.gracePeriodMinutes,
                    onSelect: (v) => notifier
                        .update((s) => s.copyWith(gracePeriodMinutes: v)),
                  ),
                ),
                _divider(),
                _navTile(
                  icon: Icons.timer_outlined,
                  title: 'Standard Hours',
                  subtitle:
                      '${settings.standardHours.toStringAsFixed(0)} hours/day',
                  onTap: () => _showPickerSheet(
                    context: context,
                    title: 'Standard Working Hours',
                    icon: Icons.timer_outlined,
                    unit: 'hours/day',
                    options: [6, 7, 8, 9, 10, 12],
                    current: settings.standardHours.toInt(),
                    onSelect: (v) => notifier
                        .update((s) => s.copyWith(standardHours: v.toDouble())),
                  ),
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.gps_fixed,
                  title: 'GPS Enforcement',
                  subtitle: 'Managed by backend security policy',
                  value: settings.gpsEnforcement,
                  onChanged: null,
                ),
                _divider(),
                _toggleTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Selfie Requirement',
                  subtitle: settings.selfieRequired
                      ? 'Required for check-in'
                      : 'Selfie not required',
                  value: settings.selfieRequired,
                  onChanged: (v) =>
                      notifier.update((s) => s.copyWith(selfieRequired: v)),
                ),
              ]),

            if (isAdmin)
              _section('Salary & Payroll', [
                _navTile(
                  icon: Icons.payments,
                  title: 'Salary Cycle',
                  subtitle:
                      '${_ordinal(settings.salaryCycleDay)} of every month',
                  onTap: () => _showPickerSheet(
                    context: context,
                    title: 'Salary Cycle Day',
                    icon: Icons.payments,
                    unit: 'of each month',
                    options: List.generate(28, (i) => i + 1),
                    current: settings.salaryCycleDay,
                    onSelect: (v) =>
                        notifier.update((s) => s.copyWith(salaryCycleDay: v)),
                  ),
                ),
                _divider(),
                _navTile(
                  icon: Icons.account_balance,
                  title: 'Overtime Policy',
                  subtitle:
                      'After ${settings.overtimeAfterHours.toStringAsFixed(0)} hours',
                  onTap: () => _showPickerSheet(
                    context: context,
                    title: 'Overtime Starts After',
                    icon: Icons.account_balance,
                    unit: 'hours',
                    options: [6, 7, 8, 9, 10],
                    current: settings.overtimeAfterHours.toInt(),
                    onSelect: (v) => notifier.update(
                        (s) => s.copyWith(overtimeAfterHours: v.toDouble())),
                  ),
                ),
                _divider(),
                _navTile(
                  icon: Icons.remove_circle_outline,
                  title: 'Deduction Rules',
                  subtitle:
                      '${settings.absenceDeductionPercent.toStringAsFixed(0)}% per absent day',
                  onTap: () => _showPickerSheet(
                    context: context,
                    title: 'Absence Deduction',
                    icon: Icons.remove_circle_outline,
                    unit: '% of daily salary',
                    options: [25, 50, 75, 100],
                    current: settings.absenceDeductionPercent.toInt(),
                    onSelect: (v) => notifier.update((s) =>
                        s.copyWith(absenceDeductionPercent: v.toDouble())),
                  ),
                ),
              ]),

            // ── Notifications ─────────────────────────────────────────
            _section(context.tr('notifications'), [
              _toggleTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: settings.pushNotifications
                    ? 'App notifications enabled'
                    : 'Notifications disabled',
                value: settings.pushNotifications,
                onChanged: (v) =>
                    notifier.update((s) => s.copyWith(pushNotifications: v)),
              ),
              _divider(),
              _toggleTile(
                icon: Icons.sms_outlined,
                title: 'SMS Alerts',
                subtitle: 'Requires SMS gateway integration',
                value: settings.smsAlerts,
                onChanged: null,
              ),
            ]),

            // ── Backend Configuration ─────────────────────────────────
            _section('Backend Configuration', [
              _navTile(
                icon: Icons.dns_outlined,
                title: context.tr('api_server_url'),
                subtitle: apiConfig.apiUrl.isEmpty
                    ? 'Not configured'
                    : apiConfig.apiUrl,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _ApiUrlSheet(
                    currentUrl: apiConfig.apiUrl,
                    onSave: (url) =>
                        ref.read(apiConfigProvider.notifier).setApiUrl(url),
                  ),
                ),
              ),
              _divider(),
              _toggleTile(
                icon: Icons.cloud_outlined,
                title: 'Remote Backend Mode',
                subtitle: remoteModeLocked
                    ? 'Managed by build configuration'
                    : apiConfig.useRemote
                        ? (apiConfig.isConfigured
                            ? 'Using API backend'
                            : 'API URL required before sign in')
                        : 'Using local demo data',
                value: apiConfig.useRemote,
                onChanged: remoteModeLocked
                    ? null
                    : (value) => _confirmRemoteModeChange(context, ref, value),
              ),
            ]),

            // ── Security ──────────────────────────────────────────────
            _section('Security', [
              _toggleTile(
                icon: Icons.phone_android,
                title: 'Device Binding',
                subtitle: 'Enforced by backend at sign-in',
                value: settings.deviceBinding,
                onChanged: null,
              ),
              _divider(),
              _toggleTile(
                icon: Icons.location_off,
                title: 'Mock GPS Detection',
                subtitle: settings.mockGpsDetection
                    ? 'Fake location detected & blocked'
                    : 'Mock GPS detection off',
                value: settings.mockGpsDetection,
                onChanged: (v) =>
                    notifier.update((s) => s.copyWith(mockGpsDetection: v)),
              ),
              _divider(),
              _navTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => showChangePasswordSheet(context),
              ),
              _divider(),
              _navTile(
                icon: Icons.devices_outlined,
                title: context.tr('logout_all_devices'),
                subtitle: 'Sign out of all active sessions',
                onTap: () => _confirmLogoutAll(context, ref),
              ),
            ]),

            // ── Language ──────────────────────────────────────────────
            _section(context.tr('language'), [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.language, color: AppColors.primary, size: 18),
                ),
                title: Text(
                  context.tr('language'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isArabic ? context.tr('arabic') : context.tr('english'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _langChip('EN', !isArabic, () => localeNotifier.setLocale(const Locale('en'))),
                    const SizedBox(width: 8),
                    _langChip('عر', isArabic, () => localeNotifier.setLocale(const Locale('ar'))),
                  ],
                ),
              ),
            ]),

            // ── Reports & Export ──────────────────────────────────────
            _section('Reports & Export', [
              if (isAdmin) ...[
                _navTile(
                  icon: Icons.backup_outlined,
                  title: context.tr('backup_export'),
                  subtitle: 'Staff, attendance, tasks, KPI, leaves',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BackupExportScreen(),
                    ),
                  ),
                ),
                _divider(),
              ],
              _navTile(
                icon: Icons.file_download_outlined,
                title: context.tr('export_formats'),
                subtitle:
                    '${settings.exportPdf ? 'PDF' : ''}${settings.exportPdf && settings.exportExcel ? ' & ' : ''}${settings.exportExcel ? 'Excel' : ''} enabled',
                onTap: () =>
                    _showExportFormatsSheet(context, settings, notifier),
              ),
              _divider(),
              _navTile(
                icon: Icons.history,
                title: context.tr('admin_audit_logs'),
                subtitle: isAdmin
                    ? 'Staff edits, range changes, tasks, overtime, reads'
                    : 'View local audit trail',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminAuditLogScreen(),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('account_actions'),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  AccountActionButtons(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(context.tr('app_version'),
                style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmLogoutAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout All Devices'),
        content: const Text(
            'This will sign you out of all active sessions on all devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logoutAll();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout All'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoteModeChange(
    BuildContext context,
    WidgetRef ref,
    bool useRemote,
  ) async {
    final currentUseRemote = ref.read(apiConfigProvider).useRemote;
    if (currentUseRemote == useRemote) {
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              useRemote ? 'Enable Remote Backend' : 'Enable Demo Mode',
            ),
            content: const Text(
              'Switching backend mode will sign you out and reload the app data source.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await ref.read(authControllerProvider.notifier).logout();
    await ref.read(apiConfigProvider.notifier).setUseRemote(useRemote);
    if (!context.mounted) {
      return;
    }

    AppUtils.showSnackBar(
      context,
      useRemote ? 'Remote backend mode enabled' : 'Demo mode enabled',
    );
    context.go('/login');
  }

  // ── Widget helpers ────────────────────────────────────────────────────

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _divider() => const Divider(
      height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F0F0));

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
    );
  }

  Widget _langChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      builder: (_) => _PickerSheet(
        title: title,
        icon: icon,
        unit: unit,
        options: options,
        current: current,
        onSelect: onSelect,
      ),
    );
  }

  void _showCompanySheet(BuildContext context, WidgetRef ref,
      HrSettings settings, HrSettingsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompanySheet(settings: settings, notifier: notifier),
    );
  }

  void _showDepartmentsSheet(
      BuildContext context, HrSettings settings, HrSettingsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DepartmentsSheet(settings: settings, notifier: notifier),
    );
  }

  void _showExportFormatsSheet(
      BuildContext context, HrSettings settings, HrSettingsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ExportFormatsSheet(settings: settings, notifier: notifier),
    );
  }

  String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}

// ── Picker Sheet ──────────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final String unit;
  final List<int> options;
  final int current;
  final ValueChanged<int> onSelect;

  const _PickerSheet({
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.primaryGradient : null,
                        color: selected ? null : AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              selected ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '$opt $unit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.primary,
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

// ── Company Settings Sheet ────────────────────────────────────────────────────

class _CompanySheet extends StatefulWidget {
  final HrSettings settings;
  final HrSettingsNotifier notifier;
  const _CompanySheet({required this.settings, required this.notifier});

  @override
  State<_CompanySheet> createState() => _CompanySheetState();
}

class _CompanySheetState extends State<_CompanySheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.settings.companyName);
    _addressCtrl = TextEditingController(text: widget.settings.companyAddress);
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
    await Future.delayed(const Duration(milliseconds: 500));
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.business, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company Settings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Update company information',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

// ── Departments Sheet ─────────────────────────────────────────────────────────

class _DepartmentsSheet extends StatefulWidget {
  final HrSettings settings;
  final HrSettingsNotifier notifier;
  const _DepartmentsSheet({required this.settings, required this.notifier});

  @override
  State<_DepartmentsSheet> createState() => _DepartmentsSheetState();
}

class _DepartmentsSheetState extends State<_DepartmentsSheet> {
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Departments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),

          // Add new department
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'New department name',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF6F8FF),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _departments.length,
              itemBuilder: (_, i) {
                final dept = _departments[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
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

// ── API URL Sheet ─────────────────────────────────────────────────────────────

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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dns_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('API Server URL',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('e.g. http://192.168.1.100:8000/api',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'http://192.168.1.100:8000/api',
              prefixIcon:
                  const Icon(Icons.link, size: 18, color: AppColors.primary),
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Export Formats Sheet ──────────────────────────────────────────────────────

class _ExportFormatsSheet extends StatefulWidget {
  final HrSettings settings;
  final HrSettingsNotifier notifier;
  const _ExportFormatsSheet({required this.settings, required this.notifier});

  @override
  State<_ExportFormatsSheet> createState() => _ExportFormatsSheetState();
}

class _ExportFormatsSheetState extends State<_ExportFormatsSheet> {
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.file_download_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Export Formats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }
}
