import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/tap_effects.dart';
import '../../../data/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import 'admin_dashboard_screen.dart';
import 'admin_sidebar.dart';
import 'staff_list_screen.dart';
import 'attendance_report_screen.dart';
import 'kpi_dashboard_screen.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    StaffListScreen(),
    AttendanceReportScreen(),
    KpiDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AdminSidebar(),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildFloatingNavBar(context, unreadCount),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, int unreadCount) {
    final items = [
      (Icons.dashboard_outlined, Icons.dashboard_rounded, context.tr('dashboard')),
      (Icons.people_outline, Icons.people_rounded, context.tr('staff')),
      (Icons.event_note_outlined, Icons.event_note_rounded, context.tr('attendance')),
      (Icons.bar_chart_outlined, Icons.bar_chart_rounded, context.tr('kpi')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 4 tab items
              ...List.generate(items.length, (i) {
                final selected = _currentIndex == i;
                final (outlinedIcon, filledIcon, label) = items[i];
                return Expanded(
                  child: TapEffect(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _currentIndex = i);
                    },
                    borderRadius: 14,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.primaryGradient : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? filledIcon : outlinedIcon,
                            size: 22,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Menu / drawer button
              Expanded(
                child: TapEffect(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  borderRadius: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.menu_rounded,
                              size: 22,
                              color: AppColors.textSecondary,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.accentGradient,
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
                        const SizedBox(height: 3),
                        Text(
                          context.tr('more'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
