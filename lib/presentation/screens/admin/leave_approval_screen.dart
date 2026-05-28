import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/leave_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../../core/l10n/app_localizations.dart';

class LeaveApprovalScreen extends ConsumerStatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  ConsumerState<LeaveApprovalScreen> createState() =>
      _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends ConsumerState<LeaveApprovalScreen>
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
    final pending = allLeaves.where((l) => l.status == 'Pending').toList();
    final approved = allLeaves.where((l) => l.status == 'Approved').toList();
    final rejected = allLeaves.where((l) => l.status == 'Rejected').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('leave_management')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
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
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.beach_access, size: 60, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(context.tr('no_leave_requests'),
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: leaves.length,
      itemBuilder: (ctx, i) =>
          _leaveCard(ctx, leaves[i], showActions: showActions),
    );
  }

  Widget _leaveCard(BuildContext context, LeaveModel leave,
      {bool showActions = false}) {
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  AppUtils.getStatusColor(leave.status).withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(AppUtils.getInitials(leave.staffName),
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
                      Text(leave.staffName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(leave.staffCode,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(status: leave.status),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _infoChip(
                        Icons.category, leave.leaveType, AppColors.primary),
                    const SizedBox(width: 8),
                    _infoChip(
                        Icons.date_range,
                        '${leave.totalDays} day${leave.totalDays > 1 ? 's' : ''}',
                        AppColors.accent),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                        '${AppUtils.formatDate(leave.fromDate)} - ${AppUtils.formatDate(leave.toDate)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(leave.reason, style: const TextStyle(fontSize: 13)),
                if (leave.approvedBy != null) ...[
                  const SizedBox(height: 6),
                  Text('Approved by: ${leave.approvedBy}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.success)),
                ],
                if (leave.rejectionReason != null) ...[
                  const SizedBox(height: 6),
                  Text('Rejection: ${leave.rejectionReason}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.error)),
                ],
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close, size: 16),
                          label: Text(context.tr('reject')),
                          onPressed: () => _rejectLeave(context, leave),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 16),
                          label: Text(context.tr('approve')),
                          onPressed: () => _approveLeave(context, leave),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _approveLeave(BuildContext context, LeaveModel leave) async {
    final approver = ref.read(currentUserProvider)?.name ?? 'Admin';
    try {
      await ref.read(leaveNotifierProvider(null).notifier).updateStatus(
            leaveId: leave.id,
            status: AppConstants.leaveStatusApproved,
            approvedBy: approver,
            rejectionReason: null,
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to approve leave right now.',
        isError: true,
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    AppUtils.showSnackBar(context, 'Leave approved for ${leave.staffName}');
  }

  void _rejectLeave(BuildContext context, LeaveModel leave) {
    showDialog(
      context: context,
      builder: (ctx) {
        final reasonCtrl = TextEditingController();
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(context.tr('reject_leave')),
          content: TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(labelText: 'Rejection reason'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('cancel'))),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonCtrl.text.trim();
                if (reason.isEmpty) {
                  AppUtils.showSnackBar(
                    context,
                    'Rejection reason is required.',
                    isError: true,
                  );
                  return;
                }
                final approver = ref.read(currentUserProvider)?.name ?? 'Admin';
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
                  if (!context.mounted) {
                    return;
                  }
                  AppUtils.showSnackBar(
                    context,
                    'Unable to reject leave right now.',
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
                  'Leave rejected for ${leave.staffName}',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(context.tr('reject')),
            ),
          ],
        );
      },
    );
  }
}
