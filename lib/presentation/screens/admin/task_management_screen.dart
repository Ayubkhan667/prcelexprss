import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  String _statusFilter = '';
  String _staffFilter = '';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(allTasksProvider);
    final staffList = ref.watch(staffListProvider);
    final filteredTasks = _filterTasks(tasks);

    final pendingCount = tasks
        .where((task) => task.status == AppConstants.taskStatusPending)
        .length;
    final completedCount = tasks
        .where((task) => task.status == AppConstants.taskStatusCompleted)
        .length;
    final terminatedCount = tasks
        .where((task) => task.status == AppConstants.taskStatusTerminated)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Task Cards'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskSheet(context, staffList),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Assign Task'),
      ),
      body: Column(
        children: [
          _filterPanel(staffList),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Pending',
                    pendingCount.toString(),
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Done',
                    completedCount.toString(),
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Closed',
                    terminatedCount.toString(),
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTasks.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (_, index) => _taskCard(filteredTasks[index]),
                  ),
          ),
        ],
      ),
    );
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      if (_statusFilter.isNotEmpty && task.status != _statusFilter) {
        return false;
      }
      if (_staffFilter.isNotEmpty && task.staffId != _staffFilter) {
        return false;
      }
      if (_searchQuery.isEmpty) {
        return true;
      }
      final query = _searchQuery.toLowerCase();
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.staffName.toLowerCase().contains(query) ||
          task.staffCode.toLowerCase().contains(query);
    }).toList();
  }

  Widget _filterPanel(List<StaffModel> staffList) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search task or employee',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _staffFilter.isEmpty ? null : _staffFilter,
            decoration: InputDecoration(
              labelText: 'Employee Filter',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('All Employees'),
              ),
              ...staffList.map(
                (staff) => DropdownMenuItem<String>(
                  value: staff.id,
                  child: Text('${staff.name} (${staff.staffCode})'),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _staffFilter = value ?? ''),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _statusChip('', 'All'),
                _statusChip(AppConstants.taskStatusPending, 'Pending'),
                _statusChip(AppConstants.taskStatusCompleted, 'Completed'),
                _statusChip(AppConstants.taskStatusTerminated, 'Closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _statusFilter = value),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(TaskModel task) {
    final statusColor = AppUtils.getStatusColor(task.status);
    final dueText = DateFormat('dd MMM, hh:mm a').format(task.dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task.staffName} • ${task.staffCode}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(Icons.schedule, 'Due $dueText', AppColors.primary),
              if (task.isDailyTask)
                _metaChip(Icons.today, 'Daily Task', AppColors.warning),
              if (task.assignedToAll)
                _metaChip(Icons.groups_2, 'All Staff Batch', AppColors.accent),
              _metaChip(
                Icons.admin_panel_settings,
                'By ${task.assignedBy}',
                AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (task.status == AppConstants.taskStatusCompleted &&
              task.completedAt != null)
            Text(
              'Completed ${DateFormat('dd MMM, hh:mm a').format(task.completedAt!)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (task.status == AppConstants.taskStatusTerminated &&
              task.terminatedAt != null)
            Text(
              'Closed ${DateFormat('dd MMM, hh:mm a').format(task.terminatedAt!)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (task.status == AppConstants.taskStatusPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _terminateTask(task),
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Terminate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 72, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'No task cards found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _terminateTask(TaskModel task) async {
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Terminate Task',
      message: 'Close "${task.title}" for ${task.staffName}?',
      confirmText: 'Terminate',
      isDangerous: true,
    );
    if (confirm != true) {
      return;
    }

    try {
      await ref.read(hrOperationsRepositoryProvider).terminateTask(task.id);
      ref.read(mockDataRevisionProvider.notifier).state++;
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to terminate task right now.',
        isError: true,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    AppUtils.showSnackBar(context, 'Task terminated');
  }

  Future<void> _showCreateTaskSheet(
    BuildContext context,
    List<StaffModel> staffList,
  ) async {
    final activeStaff = staffList
        .where((staff) => staff.status == AppConstants.statusActive)
        .toList();
    final user = ref.read(currentUserProvider);
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    var assignToAll = false;
    var isDailyTask = true;
    var selectedStaffId = activeStaff.isNotEmpty ? activeStaff.first.id : '';
    var dueDate = DateTime.now().add(const Duration(hours: 8));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetBodyContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(sheetBodyContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Assign Task Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      decoration: _fieldDecoration('Task title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: _fieldDecoration('Task description'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: assignToAll,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Assign to all active employees'),
                      subtitle:
                          const Text('Creates a task card for each employee'),
                      onChanged: (value) =>
                          setSheetState(() => assignToAll = value),
                    ),
                    if (!assignToAll)
                      DropdownButtonFormField<String>(
                        value: selectedStaffId.isEmpty ? null : selectedStaffId,
                        decoration: _fieldDecoration('Select employee'),
                        items: activeStaff
                            .map(
                              (staff) => DropdownMenuItem<String>(
                                value: staff.id,
                                child:
                                    Text('${staff.name} (${staff.staffCode})'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setSheetState(
                          () => selectedStaffId = value ?? '',
                        ),
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: isDailyTask,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Daily task'),
                      subtitle:
                          const Text('Can be closed on the same day by admin'),
                      onChanged: (value) =>
                          setSheetState(() => isDailyTask = value),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Due Date & Time',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(dueDate),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: sheetBodyContext,
                                      initialDate: dueDate,
                                      firstDate: DateTime.now()
                                          .subtract(const Duration(days: 1)),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 30)),
                                    );
                                    if (picked == null) {
                                      return;
                                    }
                                    setSheetState(() {
                                      dueDate = DateTime(
                                        picked.year,
                                        picked.month,
                                        picked.day,
                                        dueDate.hour,
                                        dueDate.minute,
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.event),
                                  label: const Text('Date'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: sheetBodyContext,
                                      initialTime: TimeOfDay.fromDateTime(
                                        dueDate,
                                      ),
                                    );
                                    if (picked == null) {
                                      return;
                                    }
                                    setSheetState(() {
                                      dueDate = DateTime(
                                        dueDate.year,
                                        dueDate.month,
                                        dueDate.day,
                                        picked.hour,
                                        picked.minute,
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.access_time),
                                  label: const Text('Time'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final title = titleCtrl.text.trim();
                          final description = descriptionCtrl.text.trim();
                          if (title.isEmpty || description.isEmpty) {
                            AppUtils.showSnackBar(
                              context,
                              'Title and description are required',
                              isError: true,
                            );
                            return;
                          }
                          if (!assignToAll && selectedStaffId.isEmpty) {
                            AppUtils.showSnackBar(
                              context,
                              'Select an employee',
                              isError: true,
                            );
                            return;
                          }

                          final assignees = assignToAll
                              ? activeStaff
                              : activeStaff
                                  .where((staff) => staff.id == selectedStaffId)
                                  .toList();
                          if (assignees.isEmpty) {
                            AppUtils.showSnackBar(
                              context,
                              'No active employees available',
                              isError: true,
                            );
                            return;
                          }

                          try {
                            await ref.read(hrOperationsRepositoryProvider).assignTask(
                                  title: title,
                                  description: description,
                                  assignedBy: user?.name ?? 'Admin',
                                  assignedByRole: 'Admin',
                                  assignees: assignees,
                                  assignToAll: assignToAll,
                                  isDailyTask: isDailyTask,
                                  dueDate: dueDate,
                                );
                            ref.read(mockDataRevisionProvider.notifier).state++;
                          } catch (_) {
                            if (!mounted || !context.mounted) {
                              return;
                            }
                            AppUtils.showSnackBar(
                              context,
                              'Unable to assign task right now.',
                              isError: true,
                            );
                            return;
                          }

                          if (!sheetContext.mounted || !context.mounted) {
                            return;
                          }
                          Navigator.pop(sheetContext);
                          AppUtils.showSnackBar(
                            context,
                            assignToAll
                                ? 'Task assigned to all active employees'
                                : 'Task assigned successfully',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.send),
                        label: const Text('Send Task Card'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
