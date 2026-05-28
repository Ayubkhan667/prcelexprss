import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/services/biometric_service.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/account_actions.dart';
import '../../../core/l10n/app_localizations.dart';

class StaffProfileScreen extends ConsumerStatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  ConsumerState<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends ConsumerState<StaffProfileScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _isUpdatingBiometric = false;
  List<BiometricType> _biometricTypes = [];

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final results = await Future.wait([
      BiometricService.isBiometricAvailable(),
      BiometricService.isEnabled(),
      BiometricService.getAvailableTypes(),
    ]);
    if (!mounted) return;
    setState(() {
      _biometricAvailable = results[0] as bool;
      _biometricEnabled = results[1] as bool;
      _biometricTypes = results[2] as List<BiometricType>;
    });
  }

  Future<void> _toggleBiometric(bool value, String? userEmail) async {
    if (_isUpdatingBiometric) {
      return;
    }

    if (value) {
      final identifier = (userEmail ?? '').trim();
      if (identifier.isEmpty) {
        _showBiometricFeedback(
          'A valid account email is required for biometric login.',
          isError: true,
        );
        return;
      }

      final result = await BiometricService.authenticate(
        reason:
            'Verify identity to enable ${BiometricService.getBiometricLabel(_biometricTypes)} login',
      );
      if (!result.success || !mounted) return;
    }

    setState(() => _isUpdatingBiometric = true);

    try {
      if (value) {
        await ref.read(authControllerProvider.notifier).enableBiometricSignIn(
              identifier: userEmail!.trim(),
            );
      } else {
        await ref
            .read(authControllerProvider.notifier)
            .disableBiometricSignIn();
      }
    } catch (error) {
      if (!mounted) return;
      _showBiometricFeedback(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
      setState(() => _isUpdatingBiometric = false);
      return;
    }

    if (!mounted) return;
    setState(() {
      _biometricEnabled = value;
      _isUpdatingBiometric = false;
    });
    _showBiometricFeedback(value
        ? '${BiometricService.getBiometricLabel(_biometricTypes)} login enabled'
        : 'Biometric login disabled');
  }

  void _showBiometricFeedback(
    String message, {
    bool isError = false,
  }) {
    AppUtils.showSnackBar(context, message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final staff = ref.watch(currentStaffProvider);
    final allStaff = ref.watch(allStaffListProvider);
    final shift =
        staff != null ? ref.watch(shiftByIdProvider(staff.shiftId)) : null;
    final branch =
        staff != null ? ref.watch(branchByIdProvider(staff.branchId)) : null;
    final kpiList = staff != null ? ref.watch(kpiListProvider(staff.id)) : [];
    final currentKpi = kpiList.isNotEmpty ? kpiList.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            title: Text(context.tr('my_profile')),
            actions: [
              IconButton(
                  icon: const Icon(Icons.edit_outlined), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            AppUtils.getInitials(user?.name ?? 'S'),
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(user?.name ?? '',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    if (staff != null)
                      Text(
                        '${staff.staffCode} • ${staff.jobTitle}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    const SizedBox(height: 6),
                    StatusBadge(status: staff?.status ?? 'Active'),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI card
                  if (currentKpi != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppUtils.getKpiColor(currentKpi.totalKpiScore),
                            AppUtils.getKpiColor(currentKpi.totalKpiScore)
                                .withValues(alpha: 0.7)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              color: Colors.white, size: 32),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('KPI Performance',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              Text(currentKpi.totalKpiScore.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              Text(currentKpi.rating,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              _kpiMini('Attendance',
                                  '${currentKpi.attendanceRate.toStringAsFixed(0)}%'),
                              const SizedBox(height: 8),
                              _kpiMini(
                                  'Late Days', currentKpi.lateCount.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── 1. Personal Information ──────────────────────────────
                  _section('Personal Information'),
                  _card([
                    _infoRow(Icons.person_outline, 'Preferred Name',
                        staff?.preferredName ?? user?.name ?? '-'),
                    _infoRow(Icons.badge_outlined, 'First Name',
                        staff?.firstName ?? '-'),
                    _infoRow(Icons.badge_outlined, 'Last Name',
                        staff?.lastName ?? '-'),
                    _divider(),
                    _infoRow(
                        Icons.cake_outlined,
                        'Date of Birth',
                        staff?.dateOfBirth != null
                            ? AppUtils.formatDate(staff!.dateOfBirth!)
                            : '-'),
                    _infoRow(Icons.public_outlined, 'Nationality',
                        staff?.nationality ?? '-'),
                    _infoRow(Icons.wc_outlined, 'Gender', staff?.gender ?? '-'),
                    _infoRow(Icons.favorite_border, 'Marital Status',
                        staff?.maritalStatus ?? '-'),
                    _divider(),
                    _infoRow(Icons.phone_outlined, 'Mobile Number',
                        staff?.mobile ?? user?.mobile ?? '-'),
                    _infoRow(Icons.email_outlined, 'Personal Email',
                        staff?.personalEmail ?? '-'),
                    _infoRow(Icons.phone_in_talk_outlined, 'Work Number',
                        staff?.workPhone ?? '-'),
                    _infoRow(
                        Icons.work_outline, 'Work Email', staff?.email ?? '-'),
                    _divider(),
                    _infoRow(Icons.home_outlined, 'Personal Address',
                        staff?.personalAddress ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 2. About Me ──────────────────────────────────────────
                  _section('About Me'),
                  _card([
                    if (staff?.aboutMe != null)
                      _textBlock(
                          Icons.info_outline, 'About Me', staff!.aboutMe!),
                    if (staff?.whatIDo != null)
                      _textBlock(Icons.work_history_outlined, 'What I Do',
                          staff!.whatIDo!),
                    if (staff?.skills != null && staff!.skills!.isNotEmpty) ...[
                      _divider(),
                      _labelRow(Icons.psychology_outlined, 'Skills'),
                      const SizedBox(height: 6),
                      _chipWrap(staff.skills!, AppColors.primary),
                    ],
                    if (staff?.hobbies != null &&
                        staff!.hobbies!.isNotEmpty) ...[
                      _divider(),
                      _labelRow(Icons.interests_outlined, 'Hobbies'),
                      const SizedBox(height: 6),
                      _chipWrap(staff.hobbies!, AppColors.accent),
                    ],
                    if (staff?.socialMedia != null &&
                        staff!.socialMedia!.isNotEmpty) ...[
                      _divider(),
                      _labelRow(Icons.share_outlined, 'Social Media'),
                      const SizedBox(height: 4),
                      ...staff.socialMedia!.entries.map(
                          (e) => _infoRow(_socialIcon(e.key), e.key, e.value)),
                    ],
                  ]),
                  const SizedBox(height: 16),

                  // ── 3. Employment Profile ────────────────────────────────
                  _section('Employment Profile'),
                  _card([
                    _infoRow(Icons.work_outline, 'Job Title',
                        staff?.jobTitle ?? '-'),
                    _infoRow(Icons.business_outlined, 'Department',
                        staff?.department ?? '-'),
                    _infoRow(Icons.badge_outlined, 'Employee ID',
                        staff?.staffCode ?? '-'),
                    _infoRow(Icons.fingerprint, 'Biometric Device ID',
                        _biometricDeviceId(user?.deviceId, staff?.staffCode)),
                    _infoRow(Icons.category_outlined, 'Job Type',
                        staff?.category ?? '-'),
                    _infoRow(
                        Icons.event_available_outlined,
                        'Joining Date',
                        staff != null
                            ? AppUtils.formatDate(staff.joiningDate)
                            : '-'),
                    _infoRow(
                        Icons.event_repeat_outlined,
                        'Probation End',
                        staff != null
                            ? AppUtils.formatDate(
                                staff.joiningDate.add(const Duration(days: 90)))
                            : '-'),
                    _infoRow(Icons.location_city_outlined, 'Work Location',
                        staff?.branchName ?? '-'),
                    _infoRow(
                        Icons.radar_outlined,
                        'Assigned Range',
                        staff == null
                            ? '-'
                            : _rangeLabel(
                                staff.allowedLocationRadiusMeters,
                                branch?.allowedRadius,
                              )),
                    _infoRow(
                        Icons.free_breakfast_outlined,
                        'Daily Break',
                        staff == null
                            ? '-'
                            : '${staff.dailyBreakMinutes} minutes'),
                    _infoRow(Icons.apartment_outlined, 'Office Address',
                        branch?.address ?? '-'),
                    _infoRow(Icons.calendar_view_week_outlined, 'Work Week',
                        _workWeek(staff?.weeklyOffDay)),
                    _infoRow(
                        Icons.schedule_outlined,
                        'Work Timing',
                        shift != null
                            ? '${shift.startTime} - ${shift.endTime}'
                            : (staff?.shiftName ?? '-')),
                    _infoRow(Icons.account_tree_outlined, 'Reports To',
                        _reportTo(allStaff, staff)),
                    _infoRow(Icons.map_outlined, 'Legal Residence', 'Oman'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 4. Contract Details ──────────────────────────────────
                  _section('Contract Details'),
                  _card([
                    _infoRow(Icons.description_outlined, 'Contract Type',
                        staff?.contractType ?? '-'),
                    _infoRow(Icons.timelapse_outlined, 'Contract Terms',
                        staff?.contractTerms ?? '-'),
                    _infoRow(
                        Icons.play_circle_outline,
                        'Start Date',
                        staff?.contractStartDate != null
                            ? AppUtils.formatDate(staff!.contractStartDate!)
                            : '-'),
                    _infoRow(
                        Icons.stop_circle_outlined,
                        'Expire Date',
                        staff?.contractExpireDate != null
                            ? AppUtils.formatDate(staff!.contractExpireDate!)
                            : '-'),
                    _infoRow(Icons.payments_outlined, 'Salary Type',
                        staff?.salaryType ?? '-'),
                    _infoRow(
                        Icons.attach_money,
                        'Basic Salary',
                        staff != null
                            ? 'OMR ${staff.basicSalary.toStringAsFixed(3)}'
                            : '-'),
                    _infoRow(
                        Icons.more_time,
                        'OT Rate / hr',
                        staff != null
                            ? 'OMR ${staff.overtimeRate.toStringAsFixed(3)}'
                            : '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 5. Documents ─────────────────────────────────────────
                  _section('Identity & Documents'),
                  _card([
                    _infoRow(Icons.people_outline, 'Sponsor Name',
                        staff?.sponsorName ?? '-'),
                    _divider(),
                    _infoRow(Icons.credit_card_outlined, 'Civil ID',
                        staff?.civilId ?? staff?.idCardNumber ?? '-'),
                    _infoRow(
                        Icons.event_busy_outlined,
                        'Civil ID Expiry',
                        staff?.civilIdExpireDate != null
                            ? AppUtils.formatDate(staff!.civilIdExpireDate!)
                            : '-'),
                    _divider(),
                    _infoRow(Icons.book_outlined, 'Passport Number',
                        staff?.passportNumber ?? '-'),
                    _infoRow(
                        Icons.event_busy_outlined,
                        'Passport Expiry',
                        staff?.passportExpireDate != null
                            ? AppUtils.formatDate(staff!.passportExpireDate!)
                            : '-'),
                    _infoRow(Icons.verified_outlined, 'Passport Status',
                        staff?.passportStatus ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 6. Bank Details ──────────────────────────────────────
                  _section('Bank Details'),
                  _card([
                    _infoRow(Icons.account_balance_outlined, 'Bank Name',
                        staff?.bankName ?? '-'),
                    _infoRow(Icons.person_pin_outlined, 'Name as per Bank',
                        staff?.nameAsPerBank ?? '-'),
                    _infoRow(Icons.qr_code_2_outlined, 'SWIFT Code',
                        staff?.swiftCode ?? '-'),
                    _infoRow(Icons.numbers_outlined, 'Account Number',
                        staff?.accountNumber ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 7. Emergency Contact ─────────────────────────────────
                  _section('Emergency Contact'),
                  _card([
                    _infoRow(Icons.person_outline, 'Contact Name',
                        staff?.emergencyContactName ?? '-'),
                    _infoRow(Icons.family_restroom_outlined, 'Relation',
                        staff?.emergencyContactRelation ?? '-'),
                    _infoRow(Icons.phone_outlined, 'Phone Number',
                        staff?.emergencyContactPhone ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 8. HR Document Status ────────────────────────────────
                  _section('Passport — HR Status'),
                  _card([
                    _infoRow(Icons.upload_file_outlined, 'Submission to HR',
                        staff?.passportSubmissionStatus ?? '-'),
                    _infoRow(Icons.download_outlined, 'Collection from HR',
                        staff?.passportCollectionStatus ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 9. Account ───────────────────────────────────────────
                  _section('Account'),
                  _card([
                    _infoRow(Icons.manage_accounts_outlined, 'Role',
                        user?.role.toUpperCase() ?? '-'),
                    _infoRow(Icons.phone_android, 'Device Bound', 'Yes'),
                    _infoRow(
                        Icons.security_outlined, 'Status', user?.status ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ── 10. Security ─────────────────────────────────────────
                  _section('Security'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6)
                      ],
                    ),
                    child: _biometricAvailable
                        ? SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            secondary: Icon(
                              BiometricService.isFaceId(_biometricTypes)
                                  ? Icons.face_retouching_natural
                                  : Icons.fingerprint,
                              color: _biometricEnabled
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 26,
                            ),
                            title: Text(
                              '${BiometricService.getBiometricLabel(_biometricTypes)} Login',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              _isUpdatingBiometric
                                  ? 'Updating biometric sign-in...'
                                  : _biometricEnabled
                                      ? 'Enabled — tap to disable'
                                      : 'Tap to enable quick sign-in',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                            value: _biometricEnabled,
                            activeColor: AppColors.primary,
                            onChanged: _isUpdatingBiometric
                                ? null
                                : (v) => _toggleBiometric(v, user?.email),
                          )
                        : ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: const Icon(Icons.fingerprint,
                                color: AppColors.textHint),
                            title: Text(context.tr('biometric_login'),
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.textHint)),
                            subtitle: Text(context.tr('not_available_on_device'),
                                style: const TextStyle(fontSize: 12)),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // ── Logout & Change Password ──────────────────────────
                  _section('Account Actions'),
                  const AccountActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      );

  Widget _card(List<Widget> rows) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: rows),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
            SizedBox(
                width: 120,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary))),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      );

  Widget _textBlock(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary, height: 1.45)),
          ],
        ),
      );

  Widget _labelRow(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      );

  Widget _chipWrap(List<String> items, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((s) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Text(s,
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ))
              .toList(),
        ),
      );

  Widget _divider() =>
      const Divider(height: 1, thickness: 0.5, color: AppColors.divider);

  Widget _kpiMini(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: TextStyle(
                  fontSize: 9, color: Colors.white.withValues(alpha: 0.75))),
        ],
      );

  IconData _socialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.work_outline;
      case 'twitter':
      case 'x':
        return Icons.tag;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'whatsapp':
        return Icons.chat_outlined;
      default:
        return Icons.link;
    }
  }

  String _biometricDeviceId(String? deviceId, String? staffCode) {
    if (deviceId != null && deviceId.isNotEmpty) return deviceId;
    if (staffCode != null && staffCode.isNotEmpty) return 'BIO-$staffCode';
    return '-';
  }

  String _workWeek(String? weeklyOffDay) {
    switch ((weeklyOffDay ?? '').toLowerCase()) {
      case 'friday':
        return 'Saturday - Thursday';
      case 'saturday':
        return 'Sunday - Friday';
      default:
        return weeklyOffDay ?? '-';
    }
  }

  String _rangeLabel(double? staffRange, double? branchRange) {
    final range = staffRange ?? branchRange;
    if (range == null || range <= 0) return '-';
    final source = staffRange == null ? 'branch default' : 'employee fixed';
    return '${range.toStringAsFixed(0)}m ($source)';
  }

  String _reportTo(List<StaffModel> staffList, StaffModel? staff) {
    if (staff == null) return '-';
    final candidates = staffList
        .where((member) =>
            member.id != staff.id &&
            member.department == staff.department &&
            member.status == 'Active')
        .toList();
    for (final m in candidates) {
      if (m.category == 'Manager') return '${m.name} (${m.jobTitle})';
    }
    for (final m in candidates) {
      if (m.category == 'Supervisor') return '${m.name} (${m.jobTitle})';
    }
    return 'Saif Al-Bulushi (Admin)';
  }
}
