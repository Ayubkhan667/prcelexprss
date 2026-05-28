import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/shift_roster_model.dart';
import '../../../data/models/shift_swap_request_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';

class ShiftRosterScreen extends ConsumerStatefulWidget {
  final bool adminMode;
  const ShiftRosterScreen({
    super.key,
    this.adminMode = false,
  });

  @override
  ConsumerState<ShiftRosterScreen> createState() => _ShiftRosterScreenState();
}

class _ShiftRosterScreenState extends ConsumerState<ShiftRosterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentStaff = ref.watch(currentStaffProvider);
    final rosters = ref.watch(
      shiftRostersProvider(widget.adminMode ? null : currentStaff?.id),
    );
    final allSwaps = ref.watch(shiftSwapRequestsProvider);
    final swaps = widget.adminMode
        ? allSwaps
        : allSwaps
            .where((item) =>
                item.requesterStaffId == currentStaff?.id ||
                item.targetStaffId == currentStaff?.id)
            .toList();
    final canManageRosters = currentUser?.role == AppConstants.roleAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.adminMode ? 'Roster & Swaps' : 'My Roster'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Rosters'),
            Tab(text: 'Swap Requests'),
          ],
        ),
      ),
      floatingActionButton: _buildFab(
        canManageRosters: canManageRosters,
        currentStaff: currentStaff,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _rosterTab(rosters, canManageRosters),
          _swapTab(swaps),
        ],
      ),
    );
  }

  Widget? _buildFab({
    required bool canManageRosters,
    required StaffModel? currentStaff,
  }) {
    if (_tabController.index == 0 && widget.adminMode && canManageRosters) {
      return FloatingActionButton.extended(
        onPressed: () => _showRosterSheet(),
        label: const Text('Add Roster'),
        icon: const Icon(Icons.add),
      );
    }
    if (_tabController.index == 1 &&
        !widget.adminMode &&
        currentStaff != null) {
      return FloatingActionButton.extended(
        onPressed: () => _showSwapSheet(currentStaff),
        label: const Text('Request Swap'),
        icon: const Icon(Icons.swap_horiz),
      );
    }
    return null;
  }

  Widget _rosterTab(List<ShiftRosterModel> rosters, bool canManageRosters) {
    if (rosters.isEmpty) {
      return const Center(child: Text('No roster assignments found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: rosters.length,
      itemBuilder: (_, index) {
        final roster = rosters[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.schedule_outlined,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              '${roster.shiftName} • ${AppUtils.formatDate(roster.rosterDate)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              widget.adminMode
                  ? '${roster.staffName} • ${roster.startTime} - ${roster.endTime}'
                  : '${roster.startTime} - ${roster.endTime}',
            ),
            trailing: canManageRosters
                ? IconButton(
                    onPressed: () => _showRosterSheet(existing: roster),
                    icon: const Icon(Icons.edit_outlined),
                  )
                : StatusBadge(status: roster.status, fontSize: 10),
          ),
        );
      },
    );
  }

  Widget _swapTab(List<ShiftSwapRequestModel> swaps) {
    if (swaps.isEmpty) {
      return const Center(child: Text('No shift swap requests found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: swaps.length,
      itemBuilder: (_, index) => _swapCard(swaps[index]),
    );
  }

  Widget _swapCard(ShiftSwapRequestModel request) {
    final canApprove = widget.adminMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${request.requesterName} -> ${request.targetName}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${AppUtils.formatDate(request.rosterDate)} • ${request.requesterShiftName} <> ${request.targetShiftName ?? '-'}',
          ),
          const SizedBox(height: 6),
          Text(request.reason),
          if (request.rejectionReason != null &&
              request.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reason: ${request.rejectionReason}',
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
          if (canApprove && request.status == 'Pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectSwap(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _updateSwapStatus(request, 'Approved'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showRosterSheet({ShiftRosterModel? existing}) async {
    final allStaff = ref.read(allStaffListProvider);
    final allShifts = ref.read(shiftListProvider);
    if (allStaff.isEmpty || allShifts.isEmpty) {
      AppUtils.showSnackBar(
        context,
        'Staff and shifts must exist before assigning a roster.',
        isError: true,
      );
      return;
    }

    String selectedStaffId = existing?.staffId ?? allStaff.first.id;
    String selectedShiftId = existing?.shiftId ?? allShifts.first.id;
    DateTime selectedDate = existing?.rosterDate ?? DateTime.now();
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStaffId,
                decoration: const InputDecoration(
                  labelText: 'Staff member',
                  border: OutlineInputBorder(),
                ),
                items: allStaff
                    .map(
                      (staff) => DropdownMenuItem(
                        value: staff.id,
                        child: Text('${staff.name} (${staff.staffCode})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setModalState(
                    () => selectedStaffId = value ?? selectedStaffId),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedShiftId,
                decoration: const InputDecoration(
                  labelText: 'Shift',
                  border: OutlineInputBorder(),
                ),
                items: allShifts
                    .map(
                      (shift) => DropdownMenuItem(
                        value: shift.id,
                        child: Text(shift.shiftName),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setModalState(
                    () => selectedShiftId = value ?? selectedShiftId),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Roster date'),
                subtitle: Text(AppUtils.formatDate(selectedDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesCtrl,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final staff =
                      allStaff.firstWhere((item) => item.id == selectedStaffId);
                  final shift = allShifts
                      .firstWhere((item) => item.id == selectedShiftId);
                  final roster = ShiftRosterModel(
                    id: existing?.id ??
                        'roster_${DateTime.now().millisecondsSinceEpoch}',
                    staffId: staff.id,
                    staffName: staff.name,
                    staffCode: staff.staffCode,
                    rosterDate: selectedDate,
                    shiftId: shift.id,
                    shiftName: shift.shiftName,
                    startTime: shift.startTime,
                    endTime: shift.endTime,
                    status: existing?.status ?? 'Scheduled',
                    notes: notesCtrl.text.trim().isEmpty
                        ? null
                        : notesCtrl.text.trim(),
                    assignedBy: ref.read(currentUserProvider)?.name ?? 'Admin',
                    createdAt: existing?.createdAt ?? DateTime.now(),
                  );
                  try {
                    await ref
                        .read(hrOperationsRepositoryProvider)
                        .saveShiftRoster(
                          roster: roster,
                          isEdit: existing != null,
                        );
                    ref.read(mockDataRevisionProvider.notifier).state++;
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context, true);
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    AppUtils.showSnackBar(
                      context,
                      'Unable to save roster right now.',
                      isError: true,
                    );
                  }
                },
                child:
                    Text(existing == null ? 'Create Roster' : 'Update Roster'),
              ),
            ],
          ),
        ),
      ),
    );

    notesCtrl.dispose();
    if (saved == true && mounted) {
      AppUtils.showSnackBar(context, 'Roster saved');
    }
  }

  Future<void> _showSwapSheet(StaffModel currentStaff) async {
    final candidates = ref
        .read(allStaffListProvider)
        .where((item) => item.id != currentStaff.id)
        .toList();
    final rosters = ref.read(shiftRostersProvider(currentStaff.id));

    if (candidates.isEmpty || rosters.isEmpty) {
      AppUtils.showSnackBar(
        context,
        'A roster and at least one teammate are required for swap requests.',
        isError: true,
      );
      return;
    }

    String targetStaffId = candidates.first.id;
    DateTime selectedDate = rosters.first.rosterDate;
    final reasonCtrl = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: targetStaffId,
                decoration: const InputDecoration(
                  labelText: 'Swap with',
                  border: OutlineInputBorder(),
                ),
                items: candidates
                    .map(
                      (staff) => DropdownMenuItem(
                        value: staff.id,
                        child: Text('${staff.name} (${staff.staffCode})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => targetStaffId = value ?? targetStaffId),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DateTime>(
                value: selectedDate,
                decoration: const InputDecoration(
                  labelText: 'Roster date',
                  border: OutlineInputBorder(),
                ),
                items: rosters
                    .map(
                      (roster) => DropdownMenuItem(
                        value: roster.rosterDate,
                        child: Text(
                          '${AppUtils.formatDate(roster.rosterDate)} • ${roster.shiftName}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => selectedDate = value ?? selectedDate),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final reason = reasonCtrl.text.trim();
                  if (reason.isEmpty) {
                    AppUtils.showSnackBar(
                      context,
                      'Reason is required.',
                      isError: true,
                    );
                    return;
                  }

                  final target =
                      candidates.firstWhere((item) => item.id == targetStaffId);
                  final requesterRoster = rosters.firstWhere((item) =>
                      item.rosterDate.year == selectedDate.year &&
                      item.rosterDate.month == selectedDate.month &&
                      item.rosterDate.day == selectedDate.day);
                  final request = ShiftSwapRequestModel(
                    id: 'swap_${DateTime.now().millisecondsSinceEpoch}',
                    requesterStaffId: currentStaff.id,
                    requesterName: currentStaff.name,
                    requesterCode: currentStaff.staffCode,
                    targetStaffId: target.id,
                    targetName: target.name,
                    targetCode: target.staffCode,
                    rosterDate: selectedDate,
                    requesterShiftId: requesterRoster.shiftId,
                    requesterShiftName: requesterRoster.shiftName,
                    reason: reason,
                    status: 'Pending',
                    createdAt: DateTime.now(),
                  );
                  try {
                    await ref
                        .read(hrOperationsRepositoryProvider)
                        .addShiftSwapRequest(request);
                    ref.read(mockDataRevisionProvider.notifier).state++;
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context, true);
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    AppUtils.showSnackBar(
                      context,
                      'Unable to submit swap request.',
                      isError: true,
                    );
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );

    reasonCtrl.dispose();
    if (saved == true && mounted) {
      AppUtils.showSnackBar(context, 'Swap request submitted');
    }
  }

  Future<void> _rejectSwap(ShiftSwapRequestModel request) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Swap Request'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Reason for rejection'),
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
    await _updateSwapStatus(request, 'Rejected', rejectionReason: reason);
  }

  Future<void> _updateSwapStatus(
    ShiftSwapRequestModel request,
    String status, {
    String? rejectionReason,
  }) async {
    try {
      await ref
          .read(hrOperationsRepositoryProvider)
          .updateShiftSwapRequestStatus(
            requestId: request.id,
            status: status,
            rejectionReason: rejectionReason,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(context, 'Swap request updated');
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to update swap request.',
        isError: true,
      );
    }
  }
}
