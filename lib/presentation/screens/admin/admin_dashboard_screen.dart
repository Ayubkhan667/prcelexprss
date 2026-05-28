import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/charts/attendance_pie_chart.dart';
import 'salary_management_screen.dart';
import 'loan_management_screen.dart';
import 'leave_approval_screen.dart';
import 'branch_management_screen.dart';
import 'overtime_approval_screen.dart';
import 'task_management_screen.dart';
import 'today_attendance_list_screen.dart';
import '../../../core/utils/tap_effects.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final user = ref.watch(currentUserProvider);
    final date = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Good ${_greeting()}, ${user?.name.split(' ').first ?? 'Admin'}!',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(AppUtils.formatDate(date),
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(AppUtils.getInitials(user?.name ?? 'A'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick action cards
                  Row(
                    children: [
                      _quickAction(
                          context,
                          Icons.people,
                          context.tr('salary'),
                          AppColors.primary,
                          () => _navigate(
                              context, const SalaryManagementScreen())),
                      const SizedBox(width: 10),
                      _quickAction(
                          context,
                          Icons.account_balance_wallet,
                          context.tr('loan'),
                          AppColors.accent,
                          () =>
                              _navigate(context, const LoanManagementScreen())),
                      const SizedBox(width: 10),
                      _quickAction(
                          context,
                          Icons.beach_access,
                          context.tr('leave'),
                          AppColors.onLeave,
                          () =>
                              _navigate(context, const LeaveApprovalScreen())),
                      const SizedBox(width: 10),
                      _quickAction(
                          context,
                          Icons.location_on,
                          context.tr('branch'),
                          AppColors.success,
                          () => _navigate(
                              context, const BranchManagementScreen())),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _quickAction(
                          context,
                          Icons.assignment_outlined,
                          context.tr('task'),
                          AppColors.primaryDark,
                          () =>
                              _navigate(context, const TaskManagementScreen())),
                      const SizedBox(width: 10),
                      _quickAction(
                          context,
                          Icons.more_time,
                          context.tr('overtime'),
                          AppColors.warning,
                          () => _navigate(
                              context, const OvertimeApprovalScreen())),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Today stats header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('todays_overview'),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(AppUtils.formatDate(date, format: 'dd MMM'),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      DashboardStatCard(
                          title: 'Total Staff',
                          value: stats['total_staff'].toString(),
                          icon: Icons.people_alt,
                          color: AppColors.primary,
                          onTap: () => _navigate(
                              context,
                              const TodayAttendanceListScreen(
                                  title: 'All Staff'))),
                      DashboardStatCard(
                          title: 'Present Today',
                          value: stats['present_today'].toString(),
                          icon: Icons.check_circle,
                          color: AppColors.present,
                          onTap: () => _navigate(
                              context,
                              const TodayAttendanceListScreen(
                                  title: 'Present Today',
                                  statuses: [
                                    'Present',
                                    'Late',
                                    'Overtime',
                                    'Missing Checkout'
                                  ]))),
                      DashboardStatCard(
                          title: 'Absent Today',
                          value: stats['absent_today'].toString(),
                          icon: Icons.cancel,
                          color: AppColors.absent,
                          onTap: () => _navigate(
                              context,
                              const TodayAttendanceListScreen(
                                  title: 'Absent Today',
                                  statuses: ['Absent']))),
                      DashboardStatCard(
                          title: 'Late Today',
                          value: stats['late_today'].toString(),
                          icon: Icons.access_time,
                          color: AppColors.late,
                          onTap: () => _navigate(
                              context,
                              const TodayAttendanceListScreen(
                                  title: 'Late Today', statuses: ['Late']))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: [
                      StatCard(
                          title: 'On Leave',
                          value: stats['on_leave'].toString(),
                          icon: Icons.beach_access,
                          color: AppColors.onLeave,
                          isSmall: true),
                      StatCard(
                          title: 'OT Hours',
                          value:
                              stats['total_overtime_hours'].toStringAsFixed(0),
                          icon: Icons.more_time,
                          color: AppColors.overtime,
                          isSmall: true),
                      StatCard(
                          title: 'Salary Pending',
                          value: stats['salary_pending'].toString(),
                          icon: Icons.payments,
                          color: AppColors.warning,
                          isSmall: true),
                      StatCard(
                          title: 'Loan Balance',
                          value: _formatShort(stats['total_loan_balance']),
                          icon: Icons.account_balance,
                          color: AppColors.error,
                          isSmall: true),
                      StatCard(
                          title: 'KPI Average',
                          value: '${stats['kpi_average'].toStringAsFixed(1)}%',
                          icon: Icons.show_chart,
                          color: AppColors.primary,
                          isSmall: true),
                      StatCard(
                          title: 'Overtime Staff',
                          value: stats['overtime_count'].toString(),
                          icon: Icons.timelapse,
                          color: AppColors.accent,
                          isSmall: true),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Pie Chart
                  _sectionHeader('Attendance Breakdown (This Month)'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8)
                      ],
                    ),
                    child: AttendancePieChart(
                      present: (stats['monthly_present'] as int? ?? 0) > 0
                          ? stats['monthly_present'] as int
                          : stats['present_today'] ?? 0,
                      absent: (stats['monthly_absent'] as int? ?? 0) > 0
                          ? stats['monthly_absent'] as int
                          : stats['absent_today'] ?? 0,
                      late: (stats['monthly_late'] as int? ?? 0) > 0
                          ? stats['monthly_late'] as int
                          : stats['late_today'] ?? 0,
                      onLeave: (stats['monthly_on_leave'] as int? ?? 0) > 0
                          ? stats['monthly_on_leave'] as int
                          : stats['on_leave'] ?? 0,
                      overtime: (stats['monthly_overtime'] as int? ?? 0) > 0
                          ? stats['monthly_overtime'] as int
                          : stats['overtime_count'] ?? 0,
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Highlights
                  _sectionHeader('Performance Highlights'),
                  const SizedBox(height: 12),
                  _highlightCard(Icons.emoji_events, 'Best Staff of Month',
                      stats['best_staff'], AppColors.success),
                  const SizedBox(height: 8),
                  _highlightCard(Icons.trending_down, 'Lowest KPI Staff',
                      stats['lowest_kpi_staff'], AppColors.error),
                  const SizedBox(height: 8),
                  _highlightCard(Icons.more_time, 'Highest Overtime',
                      stats['highest_overtime_staff'], AppColors.accent),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatShort(dynamic value) {
    final v = (value as num).toDouble();
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: TapEffect(
        onTap: onTap,
        borderRadius: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary));
  }

  Widget _highlightCard(
      IconData icon, String label, String? value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text(value ?? '-',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
