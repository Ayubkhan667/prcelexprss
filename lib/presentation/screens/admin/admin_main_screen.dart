import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/tap_effects.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/app_providers.dart';
import 'admin_dashboard_screen.dart';
import 'staff_list_screen.dart';
import 'attendance_report_screen.dart';
import 'kpi_dashboard_screen.dart';
import 'settings_screen.dart';
import 'manual_attendance_screen.dart';
import 'attendance_edit_log_screen.dart';
import 'overtime_approval_screen.dart';
import 'task_management_screen.dart';
import 'holiday_calendar_screen.dart';
import '../shared/notification_screen.dart';
import '../../../core/l10n/app_localizations.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    StaffListScreen(),
    AttendanceReportScreen(),
    KpiDashboardScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            HapticFeedback.selectionClick();
            SoundService.instance.playClick();
            if (i == 4) {
              _showMoreMenu(context);
            } else {
              setState(() => _currentIndex = i);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard),
                label: context.tr('dashboard')),
            BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline),
                activeIcon: const Icon(Icons.people),
                label: context.tr('staff')),
            BottomNavigationBarItem(
                icon: const Icon(Icons.event_note_outlined),
                activeIcon: const Icon(Icons.event_note),
                label: context.tr('attendance')),
            BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart),
                label: context.tr('kpi')),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.more_horiz),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: context.tr('more'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final unreadCount = ref.read(unreadNotificationCountProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(context.tr('more_options'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            _menuTile(
              context,
              icon: Icons.notifications_outlined,
              label: context.tr('notifications'),
              badge: unreadCount,
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()));
              },
            ),
            _menuTile(
              context,
              icon: Icons.edit_calendar_outlined,
              label: context.tr('manual_attendance_entry'),
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManualAttendanceScreen()));
              },
            ),
            _menuTile(
              context,
              icon: Icons.history_edu_outlined,
              label: context.tr('attendance_edit_logs'),
              color: AppColors.warning,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AttendanceEditLogScreen()));
              },
            ),
            _menuTile(
              context,
              icon: Icons.assignment_outlined,
              label: context.tr('task_cards'),
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TaskManagementScreen()));
              },
            ),
            _menuTile(
              context,
              icon: Icons.more_time_outlined,
              label: context.tr('overtime_approval'),
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OvertimeApprovalScreen()));
              },
            ),
            _menuTile(
              context,
              icon: Icons.calendar_month_outlined,
              label: context.tr('holiday_calendar'),
              color: const Color(0xFF6A1B9A),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HolidayCalendarScreen()));
              },
            ),
            _menuTile(
              context,
              icon: Icons.settings_outlined,
              label: context.tr('settings'),
              color: AppColors.textSecondary,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return TapEffect(
      onTap: onTap,
      borderRadius: 10,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        trailing: badge > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
