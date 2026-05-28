import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/branch_model.dart';
import 'fake_gps_service.dart';

class AttendanceLocationResult {
  final bool serviceEnabled;
  final bool permissionGranted;
  final bool openAppSettingsSuggested;
  final bool openLocationSettingsSuggested;
  final bool isInsideGeofence;
  final bool isMockGps;
  final double? distanceMeters;
  final Position? position;
  final List<String> warnings;
  final String message;

  const AttendanceLocationResult({
    required this.serviceEnabled,
    required this.permissionGranted,
    required this.openAppSettingsSuggested,
    required this.openLocationSettingsSuggested,
    required this.isInsideGeofence,
    required this.isMockGps,
    required this.distanceMeters,
    required this.position,
    required this.warnings,
    required this.message,
  });

  bool get canProceed =>
      serviceEnabled &&
      permissionGranted &&
      position != null &&
      isInsideGeofence &&
      !isMockGps;
}

class AttendanceWifiResult {
  final bool isConnectedToWifi;
  final bool isMatchingBranchWifi;
  final String? currentWifiSsid;
  final String? requiredWifiSsid;
  final List<String> warnings;
  final String message;

  const AttendanceWifiResult({
    required this.isConnectedToWifi,
    required this.isMatchingBranchWifi,
    required this.currentWifiSsid,
    required this.requiredWifiSsid,
    required this.warnings,
    required this.message,
  });

  bool get canProceed =>
      isConnectedToWifi &&
      isMatchingBranchWifi &&
      currentWifiSsid != null &&
      requiredWifiSsid != null;
}

class AttendanceAccessResult {
  final AttendanceLocationResult location;
  final AttendanceWifiResult wifi;

  const AttendanceAccessResult({
    required this.location,
    required this.wifi,
  });

  bool get canProceed => location.canProceed && wifi.canProceed;

  List<String> get warnings => [
        ...location.warnings,
        ...wifi.warnings,
      ];

  String get message {
    if (!location.canProceed && !wifi.canProceed) {
      return '${location.message} ${wifi.message}'.trim();
    }
    if (!location.canProceed) {
      return location.message;
    }
    if (!wifi.canProceed) {
      return wifi.message;
    }
    return 'Location and office Wi-Fi verified.';
  }
}

class AttendanceSelfieResult {
  final XFile? file;
  final bool openAppSettingsSuggested;
  final String message;

  const AttendanceSelfieResult({
    required this.file,
    required this.openAppSettingsSuggested,
    required this.message,
  });

  bool get isSuccess => file != null;
}

