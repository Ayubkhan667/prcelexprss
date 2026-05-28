import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/kpi_model.dart';

class StaffKpiScreen extends ConsumerWidget {
  const StaffKpiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    final kpiList =
        staff != null ? ref.watch(kpiListProvider(staff.id)) : <KpiModel>[];
    final currentKpi = kpiList.isNotEmpty ? kpiList.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My KPI Report'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: kpiList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 72, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('No KPI data available',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 15)),
                  SizedBox(height: 6),
                  Text('KPI is calculated at end of each month',
                      style:
                          TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentKpi != null) ...[
                    _scoreHeader(currentKpi),
                    const SizedBox(height: 20),
                    _sectionTitle('Score Breakdown'),
                    const SizedBox(height: 12),
                    _scoreBreakdown(currentKpi),
                    const SizedBox(height: 20),
                    _sectionTitle('Attendance Details'),
                    const SizedBox(height: 12),
                    _attendanceDetails(currentKpi),
                    const SizedBox(height: 20),
                    _sectionTitle('What Affects Your KPI'),
                    const SizedBox(height: 12),
                    _ruleCard(
                        'Task Delivery',
                        'Completed task cards now carry the highest KPI weight. Closed tasks are excluded.',
                        Icons.assignment_turned_in,
                        AppColors.primaryDark),
                    _ruleCard(
                        'Attendance',
                        'Each absent day reduces attendance score. Target: 100% presence.',
                        Icons.event_available,
                        AppColors.success),
                    _ruleCard(
                        'Punctuality',
                        'Late check-ins reduce punctuality score. Grace period: 15 mins.',
                        Icons.access_time,
                        AppColors.warning),
                    _ruleCard(
                        'Overtime',
                        'Approved overtime hours add to your score (bonus points).',
                        Icons.more_time,
                        AppColors.primary),
                    _ruleCard(
                        'Location',
                        'Check-ins must be within branch geofence radius (150m).',
                        Icons.location_on,
                        AppColors.onLeave),
                    _ruleCard(
                        'Discipline',
                        'Fake GPS, missing checkouts, and early checkouts reduce this score.',
                        Icons.gpp_maybe,
                        AppColors.error),
                  ],
                  if (kpiList.length > 1) ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Monthly History'),
                    const SizedBox(height: 12),
                    ...kpiList.map((k) => _historyTile(k)),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _scoreHeader(KpiModel kpi) {
    final color = AppUtils.getKpiColor(kpi.totalKpiScore);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4))
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
                  Text('KPI Score — ${kpi.month}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(kpi.totalKpiScore.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          height: 1)),
                  Text('out of 100',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(24)),
                child: Text(kpi.rating,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: kpi.totalKpiScore / 100,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tasks: ${kpi.taskCompletedCount}/${kpi.taskAssignedCount}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11)),
              Text('Attendance: ${kpi.attendanceRate}%',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11)),
              Text('Late: ${kpi.lateCount} times',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreBreakdown(KpiModel kpi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          _scoreRow('Task Delivery', kpi.taskScore, AppConstants.kpiTaskWeight,
              AppColors.primaryDark),
          const Divider(height: 16),
          _scoreRow('Attendance Score', kpi.attendanceScore,
              AppConstants.kpiAttendanceWeight, AppColors.success),
          const Divider(height: 16),
          _scoreRow('Punctuality Score', kpi.punctualityScore,
              AppConstants.kpiPunctualityWeight, AppColors.warning),
          const Divider(height: 16),
          _scoreRow('Overtime Score', kpi.overtimeScore,
              AppConstants.kpiOvertimeWeight, AppColors.primary),
          const Divider(height: 16),
          _scoreRow('Location Score', kpi.locationScore,
              AppConstants.kpiLocationWeight, AppColors.onLeave),
          const Divider(height: 16),
          _scoreRow('Discipline Score', kpi.disciplineScore,
              AppConstants.kpiDisciplineWeight, AppColors.error),
          const Divider(height: 16, thickness: 1.5),
          _scoreRow('Total KPI Score', kpi.totalKpiScore, 100,
              AppUtils.getKpiColor(kpi.totalKpiScore),
              isTotal: true),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, double score, int max, Color color,
      {bool isTotal = false}) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            value: score / max,
            strokeWidth: 2.5,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 13 : 12,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          '${score.toStringAsFixed(1)} / $max',
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _attendanceDetails(KpiModel kpi) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _statChip('Present Days', '${(kpi.attendanceRate * 0.22).round()}',
            AppColors.success, Icons.check_circle_outline),
        _statChip(
            'Absent',
            '${kpi.missingCheckoutCount + (100 - kpi.attendanceRate) ~/ 5}',
            AppColors.error,
            Icons.cancel_outlined),
        _statChip('Late Check-ins', '${kpi.lateCount}', AppColors.warning,
            Icons.access_time),
        _statChip('Missing Checkout', '${kpi.missingCheckoutCount}',
            AppColors.error, Icons.logout),
        _statChip('Early Checkout', '${kpi.earlyCheckoutCount}',
            AppColors.warning, Icons.exit_to_app),
        _statChip('OT Hours', '${kpi.overtimeHours.toStringAsFixed(1)}h',
            AppColors.primary, Icons.more_time),
        _statChip('Total Hours', '${kpi.totalWorkingHours.toStringAsFixed(0)}h',
            AppColors.textPrimary, Icons.timer_outlined),
        _statChip(
            'Fake GPS',
            '${kpi.fakeGpsCount}',
            kpi.fakeGpsCount > 0 ? AppColors.error : AppColors.success,
            Icons.gps_off),
        _statChip(
            'Tasks Done',
            '${kpi.taskCompletedCount}/${kpi.taskAssignedCount}',
            AppColors.primaryDark,
            Icons.assignment_turned_in),
        _statChip('Task Rate', '${kpi.taskCompletionRate.toStringAsFixed(0)}%',
            AppColors.primaryDark, Icons.task_alt),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ruleCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(KpiModel kpi) {
    final color = AppUtils.getKpiColor(kpi.totalKpiScore);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kpi.month,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                    'Attendance: ${kpi.attendanceRate}% • Late: ${kpi.lateCount}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(kpi.totalKpiScore.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: color)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(kpi.rating,
                    style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      );
}
