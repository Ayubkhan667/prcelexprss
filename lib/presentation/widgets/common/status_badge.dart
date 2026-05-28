import 'package:flutter/material.dart';
import '../../../core/utils/app_utils.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.getStatusColor(status);
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class KpiBadge extends StatelessWidget {
  final double score;
  final String rating;

  const KpiBadge({super.key, required this.score, required this.rating});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.getKpiColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Text(rating,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
