import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/leave_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/l10n/app_localizations.dart';

class SupervisorLeaveApprovalScreen extends ConsumerStatefulWidget {
  const SupervisorLeaveApprovalScreen({super.key});

  @override
  ConsumerState<SupervisorLeaveApprovalScreen> createState() =>
      _SupervisorLeaveApprovalScreenState();
}

class _SupervisorLeaveApprovalScreenState
    extends ConsumerState<SupervisorLeaveApprovalScreen>
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
    final allLeaves = ref.watch(leaveListProvider(null));
    final pending = allLeaves
        .where((leave) => leave.status == AppConstants.leaveStatusPending)
        .toList();
    final approved = allLeaves
        .where((leave) => leave.status == AppConstants.leaveStatusApproved)
        .toList();
    final rejected = allLeaves
        .where((leave) => leave.status == AppConstants.leaveStatusRejected)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('leave_approvals')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Approved (${approved.length})'),
            Tab(text: 'Rejected (${rejected.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _leaveList(pending, showActions: true),
          _leaveList(approved),
          _leaveList(rejected),
        ],
      ),
    );
  }

  Widget _leaveList(List<LeaveModel> leaves, {bool showActions = false}) {
    if (leaves.isEmpty) {
      return Center(
        child: Text(context.tr('no_leave_requests'),
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaves.length,
      itemBuilder: (_, i) => _leaveCard(leaves[i], showActions: showActions),
    );
  }

  Widget _leaveCard(LeaveModel leave, {bool showActions = false}) {
    Color statusColor;
    switch (leave.status) {
      case 'Approved':
        statusColor = AppColors.success;
        break;
      case 'Rejected':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    final days = leave.toDate.difference(leave.fromDate).inDays + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    leave.staffName.isNotEmpty
                        ? leave.staffName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(leave.staffName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(leave.staffCode,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    leave.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.event_note, 'Leave Type', leave.leaveType),
            const SizedBox(height: 6),
            _infoRow(
              Icons.date_range,
              'Period',
              '${DateFormat('dd MMM').format(leave.fromDate)} – ${DateFormat('dd MMM yyyy').format(leave.toDate)} ($days day${days > 1 ? 's' : ''})',
            ),
            const SizedBox(height: 6),
            _infoRow(Icons.notes, 'Reason', leave.reason),
            if (leave.approvedBy != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.person_outline, 'Reviewed By', leave.approvedBy!),
            ],
            if (leave.rejectionReason != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.cancel_outlined, 'Rejection Reason',
                  leave.rejectionReason!),
            ],
            if (showActions) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(leave),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(context.tr('reject')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveLeave(leave),
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(context.tr('approve')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Future<void> _approveLeave(LeaveModel leave) async {
    final approver = ref.read(currentUserProvider)?.name ?? 'Supervisor';
    try {
      await ref.read(leaveNotifierProvider(null).notifier).updateStatus(
            leaveId: leave.id,
            status: AppConstants.leaveStatusApproved,
            approvedBy: approver,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to approve leave right now.',
        isError: true,
      );
      return;
    }
    if (!mounted) {
      return;
    }
    AppUtils.showSnackBar(context, 'Leave approved for ${leave.staffName}');
  }

  void _showRejectDialog(LeaveModel leave) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('reject_leave')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rejecting leave for ${leave.staffName}'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = ctrl.text.trim();
              if (reason.isEmpty) {
                AppUtils.showSnackBar(
                  context,
                  'Rejection reason is required.',
                  isError: true,
                );
                return;
              }
              final approver =
                  ref.read(currentUserProvider)?.name ?? 'Supervisor';
              try {
                await ref
                    .read(leaveNotifierProvider(null).notifier)
                    .updateStatus(
                      leaveId: leave.id,
                      status: AppConstants.leaveStatusRejected,
                      approvedBy: approver,
                      rejectionReason: reason,
                    );
              } catch (_) {
                if (!mounted) {
                  return;
                }
                AppUtils.showSnackBar(
                  context,
                  'Unable to reject leave right now.',
                  isError: true,
                );
                return;
              }
              if (!mounted || !dialogContext.mounted) {
                return;
              }
              Navigator.pop(dialogContext);
              AppUtils.showSnackBar(
                context,
                'Leave rejected for ${leave.staffName}',
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: Text(context.tr('reject')),
          ),
        ],
      ),
    );
  }
}
