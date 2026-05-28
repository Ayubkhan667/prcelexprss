import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/salary_model.dart';
import '../../widgets/common/status_badge.dart';

class SalaryScreen extends ConsumerWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    final salaries = staff != null
        ? ref.watch(salaryListProvider(staff.id))
        : <SalaryModel>[];

    final latestSalary = salaries.isNotEmpty ? salaries.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Salary'),
        actions: [
          IconButton(
              icon: const Icon(Icons.file_download_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Latest salary banner
          if (latestSalary != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
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
                          Text(latestSalary.month,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8))),
                          Text(
                              'OMR ${latestSalary.netSalary.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const Text('Net Salary',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                      StatusBadge(status: latestSalary.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _salaryChip('Basic', latestSalary.basicSalary),
                      _salaryChip('OT', latestSalary.overtimeAmount),
                      _salaryChip('Allow', latestSalary.allowance),
                      _salaryChip('Deduct', latestSalary.totalDeductions,
                          isDeduction: true),
                    ],
                  ),
                ],
              ),
            ),

          // History list
          Expanded(
            child: salaries.isEmpty
                ? const Center(child: Text('No salary records found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: salaries.length,
                    itemBuilder: (ctx, i) => _salaryCard(context, salaries[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _salaryChip(String label, double amount, {bool isDeduction = false}) {
    return Column(
      children: [
        Text('OMR ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDeduction ? Colors.red[200] : Colors.white,
            )),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.white.withValues(alpha: 0.75))),
      ],
    );
  }

  Widget _salaryCard(BuildContext context, SalaryModel salary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.payments_outlined,
              color: AppColors.primary, size: 20),
        ),
        title: Text(salary.month,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('Net: OMR ${salary.netSalary.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600)),
        trailing: StatusBadge(status: salary.paymentStatus, fontSize: 10),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(),
                _row(
                    'Basic Salary',
                    'OMR ${salary.basicSalary.toStringAsFixed(0)}',
                    AppColors.textPrimary),
                _row(
                    'Overtime Amount',
                    '+ OMR ${salary.overtimeAmount.toStringAsFixed(0)}',
                    AppColors.success),
                _row(
                    'Allowance',
                    '+ OMR ${salary.allowance.toStringAsFixed(0)}',
                    AppColors.primary),
                if (salary.loanDeduction > 0)
                  _row(
                      'Loan Deduction',
                      '- OMR ${salary.loanDeduction.toStringAsFixed(0)}',
                      AppColors.error),
                if (salary.absenceDeduction > 0)
                  _row(
                      'Absence Deduction',
                      '- OMR ${salary.absenceDeduction.toStringAsFixed(0)}',
                      AppColors.error),
                if (salary.penalty > 0)
                  _row('Penalty', '- OMR ${salary.penalty.toStringAsFixed(0)}',
                      AppColors.error),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Salary',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('OMR ${salary.netSalary.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
                if (salary.paidDate != null) ...[
                  const SizedBox(height: 4),
                  Text('Paid on: ${AppUtils.formatDate(salary.paidDate!)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.success)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
