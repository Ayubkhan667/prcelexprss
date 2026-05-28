import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/holiday_model.dart';
import '../../../data/providers/app_providers.dart';

class OvertimeApprovalScreen extends ConsumerStatefulWidget {
  const OvertimeApprovalScreen({super.key});

  @override
  ConsumerState<OvertimeApprovalScreen> createState() =>
      _OvertimeApprovalScreenState();
}

class _OvertimeApprovalScreenState extends ConsumerState<OvertimeApprovalScreen>
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
    final allAttendance = ref.watch(attendanceListProvider(null));
    final overtimeRecords = allAttendance
        .where((attendance) => attendance.overtimeHours > 0)
        .toList();
    final pending = overtimeRecords.where(_isPendingRecord).toList();
    final approved = overtimeRecords
        .where((record) =>
            record.approvalStatus == AppConstants.overtimeStatusApproved)
        .toList();
    final rejected = overtimeRecords
        .where((record) =>
            record.approvalStatus == AppConstants.overtimeStatusRejected)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Overtime Approval'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Approved (${approved.length})'),
            Tab(text: 'Rejected (${rejected.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSummaryBar(pending, approved, rejected),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _overtimeList(pending, showActions: true),
                _overtimeList(approved),
                _overtimeList(rejected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isPendingRecord(AttendanceModel record) {
    return record.approvalStatus != AppConstants.overtimeStatusApproved &&
        record.approvalStatus != AppConstants.overtimeStatusRejected;
  }

  Widget _buildSummaryBar(
    List<AttendanceModel> pending,
    List<AttendanceModel> approved,
    List<AttendanceModel> rejected,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _summaryTile(
            'Pending',
            pending.length,
            pending.fold<double>(
                0, (sum, record) => sum + record.overtimeHours),
            AppColors.warning,
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          _summaryTile(
            'Approved',
            approved.length,
            approved.fold<double>(
                0, (sum, record) => sum + record.overtimeHours),
            AppColors.success,
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          _summaryTile(
            'Rejected',
            rejected.length,
            rejected.fold<double>(
                0, (sum, record) => sum + record.overtimeHours),
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, int count, double hours, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count records',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
            Text(
              '${hours.toStringAsFixed(1)}h',
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overtimeList(
    List<AttendanceModel> records, {
    bool showActions = false,
  }) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'No overtime records',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (_, index) =>
          _overtimeCard(records[index], showActions: showActions),
    );
  }

  Widget _overtimeCard(AttendanceModel record, {bool showActions = false}) {
    final staff = ref.watch(staffByIdProvider(record.staffId));
    final holidays = ref.watch(holidayListProvider);
    final isHoliday = _isHolidayDate(record.date, holidays);
    final otMultiplier = _getOtMultiplierForDate(record.date, holidays);
    final otLabel = _getOtLabelForDate(record.date, holidays);
    final overtimeAmount =
        record.overtimeHours * (staff?.overtimeRate ?? 0) * otMultiplier;
    final statusColor = _statusColor(record.approvalStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
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
                  radius: 20,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                  child: Text(
                    record.staffName.isNotEmpty
                        ? record.staffName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.staffName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${record.staffCode} • ${DateFormat('dd MMM yyyy').format(record.date)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${record.overtimeHours.toStringAsFixed(1)}h OT',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isHoliday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$otLabel • ${otMultiplier}x',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _statusLabel(record.approvalStatus),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _detailItem(
                    Icons.login,
                    'Check In',
                    record.checkInTime != null
                        ? _fmt(record.checkInTime!)
                        : '--',
                  ),
                  _detailItem(
                    Icons.logout,
                    'Check Out',
                    record.checkOutTime != null
                        ? _fmt(record.checkOutTime!)
                        : '--',
                  ),
                  _detailItem(
                    Icons.schedule,
                    'Total Hours',
                    '${record.workingHours.toStringAsFixed(1)}h',
                  ),
                  _detailItem(
                    Icons.payments,
                    'OT Amount',
                    'OMR ${overtimeAmount.toStringAsFixed(0)}',
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateOvertime(
                          record, AppConstants.overtimeStatusRejected),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateOvertime(
                          record, AppConstants.overtimeStatusApproved),
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(
                          'Approve (OMR ${overtimeAmount.toStringAsFixed(0)})'),
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

  Widget _detailItem(
    IconData icon,
    String label,
    String value, {
    Color color = AppColors.textPrimary,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOvertime(AttendanceModel record, String status) async {
    final approve = status == AppConstants.overtimeStatusApproved;
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: approve ? 'Approve Overtime' : 'Reject Overtime',
      message:
          '${approve ? 'Approve' : 'Reject'} ${record.overtimeHours.toStringAsFixed(1)}h overtime for ${record.staffName}?',
      confirmText: approve ? 'Approve' : 'Reject',
      isDangerous: !approve,
    );
    if (confirm != true) {
      return;
    }

    try {
      await ref.read(attendanceRepositoryProvider).updateOvertimeApprovalStatus(
            attendanceId: record.id,
            status: status,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to update overtime right now.',
        isError: true,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    AppUtils.showSnackBar(
      context,
      approve ? 'Overtime approved' : 'Overtime rejected',
      isError: !approve,
    );
  }

  Color _statusColor(String status) {
    if (status == AppConstants.overtimeStatusApproved) {
      return AppColors.success;
    }
    if (status == AppConstants.overtimeStatusRejected) {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  String _statusLabel(String status) {
    if (_isPendingLabel(status)) {
      return 'Pending';
    }
    return status;
  }

  bool _isPendingLabel(String status) {
    return status != AppConstants.overtimeStatusApproved &&
        status != AppConstants.overtimeStatusRejected;
  }

  String _fmt(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  HolidayModel? _holidayForDate(DateTime date, List<HolidayModel> holidays) {
    for (final holiday in holidays) {
      if (holiday.date.year == date.year &&
          holiday.date.month == date.month &&
          holiday.date.day == date.day) {
        return holiday;
      }
    }
    return null;
  }

  bool _isHolidayDate(DateTime date, List<HolidayModel> holidays) {
    return date.weekday == DateTime.friday ||
        _holidayForDate(date, holidays) != null;
  }

  double _getOtMultiplierForDate(DateTime date, List<HolidayModel> holidays) {
    final holiday = _holidayForDate(date, holidays);
    if (holiday != null) {
      return holiday.otMultiplier;
    }
    if (date.weekday == DateTime.friday) {
      return 1.5;
    }
    return 1.5;
  }

  String _getOtLabelForDate(DateTime date, List<HolidayModel> holidays) {
    final holiday = _holidayForDate(date, holidays);
    if (holiday != null) {
      return '${holiday.name} OT';
    }
    if (date.weekday == DateTime.friday) {
      return 'Friday OT';
    }
    return 'OT';
  }
}
