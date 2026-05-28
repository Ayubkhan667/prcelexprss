import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/status_badge.dart';
import 'leave_request_screen.dart';
import 'salary_screen.dart';
import 'loan_screen.dart';
import 'staff_kpi_screen.dart';
import 'staff_task_screen.dart';
import 'expense_screen.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final staff = ref.watch(currentStaffProvider);
    final kpiList =
        staff != null ? ref.watch(kpiListProvider(staff.id)) : <dynamic>[];
    final attendanceList = staff != null
        ? ref.watch(attendanceListProvider(staff.id))
        : <AttendanceModel>[];
    final todayAtt = ref.watch(todayAttendanceForStaffProvider(staff?.id));
    final taskList =
        staff != null ? ref.watch(taskListProvider(staff.id)) : <TaskModel>[];
    final pendingTasks =
        taskList.where((task) => task.status == 'Pending').toList();

    final currentKpi = kpiList.isNotEmpty ? kpiList.first : null;
    final presentDays = attendanceList
        .where((a) => a.status != 'Absent' && a.status != 'On Leave')
        .length;
    final lateDays = attendanceList.where((a) => a.status == 'Late').length;
    final totalOt =
        attendanceList.fold<double>(0, (s, a) => s + a.overtimeHours);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(AppUtils.getInitials(user?.name ?? 'S'),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${_greeting()}, ${user?.name.split(' ').first ?? 'Staff'}!',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            if (staff != null)
                              Text('${staff.staffCode} • ${staff.category}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                        const Spacer(),
                        if (todayAtt != null)
                          StatusBadge(status: todayAtt.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(AppUtils.formatDate(DateTime.now()),
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75))),
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
                  // Today check-in/out card
                  _todayCard(todayAtt),
                  if (staff != null) ...[
                    const SizedBox(height: 12),
                    _taskCard(context, pendingTasks, taskList.length),
                  ],
                  const SizedBox(height: 16),

                  // Quick actions
                  const Text('Quick Actions',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _quickAction(
                          context,
                          Icons.payments_outlined,
                          'My Salary',
                          AppColors.primary,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SalaryScreen()))),
                      const SizedBox(width: 10),
                      _quickAction(
                          context,
                          Icons.account_balance_outlined,
                          'My Loans',
                          AppColors.accent,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoanScreen()))),
                      const SizedBox(width: 10),
                      _quickAction(
                          context,
                          Icons.beach_access_outlined,
                          'Leave',
                          AppColors.onLeave,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LeaveRequestScreen()))),
                      const SizedBox(width: 10),
                      _quickAction(
                          context,
                          Icons.bar_chart_outlined,
                          'My KPI',
                          AppColors.success,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const StaffKpiScreen()))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _quickAction(
                          context,
                          Icons.receipt_long_outlined,
                          'Expenses',
                          const Color(0xFF7B61FF),
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ExpenseScreen()))),
                      const SizedBox(width: 10),
                      const Expanded(child: SizedBox()),
                      const SizedBox(width: 10),
                      const Expanded(child: SizedBox()),
                      const SizedBox(width: 10),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  const Text('This Month Stats',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      StatCard(
                          title: 'Present Days',
                          value: presentDays.toString(),
                          icon: Icons.check_circle_outline,
                          color: AppColors.present),
                      StatCard(
                          title: 'Late Days',
                          value: lateDays.toString(),
                          icon: Icons.access_time_outlined,
                          color: AppColors.late),
                      StatCard(
                          title: 'Overtime hrs',
                          value: totalOt.toStringAsFixed(1),
                          icon: Icons.more_time,
                          color: AppColors.overtime),
                      if (currentKpi != null)
                        StatCard(
                            title: 'KPI Score',
                            value: currentKpi.totalKpiScore.toStringAsFixed(1),
                            icon: Icons.show_chart,
                            color:
                                AppUtils.getKpiColor(currentKpi.totalKpiScore)),
                    ],
                  ),

                  if (currentKpi != null) ...[
                    const SizedBox(height: 20),
                    const Text('KPI Performance',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    _kpiCard(currentKpi),
                  ],

                  const SizedBox(height: 20),
                  // Recent activity
                  const Text('Recent Activity',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  ...attendanceList.take(5).map((a) => _activityItem(a)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayCard(dynamic todayAtt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.9),
            AppColors.accentDark.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.today, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Attendance",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _timeChip(
                        'IN',
                        todayAtt?.checkInTime != null
                            ? AppUtils.formatTime(todayAtt.checkInTime!)
                            : '--:--',
                        Colors.white),
                    const SizedBox(width: 10),
                    _timeChip(
                        'OUT',
                        todayAtt?.checkOutTime != null
                            ? AppUtils.formatTime(todayAtt.checkOutTime!)
                            : '--:--',
                        Colors.white),
                  ],
                ),
              ],
            ),
          ),
          if (todayAtt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(todayAtt.status,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _timeChip(String label, String time, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 11, color: textColor.withValues(alpha: 0.7))),
        Text(time,
            style: TextStyle(
                fontSize: 12, color: textColor, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _taskCard(
    BuildContext context,
    List<TaskModel> pendingTasks,
    int totalTasks,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StaffTaskScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pendingTasks.isEmpty
                        ? 'No pending tasks right now'
                        : '${pendingTasks.length} pending of $totalTasks total tasks',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10, color: color, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(dynamic kpi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('KPI Score',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Text(kpi.totalKpiScore.toStringAsFixed(1),
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppUtils.getKpiColor(kpi.totalKpiScore))),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppUtils.getKpiColor(kpi.totalKpiScore)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppUtils.getKpiColor(kpi.totalKpiScore)
                          .withValues(alpha: 0.3)),
                ),
                child: Text(kpi.rating,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppUtils.getKpiColor(kpi.totalKpiScore))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: kpi.totalKpiScore / 100,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppUtils.getKpiColor(kpi.totalKpiScore)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(dynamic att) {
    final color = AppUtils.getStatusColor(att.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(AppUtils.formatDate(att.date),
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (att.checkInTime != null)
            Text(AppUtils.formatTime(att.checkInTime!),
                style: const TextStyle(fontSize: 11, color: AppColors.success)),
          const SizedBox(width: 8),
          StatusBadge(status: att.status, fontSize: 10),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
