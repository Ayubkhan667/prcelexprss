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
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.dashboardGradient,
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      bottom: -20,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 10,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
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
                                    '${_greeting(context)} 👋',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.name.split(' ').first ?? 'Admin',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.3),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      AppUtils.formatDate(date),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.95),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryDark.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                                  child: Text(
                                    AppUtils.getInitials(user?.name ?? 'A'),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                    childAspectRatio: 1.7,
                    children: [
                      DashboardStatCard(
                          title: context.tr('total_staff'),
                          value: stats['total_staff'].toString(),
                          icon: Icons.people_alt,
                          color: AppColors.primary,
                          onTap: () => _navigate(
                              context,
                              TodayAttendanceListScreen(
                                  title: context.tr('all_staff_title')))),
                      DashboardStatCard(
                          title: context.tr('present_today'),
                          value: stats['present_today'].toString(),
                          icon: Icons.check_circle,
                          color: AppColors.present,
                          onTap: () => _navigate(
                              context,
                              TodayAttendanceListScreen(
                                  title: context.tr('present_today'),
                                  statuses: [
                                    'Present',
                                    'Late',
                                    'Overtime',
                                    'Missing Checkout'
                                  ]))),
                      DashboardStatCard(
                          title: context.tr('absent_today'),
                          value: stats['absent_today'].toString(),
                          icon: Icons.cancel,
                          color: AppColors.absent,
                          onTap: () => _navigate(
                              context,
                              TodayAttendanceListScreen(
                                  title: context.tr('absent_today'),
                                  statuses: ['Absent']))),
                      DashboardStatCard(
                          title: context.tr('late_today'),
                          value: stats['late_today'].toString(),
                          icon: Icons.access_time,
                          color: AppColors.late,
                          onTap: () => _navigate(
                              context,
                              TodayAttendanceListScreen(
                                  title: context.tr('late_today'),
                                  statuses: ['Late']))),
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
                          title: context.tr('on_leave'),
                          value: stats['on_leave'].toString(),
                          icon: Icons.beach_access,
                          color: AppColors.onLeave,
                          isSmall: true),
                      StatCard(
                          title: context.tr('ot_hours'),
                          value:
                              stats['total_overtime_hours'].toStringAsFixed(0),
                          icon: Icons.more_time,
                          color: AppColors.overtime,
                          isSmall: true),
                      StatCard(
                          title: context.tr('salary_pending'),
                          value: stats['salary_pending'].toString(),
                          icon: Icons.payments,
                          color: AppColors.warning,
                          isSmall: true),
                      StatCard(
                          title: context.tr('loan_balance'),
                          value: _formatShort(stats['total_loan_balance']),
                          icon: Icons.account_balance,
                          color: AppColors.error,
                          isSmall: true),
                      StatCard(
                          title: context.tr('kpi_average'),
                          value: '${stats['kpi_average'].toStringAsFixed(1)}%',
                          icon: Icons.show_chart,
                          color: AppColors.primary,
                          isSmall: true),
                      StatCard(
                          title: context.tr('overtime_staff'),
                          value: stats['overtime_count'].toString(),
                          icon: Icons.timelapse,
                          color: AppColors.accent,
                          isSmall: true),
                      StatCard(
                          title: 'Doc Alerts',
                          value: stats['expiring_documents'].toString(),
                          icon: Icons.badge_outlined,
                          color: AppColors.warning,
                          isSmall: true),
                      StatCard(
                          title: 'Expired Docs',
                          value: stats['expired_documents'].toString(),
                          icon: Icons.gpp_bad_outlined,
                          color: AppColors.error,
                          isSmall: true),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Pie Chart
                  _sectionHeader(context.tr('attendance_breakdown')),
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
                  _sectionHeader(context.tr('performance_highlights')),
                  const SizedBox(height: 12),
                  _highlightCard(
                      Icons.emoji_events,
                      context.tr('best_staff_month'),
                      stats['best_staff'],
                      AppColors.success),
                  const SizedBox(height: 8),
                  _highlightCard(
                      Icons.trending_down,
                      context.tr('lowest_kpi_staff'),
                      stats['lowest_kpi_staff'],
                      AppColors.error),
                  const SizedBox(height: 8),
                  _highlightCard(
                      Icons.more_time,
                      context.tr('highest_overtime'),
                      stats['highest_overtime_staff'],
                      AppColors.accent),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    if (h < 12) return context.tr('good_morning');
    if (h < 17) return context.tr('good_afternoon');
    return context.tr('good_evening');
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
        borderRadius: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2)),
      ],
    );
  }

  Widget _highlightCard(
      IconData icon, String label, String? value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.85), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value ?? '-',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
