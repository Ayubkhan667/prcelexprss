import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class ManualAttendanceScreen extends ConsumerStatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  ConsumerState<ManualAttendanceScreen> createState() =>
      _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState
    extends ConsumerState<ManualAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();

  StaffModel? _selectedStaff;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  String _attendanceStatus = 'Present';
  bool _isSubmitting = false;

  final List<String> _statusOptions = [
    'Present',
    'Absent',
    'Late',
    'On Leave',
    'Half Day',
    'Holiday'
  ];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffList = ref.watch(allStaffListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('manual_attendance_entry')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoAlert(),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Staff & Date',
                children: [
                  _label('Select Staff *'),
                  DropdownButtonFormField<StaffModel>(
                    value: _selectedStaff,
                    decoration: _inputDecoration('Choose staff member'),
                    items: staffList.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text('${s.name} (${s.staffCode})'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedStaff = v),
                    validator: (v) =>
                        v == null ? 'Please select a staff member' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Attendance Date *'),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy')
                                .format(_selectedDate),
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down,
                              color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Attendance Status',
                children: [
                  _label('Status *'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statusOptions.map((s) {
                      final selected = _attendanceStatus == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _attendanceStatus = s),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Times (optional)',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Check-In Time'),
                            GestureDetector(
                              onTap: () => _pickTime(context, isCheckIn: true),
                              child: _timePicker(
                                  _checkInTime, 'Select time', Icons.login),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Check-Out Time'),
                            GestureDetector(
                              onTap: () => _pickTime(context, isCheckIn: false),
                              child: _timePicker(
                                  _checkOutTime, 'Select time', Icons.logout),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Reason for Manual Entry *',
                children: [
                  TextFormField(
                    controller: _reasonCtrl,
                    maxLines: 3,
                    decoration: _inputDecoration(
                        'Explain why manual attendance is being entered (required for audit trail)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Reason is required for audit trail';
                      }
                      if (v.trim().length < 10) {
                        return 'Please provide a detailed reason (min 10 chars)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitManualAttendance,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit for Approval'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Manual attendance entries require admin approval and are logged in the audit trail for compliance.',
              style: TextStyle(color: AppColors.info, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _timePicker(TimeOfDay? time, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            time != null ? time.format(context) : hint,
            style: TextStyle(
              color: time != null ? AppColors.textPrimary : AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context,
      {required bool isCheckIn}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn
          ? (_checkInTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_checkOutTime ?? const TimeOfDay(hour: 17, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }

  Future<void> _submitManualAttendance() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStaff == null) return;

    setState(() => _isSubmitting = true);

    final checkInTime = _checkInTime == null
        ? null
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _checkInTime!.hour,
            _checkInTime!.minute,
          );
    final checkOutTime = _checkOutTime == null
        ? null
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _checkOutTime!.hour,
            _checkOutTime!.minute,
          );

    if (checkInTime != null &&
        checkOutTime != null &&
        checkOutTime.isBefore(checkInTime)) {
      setState(() => _isSubmitting = false);
      AppUtils.showSnackBar(
        context,
        'Check-out time cannot be earlier than check-in time.',
        isError: true,
      );
      return;
    }

    final workingHours = checkInTime != null && checkOutTime != null
        ? checkOutTime.difference(checkInTime).inMinutes / 60
        : 0.0;
    final attendance = AttendanceModel(
      id: 'manual_${_selectedStaff!.id}_${_selectedDate.millisecondsSinceEpoch}',
      staffId: _selectedStaff!.id,
      staffName: _selectedStaff!.name,
      staffCode: _selectedStaff!.staffCode,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      workingHours: workingHours,
      overtimeHours: 0,
      lateMinutes: _attendanceStatus == AppConstants.attendanceLate ? 15 : 0,
      earlyCheckoutMinutes: 0,
      status: _attendanceStatus,
      isLocationValid: true,
      isMockGps: false,
      approvalStatus: AppConstants.leaveStatusPending,
      notes: 'Manual entry: ${_reasonCtrl.text.trim()}',
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(attendanceRepositoryProvider).saveAttendance(
            attendance: attendance,
            isEdit: false,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
      setState(() => _isSubmitting = false);
    } catch (_) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Unable to submit manual attendance right now.',
          isError: true,
        );
      }
      return;
    }

    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Submitted'),
          ],
        ),
        content: Text(
          'Manual attendance for ${_selectedStaff?.name ?? ''} on '
          '${DateFormat('dd MMM yyyy').format(_selectedDate)} '
          'has been submitted for approval.\n\n'
          'The entry will be logged in the audit trail.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
