import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'smart_hr_channel',
    String channelName = 'Smart HR Notifications',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    await init();
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> showCheckInSuccess(String staffName, String time) async {
    await showNotification(
      id: 1001,
      title: 'Check-In Successful',
      body: '$staffName checked in at $time',
    );
  }

  Future<void> showCheckOutSuccess(String staffName, String time) async {
    await showNotification(
      id: 1002,
      title: 'Check-Out Successful',
      body: '$staffName checked out at $time',
    );
  }

  Future<void> showLateAlert(String staffName, int lateMinutes) async {
    await showNotification(
      id: 1003,
      title: 'Late Check-In Alert',
      body: '$staffName is $lateMinutes minutes late',
      channelId: 'smart_hr_alerts',
      channelName: 'HR Alerts',
    );
  }

  Future<void> showMissingCheckout(String staffName) async {
    await showNotification(
      id: 1004,
      title: 'Missing Check-Out',
      body: '$staffName has not checked out yet. Please check out if shift is over.',
      channelId: 'smart_hr_alerts',
      channelName: 'HR Alerts',
    );
  }

  Future<void> showLeaveStatusNotification(
      String staffName, String status, String leaveType) async {
    await showNotification(
      id: 1005,
      title: 'Leave $status',
      body: 'Your $leaveType request has been $status',
    );
  }

  Future<void> showOvertimeApproval(String staffName, double hours) async {
    await showNotification(
      id: 1006,
      title: 'Overtime Approved',
      body:
          '${hours.toStringAsFixed(1)} hours overtime approved for $staffName',
    );
  }

  Future<void> showSalaryGenerated(String staffName, String month) async {
    await showNotification(
      id: 1007,
      title: 'Salary Generated',
      body: 'Salary for $month has been processed for $staffName',
    );
  }

  Future<void> showLoanDeduction(
      String staffName, double amount, double balance) async {
    await showNotification(
      id: 1008,
      title: 'Loan Deduction Applied',
      body:
          'OMR ${amount.toStringAsFixed(3)} deducted. Remaining balance: OMR ${balance.toStringAsFixed(3)}',
    );
  }

  Future<void> showLocationAlert(String staffName) async {
    await showNotification(
      id: 1009,
      title: 'Outside Work Location',
      body:
          '$staffName: You are outside your assigned work location. Please check out if your shift is finished.',
      channelId: 'smart_hr_alerts',
      channelName: 'HR Alerts',
    );
  }

  Future<void> showFakeGpsAlert(String staffName) async {
    await showNotification(
      id: 1010,
      title: 'Fake GPS Detected',
      body:
          'Admin Alert: Suspicious GPS activity detected for $staffName. Please investigate.',
      channelId: 'smart_hr_alerts',
      channelName: 'HR Alerts',
      importance: Importance.max,
      priority: Priority.max,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
