import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class AttendancePieChart extends StatefulWidget {
  final int present;
  final int absent;
  final int late;
  final int onLeave;
  final int overtime;

  const AttendancePieChart({
    super.key,
    required this.present,
    required this.absent,
    required this.late,
    required this.onLeave,
    required this.overtime,
  });

  @override
  State<AttendancePieChart> createState() => _AttendancePieChartState();
}

class _AttendancePieChartState extends State<AttendancePieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AttendancePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.present +
        widget.absent +
        widget.late +
        widget.onLeave +
        widget.overtime;
    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    final items = [
      _ArcItem('Present', widget.present, total, AppColors.present),
      _ArcItem('Absent', widget.absent, total, AppColors.absent),
      _ArcItem('Late', widget.late, total, AppColors.late),
      _ArcItem('On Leave', widget.onLeave, total, AppColors.onLeave),
      _ArcItem('Overtime', widget.overtime, total, AppColors.overtime),
    ];

    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return CustomPaint(
              size: const Size(double.infinity, 200),
              painter:
                  _SemiArcPainter(items: items, progress: _animation.value),
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: items.map((item) => _LegendTile(item: item)).toList(),
        ),
      ],
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _ArcItem {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _ArcItem(this.label, this.count, this.total, this.color);

  double get ratio => total > 0 ? count / total : 0.0;
  String get pct => '${(ratio * 100).toStringAsFixed(0)}%';
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _SemiArcPainter extends CustomPainter {
  final List<_ArcItem> items;
  final double progress;

  const _SemiArcPainter({required this.items, required this.progress});

  static const double _strokeWidth = 14.0;
  static const double _gap = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 16;
    final maxRadius = (math.min(cx, cy) - 8).clamp(40.0, 160.0);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final radius = maxRadius - i * (_strokeWidth + _gap);
      if (radius <= _strokeWidth / 2) continue;

      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

      // Track (background)
      canvas.drawArc(
        rect,
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = item.color.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      // Filled arc
      final sweep = math.pi * item.ratio * progress;
      if (sweep > 0.01) {
        canvas.drawArc(
          rect,
          math.pi,
          sweep,
          false,
          Paint()
            ..color = item.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = _strokeWidth
            ..strokeCap = StrokeCap.round,
        );
      }

      // Percentage label at arc tip
      if (item.ratio > 0.04 && progress > 0.5) {
        final tipAngle = math.pi + math.pi * item.ratio * progress;
        final labelOpacity = ((progress - 0.5) * 2).clamp(0.0, 1.0);
        final tx = cx + radius * math.cos(tipAngle);
        final ty = cy + radius * math.sin(tipAngle);

        final tp = TextPainter(
          text: TextSpan(
            text: item.pct,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: item.color.withValues(alpha: labelOpacity),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset(tx - tp.width / 2, ty - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_SemiArcPainter old) => old.progress != progress;
}

// ─── Legend tile ──────────────────────────────────────────────────────────────

class _LegendTile extends StatelessWidget {
  final _ArcItem item;
  const _LegendTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '${item.label} (${item.count})',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─── KPI Bar Chart (unchanged) ────────────────────────────────────────────────

class KpiBarChart extends StatelessWidget {
  final List<KpiBarData> data;

  const KpiBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: data.asMap().entries.map((e) {
          final color = e.value.score >= 80
              ? AppColors.success
              : e.value.score >= 60
                  ? AppColors.warning
                  : AppColors.error;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.score,
                color: color,
                width: 18,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[i].name.split(' ').first,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}',
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textSecondary),
              ),
              reservedSize: 28,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class KpiBarData {
  final String name;
  final double score;
  const KpiBarData(this.name, this.score);
}
