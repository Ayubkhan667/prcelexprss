import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/kpi_model.dart';
import '../../widgets/common/stat_card.dart';

class SupervisorDashboardScreen extends ConsumerWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final today = DateTime.now();
    final allStaff = ref
        .watch(allStaffListProvider)
        .where((staff) => staff.status == 'Active')
        .toList();
    final todayAttendance = ref
            .watch(
              attendanceByDateAsyncProvider(
                DateTime(today.year, today.month, today.day),
              ),
            )
            .valueOrNull ??
        const [];
    final kpiList = ref.watch(allKpiProvider);
    final pendingLeaves = ref.watch(pendingLeavesProvider);

    int present = 0, late = 0, absent = 0, onLeave = 0;
    for (final attendance in todayAttendance) {
      switch (attendance.status) {
        case 'Present':
        case 'Overtime':
        case 'Missing Checkout':
          present++;
          break;
        case 'Late':
          late++;
          present++;
          break;
        case 'On Leave':
          onLeave++;
          break;
        default:
          absent++;
      }
    }
    final accounted = present + onLeave + absent;
    if (allStaff.length > accounted) {
      absent += allStaff.length - accounted;
    }
    final avgKpi = kpiList.isEmpty
        ? 0.0
        : kpiList.fold<double>(0, (s, k) => s + k.totalKpiScore) /
            kpiList.length;

    KpiModel? bestKpi;
    KpiModel? worstKpi;
    for (final k in kpiList) {
      if (bestKpi == null || k.totalKpiScore > bestKpi.totalKpiScore) {
        bestKpi = k;
      }
      if (worstKpi == null || k.totalKpiScore < worstKpi.totalKpiScore) {
        worstKpi = k;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Supervisor'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Supervisor Dashboard — ${_formatDate(today)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
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
                  _sectionTitle('Today Overview'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        title: 'Total Staff',
                        value: allStaff.length.toString(),
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        title: 'Present',
                        value: present.toString(),
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                      StatCard(
                        title: 'Absent',
                        value: absent.toString(),
                        icon: Icons.cancel,
                        color: AppColors.error,
                      ),
                      StatCard(
                        title: 'Late Today',
                        value: late.toString(),
                        icon: Icons.alarm,
                        color: AppColors.warning,
                      ),
                      StatCard(
                        title: 'On Leave',
                        value: onLeave.toString(),
                        icon: Icons.event_busy,
                        color: AppColors.onLeave,
                      ),
                      StatCard(
                        title: 'Pending Leaves',
                        value: pendingLeaves.length.toString(),
                        icon: Icons.pending_actions,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('KPI Overview'),
                  const SizedBox(height: 12),
                  _kpiSummaryCard(avgKpi, bestKpi, worstKpi),
                  const SizedBox(height: 20),
                  _sectionTitle("Today's Staff Status"),
                  const SizedBox(height: 12),
                  ...allStaff.map(
                    (s) => _staffStatusTile(
                      s,
                      _todayStatusForStaff(s.id, todayAttendance),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );

  Widget _kpiSummaryCard(double avg, KpiModel? best, KpiModel? worst) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                'Team KPI Average: ${avg.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (best != null)
            _kpiRow(Icons.emoji_events, 'Best Staff', best.staffName,
                best.totalKpiScore, AppColors.success),
          if (worst != null)
            _kpiRow(Icons.trending_down, 'Needs Improvement', worst.staffName,
                worst.totalKpiScore, AppColors.error),
        ],
      ),
    );
  }

  Widget _kpiRow(
      IconData icon, String label, String name, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffStatusTile(StaffModel s, String status) {
    Color statusColor;
    switch (status) {
      case 'Present':
      case 'Overtime':
        statusColor = AppColors.success;
        break;
      case 'Late':
        statusColor = AppColors.warning;
        break;
      case 'Absent':
        statusColor = AppColors.error;
        break;
      case 'On Leave':
        statusColor = AppColors.onLeave;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    final nameInitial = s.name.isNotEmpty ? s.name[0].toUpperCase() : '?';
    final checkIn = s.todayCheckIn ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              nameInitial,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${s.staffCode} · ${s.category}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (checkIn.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'In: $checkIn',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _todayStatusForStaff(String staffId, List<dynamic> attendance) {
    for (final record in attendance) {
      if (record.staffId == staffId) {
        return record.status;
      }
    }
    return 'No Record';
  }
}
