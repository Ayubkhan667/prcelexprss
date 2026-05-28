import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class FakeGpsService {
  static Future<FakeGpsResult> checkFakeGps(Position position) async {
    final checks = <String>[];
    var isMock = false;

    if (position.isMocked) {
      isMock = true;
      checks.add('Location reported as mocked by OS');
    }

    if (position.accuracy == 0.0) {
      isMock = true;
      checks.add('GPS accuracy is exactly 0.0 (suspicious)');
    }

    if (position.altitude == 0.0 && position.accuracy < 2.0) {
      checks.add('Zero altitude with perfect accuracy (possible fake GPS)');
    }

    if (position.speed > 50) {
      isMock = true;
      checks.add(
        'Unrealistic speed detected: ${position.speed.toStringAsFixed(1)} m/s',
      );
    }

    if (!kIsWeb) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final android = await deviceInfo.androidInfo;
            if (!android.isPhysicalDevice) {
              isMock = true;
              checks.add('Running on emulator/virtual device');
            }
            break;
          case TargetPlatform.iOS:
            final ios = await deviceInfo.iosInfo;
            if (!ios.isPhysicalDevice) {
              isMock = true;
              checks.add('Running on iOS Simulator');
            }
            break;
          case TargetPlatform.macOS:
          case TargetPlatform.windows:
          case TargetPlatform.linux:
          case TargetPlatform.fuchsia:
            break;
        }
      } catch (_) {}
    }

    return FakeGpsResult(
      isMockGps: isMock,
      reasons: checks,
      position: position,
    );
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static bool isInsideGeofence({
    required double staffLat,
    required double staffLon,
    required double branchLat,
    required double branchLon,
    required double allowedRadiusMeters,
  }) {
    final distance =
        calculateDistance(staffLat, staffLon, branchLat, branchLon);
    return distance <= allowedRadiusMeters;
  }
}

class FakeGpsResult {
  final bool isMockGps;
  final List<String> reasons;
  final Position position;

  const FakeGpsResult({
    required this.isMockGps,
    required this.reasons,
    required this.position,
  });
}
