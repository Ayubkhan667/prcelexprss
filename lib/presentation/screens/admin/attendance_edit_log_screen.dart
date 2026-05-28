import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/attendance_edit_log_model.dart';
import '../../../core/l10n/app_localizations.dart';

class AttendanceEditLogScreen extends ConsumerStatefulWidget {
  const AttendanceEditLogScreen({super.key});

  @override
  ConsumerState<AttendanceEditLogScreen> createState() =>
      _AttendanceEditLogScreenState();
}

class _AttendanceEditLogScreenState
    extends ConsumerState<AttendanceEditLogScreen> {
  String _approvalFilter = '';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(attendanceEditLogListProvider);
    var logs = allLogs;
    if (_approvalFilter.isNotEmpty) {
      logs = logs.where((l) => l.approvalStatus == _approvalFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      logs = logs
          .where((l) =>
              l.staffName.toLowerCase().contains(q) ||
              l.staffCode.toLowerCase().contains(q) ||
              l.editedBy.toLowerCase().contains(q))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('attendance_edit_logs')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearch(),
          _buildFilterChips(),
          _buildStats(allLogs),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(context.tr('no_edit_logs_found'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (_, i) => _logCard(logs[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search staff or editor...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  })
              : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildFilterChips() {
    const options = ['', 'Pending', 'Approved', 'Rejected'];
    return Container(
      color: Colors.white,
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: options.map((s) {
          final selected = _approvalFilter == s;
          final label = s.isEmpty ? 'All' : s;
          Color chipColor;
          switch (s) {
            case 'Approved':
              chipColor = AppColors.success;
              break;
            case 'Rejected':
              chipColor = AppColors.error;
              break;
            case 'Pending':
              chipColor = AppColors.warning;
              break;
            default:
              chipColor = AppColors.primary;
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _approvalFilter = s),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? chipColor.withValues(alpha: 0.15)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? chipColor : AppColors.divider,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? chipColor : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStats(List<AttendanceEditLogModel> allLogs) {
    final pending = allLogs.where((l) => l.approvalStatus == 'Pending').length;
    final approved =
        allLogs.where((l) => l.approvalStatus == 'Approved').length;
    final rejected =
        allLogs.where((l) => l.approvalStatus == 'Rejected').length;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _statPill('Total', allLogs.length, AppColors.primary),
          const SizedBox(width: 8),
          _statPill('Pending', pending, AppColors.warning),
          const SizedBox(width: 8),
          _statPill('Approved', approved, AppColors.success),
          const SizedBox(width: 8),
          _statPill('Rejected', rejected, AppColors.error),
        ],
      ),
    );
  }

  Widget _statPill(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(count.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            Text(label,
                style: TextStyle(color: color, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _logCard(AttendanceEditLogModel log) {
    Color statusColor;
    IconData statusIcon;
    switch (log.approvalStatus) {
      case 'Approved':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
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
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    log.staffName.isNotEmpty
                        ? log.staffName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.staffName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(log.staffCode,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(log.approvalStatus,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _infoRow(Icons.edit_calendar, 'Field Changed', log.fieldChanged),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                    child: _infoRow(Icons.undo, 'Old Value', log.oldValue,
                        valueColor: AppColors.error)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                    child: _infoRow(Icons.redo, 'New Value', log.newValue,
                        valueColor: AppColors.success)),
              ],
            ),
            const SizedBox(height: 4),
            _infoRow(Icons.person_outline, 'Edited By',
                '${log.editedBy} (${log.editedByRole})'),
            const SizedBox(height: 4),
            _infoRow(Icons.notes, 'Reason', log.reason),
            const SizedBox(height: 4),
            _infoRow(Icons.schedule, 'Date',
                DateFormat('dd MMM yyyy HH:mm').format(log.createdAt)),
            if (log.approvedBy != null) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.verified_user, 'Approved By', log.approvedBy!),
            ],
            if (log.approvalStatus == 'Pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectLog(log),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(context.tr('reject')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveLog(log),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(context.tr('approve')),
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

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _approveLog(AttendanceEditLogModel log) async {
    final approver = ref.read(currentUserProvider)?.name ?? 'Admin';
    try {
      await ref
          .read(hrOperationsRepositoryProvider)
          .updateEditLogApprovalStatus(
            logId: log.id,
            status: 'Approved',
            approvedBy: approver,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to approve edit right now.',
        isError: true,
      );
      return;
    }
    if (!mounted) {
      return;
    }
    AppUtils.showSnackBar(context, 'Edit approved for ${log.staffName}');
  }

  Future<void> _rejectLog(AttendanceEditLogModel log) async {
    final approver = ref.read(currentUserProvider)?.name ?? 'Admin';
    try {
      await ref
          .read(hrOperationsRepositoryProvider)
          .updateEditLogApprovalStatus(
            logId: log.id,
            status: 'Rejected',
            approvedBy: approver,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to reject edit right now.',
        isError: true,
      );
      return;
    }
    if (!mounted) {
      return;
    }
    AppUtils.showSnackBar(context, 'Edit rejected for ${log.staffName}');
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('filter_by_approval_status'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...['All', 'Pending', 'Approved', 'Rejected'].map((s) {
              final value = s == 'All' ? '' : s;
              return ListTile(
                leading: Radio<String>(
                  value: value,
                  groupValue: _approvalFilter,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _approvalFilter = v ?? '');
                    Navigator.pop(context);
                  },
                ),
                title: Text(s),
              );
            }),
          ],
        ),
      ),
    );
  }
}
