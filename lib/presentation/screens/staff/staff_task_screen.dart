import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/task_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';

class StaffTaskScreen extends ConsumerStatefulWidget {
  const StaffTaskScreen({super.key});

  @override
  ConsumerState<StaffTaskScreen> createState() => _StaffTaskScreenState();
}

class _StaffTaskScreenState extends ConsumerState<StaffTaskScreen> {
  String _statusFilter = '';

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider);
    final tasks =
        staff != null ? ref.watch(taskListProvider(staff.id)) : <TaskModel>[];
    final filteredTasks = _statusFilter.isEmpty
        ? tasks
        : tasks.where((task) => task.status == _statusFilter).toList();

    final pendingCount = tasks
        .where((task) => task.status == AppConstants.taskStatusPending)
        .length;
    final completedCount = tasks
        .where((task) => task.status == AppConstants.taskStatusCompleted)
        .length;
    final closedCount = tasks
        .where((task) => task.status == AppConstants.taskStatusTerminated)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                Row(
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
                        closedCount.toString(),
                        AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _filterChip('', 'All'),
                      _filterChip(AppConstants.taskStatusPending, 'Pending'),
                      _filterChip(
                        AppConstants.taskStatusCompleted,
                        'Completed',
                      ),
                      _filterChip(
                        AppConstants.taskStatusTerminated,
                        'Closed',
                      ),
                    ],
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

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
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

  Widget _filterChip(String value, String label) {
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

  Widget _taskCard(TaskModel task) {
    final statusColor = AppUtils.getStatusColor(task.status);

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
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
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
              _metaChip(
                Icons.schedule,
                'Due ${DateFormat('dd MMM, hh:mm a').format(task.dueDate)}',
                AppColors.primary,
              ),
              if (task.isDailyTask)
                _metaChip(Icons.today, 'Daily', AppColors.warning),
              if (task.assignedToAll)
                _metaChip(Icons.groups_2, 'Shared Task', AppColors.accent),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _completeTask(task),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Completed'),
              ),
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
          Icon(Icons.assignment_turned_in_outlined,
              size: 72, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'No tasks found',
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

  Future<void> _completeTask(TaskModel task) async {
    try {
      await ref.read(hrOperationsRepositoryProvider).markTaskCompleted(task.id);
      ref.read(mockDataRevisionProvider.notifier).state++;
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to mark task complete right now.',
        isError: true,
      );
      return;
    }
    if (!mounted) {
      return;
    }
    AppUtils.showSnackBar(context, 'Task marked as completed');
  }
}
