import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_edit_log_model.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';

class AttendanceCorrectionRequestScreen extends ConsumerStatefulWidget {
  final AttendanceModel attendance;
  const AttendanceCorrectionRequestScreen({
    super.key,
    required this.attendance,
  });

  @override
  ConsumerState<AttendanceCorrectionRequestScreen> createState() =>
      _AttendanceCorrectionRequestScreenState();
}

class _AttendanceCorrectionRequestScreenState
    extends ConsumerState<AttendanceCorrectionRequestScreen> {
  final _reasonCtrl = TextEditingController();
  String _field = 'Check In Time';
  String _newValue = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _newValue = _oldValueForField(_field);
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Attendance Correction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppUtils.formatDate(widget.attendance.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Current check-in: ${_oldValueForField('Check In Time')}'),
                Text(
                    'Current check-out: ${_oldValueForField('Check Out Time')}'),
                Text(
                    'Current status: ${_oldValueForField('Attendance Status')}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _field,
            decoration: const InputDecoration(
              labelText: 'Field to correct',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Check In Time',
                child: Text('Check In Time'),
              ),
              DropdownMenuItem(
                value: 'Check Out Time',
                child: Text('Check Out Time'),
              ),
              DropdownMenuItem(
                value: 'Attendance Status',
                child: Text('Attendance Status'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _field = value ?? _field;
                _newValue = _oldValueForField(_field);
              });
            },
          ),
          const SizedBox(height: 12),
          if (_field == 'Attendance Status')
            DropdownButtonFormField<String>(
              value: _newValue,
              decoration: const InputDecoration(
                labelText: 'Requested value',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: AppConstants.attendancePresent,
                  child: Text('Present'),
                ),
                DropdownMenuItem(
                  value: AppConstants.attendanceLate,
                  child: Text('Late'),
                ),
                DropdownMenuItem(
                  value: AppConstants.attendanceAbsent,
                  child: Text('Absent'),
                ),
                DropdownMenuItem(
                  value: AppConstants.attendanceOnLeave,
                  child: Text('On Leave'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _newValue = value ?? _newValue),
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Requested time'),
              subtitle: Text(_newValue),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Reason',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_isSubmitting ? 'Submitting...' : 'Submit Request'),
          ),
        ],
      ),
    );
  }

  String _oldValueForField(String field) {
    switch (field) {
      case 'Check In Time':
        return widget.attendance.checkInTime != null
            ? AppUtils.formatTime(widget.attendance.checkInTime!)
            : '--:--';
      case 'Check Out Time':
        return widget.attendance.checkOutTime != null
            ? AppUtils.formatTime(widget.attendance.checkOutTime!)
            : '--:--';
      case 'Attendance Status':
      default:
        return widget.attendance.status;
    }
  }

  Future<void> _pickTime() async {
    final parts = _newValue.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _newValue =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _submit() async {
    final currentUser = ref.read(currentUserProvider);
    final currentStaff = ref.read(currentStaffProvider);
    final reason = _reasonCtrl.text.trim();
    if (currentStaff == null || currentUser == null) {
      return;
    }
    if (reason.isEmpty) {
      AppUtils.showSnackBar(
        context,
        'Reason is required.',
        isError: true,
      );
      return;
    }
    if (_newValue == _oldValueForField(_field)) {
      AppUtils.showSnackBar(
        context,
        'Choose a different value before submitting.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final log = AttendanceEditLogModel(
      id: 'edit_${DateTime.now().millisecondsSinceEpoch}',
      attendanceId: widget.attendance.id,
      staffId: currentStaff.id,
      staffName: currentStaff.name,
      staffCode: currentStaff.staffCode,
      editedBy: currentUser.name,
      editedByRole: currentUser.role,
      fieldChanged: _field,
      oldValue: _oldValueForField(_field),
      newValue: _newValue,
      reason: reason,
      approvalStatus: 'Pending',
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(hrOperationsRepositoryProvider).addEditLog(log);
      ref.read(mockDataRevisionProvider.notifier).state++;
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      AppUtils.showSnackBar(context, 'Correction request submitted');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      AppUtils.showSnackBar(
        context,
        'Unable to submit correction request.',
        isError: true,
      );
    }
  }
}
