import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/settings_provider.dart';
import 'supervisor_dashboard_screen.dart';
import 'supervisor_staff_screen.dart';
import 'supervisor_attendance_screen.dart';
import 'supervisor_leave_approval_screen.dart';
import '../admin/settings_screen.dart';

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
        const _SupervisorNavEntry(
          screen: SupervisorDashboardScreen(),
          item: BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ),
      if (settings.supervisorStaffAccess)
        const _SupervisorNavEntry(
          screen: SupervisorStaffScreen(),
          item: BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Team',
          ),
        ),
      if (settings.supervisorAttendanceAccess)
        const _SupervisorNavEntry(
          screen: SupervisorAttendanceScreen(),
          item: BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'Attendance',
          ),
        ),
      if (settings.supervisorLeaveAccess)
        const _SupervisorNavEntry(
          screen: SupervisorLeaveApprovalScreen(),
          item: BottomNavigationBarItem(
            icon: Icon(Icons.approval_outlined),
            activeIcon: Icon(Icons.approval),
            label: 'Leaves',
          ),
        ),
      const _SupervisorNavEntry(
        screen: SettingsScreen(),
        item: BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
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

  const _SupervisorNavEntry({
    required this.screen,
    required this.item,
  });
}
