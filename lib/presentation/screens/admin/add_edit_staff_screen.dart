import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/audit_log_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/l10n/app_localizations.dart';

class AddEditStaffScreen extends ConsumerStatefulWidget {
  final String? staffId;
  const AddEditStaffScreen({super.key, this.staffId});

  @override
  ConsumerState<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends ConsumerState<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _idCardCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _rangeCtrl = TextEditingController();
  final _breakMinutesCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _otRateCtrl = TextEditingController();
  String _role = AppConstants.roleStaff;
  String _category = 'Driver';
  String _department = 'Operations';
  String _status = 'Active';
  String _weeklyOff = 'Friday';
  String _branchId = 'b001';
  String _shiftId = 's001';
  bool _isLoading = false;
  bool _didPopulateForm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _idCardCtrl.dispose();
    _jobTitleCtrl.dispose();
    _rangeCtrl.dispose();
    _breakMinutesCtrl.dispose();
    _salaryCtrl.dispose();
    _otRateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final useRemote = ref.read(useRemoteDataProvider);
    final branch = ref.read(branchByIdProvider(_branchId));
    final shift = ref.read(shiftByIdProvider(_shiftId));
    final existingStaff = widget.staffId != null
        ? ref.read(staffByIdProvider(widget.staffId!))
        : null;
    final now = DateTime.now();
    final suffix = now.microsecondsSinceEpoch.toString().substring(8);
    final staffId = existingStaff?.id ?? (useRemote ? '' : 'st$suffix');
    final userId = existingStaff?.userId ?? (useRemote ? '' : 'u$suffix');
    final staffCount = ref.read(allStaffListProvider).length;
    final staffCode = existingStaff?.staffCode ??
        (useRemote ? '' : 'SHR-${(staffCount + 1).toString().padLeft(3, '0')}');
    final rangeText = _rangeCtrl.text.trim();
    final breakText = _breakMinutesCtrl.text.trim();
    final allowedRange = double.tryParse(rangeText);
    final dailyBreakMinutes = int.tryParse(breakText);

