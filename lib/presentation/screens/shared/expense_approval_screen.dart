import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';

class ExpenseApprovalScreen extends ConsumerStatefulWidget {
  const ExpenseApprovalScreen({super.key});

  @override
  ConsumerState<ExpenseApprovalScreen> createState() =>
      _ExpenseApprovalScreenState();
}

class _ExpenseApprovalScreenState extends ConsumerState<ExpenseApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(allExpensesProvider);
    final pending = expenses.where((item) => item.status == 'Pending').toList();
    final approved =
        expenses.where((item) => item.status == 'Approved').toList();
    final rejected =
        expenses.where((item) => item.status == 'Rejected').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expense Approvals'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            const Tab(text: 'Approved'),
            const Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _expenseList(pending, showActions: true),
          _expenseList(approved),
          _expenseList(rejected),
        ],
      ),
    );
  }

  Widget _expenseList(List<ExpenseModel> expenses, {bool showActions = false}) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expense claims found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: expenses.length,
      itemBuilder: (_, index) =>
          _expenseCard(expenses[index], showActions: showActions),
    );
  }

  Widget _expenseCard(
    ExpenseModel expense, {
    bool showActions = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    expense.staffName.isNotEmpty
                        ? expense.staffName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.staffName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${expense.staffCode} • ${expense.expenseType}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: expense.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _chip(
                  icon: Icons.payments_outlined,
                  label: 'OMR ${expense.amount.toStringAsFixed(3)}',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _chip(
                  icon: Icons.event_outlined,
                  label: AppUtils.formatDate(expense.expenseDate),
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(expense.description),
            if (expense.approvedBy != null) ...[
              const SizedBox(height: 8),
              Text(
                'Approved by ${expense.approvedBy}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                ),
              ),
            ],
            if (expense.rejectionReason != null &&
                expense.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${expense.rejectionReason}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectExpense(expense),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(expense, 'Approved'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectExpense(ExpenseModel expense) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Expense'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Add rejection reason',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) {
      return;
    }
    await _updateStatus(expense, 'Rejected', rejectionReason: reason);
  }

  Future<void> _updateStatus(
    ExpenseModel expense,
    String status, {
    String? rejectionReason,
  }) async {
    final approver = ref.read(currentUserProvider)?.name;
    try {
      await ref.read(hrOperationsRepositoryProvider).updateExpenseStatus(
            expenseId: expense.id,
            status: status,
            approvedBy: approver,
            rejectionReason: rejectionReason,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(context, 'Expense status updated');
    } catch (_) {
      ref.read(mockDataRevisionProvider.notifier).state++;
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to update expense right now.',
        isError: true,
      );
    }
  }
}
