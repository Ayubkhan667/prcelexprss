import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class SupervisorAttendanceScreen extends ConsumerStatefulWidget {
  const SupervisorAttendanceScreen({super.key});

  @override
  ConsumerState<SupervisorAttendanceScreen> createState() =>
      _SupervisorAttendanceScreenState();
}

class _SupervisorAttendanceScreenState
    extends ConsumerState<SupervisorAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String _statusFilter = '';

  @override
  Widget build(BuildContext context) {
    var records =
        ref.watch(attendanceByDateAsyncProvider(_selectedDate)).valueOrNull ??
            const <AttendanceModel>[];
    if (_statusFilter.isNotEmpty) {
      records = records.where((r) => r.status == _statusFilter).toList();
    }

    final stats = _computeStats(records);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Team Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(records.length),
          _buildStatsSummary(stats),
          _buildStatusFilters(),
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Text(context.tr('no_records_for_date'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: records.length,
                    itemBuilder: (_, i) => _attendanceCard(records[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(int count) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.event, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '$count records',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(Map<String, int> stats) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _statPill('Present', stats['Present'] ?? 0, AppColors.success),
          const SizedBox(width: 8),
          _statPill('Late', stats['Late'] ?? 0, AppColors.warning),
          const SizedBox(width: 8),
          _statPill('Absent', stats['Absent'] ?? 0, AppColors.error),
          const SizedBox(width: 8),
          _statPill('Leave', stats['On Leave'] ?? 0, AppColors.onLeave),
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

  Widget _buildStatusFilters() {
    const statuses = ['', 'Present', 'Late', 'Absent', 'On Leave', 'Overtime'];
    return Container(
      height: 44,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: statuses.map((s) {
          final selected = _statusFilter == s;
          final label = s.isEmpty ? 'All' : s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _statusFilter = s),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
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

  Widget _attendanceCard(AttendanceModel r) {
    Color statusColor;
    switch (r.status) {
      case 'Present':
        statusColor = AppColors.success;
        break;
      case 'Late':
        statusColor = AppColors.warning;
        break;
      case 'Absent':
        statusColor = AppColors.error;
        break;
      case 'On Leave':
        statusColor = AppColors.onLeave;
        break;
      case 'Overtime':
        statusColor = AppColors.overtime;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  r.staffName.isNotEmpty ? r.staffName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.staffName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(r.staffCode,
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
                  r.status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _timeChip(Icons.login, 'In',
                  r.checkInTime != null ? _fmt(r.checkInTime!) : '--'),
              const SizedBox(width: 8),
              _timeChip(Icons.logout, 'Out',
                  r.checkOutTime != null ? _fmt(r.checkOutTime!) : '--'),
              const SizedBox(width: 8),
              _timeChip(Icons.schedule, 'Hours',
                  '${r.workingHours.toStringAsFixed(1)}h'),
              if (r.overtimeHours > 0) ...[
                const SizedBox(width: 8),
                _timeChip(Icons.more_time, 'OT',
                    '${r.overtimeHours.toStringAsFixed(1)}h',
                    color: AppColors.accent),
              ],
            ],
          ),
          if (r.lateMinutes > 0 || r.isMockGps)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                children: [
                  if (r.lateMinutes > 0)
                    _alertChip('Late ${r.lateMinutes}m', AppColors.warning),
                  if (r.isMockGps) _alertChip('Fake GPS', AppColors.error),
                  if (!r.isLocationValid)
                    _alertChip('Invalid Location', AppColors.error),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _timeChip(IconData icon, String label, String value,
      {Color color = AppColors.primary}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textSecondary)),
                Text(value,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  Map<String, int> _computeStats(List<AttendanceModel> records) {
    final m = <String, int>{};
    for (final r in records) {
      m[r.status] = (m[r.status] ?? 0) + 1;
    }
    return m;
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
