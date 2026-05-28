import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/loan_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../../core/l10n/app_localizations.dart';

class LoanScreen extends ConsumerWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    final loans =
        staff != null ? ref.watch(loanListProvider(staff.id)) : <LoanModel>[];

    final totalBalance = loans
        .where((l) => l.status == 'Active')
        .fold<double>(0, (s, l) => s + l.balanceAmount);
    final totalMonthly = loans
        .where((l) => l.status == 'Active')
        .fold<double>(0, (s, l) => s + l.monthlyDeduction);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('my_loans'))),
      body: Column(
        children: [
          if (loans.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC62828), Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem(
                      'Total Balance',
                      'OMR ${totalBalance.toStringAsFixed(0)}',
                      Icons.account_balance),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _summaryItem(
                      'Monthly Ded.',
                      'OMR ${totalMonthly.toStringAsFixed(0)}',
                      Icons.calendar_month),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _summaryItem(
                      'Active Loans',
                      loans
                          .where((l) => l.status == 'Active')
                          .length
                          .toString(),
                      Icons.pending_actions),
                ],
              ),
            ),
          Expanded(
            child: loans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(context.tr('no_active_loans'),
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: loans.length,
                    itemBuilder: (ctx, i) => _loanCard(loans[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _loanCard(LoanModel loan) {
    final pct = (loan.repaymentProgress * 100).toStringAsFixed(0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.purpose ?? 'Loan',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('Since ${AppUtils.formatDate(loan.loanDate)}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(status: loan.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _loanStat(
                  'Loan Amount',
                  'OMR ${loan.loanAmount.toStringAsFixed(0)}',
                  AppColors.textPrimary),
              _loanStat('Paid', 'OMR ${loan.paidAmount.toStringAsFixed(0)}',
                  AppColors.success),
              _loanStat(
                  'Balance',
                  'OMR ${loan.balanceAmount.toStringAsFixed(0)}',
                  AppColors.error),
              _loanStat(
                  'Monthly',
                  'OMR ${loan.monthlyDeduction.toStringAsFixed(0)}',
                  AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Repaid: $pct%',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600)),
              Text('Remaining: ${100 - int.parse(pct)}%',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
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
        ],
      ),
    );
  }

  Widget _loanStat(String label, String value, Color color) {
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
}
