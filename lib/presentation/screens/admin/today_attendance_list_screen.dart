import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/app_providers.dart';
import 'staff_detail_screen.dart';

class TodayAttendanceListScreen extends ConsumerWidget {
  final String title;
  // null = all staff, otherwise filter attendance by these statuses
  final List<String>? statuses;

  const TodayAttendanceListScreen({
    super.key,
    required this.title,
    this.statuses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final attendanceAsync = ref.watch(attendanceByDateAsyncProvider(date));
    final allStaff = ref.watch(allStaffListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (attendance) {
          if (statuses == null) {
            // Total Staff — show all staff
            return _buildStaffList(context, allStaff, attendance);
          }
          final filtered =
              attendance.where((a) => statuses!.contains(a.status)).toList();
          if (filtered.isEmpty) {
            return const Center(
              child: Text('No records found',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return _buildAttendanceList(context, filtered, allStaff);
        },
      ),
    );
  }

  Widget _buildAttendanceList(BuildContext context,
      List<AttendanceModel> records, List<StaffModel> allStaff) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final att = records[i];
        final staff = allStaff.where((s) => s.id == att.staffId).firstOrNull;
        return _AttendanceTile(attendance: att, staff: staff);
      },
    );
  }

  Widget _buildStaffList(BuildContext context, List<StaffModel> allStaff,
      List<AttendanceModel> attendance) {
    if (allStaff.isEmpty) {
      return const Center(
        child: Text('No staff found',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: allStaff.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final staff = allStaff[i];
        final att = attendance.where((a) => a.staffId == staff.id).firstOrNull;
        return _StaffTile(staff: staff, attendance: att);
      },
    );
  }
}

class _AttendanceTile extends ConsumerWidget {
  final AttendanceModel attendance;
  final StaffModel? staff;

  const _AttendanceTile({required this.attendance, this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(attendance.status);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: staff == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StaffDetailScreen(staffId: staff!.id)),
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                _initials(attendance.staffName),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attendance.staffName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  if (staff != null)
                    Text(staff!.jobTitle,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusChip(status: attendance.status, color: color),
                if (attendance.checkInTime != null)
                  Text(
                    _fmt(attendance.checkInTime!),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return AppColors.present;
      case 'Absent':
        return AppColors.absent;
      case 'Late':
        return AppColors.late;
      case 'On Leave':
        return AppColors.onLeave;
      case 'Overtime':
        return AppColors.overtime;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StaffTile extends ConsumerWidget {
  final StaffModel staff;
  final AttendanceModel? attendance;

  const _StaffTile({required this.staff, this.attendance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = attendance?.status ?? 'Absent';
    final color = _statusColor(status);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: staff.id)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                _initials(staff.name),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  Text(staff.department,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            _StatusChip(status: status, color: color),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return AppColors.present;
      case 'Absent':
        return AppColors.absent;
      case 'Late':
        return AppColors.late;
      case 'On Leave':
        return AppColors.onLeave;
      case 'Overtime':
        return AppColors.overtime;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