    try {
      final result = await ref.read(staffRepositoryProvider).saveStaff(
            staff: StaffModel(
              id: staffId,
              userId: userId,
              staffCode: staffCode,
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              mobile: _mobileCtrl.text.trim(),
              idCardNumber: _idCardCtrl.text.trim().isEmpty
                  ? existingStaff?.idCardNumber
                  : _idCardCtrl.text.trim(),
              jobTitle: _jobTitleCtrl.text.trim(),
              category: _category,
              department: _department,
              branchId: _branchId,
              branchName: branch?.branchName ?? existingStaff?.branchName ?? '',
              shiftId: _shiftId,
              shiftName: shift?.shiftName ?? existingStaff?.shiftName ?? '',
              allowedLocationRadiusMeters: rangeText.isEmpty
                  ? null
                  : allowedRange != null && allowedRange > 0
                      ? allowedRange
                      : existingStaff?.allowedLocationRadiusMeters,
              dailyBreakMinutes: breakText.isEmpty
                  ? AppConstants.defaultDailyBreakMinutes
                  : dailyBreakMinutes != null && dailyBreakMinutes >= 0
                      ? dailyBreakMinutes
                      : existingStaff?.dailyBreakMinutes ??
                          AppConstants.defaultDailyBreakMinutes,
              joiningDate: existingStaff?.joiningDate ?? now,
              basicSalary: double.tryParse(_salaryCtrl.text.trim()) ??
                  existingStaff?.basicSalary ??
                  0,
              overtimeRate: double.tryParse(_otRateCtrl.text.trim()) ??
                  existingStaff?.overtimeRate ??
                  0,
              weeklyOffDay: _weeklyOff,
              status: _status,
              profileImageUrl: existingStaff?.profileImageUrl,
              kpiScore: existingStaff?.kpiScore,
              kpiRating: existingStaff?.kpiRating,
              loanBalance: existingStaff?.loanBalance ?? 0,
              overtimeHours: existingStaff?.overtimeHours ?? 0,
              todayCheckIn: existingStaff?.todayCheckIn,
              todayCheckOut: existingStaff?.todayCheckOut,
              todayStatus: existingStaff?.todayStatus,
              preferredName: existingStaff?.preferredName,
              firstName: existingStaff?.firstName,
              lastName: existingStaff?.lastName,
              dateOfBirth: existingStaff?.dateOfBirth,
              nationality: existingStaff?.nationality,
              gender: existingStaff?.gender,
              maritalStatus: existingStaff?.maritalStatus,
              personalEmail: existingStaff?.personalEmail,
              workPhone: existingStaff?.workPhone,
              personalAddress: existingStaff?.personalAddress,
              aboutMe: existingStaff?.aboutMe,
              whatIDo: existingStaff?.whatIDo,
              skills: existingStaff?.skills,
              socialMedia: existingStaff?.socialMedia,
              hobbies: existingStaff?.hobbies,
              sponsorName: existingStaff?.sponsorName,
              civilId: existingStaff?.civilId,
              civilIdExpireDate: existingStaff?.civilIdExpireDate,
              passportNumber: existingStaff?.passportNumber,
              passportExpireDate: existingStaff?.passportExpireDate,
              passportStatus: existingStaff?.passportStatus,
              contractType: existingStaff?.contractType,
              contractTerms: existingStaff?.contractTerms,
              contractStartDate: existingStaff?.contractStartDate,
              contractExpireDate: existingStaff?.contractExpireDate,
              salaryType: existingStaff?.salaryType,
              nameAsPerBank: existingStaff?.nameAsPerBank,
              bankName: existingStaff?.bankName,
              swiftCode: existingStaff?.swiftCode,
              accountNumber: existingStaff?.accountNumber,
              emergencyContactName: existingStaff?.emergencyContactName,
              emergencyContactRelation: existingStaff?.emergencyContactRelation,
              emergencyContactPhone: existingStaff?.emergencyContactPhone,
              passportSubmissionStatus: existingStaff?.passportSubmissionStatus,
              passportCollectionStatus: existingStaff?.passportCollectionStatus,
            ),
            user: UserModel(
              id: userId,
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              mobile: _mobileCtrl.text.trim(),
              role: _role,
              status: _status,
              createdAt: now,
            ),
            isEdit: existingStaff != null,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
      unawaited(
        AuditLogService.record(
          action: existingStaff != null ? 'staff_edit' : 'staff_create',
          title: existingStaff != null ? 'Staff updated' : 'Staff created',
          description:
              '${_nameCtrl.text.trim()} account saved. Range: ${rangeText.isEmpty ? 'branch default' : '${rangeText}m'}, break: ${breakText.isEmpty ? AppConstants.defaultDailyBreakMinutes : breakText} min.',
          targetType: 'staff',
          targetId: existingStaff?.id ?? staffId,
          targetName: _nameCtrl.text.trim(),
          actor: ref.read(currentUserProvider),
          metadata: {
            'branch_id': _branchId,
            'shift_id': _shiftId,
            'range_meters': rangeText,
            'daily_break_minutes': breakText,
            'status': _status,
          },
        ),
      );
      setState(() => _isLoading = false);
      if (mounted) {
        if (widget.staffId == null && result.temporaryPassword != null) {
          await _showTemporaryPasswordDialog(result.temporaryPassword!);
          if (!mounted) {
            return;
          }
        }
        final roleLabel = _role == AppConstants.roleAdmin
            ? 'Admin'
            : _role == AppConstants.roleSupervisor
                ? 'Supervisor'
                : 'Staff';
        AppUtils.showSnackBar(
          context,
          widget.staffId != null
              ? '$roleLabel account updated successfully'
              : '$roleLabel account created successfully',
        );
        Navigator.pop(context);
      }
    } catch (e, st) {
      debugPrint('saveStaff error: $e\n$st');
      setState(() => _isLoading = false);
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        AppUtils.showSnackBar(
          context,
          msg.length > 120 ? 'Unable to save staff right now' : msg,
          isError: true,
        );
      }
    }
  }

  Future<void> _showTemporaryPasswordDialog(String password) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temporary Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this one-time password securely with the new user. They should change it after their first sign-in.',
            ),
            const SizedBox(height: 12),
            SelectableText(
              password,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStaffAsync = ref.watch(allStaffListAsyncProvider);
    final existingStaff = widget.staffId != null
        ? ref.watch(staffByIdProvider(widget.staffId!))
        : null;
    if (!_didPopulateForm && existingStaff != null) {
      _populateForm(existingStaff);
    }

    final branches = ref.watch(branchListProvider);
    final shifts = ref.watch(shiftListProvider);
    final isEdit = widget.staffId != null;

    if (isEdit && existingStaff == null && allStaffAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('edit_staff'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isStaff = _role == AppConstants.roleStaff;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? 'Edit Account'
            : (_role == AppConstants.roleAdmin
                ? 'Create Admin Account'
                : _role == AppConstants.roleSupervisor
                    ? 'Create Supervisor Account'
                    : 'Add New Staff')),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Account Role selector ──────────────────────────
              if (!isEdit) ...[
                _sectionTitle('Account Type'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _roleChip(
                      label: 'Staff',
                      icon: Icons.badge_outlined,
                      value: AppConstants.roleStaff,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _roleChip(
                      label: 'Supervisor',
                      icon: Icons.supervisor_account_outlined,
                      value: AppConstants.roleSupervisor,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 10),
                    _roleChip(
                      label: 'Admin',
                      icon: Icons.admin_panel_settings_outlined,
                      value: AppConstants.roleAdmin,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              _sectionTitle('Personal Information'),
              const SizedBox(height: 12),
              CustomTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 12),
              CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  }),
              const SizedBox(height: 12),
              CustomTextField(
                  controller: _mobileCtrl,
                  label: 'Mobile Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 12),
              CustomTextField(
                  controller: _idCardCtrl,
                  label: 'ID Card Number',
                  prefixIcon: Icons.credit_card_outlined),
              if (isStaff) ...[
                const SizedBox(height: 20),
                _sectionTitle('Job Details'),
                const SizedBox(height: 12),
                CustomTextField(
                    controller: _jobTitleCtrl,
                    label: 'Job Title',
                    prefixIcon: Icons.work_outline,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                CustomDropdown<String>(
                  value: _category,
                  label: 'Category',
                  prefixIcon: Icons.category_outlined,
                  items: AppConstants.staffCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 12),
                CustomDropdown<String>(
                  value: _department,
                  label: 'Department',
                  prefixIcon: Icons.business_outlined,
                  items: AppConstants.departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _department = v ?? _department),
                ),
                const SizedBox(height: 12),
                CustomDropdown<String>(
                  value: _branchId,
                  label: 'Assigned Branch',
                  prefixIcon: Icons.location_on_outlined,
                  items: branches
                      .map((b) => DropdownMenuItem(
                          value: b.id, child: Text(b.branchName)))
                      .toList(),
                  onChanged: (v) => setState(() => _branchId = v ?? _branchId),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _rangeCtrl,
                  label: 'Employee Range (meters)',
                  prefixIcon: Icons.radar_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final text = v?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final value = double.tryParse(text);
                    if (value == null || value <= 0) {
                      return 'Enter a valid range';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _breakMinutesCtrl,
                  label: 'Daily Break Limit (minutes)',
                  prefixIcon: Icons.free_breakfast_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final text = v?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final value = int.tryParse(text);
                    if (value == null || value < 0) {
                      return 'Enter valid minutes';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomDropdown<String>(
                  value: _shiftId,
                  label: 'Shift',
                  prefixIcon: Icons.schedule_outlined,
                  items: shifts
                      .map((s) => DropdownMenuItem(
                          value: s.id, child: Text(s.shiftName)))
                      .toList(),
                  onChanged: (v) => setState(() => _shiftId = v ?? _shiftId),
                ),
                const SizedBox(height: 12),
                CustomDropdown<String>(
                  value: _weeklyOff,
                  label: 'Weekly Off Day',
                  prefixIcon: Icons.weekend_outlined,
                  items: [
                    'Sunday',
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday'
                  ]
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _weeklyOff = v ?? _weeklyOff),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Salary'),
                const SizedBox(height: 12),
                CustomTextField(
                    controller: _salaryCtrl,
                    label: 'Basic Salary (PKR)',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                CustomTextField(
                    controller: _otRateCtrl,
                    label: 'Overtime Rate (PKR/hr)',
                    prefixIcon: Icons.more_time,
                    keyboardType: TextInputType.number),
              ], // end if (isStaff)
              const SizedBox(height: 20),
              _sectionTitle('Account Status'),
              const SizedBox(height: 12),
              CustomDropdown<String>(
                value: _status,
                label: 'Status',
                prefixIcon: Icons.toggle_on_outlined,
                items: [
                  AppConstants.statusActive,
                  AppConstants.statusInactive,
                  AppConstants.statusSuspended
                ]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: isEdit
                    ? 'Update Account'
                    : (_role == AppConstants.roleAdmin
                        ? 'Create Admin Account'
                        : _role == AppConstants.roleSupervisor
                            ? 'Create Supervisor Account'
                            : context.tr('add_staff')),
                icon: isEdit ? Icons.save_outlined : Icons.person_add_outlined,
                onPressed: _isLoading ? null : _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _populateForm(StaffModel staff) {
    _didPopulateForm = true;
    _nameCtrl.text = staff.name;
    _emailCtrl.text = staff.email;
    _mobileCtrl.text = staff.mobile;
    _idCardCtrl.text = staff.idCardNumber ?? '';
    _jobTitleCtrl.text = staff.jobTitle;
    _salaryCtrl.text = staff.basicSalary.toStringAsFixed(0);
    _otRateCtrl.text = staff.overtimeRate.toStringAsFixed(0);
    _category = staff.category;
    _department = staff.department;
    _status = staff.status;
    _weeklyOff = staff.weeklyOffDay;
    _branchId = staff.branchId;
    _shiftId = staff.shiftId;
    _rangeCtrl.text =
        staff.allowedLocationRadiusMeters?.toStringAsFixed(0) ?? '';
    _breakMinutesCtrl.text = staff.dailyBreakMinutes.toString();
  }

  Widget _roleChip({
    required String label,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final isSelected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? color : AppColors.textSecondary,
                  size: 22),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(6)),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary)),
    );
  }
}
