import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/audit_log_service.dart';
import '../../../data/services/export_service.dart';

class BackupExportScreen extends ConsumerStatefulWidget {
  const BackupExportScreen({super.key});

  @override
  ConsumerState<BackupExportScreen> createState() => _BackupExportScreenState();
}

class _BackupExportScreenState extends ConsumerState<BackupExportScreen> {
  String? _busyKey;

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(allStaffListAsyncProvider);
    final attendanceAsync = ref.watch(attendanceListAsyncProvider(null));
    final tasksAsync = ref.watch(allTasksAsyncProvider);
    final kpiAsync = ref.watch(allKpiAsyncProvider);
    final leavesAsync = ref.watch(leaveListAsyncProvider(null));

    final staff = ref.watch(allStaffListProvider);
    final attendance = ref.watch(attendanceListProvider(null));
    final tasks = ref.watch(allTasksProvider);
    final kpis = ref.watch(allKpiProvider);
    final leaves = ref.watch(leaveListProvider(null));
    final loading = staffAsync.isLoading ||
        attendanceAsync.isLoading ||
        tasksAsync.isLoading ||
        kpiAsync.isLoading ||
        leavesAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Backup & Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryGrid([
            _SummaryItem('Staff', staff.length, Icons.people_outline),
            _SummaryItem('Attendance', attendance.length, Icons.event_note),
            _SummaryItem('Tasks', tasks.length, Icons.assignment_outlined),
            _SummaryItem('KPI', kpis.length, Icons.insights_outlined),
            _SummaryItem('Leaves', leaves.length, Icons.event_available),
          ]),
          const SizedBox(height: 16),
          if (loading)
            const LinearProgressIndicator(minHeight: 3)
          else
            const SizedBox(height: 3),
          const SizedBox(height: 16),
          _exportTile(
            keyName: 'backup',
            icon: Icons.backup_outlined,
            title: 'Full Database Backup',
            subtitle: 'JSON export for staff, attendance, tasks, KPI, leaves',
            onTap: () => _runExport(
              keyName: 'backup',
              successMessage: 'Database backup exported',
              action: () => ExportService.exportDatabaseBackupToJson(
                staff: staff,
                attendance: attendance,
                tasks: tasks,
                kpis: kpis,
                leaves: leaves,
              ),
            ),
          ),
          _exportTile(
            keyName: 'staff',
            icon: Icons.people_outline,
            title: 'Export Staff',
            subtitle: 'Excel staff master report',
            onTap: () => _runExport(
              keyName: 'staff',
              successMessage: 'Staff report exported',
              action: () => ExportService.exportStaffToExcel(staff),
            ),
          ),
          _exportTile(
            keyName: 'attendance',
            icon: Icons.event_note_outlined,
            title: 'Export Attendance',
            subtitle: 'Excel attendance report',
            onTap: () => _runExport(
              keyName: 'attendance',
              successMessage: 'Attendance report exported',
              action: () => ExportService.exportAttendanceToExcel(attendance),
            ),
          ),
          _exportTile(
            keyName: 'tasks',
            icon: Icons.assignment_outlined,
            title: 'Export Tasks',
            subtitle: 'Excel task cards and daily termination status',
            onTap: () => _runExport(
              keyName: 'tasks',
              successMessage: 'Task report exported',
              action: () => ExportService.exportTasksToExcel(tasks),
            ),
          ),
          _exportTile(
            keyName: 'kpi',
            icon: Icons.insights_outlined,
            title: 'Export KPI',
            subtitle: 'Excel KPI scores with task weight',
            onTap: () => _runExport(
              keyName: 'kpi',
              successMessage: 'KPI report exported',
              action: () => ExportService.exportKpiToExcel(kpis),
            ),
          ),
          _exportTile(
            keyName: 'leaves',
            icon: Icons.event_available_outlined,
            title: 'Export Leaves',
            subtitle: 'Excel leave requests and approvals',
            onTap: () => _runExport(
              keyName: 'leaves',
              successMessage: 'Leave report exported',
              action: () => ExportService.exportLeavesToExcel(leaves),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid(List<_SummaryItem> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => SizedBox(
              width: (MediaQuery.of(context).size.width - 42) / 2,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.value.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _exportTile({
    required String keyName,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final busy = _busyKey == keyName;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: _busyKey == null ? onTap : null,
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }

  Future<void> _runExport({
    required String keyName,
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    setState(() => _busyKey = keyName);
    try {
      await action();
      unawaited(
        AuditLogService.record(
          action: 'export_$keyName',
          title: 'Report exported',
          description: successMessage,
          targetType: 'export',
          targetName: keyName,
          actor: ref.read(currentUserProvider),
        ),
      );
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(context, successMessage);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to export right now.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _busyKey = null);
      }
    }
  }
}

class _SummaryItem {
  final String label;
  final int value;
  final IconData icon;

  const _SummaryItem(this.label, this.value, this.icon);
}
