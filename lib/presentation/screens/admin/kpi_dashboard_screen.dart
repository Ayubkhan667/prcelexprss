import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/kpi_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/charts/attendance_pie_chart.dart';
import '../../../core/l10n/app_localizations.dart';

class KpiDashboardScreen extends ConsumerWidget {
  const KpiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiList = ref.watch(allKpiProvider);
    if (kpiList.isEmpty) {
      return Scaffold(body: Center(child: Text(context.tr('no_kpi_data'))));
    }

    kpiList.sort((a, b) => b.totalKpiScore.compareTo(a.totalKpiScore));
    final best = kpiList.first;
    final avgScore =
        kpiList.fold<double>(0, (s, k) => s + k.totalKpiScore) / kpiList.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('kpi_dashboard')),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary row
            Row(
              children: [
                Expanded(
                    child: _kpiSummaryCard(
                        context.tr('average_kpi'),
                        avgScore.toStringAsFixed(1),
                        Icons.analytics,
                        AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(
                    child: _kpiSummaryCard(
                        context.tr('best_score'),
                        best.totalKpiScore.toStringAsFixed(1),
                        Icons.emoji_events,
                        AppColors.success)),
                const SizedBox(width: 10),
                Expanded(
                    child: _kpiSummaryCard(
                        context.tr('total_staff'),
                        kpiList.length.toString(),
                        Icons.people,
                        AppColors.accent)),
              ],
            ),
            const SizedBox(height: 20),

            // KPI bar chart
            _sectionHeader(context.tr('staff_kpi_scores')),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: KpiBarChart(
                data: kpiList
                    .map((k) => KpiBarData(k.staffName, k.totalKpiScore))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Top performers
            _sectionHeader(context.tr('top_performers')),
            const SizedBox(height: 10),
            ...kpiList.take(3).toList().asMap().entries.map((e) {
              final k = e.value;
              final rank = e.key + 1;
              return _leaderboardCard(k, rank);
            }),

            const SizedBox(height: 20),
            // Full KPI list
            _sectionHeader(context.tr('all_staff_kpi')),
            const SizedBox(height: 10),
            ...kpiList.map((k) => _kpiListCard(context, k)),

            const SizedBox(height: 20),
            _sectionHeader(context.tr('score_breakdown_weights')),
            const SizedBox(height: 10),
            _scoreWeightCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _kpiSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withValues(alpha: 0.85)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _leaderboardCard(KpiModel k, int rank) {
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : const Color(0xFFCD7F32);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecor(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
            child: Center(
                child: Text('#$rank',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 13))),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySurface,
            child: Text(AppUtils.getInitials(k.staffName),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.staffName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(k.staffCode,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(k.totalKpiScore.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppUtils.getKpiColor(k.totalKpiScore))),
              StatusBadge(status: k.rating, fontSize: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiListCard(BuildContext context, KpiModel k) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _cardDecor(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppUtils.getKpiColor(k.totalKpiScore)
                      .withValues(alpha: 0.1),
                  child: Text(AppUtils.getInitials(k.staffName),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppUtils.getKpiColor(k.totalKpiScore))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k.staffName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      Text('${k.staffCode} • ${k.month}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(k.totalKpiScore.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppUtils.getKpiColor(k.totalKpiScore))),
                    StatusBadge(status: k.rating, fontSize: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Score bars
            _scoreLine(context.tr('attendance_label'), k.attendanceScore, 40, AppColors.present),
            _scoreLine(context.tr('punctuality'), k.punctualityScore, 25, AppColors.primary),
            _scoreLine(context.tr('overtime'), k.overtimeScore, 15, AppColors.accent),
            _scoreLine(context.tr('location_short'), k.locationScore, 10, AppColors.success),
            _scoreLine(context.tr('discipline_short'), k.disciplineScore, 10, AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _scoreLine(String label, double score, double maxScore, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: maxScore > 0 ? score / maxScore : 0,
                minHeight: 5,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('${score.toStringAsFixed(1)}/$maxScore',
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _scoreWeightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        children: [
          _weightRow(context.tr('attendance_label'), 40, AppColors.present, context),
          _weightRow(context.tr('punctuality'), 25, AppColors.primary, context),
          _weightRow(context.tr('overtime_extra_support'), 15, AppColors.accent, context),
          _weightRow(context.tr('location_compliance'), 10, AppColors.success, context),
          _weightRow(context.tr('discipline_violation'), 10, AppColors.warning, context),
        ],
      ),
    );
  }

  Widget _weightRow(String label, int weight, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text('$weight ${context.tr('pts_label')}',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary));

  BoxDecoration _cardDecor() => BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: const Color.fromARGB(255, 139, 84, 84)
                  .withValues(alpha: 0.05),
              blurRadius: 6)
        ],
      );
}
