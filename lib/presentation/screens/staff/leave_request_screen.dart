import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/leave_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/l10n/app_localizations.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider);
    final leaves =
        staff != null ? ref.watch(leaveListProvider(staff.id)) : <LeaveModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('leave_requests')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Apply Leave'), Tab(text: 'My Requests')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _applyLeaveTab(),
          _myLeavesTab(leaves),
        ],
      ),
    );
  }

  Widget _applyLeaveTab() {
    final formKey = GlobalKey<FormState>();
    String leaveType = AppConstants.leaveTypes.first;
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now().add(const Duration(days: 1));
    final reasonCtrl = TextEditingController();
    PlatformFile? attachment;

    return StatefulBuilder(
      builder: (ctx, setS) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave balance cards
              Row(
                children: [
                  _leaveBalanceCard('Annual Leave', 15, 10, AppColors.primary),
                  const SizedBox(width: 10),
                  _leaveBalanceCard('Sick Leave', 10, 8, AppColors.warning),
                  const SizedBox(width: 10),
                  _leaveBalanceCard('Emergency', 5, 4, AppColors.error),
                ],
              ),
              const SizedBox(height: 20),

              Text(ctx.tr('apply_for_leave'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              CustomDropdown<String>(
                value: leaveType,
                label: 'Leave Type',
                prefixIcon: Icons.category_outlined,
                items: AppConstants.leaveTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setS(() => leaveType = v ?? leaveType),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: fromDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setS(() => fromDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'From Date',
                          prefixIcon: Icon(Icons.calendar_today, size: 18),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(AppUtils.formatDate(fromDate),
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: toDate,
                          firstDate: fromDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setS(() => toDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'To Date',
                          prefixIcon: Icon(Icons.calendar_today, size: 18),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(AppUtils.formatDate(toDate),
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.date_range,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                        'Duration: ${toDate.difference(fromDate).inDays + 1} day(s)',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: reasonCtrl,
                label: 'Reason for Leave',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
                validator: (v) =>
                    v?.isEmpty == true ? 'Please provide a reason' : null,
              ),
              const SizedBox(height: 12),

              // Attachment
              InkWell(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.custom,
                    allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
                  );
                  if (result == null || result.files.isEmpty) {
                    return;
                  }

                  setS(() => attachment = result.files.single);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.divider, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          attachment == null
                              ? 'Attach Document (Optional)'
                              : attachment!.name,
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_outlined),
                  label: Text(ctx.tr('submit_leave_request')),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final staff = ref.read(currentStaffProvider);
                    if (staff == null) return;
                    final newLeave = LeaveModel(
                      id: 'lv_${DateTime.now().millisecondsSinceEpoch}',
                      staffId: staff.id,
                      staffName: staff.name,
                      staffCode: staff.staffCode,
                      leaveType: leaveType,
                      fromDate: fromDate,
                      toDate: toDate,
                      reason: reasonCtrl.text.trim(),
                      attachmentUrl: null,
                      status: 'Pending',
                      createdAt: DateTime.now(),
                    );
                    try {
                      await ref
                          .read(leaveNotifierProvider(staff.id).notifier)
                          .submit(
                            newLeave,
                            attachmentPath: attachment?.path,
                          );
                    } catch (_) {
                      if (!ctx.mounted) {
                        return;
                      }
                      AppUtils.showSnackBar(
                        ctx,
                        'Unable to submit leave request right now.',
                        isError: true,
                      );
                      return;
                    }
                    if (!mounted || !ctx.mounted) {
                      return;
                    }
                    reasonCtrl.clear();
                    setS(() => attachment = null);
                    AppUtils.showSnackBar(
                        ctx, 'Leave request submitted — pending approval');
                    _tabController.animateTo(1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _myLeavesTab(List<LeaveModel> leaves) {
    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.beach_access, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(context.tr('no_leave_requests_yet'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: leaves.length,
      itemBuilder: (ctx, i) => _leaveCard(leaves[i]),
    );
  }

  Widget _leaveCard(LeaveModel leave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.beach_access_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(leave.leaveType,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              StatusBadge(status: leave.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.date_range_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                  '${AppUtils.formatDate(leave.fromDate)} - ${AppUtils.formatDate(leave.toDate)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('${leave.totalDays}d',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(leave.reason,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          if (leave.approvedBy != null) ...[
            const SizedBox(height: 6),
            Text('Approved by: ${leave.approvedBy}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500)),
          ],
          if (leave.rejectionReason != null) ...[
            const SizedBox(height: 6),
            Text('Rejected: ${leave.rejectionReason}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 4),
          Text('Applied: ${AppUtils.formatDate(leave.createdAt)}',
              style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _leaveBalanceCard(String type, int total, int remaining, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('$remaining',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text('/$total',
                style: TextStyle(
                    fontSize: 11, color: color.withValues(alpha: 0.7))),
            Text(type.split(' ').first,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
