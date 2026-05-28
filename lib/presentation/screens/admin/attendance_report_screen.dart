import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/attendance_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../../core/l10n/app_localizations.dart';

class AttendanceReportScreen extends ConsumerStatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  ConsumerState<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends ConsumerState<AttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

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
    final allAttendance = ref.watch(attendanceListProvider(null));
    final todayAtt = allAttendance.where((a) {
      final d = _selectedDate;
      return a.date.year == d.year &&
          a.date.month == d.month &&
          a.date.day == d.day;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('attendance_reports')),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportReport,
            tooltip: 'Export',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: context.tr('daily_tab')),
            Tab(text: context.tr('all_staff_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _dailyTab(todayAtt),
          _allStaffTab(allAttendance),
        ],
      ),
    );
  }

  Widget _dailyTab(List<AttendanceModel> records) {
    return Column(
      children: [
        // Date picker
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(AppUtils.formatDate(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range, size: 16),
                label: Text(context.tr('pick_date')),
                onPressed: _pickDate,
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6)),
              ),
            ],
          ),
        ),
        // Summary
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem(context.tr('total_label'), records.length, AppColors.primary),
              _summaryItem(
                  context.tr('present'),
                  records
                      .where((a) =>
                          a.status == 'Present' ||
                          a.status == 'Late' ||
                          a.status == 'Overtime')
                      .length,
                  AppColors.present),
              _summaryItem(
                  context.tr('absent'),
                  records.where((a) => a.status == 'Absent').length,
                  AppColors.absent),
              _summaryItem(
                  context.tr('late'),
                  records.where((a) => a.status == 'Late').length,
                  AppColors.late),
              _summaryItem(
                  context.tr('leave'),
                  records.where((a) => a.status == 'On Leave').length,
                  AppColors.onLeave),
            ],
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? Center(child: Text(context.tr('no_attendance_for_date')))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: records.length,
                  itemBuilder: (ctx, i) => _attendanceCard(records[i]),
                ),
        ),
      ],
    );
  }

  Widget _allStaffTab(List<AttendanceModel> allRecords) {
    final staffMap = <String, List<AttendanceModel>>{};
    for (final att in allRecords) {
      staffMap.putIfAbsent(att.staffId, () => []).add(att);
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: staffMap.entries.map((entry) {
        final records = entry.value;
        final staff = records.first;
        final totalDays = records.length;
        final presentDays = records
            .where((a) => a.status != 'Absent' && a.status != 'On Leave')
            .length;
        final lateDays = records.where((a) => a.status == 'Late').length;
        final totalOt = records.fold<double>(0, (s, a) => s + a.overtimeHours);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(AppUtils.getInitials(staff.staffName),
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
                        Text(staff.staffName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(staff.staffCode,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat(context.tr('total_label'), totalDays, AppColors.primary),
                  _miniStat(context.tr('present'), presentDays, AppColors.present),
                  _miniStat(context.tr('late'), lateDays, AppColors.late),
                  _miniStat(
                      context.tr('ot_hrs'), totalOt.toStringAsFixed(1), AppColors.accent),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _attendanceCard(AttendanceModel att) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primarySurface,
          child: Text(AppUtils.getInitials(att.staffName),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(att.staffName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700))),
            StatusBadge(status: att.status, fontSize: 10),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(att.staffCode,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.login, size: 12, color: AppColors.success),
                const SizedBox(width: 3),
                Text(
                    att.checkInTime != null
                        ? AppUtils.formatTime(att.checkInTime!)
                        : '--:--',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                const Icon(Icons.logout, size: 12, color: AppColors.error),
                const SizedBox(width: 3),
                Text(
                    att.checkOutTime != null
                        ? AppUtils.formatTime(att.checkOutTime!)
                        : '--:--',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                if (att.workingHours > 0)
                  Text('${att.workingHours.toStringAsFixed(1)}h',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
              ],
            ),
            if (att.lateMinutes > 0)
              Text('${context.tr('late_by_label')} ${att.lateMinutes} ${context.tr('minutes_short')}',
                  style: const TextStyle(fontSize: 10, color: AppColors.late)),
            if (att.overtimeHours > 0)
              Text('OT: ${att.overtimeHours.toStringAsFixed(1)}h',
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.overtime)),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(count.toString(),
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _miniStat(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(value.toString(),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _exportReport() {
    AppUtils.showSnackBar(
      context,
      'Exporting report... (Feature available in full version)',
    );
  }
}
