import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/settings_provider.dart';
import 'supervisor_dashboard_screen.dart';
import 'supervisor_staff_screen.dart';
import 'supervisor_attendance_screen.dart';
import 'supervisor_leave_approval_screen.dart';
import '../admin/settings_screen.dart';
import '../../../core/l10n/app_localizations.dart';

class SupervisorMainScreen extends ConsumerStatefulWidget {
  const SupervisorMainScreen({super.key});

  @override
  ConsumerState<SupervisorMainScreen> createState() =>
      _SupervisorMainScreenState();
}

class _SupervisorMainScreenState extends ConsumerState<SupervisorMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(hrSettingsProvider);
    final entries = <_SupervisorNavEntry>[
      if (settings.supervisorDashboardAccess)
        _SupervisorNavEntry(
          screen: const SupervisorDashboardScreen(),
          item: BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: context.tr('dashboard'),
          ),
        ),
      if (settings.supervisorStaffAccess)
        _SupervisorNavEntry(
          screen: const SupervisorStaffScreen(),
          item: BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: context.tr('my_team'),
          ),
        ),
      if (settings.supervisorAttendanceAccess)
        _SupervisorNavEntry(
          screen: const SupervisorAttendanceScreen(),
          item: BottomNavigationBarItem(
            icon: const Icon(Icons.event_note_outlined),
            activeIcon: const Icon(Icons.event_note),
            label: context.tr('attendance'),
          ),
        ),
      if (settings.supervisorLeaveAccess)
        _SupervisorNavEntry(
          screen: const SupervisorLeaveApprovalScreen(),
          item: BottomNavigationBarItem(
            icon: const Icon(Icons.approval_outlined),
            activeIcon: const Icon(Icons.approval),
            label: context.tr('leave_approvals'),
          ),
        ),
      _SupervisorNavEntry(
        screen: const SettingsScreen(),
        item: BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: context.tr('settings'),
        ),
      ),
    ];
    final safeIndex =
        _currentIndex >= entries.length ? entries.length - 1 : _currentIndex;
    if (safeIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = safeIndex);
        }
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: entries.map((entry) => entry.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: entries.map((entry) => entry.item).toList(),
        ),
      ),
    );
  }
}

class _SupervisorNavEntry {
  final Widget screen;
  final BottomNavigationBarItem item;

  _SupervisorNavEntry({
    required this.screen,
    required this.item,
  });
}
