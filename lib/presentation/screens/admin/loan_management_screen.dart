import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/loan_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/l10n/app_localizations.dart';

class LoanManagementScreen extends ConsumerWidget {
  const LoanManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(allLoansProvider);
    final totalBalance = loans
        .where((l) => l.status == 'Active')
        .fold<double>(0, (s, l) => s + l.balanceAmount);
    final activeCount = loans.where((l) => l.status == 'Active').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('loan_management')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddLoanDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(
                    context.tr('total_balance'),
                    'OMR ${totalBalance.toStringAsFixed(0)}',
                    AppColors.error,
                    Icons.account_balance),
                _summaryItem(context.tr('active_loans'), activeCount.toString(),
                    AppColors.primary, Icons.pending_actions),
                _summaryItem(context.tr('total_loans'), loans.length.toString(),
                    AppColors.textSecondary, Icons.list_alt),
              ],
            ),
          ),
          Expanded(
            child: loans.isEmpty
                ? Center(child: Text(context.tr('no_loans_found')))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: loans.length,
                    itemBuilder: (ctx, i) => _loanCard(context, loans[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _loanCard(BuildContext context, LoanModel loan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySurface,
                child: Text(AppUtils.getInitials(loan.staffName),
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
                    Text(loan.staffName,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${loan.staffCode} • ${loan.purpose ?? 'Loan'}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(status: loan.status),
            ],
          ),
          const SizedBox(height: 12),
          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: loan.repaymentProgress,
              minHeight: 8,
              backgroundColor: AppColors.errorLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(loan.repaymentProgress * 100).toStringAsFixed(0)}${context.tr('percent_paid')}',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.success)),
              Text('OMR ${loan.balanceAmount.toStringAsFixed(0)} ${context.tr('remaining_balance')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _loanStatItem(
                      context.tr('total_label'),
                      'OMR ${loan.loanAmount.toStringAsFixed(0)}',
                      AppColors.textPrimary)),
              Expanded(
                  child: _loanStatItem(
                      context.tr('paid_label'),
                      'OMR ${loan.paidAmount.toStringAsFixed(0)}',
                      AppColors.success)),
              Expanded(
                  child: _loanStatItem(
                      context.tr('monthly_label'),
                      'OMR ${loan.monthlyDeduction.toStringAsFixed(0)}',
                      AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${context.tr('loan_date')}: ${AppUtils.formatDate(loan.loanDate)}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
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
                fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _loanStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  void _showAddLoanDialog(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    final monthlyCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    final staffList = ref.read(staffListProvider);
    String? selectedStaffId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.tr('add_new_loan')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: context.tr('select_staff'),
                    prefixIcon: const Icon(Icons.person_outline)),
                items: staffList
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => selectedStaffId = value,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                  controller: amountCtrl,
                  label: context.tr('loan_amount_label'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              CustomTextField(
                  controller: monthlyCtrl,
                  label: context.tr('monthly_deduction_label'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              CustomTextField(
                  controller: purposeCtrl,
                  label: context.tr('purpose_reason'),
                  maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () async {
              dynamic selectedStaff;
              for (final staff in staffList) {
                if (staff.id == selectedStaffId) {
                  selectedStaff = staff;
                  break;
                }
              }
              final amount = double.tryParse(amountCtrl.text.trim());
              final monthlyDeduction = double.tryParse(monthlyCtrl.text.trim());
              final purpose = purposeCtrl.text.trim();

              if (selectedStaff == null ||
                  amount == null ||
                  amount <= 0 ||
                  monthlyDeduction == null ||
                  monthlyDeduction <= 0) {
                AppUtils.showSnackBar(
                  context,
                  'Select staff and enter valid loan values.',
                  isError: true,
                );
                return;
              }

              try {
                await ref.read(hrOperationsRepositoryProvider).addLoan(
                      LoanModel(
                        id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
                        staffId: selectedStaff.id,
                        staffName: selectedStaff.name,
                        staffCode: selectedStaff.staffCode,
                        loanAmount: amount,
                        paidAmount: 0,
                        balanceAmount: amount,
                        monthlyDeduction: monthlyDeduction,
                        loanDate: DateTime.now(),
                        status: 'Active',
                        purpose: purpose.isEmpty ? null : purpose,
                        createdAt: DateTime.now(),
                      ),
                    );
                ref.read(mockDataRevisionProvider.notifier).state++;
              } catch (_) {
                ref.read(mockDataRevisionProvider.notifier).state++;
                if (!context.mounted) {
                  return;
                }
                AppUtils.showSnackBar(
                  context,
                  'Unable to add loan right now.',
                  isError: true,
                );
                return;
              }
              if (!ctx.mounted || !context.mounted) {
                return;
              }
              Navigator.pop(ctx);
              AppUtils.showSnackBar(context, 'Loan added successfully');
            },
            child: Text(context.tr('add_loan')),
          ),
        ],
      ),
    );
  }
}
