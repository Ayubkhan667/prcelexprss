import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'supervisor_dashboard_screen.dart';
import 'supervisor_staff_screen.dart';
import 'supervisor_attendance_screen.dart';
import 'supervisor_leave_approval_screen.dart';
import '../admin/settings_screen.dart';

class SupervisorMainScreen extends StatefulWidget {
  const SupervisorMainScreen({super.key});

  @override
  State<SupervisorMainScreen> createState() => _SupervisorMainScreenState();
}

class _SupervisorMainScreenState extends State<SupervisorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SupervisorDashboardScreen(),
    SupervisorStaffScreen(),
    SupervisorAttendanceScreen(),
    SupervisorLeaveApprovalScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.approval_outlined),
              activeIcon: Icon(Icons.approval),
              label: 'Leaves',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
