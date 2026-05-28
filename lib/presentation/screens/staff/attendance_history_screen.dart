import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/attendance_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../../core/l10n/app_localizations.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

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
    final allRecords = staff != null
        ? ref.watch(attendanceListProvider(staff.id))
        : <AttendanceModel>[];
    final sortedRecords = [...allRecords]..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) {
          return byDate;
        }

        final checkInA = a.checkInTime ?? a.date;
        final checkInB = b.checkInTime ?? b.date;
        return checkInB.compareTo(checkInA);
      });

    final monthRecords = sortedRecords
        .where((a) =>
            a.date.month == _selectedMonth.month &&
            a.date.year == _selectedMonth.year)
        .toList();

    final presentDays = monthRecords
        .where((a) => a.status != 'Absent' && a.status != 'On Leave')
        .length;
    final absentDays = monthRecords.where((a) => a.status == 'Absent').length;
    final lateDays = monthRecords.where((a) => a.status == 'Late').length;
    final totalOt = monthRecords.fold<double>(0, (s, a) => s + a.overtimeHours);
    final totalHours =
        monthRecords.fold<double>(0, (s, a) => s + a.workingHours);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('attendance_history')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Monthly'), Tab(text: 'Daily')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _monthlyTab(monthRecords, presentDays, absentDays, lateDays, totalOt,
              totalHours),
          _dailyTab(sortedRecords),
        ],
      ),
    );
  }

  Widget _monthlyTab(List<AttendanceModel> records, int present, int absent,
      int late, double totalOt, double totalHours) {
    return Column(
      children: [
        // Month selector
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _selectedMonth =
                    DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
              ),
              Text(AppUtils.formatMonth(_selectedMonth),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final next =
                      DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                  if (next
                      .isBefore(DateTime.now().add(const Duration(days: 1)))) {
                    setState(() => _selectedMonth = next);
                  }
                },
              ),
            ],
          ),
        ),
        // Summary
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryChip('Present', present.toString(), AppColors.present),
              _summaryChip('Absent', absent.toString(), AppColors.absent),
              _summaryChip('Late', late.toString(), AppColors.late),
              _summaryChip(
                  'OT hrs', totalOt.toStringAsFixed(1), AppColors.overtime),
              _summaryChip('Total hrs', totalHours.toStringAsFixed(0),
                  AppColors.primary),
            ],
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? Center(child: Text(context.tr('no_records_for_month')))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: records.length,
                  itemBuilder: (ctx, i) => _attendanceRow(records[i]),
                ),
        ),
      ],
    );
  }

  Widget _dailyTab(List<AttendanceModel> records) {
    if (records.isEmpty) {
      return Center(
        child: Text(context.tr('no_attendance_records_found')),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) => _attendanceDetailCard(records[i]),
    );
  }

  Widget _attendanceRow(AttendanceModel att) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border(
            left: BorderSide(
                color: AppUtils.getStatusColor(att.status), width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('${att.date.day}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppUtils.getStatusColor(att.status))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppUtils.formatDate(att.date, format: 'EEE'),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, size: 12, color: AppColors.success),
                    const SizedBox(width: 3),
                    Text(
                        att.checkInTime != null
                            ? AppUtils.formatTime(att.checkInTime!)
                            : '--:--',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    const Icon(Icons.logout, size: 12, color: AppColors.error),
                    const SizedBox(width: 3),
                    Text(
                        att.checkOutTime != null
                            ? AppUtils.formatTime(att.checkOutTime!)
                            : '--:--',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                if (att.lateMinutes > 0)
                  Text('Late: ${att.lateMinutes}m',
                      style:
                          const TextStyle(fontSize: 10, color: AppColors.late)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: att.status, fontSize: 10),
              if (att.workingHours > 0)
                Text('${att.workingHours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceDetailCard(AttendanceModel att) {
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppUtils.getStatusColor(att.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('${att.date.day}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppUtils.getStatusColor(att.status))),
          ),
        ),
        title: Text(AppUtils.formatDate(att.date),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        subtitle: Text(att.status,
            style: TextStyle(
                fontSize: 11, color: AppUtils.getStatusColor(att.status))),
        trailing: att.workingHours > 0
            ? Text('${att.workingHours.toStringAsFixed(1)}h',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary))
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                const Divider(),
                _detailRow(
                    'Check In',
                    att.checkInTime != null
                        ? AppUtils.formatTime(att.checkInTime!)
                        : 'N/A',
                    AppColors.success),
                _detailRow(
                    'Check Out',
                    att.checkOutTime != null
                        ? AppUtils.formatTime(att.checkOutTime!)
                        : 'N/A',
                    AppColors.error),
                _detailRow(
                    'Working Hours',
                    '${att.workingHours.toStringAsFixed(2)}h',
                    AppColors.primary),
                if (att.overtimeHours > 0)
                  _detailRow(
                      'Overtime',
                      '${att.overtimeHours.toStringAsFixed(2)}h',
                      AppColors.accent),
                if (att.lateMinutes > 0)
                  _detailRow(
                      'Late By', '${att.lateMinutes} minutes', AppColors.late),
                _detailRow(
                    'Location',
                    att.isLocationValid ? 'Valid' : 'Invalid',
                    att.isLocationValid ? AppColors.success : AppColors.error),
                if (att.isMockGps)
                  _detailRow(
                      'GPS Warning', 'Mock GPS Detected!', AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color color) {
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

  Widget _summaryChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
