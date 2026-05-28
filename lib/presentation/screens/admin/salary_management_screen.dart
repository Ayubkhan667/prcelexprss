import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/salary_model.dart';
import '../../../data/services/export_service.dart';
import '../../widgets/common/status_badge.dart';

class SalaryManagementScreen extends ConsumerWidget {
  const SalaryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaries = ref.watch(allSalariesProvider);
    final totalNet = salaries.fold<double>(0, (s, sal) => s + sal.netSalary);
    final pendingCount =
        salaries.where((s) => s.paymentStatus == 'Pending').length;
    final paidCount = salaries.where((s) => s.paymentStatus == 'Paid').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Salary Management'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showGenerateSalaryDialog(context, ref)),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: salaries.isEmpty
                ? null
                : () => ExportService.exportSalaryToExcel(salaries),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(
                    'Total Payroll',
                    'OMR ${totalNet.toStringAsFixed(0)}',
                    AppColors.primary,
                    Icons.payments),
                _summaryItem('Pending', pendingCount.toString(),
                    AppColors.warning, Icons.pending_actions),
                _summaryItem('Paid', paidCount.toString(), AppColors.success,
                    Icons.check_circle_outline),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: salaries.length,
              itemBuilder: (ctx, i) => _salaryCard(context, ref, salaries[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _salaryCard(BuildContext context, WidgetRef ref, SalaryModel salary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(AppUtils.getInitials(salary.staffName),
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
                      Text(salary.staffName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${salary.staffCode} • ${salary.month}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(status: salary.paymentStatus),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _salaryRow('Basic Salary', salary.basicSalary,
                        AppColors.textPrimary),
                    _salaryRow(
                        'Overtime', salary.overtimeAmount, AppColors.success),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _salaryRow(
                        'Allowance', salary.allowance, AppColors.primary),
                    _salaryRow('Deduction', salary.deduction, AppColors.error),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _salaryRow('Loan Deduction', salary.loanDeduction,
                        AppColors.error),
                    _salaryRow('Absence Ded.', salary.absenceDeduction,
                        AppColors.error),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Salary',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('OMR ${salary.netSalary.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showSalaryDetail(context, salary),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (salary.paymentStatus == 'Pending')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _markSalaryPaid(context, ref, salary),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success),
                          child: const Text('Mark Paid'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _salaryRow(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text('OMR ${amount.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  void _showSalaryDetail(BuildContext context, SalaryModel salary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salary Details - ${salary.staffName}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(salary.month,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const Divider(height: 20),
            _detailRow('Basic Salary', salary.basicSalary, false),
            _detailRow('Overtime Amount', salary.overtimeAmount, false),
            _detailRow('Allowance', salary.allowance, false),
            const Divider(height: 16),
            _detailRow('Loan Deduction', salary.loanDeduction, true),
            _detailRow('Absence Deduction', salary.absenceDeduction, true),
            _detailRow('Other Deduction', salary.deduction, true),
            _detailRow('Penalty', salary.penalty, true),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('NET SALARY',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('OMR ${salary.netSalary.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, double amount, bool isDeduction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(
            '${isDeduction ? '-' : '+'}OMR ${amount.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDeduction ? AppColors.error : AppColors.success),
          ),
        ],
      ),
    );
  }

  void _showGenerateSalaryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Generate Salary'),
        content: const Text(
            'Generate salary for all active staff for the current month?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              int generated = 0;
              try {
                generated = await ref
                    .read(hrOperationsRepositoryProvider)
                    .generateSalariesForMonth(DateTime.now());
                ref.read(mockDataRevisionProvider.notifier).state++;
              } catch (_) {
                if (!context.mounted) {
                  return;
                }
                AppUtils.showSnackBar(
                  context,
                  'Unable to generate salaries right now.',
                  isError: true,
                );
                return;
              }
              if (!ctx.mounted || !context.mounted) {
                return;
              }
              Navigator.pop(ctx);
              AppUtils.showSnackBar(
                context,
                generated == 0
                    ? 'Salary records already exist for this month.'
                    : 'Generated $generated salary record${generated == 1 ? '' : 's'}.',
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _markSalaryPaid(
    BuildContext context,
    WidgetRef ref,
    SalaryModel salary,
  ) async {
    try {
      await ref.read(hrOperationsRepositoryProvider).markSalaryPaid(
            salaryId: salary.id,
            paidDate: DateTime.now(),
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to mark salary as paid.',
        isError: true,
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    AppUtils.showSnackBar(
      context,
      '${salary.staffName} salary marked as paid.',
    );
  }
}