class AttendanceCaptureService {
  AttendanceCaptureService({
    ImagePicker? imagePicker,
    Connectivity? connectivity,
    NetworkInfo? networkInfo,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _connectivity = connectivity ?? Connectivity(),
        _networkInfo = networkInfo ?? NetworkInfo();

  final ImagePicker _imagePicker;
  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;

  Future<AttendanceAccessResult> verifyAttendanceAccess({
    required BranchModel branch,
    String? manualWifiSsid,
  }) async {
    final location = await verifyLocation(branch: branch);
    final wifi = await verifyWifi(
      branch: branch,
      manualWifiSsid: manualWifiSsid,
    );

    return AttendanceAccessResult(
      location: location,
      wifi: wifi,
    );
  }

  Future<AttendanceLocationResult> verifyLocation({
    required BranchModel branch,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const AttendanceLocationResult(
        serviceEnabled: false,
        permissionGranted: false,
        openAppSettingsSuggested: false,
        openLocationSettingsSuggested: true,
        isInsideGeofence: false,
        isMockGps: false,
        distanceMeters: null,
        position: null,
        warnings: [],
        message: 'Location services are disabled. Enable GPS to continue.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const AttendanceLocationResult(
        serviceEnabled: true,
        permissionGranted: false,
        openAppSettingsSuggested: false,
        openLocationSettingsSuggested: false,
        isInsideGeofence: false,
        isMockGps: false,
        distanceMeters: null,
        position: null,
        warnings: [],
        message: 'Location permission was denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const AttendanceLocationResult(
        serviceEnabled: true,
        permissionGranted: false,
        openAppSettingsSuggested: true,
        openLocationSettingsSuggested: false,
        isInsideGeofence: false,
        isMockGps: false,
        distanceMeters: null,
        position: null,
        warnings: [],
        message:
            'Location permission is permanently denied. Enable it from app settings.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final fakeGpsResult = await FakeGpsService.checkFakeGps(position);
      final distance = FakeGpsService.calculateDistance(
        position.latitude,
        position.longitude,
        branch.latitude,
        branch.longitude,
      );
      final isInsideGeofence = distance <= branch.allowedRadius;
      final warnings = <String>[
        if (!isInsideGeofence)
          'You are ${distance.toStringAsFixed(0)}m away from ${branch.branchName}.',
        ...fakeGpsResult.reasons,
      ];

      final message = fakeGpsResult.isMockGps
          ? 'Suspicious GPS signal detected. Please turn off mock location tools.'
          : isInsideGeofence
              ? 'Inside ${branch.branchName} geofence (${distance.toStringAsFixed(0)}m away).'
              : 'Outside assigned range for ${branch.branchName}. Check In/Out is blocked; use Visit or Break.';

      return AttendanceLocationResult(
        serviceEnabled: true,
        permissionGranted: true,
        openAppSettingsSuggested: false,
        openLocationSettingsSuggested: false,
        isInsideGeofence: isInsideGeofence,
        isMockGps: fakeGpsResult.isMockGps,
        distanceMeters: distance,
        position: position,
        warnings: warnings,
        message: message,
      );
    } catch (_) {
      return const AttendanceLocationResult(
        serviceEnabled: true,
        permissionGranted: true,
        openAppSettingsSuggested: false,
        openLocationSettingsSuggested: false,
        isInsideGeofence: false,
        isMockGps: false,
        distanceMeters: null,
        position: null,
        warnings: [],
        message: 'Unable to fetch your current location. Please try again.',
      );
    }
  }

  Future<AttendanceWifiResult> verifyWifi({
    required BranchModel branch,
    String? manualWifiSsid,
  }) async {
    final requiredWifi = _normalizeWifiSsid(branch.wifiSsid);
    if (requiredWifi == null) {
      return AttendanceWifiResult(
        isConnectedToWifi: false,
        isMatchingBranchWifi: false,
        currentWifiSsid: null,
        requiredWifiSsid: null,
        warnings: const [],
        message: 'Office Wi-Fi is not configured for ${branch.branchName}.',
      );
    }

    try {
      final enteredWifi = _normalizeWifiSsid(manualWifiSsid);
      final canUseManualOverride = kIsWeb || !kReleaseMode;

      if (kIsWeb) {
        if (enteredWifi == null) {
          return AttendanceWifiResult(
            isConnectedToWifi: false,
            isMatchingBranchWifi: false,
            currentWifiSsid: null,
            requiredWifiSsid: requiredWifi,
            warnings: const [
              'Browsers cannot auto-detect Wi-Fi SSID. Enter the office Wi-Fi name to continue.',
            ],
            message:
                'Enter office Wi-Fi SSID manually. Browser cannot auto-detect it.',
          );
        }

        final isMatching =
            enteredWifi.toLowerCase() == requiredWifi.toLowerCase();
        return AttendanceWifiResult(
          isConnectedToWifi: true,
          isMatchingBranchWifi: isMatching,
          currentWifiSsid: enteredWifi,
          requiredWifiSsid: requiredWifi,
          warnings: isMatching
              ? const []
              : ['Entered Wi-Fi $enteredWifi does not match $requiredWifi.'],
          message: isMatching
              ? 'Office Wi-Fi matched through manual web entry.'
              : 'Entered Wi-Fi does not match $requiredWifi.',
        );
      }

      final connectivity = await _connectivity.checkConnectivity();
      final isConnectedToWifi = connectivity.contains(ConnectivityResult.wifi);

      if (!isConnectedToWifi) {
        return AttendanceWifiResult(
          isConnectedToWifi: false,
          isMatchingBranchWifi: false,
          currentWifiSsid: null,
          requiredWifiSsid: requiredWifi,
          warnings: const ['Connect to office Wi-Fi to continue.'],
          message: 'Connect to $requiredWifi to continue.',
        );
      }

      final currentWifi = _normalizeWifiSsid(await _networkInfo.getWifiName());
      if (currentWifi == null) {
        if (canUseManualOverride && enteredWifi != null) {
          final isMatching =
              enteredWifi.toLowerCase() == requiredWifi.toLowerCase();
          return AttendanceWifiResult(
            isConnectedToWifi: true,
            isMatchingBranchWifi: isMatching,
            currentWifiSsid: enteredWifi,
            requiredWifiSsid: requiredWifi,
            warnings: isMatching
                ? const [
                    'Manual Wi-Fi verification is active for this debug build.',
                  ]
                : ['Entered Wi-Fi $enteredWifi does not match $requiredWifi.'],
            message: isMatching
                ? 'Office Wi-Fi matched through manual debug entry.'
                : 'Entered Wi-Fi does not match $requiredWifi.',
          );
        }

        return AttendanceWifiResult(
          isConnectedToWifi: true,
          isMatchingBranchWifi: false,
          currentWifiSsid: null,
          requiredWifiSsid: requiredWifi,
          warnings: const [
            'Unable to read Wi-Fi name. Keep location enabled and reconnect to Wi-Fi.',
          ],
          message:
              'Unable to verify office Wi-Fi. Keep location enabled and reconnect to Wi-Fi.',
        );
      }

      final isMatching =
          currentWifi.toLowerCase() == requiredWifi.toLowerCase();

      if (!isMatching && canUseManualOverride && enteredWifi != null) {
        final manualMatches =
            enteredWifi.toLowerCase() == requiredWifi.toLowerCase();
        if (manualMatches) {
          return AttendanceWifiResult(
            isConnectedToWifi: true,
            isMatchingBranchWifi: true,
            currentWifiSsid: enteredWifi,
            requiredWifiSsid: requiredWifi,
            warnings: const [
              'Manual Wi-Fi verification is active for this debug build.',
            ],
            message: 'Office Wi-Fi matched through manual debug entry.',
          );
        }
      }

      return AttendanceWifiResult(
        isConnectedToWifi: true,
        isMatchingBranchWifi: isMatching,
        currentWifiSsid: currentWifi,
        requiredWifiSsid: requiredWifi,
        warnings: isMatching
            ? const []
            : ['Connected to $currentWifi instead of $requiredWifi.'],
        message: isMatching
            ? 'Connected to $requiredWifi.'
            : 'Connected to $currentWifi. Switch to $requiredWifi.',
      );
    } catch (_) {
      return AttendanceWifiResult(
        isConnectedToWifi: false,
        isMatchingBranchWifi: false,
        currentWifiSsid: null,
        requiredWifiSsid: requiredWifi,
        warnings: const ['Unable to verify Wi-Fi connection right now.'],
        message: 'Unable to verify Wi-Fi connection right now.',
      );
    }
  }

  Future<AttendanceSelfieResult> captureSelfie() async {
    if (kIsWeb) {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 75,
        maxWidth: 1080,
      );

      if (file == null) {
        return const AttendanceSelfieResult(
          file: null,
          openAppSettingsSuggested: false,
          message: 'Selfie capture was cancelled.',
        );
      }

      return AttendanceSelfieResult(
        file: file,
        openAppSettingsSuggested: false,
        message: 'Selfie captured successfully.',
      );
    }

    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied || status.isRestricted) {
      return const AttendanceSelfieResult(
        file: null,
        openAppSettingsSuggested: true,
        message:
            'Camera permission is blocked. Enable it from app settings to capture a selfie.',
      );
    }

    if (!status.isGranted) {
      return const AttendanceSelfieResult(
        file: null,
        openAppSettingsSuggested: false,
        message: 'Camera permission is required to capture attendance selfie.',
      );
    }

    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 75,
      maxWidth: 1080,
    );

    if (file == null) {
      return const AttendanceSelfieResult(
        file: null,
        openAppSettingsSuggested: false,
        message: 'Selfie capture was cancelled.',
      );
    }

    return AttendanceSelfieResult(
      file: file,
      openAppSettingsSuggested: false,
      message: 'Selfie captured successfully.',
    );
  }

  Future<XFile?> retrieveLostSelfie() async {
    final response = await _imagePicker.retrieveLostData();
    if (response.isEmpty) {
      return null;
    }

    if (response.files != null && response.files!.isNotEmpty) {
      return response.files!.first;
    }

    return null;
  }

  String? _normalizeWifiSsid(String? value) {
    if (value == null) {
      return null;
    }

    var normalized = value.trim();
    if (normalized.isEmpty || normalized.toLowerCase() == '<unknown ssid>') {
      return null;
    }

    final hasWrappedDoubleQuotes =
        normalized.startsWith('"') && normalized.endsWith('"');
    final hasWrappedSingleQuotes =
        normalized.startsWith("'") && normalized.endsWith("'");

    if (normalized.length >= 2 &&
        (hasWrappedDoubleQuotes || hasWrappedSingleQuotes)) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }

    return normalized.isEmpty ? null : normalized;
  }
}
