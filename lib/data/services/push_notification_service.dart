import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repositories/hr_operations_repository.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    return;
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  bool _initialized = false;
  bool _available = false;
  String? _lastRegisteredToken;

  bool get isAvailable => _available;

  Future<void> init() async {
    if (_initialized || !_supportsPush()) {
      return;
    }
    _initialized = true;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((message) async {
        final notification = message.notification;
        if (notification == null) {
          return;
        }
        await NotificationService().showNotification(
          id: message.hashCode,
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
        );
      });

      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  Future<void> syncRegistration(HrOperationsRepository repository) async {
    await init();
    if (!_available || !_supportsPush()) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty || token == _lastRegisteredToken) {
      return;
    }

    await repository.registerPushToken(
      token: token,
      platform: defaultTargetPlatform.name,
    );
    _lastRegisteredToken = token;
  }

  Future<void> clearRegistration(HrOperationsRepository repository) async {
    if (!_available) {
      return;
    }

    try {
      await repository.deletePushToken(token: _lastRegisteredToken);
      _lastRegisteredToken = null;
    } catch (_) {
      // Keep logout flow resilient if remote token cleanup fails.
    }
  }

  bool _supportsPush() {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}
