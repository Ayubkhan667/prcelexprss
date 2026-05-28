import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceBindingService {
  static const String _keyBoundDeviceId = 'bound_device_id';
  static const String _keyBoundUserId = 'bound_user_id';
  static const String _keyGeneratedDeviceId = 'generated_device_id';

  static Future<String> getDeviceId() async {
    final info = DeviceInfoPlugin();
    final prefs = await SharedPreferences.getInstance();

    try {
      if (kIsWeb) {
        final browser = await info.webBrowserInfo;
        final parts = [
          browser.browserName.name,
          browser.platform ?? '',
          browser.vendor ?? '',
          browser.userAgent ?? '',
          '${browser.hardwareConcurrency ?? 0}',
        ].where((value) => value.trim().isNotEmpty).join('|');

        if (parts.isNotEmpty) {
          return 'web-${parts.hashCode}';
        }
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final android = await info.androidInfo;
          return android.id;
        case TargetPlatform.iOS:
          final ios = await info.iosInfo;
          return ios.identifierForVendor ?? 'unknown_ios';
        case TargetPlatform.macOS:
          final mac = await info.macOsInfo;
          return mac.systemGUID ?? 'unknown_macos';
        case TargetPlatform.windows:
          final windows = await info.windowsInfo;
          return windows.deviceId;
        case TargetPlatform.linux:
          final linux = await info.linuxInfo;
          return linux.machineId ?? 'unknown_linux';
        case TargetPlatform.fuchsia:
          break;
      }
    } catch (_) {}

    final cached = prefs.getString(_keyGeneratedDeviceId);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final generated = 'device-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_keyGeneratedDeviceId, generated);
    return generated;
  }

  static Future<DeviceBindingResult> checkBinding(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDeviceId = await getDeviceId();
    final boundDeviceId = prefs.getString(_keyBoundDeviceId);
    final boundUserId = prefs.getString(_keyBoundUserId);

    if (boundDeviceId == null) {
      await prefs.setString(_keyBoundDeviceId, currentDeviceId);
      await prefs.setString(_keyBoundUserId, userId);
      return DeviceBindingResult(
        isAllowed: true,
        deviceId: currentDeviceId,
        message: 'Device registered successfully.',
        isNewBinding: true,
      );
    }

    if (boundUserId != userId) {
      return DeviceBindingResult(
        isAllowed: false,
        deviceId: currentDeviceId,
        message:
            'This device is already bound to another account. Please use your registered device.',
        isNewBinding: false,
      );
    }

    if (boundDeviceId != currentDeviceId) {
      return DeviceBindingResult(
        isAllowed: false,
        deviceId: currentDeviceId,
        message:
            'Your account is bound to a different device. Contact admin to reset device binding.',
        isNewBinding: false,
      );
    }

    return DeviceBindingResult(
      isAllowed: true,
      deviceId: currentDeviceId,
      message: 'Device verified.',
      isNewBinding: false,
    );
  }

  static Future<void> clearBinding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBoundDeviceId);
    await prefs.remove(_keyBoundUserId);
  }

  static Future<bool> isBound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBoundDeviceId) != null;
  }
}

class DeviceBindingResult {
  final bool isAllowed;
  final String deviceId;
  final String message;
  final bool isNewBinding;

  const DeviceBindingResult({
    required this.isAllowed,
    required this.deviceId,
    required this.message,
    required this.isNewBinding,
  });
}
