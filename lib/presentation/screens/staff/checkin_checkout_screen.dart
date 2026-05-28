import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/shift_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/attendance_capture_service.dart';
import '../../../data/services/device_binding_service.dart';
import '../../../data/services/offline_attendance_queue_service.dart';

class CheckinCheckoutScreen extends ConsumerStatefulWidget {
  const CheckinCheckoutScreen({super.key});

  @override
  ConsumerState<CheckinCheckoutScreen> createState() =>
      _CheckinCheckoutScreenState();
}

class _CheckinCheckoutScreenState extends ConsumerState<CheckinCheckoutScreen>
    with WidgetsBindingObserver {
  final dynamic _captureService = AttendanceCaptureService();
  final TextEditingController _webWifiController = TextEditingController();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _clockTimer;
  Timer? _monitorTimer;

  DateTime _now = DateTime.now();
  AttendanceAccessResult? _accessResult;
  bool _isRefreshingAccess = false;
  bool _isSubmitting = false;
  String? _latestSelfieLabel;
  String? _monitorAttendanceId;
  String? _dutyOverrideAttendanceId;
  String? _dutyOverrideStatus;
  int _pendingQueueCount = 0;
  bool _cameraPermissionGranted = false;
  bool _isTestingCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((_) {
      unawaited(_handleConnectivityChanged());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_restoreLostSelfie());
      unawaited(_refreshAccessStatus());
      unawaited(_refreshOfflineQueueCount());
      unawaited(_checkCameraPermission());
    });
  }

  Future<void> _checkCameraPermission() async {
    if (kIsWeb) return;
    final status = await Permission.camera.status;
    if (!mounted) return;
    setState(() => _cameraPermissionGranted = status.isGranted);
  }

  Future<void> _testCamera() async {
    if (_isTestingCamera) return;
    setState(() => _isTestingCamera = true);
    try {
      final selfie = await _captureService.captureSelfie();
      if (!mounted) return;
      if (selfie.isSuccess && selfie.file != null) {
        setState(() {
          _cameraPermissionGranted = true;
          _latestSelfieLabel = _fileLabel(selfie.file!.path);
        });
        AppUtils.showSnackBar(context, 'Camera works! Selfie preview saved.');
      } else {
        if (selfie.openAppSettingsSuggested) {
          setState(() => _cameraPermissionGranted = false);
        }
        _showError(selfie.message);
      }
    } finally {
      if (mounted) setState(() => _isTestingCamera = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _clockTimer?.cancel();
    _monitorTimer?.cancel();
    _webWifiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAccessStatus());
      unawaited(_enforceDutyRules(showFeedback: false));
    }
  }

  Future<void> _restoreLostSelfie() async {
    final file = await _captureService.retrieveLostSelfie();
    if (!mounted || file == null) {
      return;
    }

    setState(() {
      _latestSelfieLabel = _fileLabel(file.path);
    });
  }

  Future<void> _handleConnectivityChanged() async {
    await _refreshAccessStatus(silent: true);
    await _enforceDutyRules(showFeedback: true);
    await _syncOfflineQueue(showFeedback: true);
  }

  Future<void> _refreshAccessStatus({bool silent = false}) async {
    final branch = _resolveBranch();
    if (branch == null) {
      return;
    }

    if (!silent && mounted) {
      setState(() => _isRefreshingAccess = true);
    }

    final result = await _captureService.verifyAttendanceAccess(
      branch: branch,
      manualWifiSsid: _manualWifiSsid,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _accessResult = result;
      _isRefreshingAccess = false;
    });
  }

  Future<void> _performCheckIn() async {
    final staff = _resolveStaff();
    final branch = _resolveBranch();
    final shift = _resolveShift();
    if (staff == null || branch == null || shift == null) {
      _showError('Staff, branch, or shift details are missing.');
      return;
    }

    setState(() => _isSubmitting = true);
    AttendanceAccessResult? queueAccess;
    DateTime? queueTime;
    String? queueDeviceId;
    String? queueSelfiePath;
    String? queueNotes;

    try {
      final access = await _captureService.verifyAttendanceAccess(
        branch: branch,
        manualWifiSsid: _manualWifiSsid,
      );
      if (!mounted) {
        return;
      }

      setState(() => _accessResult = access);
      if (!access.canProceed) {
        _showError(access.message);
        return;
      }

      final selfie = await _captureService.captureSelfie();
      if (!mounted) {
        return;
      }

      if (!selfie.isSuccess || selfie.file == null) {
        _showError(selfie.message);
        return;
      }

      final deviceId = await DeviceBindingService.getDeviceId();
      final now = DateTime.now();
      final notes =
          'Check-in verified with office Wi-Fi ${access.wifi.currentWifiSsid ?? _manualWifiSsid}.';
      queueAccess = access;
      queueTime = now;
      queueDeviceId = deviceId;
      queueSelfiePath = _uploadableSelfiePath(selfie.file!.path);
      queueNotes = notes;
      final attendance =
          await ref.read(attendanceRepositoryProvider).recordCheckIn(
                staff: staff,
                branch: branch,
                shift: shift,
                checkInTime: now,
                latitude: access.location.position!.latitude,
                longitude: access.location.position!.longitude,
                deviceId: deviceId,
                isLocationValid: true,
                isMockGps: false,
                wifiSsid: access.wifi.currentWifiSsid ?? _manualWifiSsid,
                selfiePath: queueSelfiePath,
                notes: notes,
              );

      _bumpRevision();
      if (!mounted) {
        return;
      }

      setState(() {
        _latestSelfieLabel = _fileLabel(selfie.file!.path);
        _dutyOverrideAttendanceId = attendance.id;
        _dutyOverrideStatus = attendance.dutyStatus;
      });

      AppUtils.showSnackBar(
        context,
        'Check-in successful at ${AppUtils.formatTime(now)}',
      );
    } on DioException catch (error) {
      if (await _queueAttendanceIfOffline(
        error: error,
        eventType: OfflineAttendanceQueueService.checkIn,
        staff: staff,
        branch: branch,
        shift: shift,
        access: queueAccess,
        eventTime: queueTime,
        deviceId: queueDeviceId,
        selfiePath: queueSelfiePath,
        notes: queueNotes,
      )) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Internet issue: check-in saved offline and will sync later.',
          );
        }
      } else {
        _showError(_remoteErrorMessage(error));
      }
    } catch (_) {
      _showError('Unable to check in right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _performCheckOut(AttendanceModel activeAttendance) async {
    final staff = _resolveStaff();
    final branch = _resolveBranch();
    final shift = _resolveShift();
    if (staff == null || branch == null || shift == null) {
      _showError('Staff, branch, or shift details are missing.');
      return;
    }

    setState(() => _isSubmitting = true);
    AttendanceAccessResult? queueAccess;
    DateTime? queueTime;
    String? queueDeviceId;
    String? queueSelfiePath;
    String? queueNotes;

    try {
      final access = await _captureService.verifyAttendanceAccess(
        branch: branch,
        manualWifiSsid: _manualWifiSsid,
      );
      if (!mounted) {
        return;
      }

      setState(() => _accessResult = access);
      if (!access.canProceed) {
        _showError(access.message);
        return;
      }

      final selfie = await _captureService.captureSelfie();
      if (!mounted) {
        return;
      }

      if (!selfie.isSuccess || selfie.file == null) {
        _showError(selfie.message);
        return;
      }

      final deviceId = await DeviceBindingService.getDeviceId();
      final checkOutTime = DateTime.now();
      final notes =
          'Check-out verified with office Wi-Fi ${access.wifi.currentWifiSsid ?? _manualWifiSsid}.';
      queueAccess = access;
      queueTime = checkOutTime;
      queueDeviceId = deviceId;
      queueSelfiePath = _uploadableSelfiePath(selfie.file!.path);
      queueNotes = notes;
      final attendance =
          await ref.read(attendanceRepositoryProvider).recordCheckOut(
                staff: staff,
                branch: branch,
                shift: shift,
                checkOutTime: checkOutTime,
                latitude: access.location.position!.latitude,
                longitude: access.location.position!.longitude,
                deviceId: deviceId,
                isLocationValid: true,
                isMockGps: false,
                wifiSsid: access.wifi.currentWifiSsid ?? _manualWifiSsid,
                selfiePath: queueSelfiePath,
                notes: notes,
              );

      if (attendance == null) {
        _showError('Attendance record not found for checkout.');
        return;
      }

      _bumpRevision();
      if (!mounted) {
        return;
      }

      setState(() {
        _latestSelfieLabel = _fileLabel(selfie.file!.path);
        _dutyOverrideAttendanceId = null;
        _dutyOverrideStatus = null;
        _monitorAttendanceId = null;
      });
      _monitorTimer?.cancel();

      _showCheckoutSummary(attendance);
    } on DioException catch (error) {
      if (await _queueAttendanceIfOffline(
        error: error,
        eventType: OfflineAttendanceQueueService.checkOut,
        staff: staff,
        branch: branch,
        shift: shift,
        access: queueAccess,
        eventTime: queueTime,
        deviceId: queueDeviceId,
        selfiePath: queueSelfiePath,
        notes: queueNotes,
      )) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Internet issue: check-out saved offline and will sync later.',
          );
        }
      } else {
        _showError(_remoteErrorMessage(error));
      }
    } catch (_) {
      _showError('Unable to check out right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _enforceDutyRules({required bool showFeedback}) async {
    final branch = _resolveBranch();
    final attendance = _resolveActiveAttendance();
    if (branch == null || attendance == null || _isSubmitting) {
      return;
    }

    final access = await _captureService.verifyAttendanceAccess(
      branch: branch,
      manualWifiSsid: _manualWifiSsid,
    );
    if (!mounted) {
      return;
    }

    setState(() => _accessResult = access);
    final dutyStatus = _effectiveDutyStatus(attendance);

    try {
      if (!access.canProceed && dutyStatus != AppConstants.dutyStatusPaused) {
        final pausedAttendance =
            await ref.read(attendanceRepositoryProvider).pauseDuty(
                  attendanceId: attendance.id,
                  pausedAt: DateTime.now(),
                  reason: 'Duty auto-paused: ${access.message}',
                );
        if (pausedAttendance != null) {
          _bumpRevision();
          if (!mounted) {
            return;
          }
          setState(() {
            _dutyOverrideAttendanceId = attendance.id;
            _dutyOverrideStatus = AppConstants.dutyStatusPaused;
          });
          if (showFeedback) {
            _showError('Duty paused. ${access.message}');
          }
        }
        return;
      }

      if (access.canProceed && dutyStatus == AppConstants.dutyStatusPaused) {
        final resumedAttendance =
            await ref.read(attendanceRepositoryProvider).resumeDuty(
                  attendanceId: attendance.id,
                  resumedAt: DateTime.now(),
                  reason:
                      'Duty auto-resumed after office Wi-Fi and location were verified.',
                );
        if (resumedAttendance != null) {
          _bumpRevision();
          if (!mounted) {
            return;
          }
          setState(() {
            _dutyOverrideAttendanceId = attendance.id;
            _dutyOverrideStatus = AppConstants.dutyStatusActive;
          });
          if (showFeedback) {
            AppUtils.showSnackBar(
              context,
              'Duty resumed. Office Wi-Fi and location verified.',
            );
          }
        }
      }
    } on DioException catch (error) {
      if (showFeedback && mounted) {
        _showError(_remoteErrorMessage(error));
      }
    } catch (_) {
      if (showFeedback && mounted) {
        _showError('Unable to sync duty status right now.');
      }
    }
  }

  Future<void> _startBreak(AttendanceModel attendance, StaffModel staff) async {
    if (_effectiveDutyStatus(attendance) == AppConstants.dutyStatusPaused) {
      AppUtils.showSnackBar(context, 'Break is already running.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final pausedAttendance =
          await ref.read(attendanceRepositoryProvider).pauseDuty(
                attendanceId: attendance.id,
                pausedAt: DateTime.now(),
                reason:
                    'Break started outside assigned range. Daily break limit: ${staff.dailyBreakMinutes} minutes.',
              );
      if (pausedAttendance == null) {
        _showError('Unable to start break for this attendance record.');
        return;
      }

      _bumpRevision();
      if (!mounted) {
        return;
      }
      setState(() {
        _dutyOverrideAttendanceId = attendance.id;
        _dutyOverrideStatus = AppConstants.dutyStatusPaused;
      });
      AppUtils.showSnackBar(
        context,
        'Break started. Remaining break: ${_remainingBreakMinutes(staff, pausedAttendance)} min',
      );
    } on DioException catch (error) {
      _showError(_remoteErrorMessage(error));
    } catch (_) {
      _showError('Unable to start break right now.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _markVisit({
    required StaffModel staff,
    required BranchModel branch,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      final access = _accessResult ??
          await _captureService.verifyAttendanceAccess(
            branch: branch,
            manualWifiSsid: _manualWifiSsid,
          );
      if (!mounted) {
        return;
      }
      setState(() => _accessResult = access);

      final location = access.location;
      if (!location.permissionGranted || location.position == null) {
        _showError(location.message);
        return;
      }
      if (location.isMockGps) {
        _showError(location.message);
        return;
      }
      if (location.isInsideGeofence) {
        AppUtils.showSnackBar(
          context,
          'You are inside assigned range. Use normal Check In/Out.',
        );
        return;
      }

      final now = DateTime.now();
      final distance = location.distanceMeters?.toStringAsFixed(0) ?? '--';
      final visitNote =
          'Visit recorded outside assigned range at ${AppUtils.formatDateTime(now)}. Distance: ${distance}m from ${branch.branchName}.';
      final existing = _resolveTodayAttendance();
      final attendance = existing == null
          ? AttendanceModel(
              id: 'visit_${staff.id}_${now.millisecondsSinceEpoch}',
              staffId: staff.id,
              staffName: staff.name,
              staffCode: staff.staffCode,
              date: DateTime(now.year, now.month, now.day),
              workingHours: 0,
              overtimeHours: 0,
              lateMinutes: 0,
              earlyCheckoutMinutes: 0,
              status: AppConstants.attendanceVisit,
              isLocationValid: true,
              isMockGps: false,
              approvalStatus: 'Auto',
              notes: visitNote,
              createdAt: now,
            )
          : existing.copyWith(
              status: existing.checkInTime == null
                  ? AppConstants.attendanceVisit
                  : existing.status,
              notes: _appendNotes(existing.notes, visitNote),
            );

      await ref.read(attendanceRepositoryProvider).saveAttendance(
            attendance: attendance,
            isEdit: existing != null,
          );
      _bumpRevision();
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(context, 'Visit marked outside assigned range.');
    } on DioException catch (error) {
      _showError(_remoteErrorMessage(error));
    } catch (_) {
      _showError('Unable to mark visit right now.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showCheckoutSummary(AttendanceModel attendance) {
    if (!mounted) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Check-Out Successful',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Duty closed with Wi-Fi and location verification.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: [
                _summaryItem(
                  context.tr('check_in'),
                  attendance.checkInTime != null
                      ? AppUtils.formatTime(attendance.checkInTime!)
                      : '--',
                  AppColors.success,
                ),
                _summaryItem(
                  context.tr('check_out'),
                  attendance.checkOutTime != null
                      ? AppUtils.formatTime(attendance.checkOutTime!)
                      : '--',
                  AppColors.error,
                ),
                _summaryItem(
                  'Worked',
                  AppUtils.formatDuration(attendance.workingHours),
                  AppColors.primary,
                ),
                _summaryItem(
                  'Paused',
                  AppUtils.formatDuration(attendance.pausedMinutes / 60.0),
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  StaffModel? _resolveStaff() {
    final authStaff = ref.read(currentStaffProvider);
    if (authStaff == null) {
      return null;
    }

    return ref.read(staffByIdProvider(authStaff.id)) ?? authStaff;
  }

  BranchModel? _resolveBranch() {
    final staff = _resolveStaff();
    if (staff == null) {
      return null;
    }

    return _effectiveBranchForStaff(
      staff,
      ref.read(branchByIdProvider(staff.branchId)),
    );
  }

  BranchModel? _effectiveBranchForStaff(StaffModel staff, BranchModel? branch) {
    if (branch == null) {
      return null;
    }
    final range = staff.allowedLocationRadiusMeters;
    if (range == null || range <= 0 || range == branch.allowedRadius) {
      return branch;
    }
    return branch.copyWith(allowedRadius: range);
  }

  ShiftModel? _resolveShift() {
    final staff = _resolveStaff();
    if (staff == null) {
      return null;
    }

    return ref.read(shiftByIdProvider(staff.shiftId));
  }

  AttendanceModel? _resolveTodayAttendance() {
    final staff = _resolveStaff();
    if (staff == null) {
      return null;
    }

    return ref.read(todayAttendanceForStaffProvider(staff.id));
  }

  AttendanceModel? _resolveActiveAttendance() {
    final todayAttendance = _resolveTodayAttendance();
    if (todayAttendance == null ||
        todayAttendance.checkInTime == null ||
        todayAttendance.checkOutTime != null) {
      return null;
    }
    return todayAttendance;
  }

  void _syncDutyMonitor(String? attendanceId) {
    if (_monitorAttendanceId == attendanceId) {
      return;
    }

    _monitorAttendanceId = attendanceId;
    if (_dutyOverrideAttendanceId != attendanceId) {
      _dutyOverrideAttendanceId = null;
      _dutyOverrideStatus = null;
    }

    _monitorTimer?.cancel();
    if (attendanceId == null) {
      return;
    }

    _monitorTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_enforceDutyRules(showFeedback: true));
    });
    unawaited(_enforceDutyRules(showFeedback: false));
  }

  String _effectiveDutyStatus(AttendanceModel attendance) {
    if (_dutyOverrideAttendanceId == attendance.id &&
        _dutyOverrideStatus != null) {
      return _dutyOverrideStatus!;
    }
    return attendance.dutyStatus;
  }

  double _workedHours(AttendanceModel attendance) {
    final checkIn = attendance.checkInTime;
    if (checkIn == null) {
      return 0;
    }

    final endTime = attendance.checkOutTime ?? _now;
    final pausedMinutes = _effectivePausedMinutes(attendance, endTime);
    final workedMinutes = endTime.difference(checkIn).inMinutes - pausedMinutes;
    return workedMinutes <= 0 ? 0 : workedMinutes / 60.0;
  }

  int _effectivePausedMinutes(AttendanceModel attendance, DateTime endTime) {
    final livePauseMinutes = attendance.pauseStartedAt != null &&
            endTime.isAfter(attendance.pauseStartedAt!)
        ? endTime.difference(attendance.pauseStartedAt!).inMinutes
        : 0;
    return attendance.pausedMinutes + livePauseMinutes;
  }

  int _remainingBreakMinutes(StaffModel staff, AttendanceModel attendance) {
    final remaining =
        staff.dailyBreakMinutes - _effectivePausedMinutes(attendance, _now);
    return remaining < 0 ? 0 : remaining;
  }

  String _appendNotes(String? current, String note) {
    final trimmed = current?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return note;
    }
    return '$trimmed\n$note';
  }

  void _bumpRevision() {
    ref.read(mockDataRevisionProvider.notifier).state++;
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    AppUtils.showSnackBar(context, message, isError: true);
  }

  String _fileLabel(String path) {
    final segments = path.split(RegExp(r'[\\/]'));
    return segments.isEmpty ? 'Selfie captured' : segments.last;
  }

  String _remoteErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return 'Something went wrong. Please try again later.';
  }

  String? get _manualWifiSsid {
    final value = _webWifiController.text.trim();
    return value.isEmpty ? null : value;
  }

  bool get _showManualWifiEntry {
    if (kIsWeb) {
      return true;
    }

    final wifi = _accessResult?.wifi;
    return wifi != null &&
        wifi.requiredWifiSsid != null &&
        wifi.currentWifiSsid == null;
  }

  String? _uploadableSelfiePath(String path) {
    if (kIsWeb) {
      return null;
    }
    return path;
  }

  Future<void> _refreshOfflineQueueCount() async {
    final count = (await OfflineAttendanceQueueService().pendingItems()).length;
    if (!mounted) {
      return;
    }
    setState(() => _pendingQueueCount = count);
  }

  Future<bool> _queueAttendanceIfOffline({
    required DioException error,
    required String eventType,
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required AttendanceAccessResult? access,
    required DateTime? eventTime,
    required String? deviceId,
    required String? selfiePath,
    required String? notes,
  }) async {
    final position = access?.location.position;
    if (!_isOfflineFailure(error) ||
        position == null ||
        eventTime == null ||
        deviceId == null ||
        deviceId.isEmpty) {
      return false;
    }

    await OfflineAttendanceQueueService().queue(
      eventType: eventType,
      staff: staff,
      branch: branch,
      shift: shift,
      eventTime: eventTime,
      latitude: position.latitude,
      longitude: position.longitude,
      deviceId: deviceId,
      isLocationValid: true,
      isMockGps: false,
      wifiSsid: access?.wifi.currentWifiSsid ?? _manualWifiSsid,
      selfiePath: selfiePath,
      notes: notes,
    );
    await _refreshOfflineQueueCount();
    return true;
  }

  bool _isOfflineFailure(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.response == null;
  }

  Future<void> _syncOfflineQueue({required bool showFeedback}) async {
    final staff = _resolveStaff();
    final branch = _resolveBranch();
    final shift = _resolveShift();
    if (staff == null || branch == null || shift == null || _isSubmitting) {
      return;
    }

    final pendingBefore =
        (await OfflineAttendanceQueueService().pendingItems()).length;
    if (pendingBefore == 0) {
      if (mounted && _pendingQueueCount != 0) {
        setState(() => _pendingQueueCount = 0);
      }
      return;
    }

    final result = await OfflineAttendanceQueueService().syncForStaff(
      repository: ref.read(attendanceRepositoryProvider),
      staff: staff,
      branch: branch,
      shift: shift,
    );
    _bumpRevision();
    await _refreshOfflineQueueCount();

    if (!mounted || !showFeedback) {
      return;
    }

    if (result.synced > 0) {
      AppUtils.showSnackBar(
        context,
        '${result.synced} offline attendance item(s) synced.',
      );
    } else if (result.failed > 0) {
      AppUtils.showSnackBar(
        context,
        'Offline attendance sync failed. It will retry later.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStaff = ref.watch(currentStaffProvider);
    final liveStaff =
        authStaff != null ? ref.watch(staffByIdProvider(authStaff.id)) : null;
    final staff = liveStaff ?? authStaff;

    final allStaffAsync = ref.watch(allStaffListAsyncProvider);
    final branchAsync = ref.watch(branchListAsyncProvider);
    final shiftAsync = ref.watch(shiftListAsyncProvider);
    final attendanceAsync = ref.watch(attendanceListAsyncProvider(staff?.id));

    if (staff == null) {
      if (allStaffAsync.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return const Scaffold(
        body: Center(
          child: Text('Staff profile not found.'),
        ),
      );
    }

    final assignedBranch = ref.watch(branchByIdProvider(staff.branchId));
    final branch = _effectiveBranchForStaff(staff, assignedBranch);
    final shift = ref.watch(shiftByIdProvider(staff.shiftId));
    final todayAttendance =
        ref.watch(todayAttendanceForStaffProvider(staff.id));

    if ((branch == null && branchAsync.isLoading) ||
        (shift == null && shiftAsync.isLoading) ||
        attendanceAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (branch == null || shift == null) {
      return const Scaffold(
        body: Center(
          child: Text('Branch or shift configuration is missing.'),
        ),
      );
    }

    final activeAttendance = todayAttendance != null &&
            todayAttendance.checkInTime != null &&
            todayAttendance.checkOutTime == null
        ? todayAttendance
        : null;
    final dutyStatus = activeAttendance == null
        ? AppConstants.dutyStatusCompleted
        : _effectiveDutyStatus(activeAttendance);
    final canProceed = _accessResult?.canProceed ?? false;
    final canSubmit = !_isSubmitting && canProceed;
    final isOutsideAssignedRange =
        _accessResult?.location.permissionGranted == true &&
            _accessResult?.location.position != null &&
            _accessResult?.location.isMockGps == false &&
            _accessResult?.location.isInsideGeofence == false;

    if (_accessResult == null && !_isRefreshingAccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_refreshAccessStatus());
        }
      });
    }

    if (_monitorAttendanceId != activeAttendance?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncDutyMonitor(activeAttendance?.id);
        }
      });
    }

    final accessWarnings = _accessResult?.warnings ?? const <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('attendance')),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF071A3E), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshAccessStatus();
          await _enforceDutyRules(showFeedback: false);
          await _syncOfflineQueue(showFeedback: true);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildClockCard(),
            const SizedBox(height: 16),
            if (_pendingQueueCount > 0) ...[
              _buildOfflineQueueCard(),
              const SizedBox(height: 16),
            ],
            _buildStaffCard(staff, shift, branch),
            const SizedBox(height: 16),
            _buildRangePolicyCard(staff, branch),
            const SizedBox(height: 16),
            if (activeAttendance != null) ...[
              _buildDutyStatusCard(
                attendance: activeAttendance,
                dutyStatus: dutyStatus,
                staff: staff,
              ),
              const SizedBox(height: 16),
            ],
            _buildAccessCard(
              title: 'Location Verification',
              icon: canProceed
                  ? Icons.location_on_rounded
                  : Icons.location_searching_rounded,
              color: _accessResult?.location.canProceed == true
                  ? AppColors.success
                  : AppColors.error,
              message: _accessResult?.location.message ??
                  'Checking branch geofence...',
              trailing: _isRefreshingAccess
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      onPressed:
                          _isSubmitting ? null : () => _refreshAccessStatus(),
                    ),
            ),
            const SizedBox(height: 12),
            _buildAccessCard(
              title: 'Office Wi-Fi Verification',
              icon: Icons.wifi_rounded,
              color: _accessResult?.wifi.canProceed == true
                  ? AppColors.success
                  : AppColors.warning,
              message: _accessResult?.wifi.message ??
                  'Checking office Wi-Fi ${branch.wifiSsid ?? ''}...',
              subtitle: _accessResult?.wifi.currentWifiSsid != null
                  ? 'Connected: ${_accessResult!.wifi.currentWifiSsid}'
                  : (branch.wifiSsid != null
                      ? 'Required: ${branch.wifiSsid}'
                      : null),
            ),
            if (_showManualWifiEntry) ...[
              const SizedBox(height: 12),
              _buildWebWifiEntry(branch),
            ],
            if (accessWarnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...accessWarnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildWarningBanner(warning),
                ),
              ),
            ],
            if (isOutsideAssignedRange) ...[
              const SizedBox(height: 12),
              _buildOutsideRangeActions(
                staff: staff,
                branch: branch,
                activeAttendance: activeAttendance,
                dutyStatus: dutyStatus,
              ),
            ],
            const SizedBox(height: 16),
            _buildSelfieCard(),
            const SizedBox(height: 16),
            if (_accessResult != null &&
                (_accessResult!.location.openAppSettingsSuggested ||
                    _accessResult!.location.openLocationSettingsSuggested))
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_accessResult!.location.openAppSettingsSuggested)
                    OutlinedButton.icon(
                      onPressed: openAppSettings,
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('App Settings'),
                    ),
                  if (_accessResult!.location.openLocationSettingsSuggested)
                    OutlinedButton.icon(
                      onPressed: Geolocator.openLocationSettings,
                      icon: const Icon(Icons.gps_fixed_outlined),
                      label: const Text('Location Settings'),
                    ),
                ],
              ),
            const SizedBox(height: 24),
            _AttendanceButton(
              isLoading: _isSubmitting,
              isCheckedIn: activeAttendance != null,
              canSubmit: activeAttendance == null ? canSubmit : canSubmit,
              onTap: !canSubmit
                  ? null
                  : activeAttendance != null
                      ? () => _performCheckOut(activeAttendance)
                      : _performCheckIn,
            ),
            const SizedBox(height: 12),
            Text(
              isOutsideAssignedRange
                  ? 'Outside assigned range: Check In/Out is blocked. Only Visit or Break can be recorded.'
                  : activeAttendance == null
                      ? 'Check-in only works when branch location and office Wi-Fi both match.'
                      : dutyStatus == AppConstants.dutyStatusPaused
                          ? 'Duty is paused. Reconnect the correct office Wi-Fi and move inside the branch geofence to resume time.'
                          : 'Duty timer runs only while branch location and office Wi-Fi stay verified.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF071A3E), Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppUtils.formatTime(_now),
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppUtils.formatDate(_now),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineQueueCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_pendingQueueCount attendance item(s) offline queue mein hain.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => _syncOfflineQueue(showFeedback: true),
            child: Text(context.tr('sync')),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(
    StaffModel staff,
    ShiftModel shift,
    BranchModel branch,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                AppUtils.getInitials(staff.name),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${staff.shiftName} • ${staff.branchName}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (branch.wifiSsid != null && branch.wifiSsid!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Office Wi-Fi: ${branch.wifiSsid}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${shift.startTime} - ${shift.endTime}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangePolicyCard(StaffModel staff, BranchModel branch) {
    final employeeRange = staff.allowedLocationRadiusMeters;
    final rangeSource =
        employeeRange == null ? 'Branch default range' : 'Employee fixed range';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.radar_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assigned Range Rule',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${branch.allowedRadius.toStringAsFixed(0)}m from ${branch.branchName} • $rangeSource',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Daily break limit: ${staff.dailyBreakMinutes} minutes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutsideRangeActions({
    required StaffModel staff,
    required BranchModel branch,
    required AttendanceModel? activeAttendance,
    required String dutyStatus,
  }) {
    final distance = _accessResult?.location.distanceMeters?.toStringAsFixed(0);
    final canStartBreak = activeAttendance != null &&
        dutyStatus != AppConstants.dutyStatusPaused &&
        !_isSubmitting;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_off_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  distance == null
                      ? 'Outside assigned range'
                      : 'Outside assigned range (${distance}m away)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Normal Check In/Out yahan allowed nahi hai. Sirf Visit record ya Break start ho sakta hai.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () => _markVisit(staff: staff, branch: branch),
                  icon: const Icon(Icons.route_outlined, size: 18),
                  label: const Text('Mark Visit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canStartBreak
                      ? () => _startBreak(activeAttendance, staff)
                      : null,
                  icon: Icon(
                    dutyStatus == AppConstants.dutyStatusPaused
                        ? Icons.pause_circle_filled_rounded
                        : Icons.free_breakfast_outlined,
                    size: 18,
                  ),
                  label: Text(
                    activeAttendance == null
                        ? 'Break needs Check In'
                        : dutyStatus == AppConstants.dutyStatusPaused
                            ? 'Break Running'
                            : 'Start Break',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDutyStatusCard({
    required AttendanceModel attendance,
    required String dutyStatus,
    required StaffModel staff,
  }) {
    final statusLabel = dutyStatus == AppConstants.dutyStatusPaused
        ? AppConstants.attendanceDutyPaused
        : attendance.status;
    final statusColor = AppUtils.getStatusColor(statusLabel);
    final workedHours = _workedHours(attendance);
    final pausedHours = _effectivePausedMinutes(attendance, _now) / 60.0;
    final remainingBreak = _remainingBreakMinutes(staff, attendance);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  dutyStatus == AppConstants.dutyStatusPaused
                      ? Icons.pause_circle_outline_rounded
                      : Icons.badge_outlined,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      dutyStatus == AppConstants.dutyStatusPaused
                          ? 'Duty timer is paused until office Wi-Fi and location are verified again.'
                          : 'Duty timer is active and being monitored.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 12,
            children: [
              _metricItem(
                context.tr('check_in'),
                attendance.checkInTime != null
                    ? AppUtils.formatTime(attendance.checkInTime!)
                    : '--',
              ),
              _metricItem('Worked', AppUtils.formatDuration(workedHours)),
              _metricItem('Paused', AppUtils.formatDuration(pausedHours)),
              _metricItem('Break Left', '$remainingBreak min'),
              _metricItem('Late', '${attendance.lateMinutes} min'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessCard({
    required String title,
    required IconData icon,
    required Color color,
    required String message,
    Widget? trailing,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildWarningBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebWifiEntry(BranchModel branch) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.language_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Manual Wi-Fi Entry',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Agar app Wi-Fi name auto-detect na kar sake, office Wi-Fi name manually enter karo.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _webWifiController,
            onChanged: (_) => unawaited(_refreshAccessStatus(silent: true)),
            decoration: InputDecoration(
              hintText: branch.wifiSsid ?? 'Office Wi-Fi SSID',
              prefixIcon: const Icon(Icons.wifi_rounded),
              filled: true,
              fillColor: AppColors.primarySurface.withValues(alpha: 0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfieCard() {
    final denied = !kIsWeb && !_cameraPermissionGranted;
    final cardColor = denied ? AppColors.error : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  denied
                      ? Icons.no_photography_rounded
                      : Icons.camera_alt_rounded,
                  color: cardColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      denied ? 'Camera Access Required' : 'Selfie Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: cardColor,
                      ),
                    ),
                    Text(
                      denied
                          ? 'Grant camera permission to capture attendance selfie.'
                          : _latestSelfieLabel == null
                              ? 'A selfie will be taken automatically on check-in/out.'
                              : 'Last captured: $_latestSelfieLabel',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (denied) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await openAppSettings();
                      await _checkCameraPermission();
                    },
                    icon: const Icon(Icons.settings_outlined, size: 16),
                    label: const Text('Open App Settings'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTestingCamera ? null : _testCamera,
                    icon: _isTestingCamera
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_front_rounded, size: 16),
                    label: const Text('Test Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatefulWidget {
  const _AttendanceButton({
    required this.isLoading,
    required this.isCheckedIn,
    required this.canSubmit,
    required this.onTap,
  });

  final bool isLoading;
  final bool isCheckedIn;
  final bool canSubmit;
  final VoidCallback? onTap;

  @override
  State<_AttendanceButton> createState() => _AttendanceButtonState();
}

class _AttendanceButtonState extends State<_AttendanceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.isCheckedIn
        ? [AppColors.error, const Color(0xFFE57373)]
        : [AppColors.success, const Color(0xFF66BB6A)];

    final bool active = widget.canSubmit && !widget.isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.canSubmit ? 1.0 : 0.52,
      child: GestureDetector(
        onTapDown: active ? (_) => _ctrl.forward() : null,
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: active ? widget.onTap : null,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isCheckedIn
                              ? Icons.logout_rounded
                              : Icons.login_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.isCheckedIn ? 'Check Out' : 'Check In',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
