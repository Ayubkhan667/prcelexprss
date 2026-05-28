import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/document_alert_model.dart';
import '../../../data/providers/app_providers.dart';

class DocumentAlertScreen extends ConsumerWidget {
  const DocumentAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(documentAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Document Alerts')),
      body: alerts.isEmpty
          ? const Center(
              child: Text('No expiring documents in the next 30 days.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: alerts.length,
              itemBuilder: (_, index) => _alertCard(alerts[index]),
            ),
    );
  }

  Widget _alertCard(DocumentAlertModel alert) {
    final color = alert.isExpired
        ? AppColors.error
        : alert.isUrgent
            ? AppColors.warning
            : AppColors.primary;

    final subtitle = alert.isExpired
        ? '${alert.documentType} expired ${alert.daysRemaining.abs()} day(s) ago'
        : '${alert.documentType} expires in ${alert.daysRemaining} day(s)';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.badge_outlined, color: color),
        ),
        title: Text(
          alert.staffName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${alert.staffCode} • $subtitle'),
            Text(
              'Expiry: ${AppUtils.formatDate(alert.expiryDate)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
