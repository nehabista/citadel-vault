// File: lib/features/notifications/data/services/notification_service.dart
// Local notification service using flutter_local_notifications only.
// Per D-13: No external push service imports. All triggers are local/client-side.

import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Notification channel IDs for Android.
class NotificationChannels {
  static const breachAlerts = 'breach_alerts';
  static const expiryReminders = 'expiry_reminders';
  static const sharing = 'sharing';
  static const emergencyAccess = 'emergency_access';
}

/// Service that wraps [FlutterLocalNotificationsPlugin] for showing
/// and scheduling local notifications across breach alerts, expiry
/// reminders, sharing events, and emergency access.
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Stream of notification tap payloads for navigation handling.
  final StreamController<String?> _tapController =
      StreamController<String?>.broadcast();

  /// Listen to notification taps (payload contains navigation info).
  Stream<String?> get onNotificationTap => _tapController.stream;

  /// Android notification channel definitions.
  static const List<AndroidNotificationChannel> _channels = [
    AndroidNotificationChannel(
      NotificationChannels.breachAlerts,
      'Breach Alerts',
      description: 'Alerts when passwords appear in data breaches',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      NotificationChannels.expiryReminders,
      'Expiry Reminders',
      description: 'Reminders when passwords are due for rotation',
      importance: Importance.defaultImportance,
    ),
    AndroidNotificationChannel(
      NotificationChannels.sharing,
      'Sharing',
      description: 'Notifications for shared items and vault invitations',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      NotificationChannels.emergencyAccess,
      'Emergency Access',
      description: 'Emergency access requests and approvals',
      importance: Importance.max,
    ),
  ];

  /// Initialize the notification plugin and create Android channels.
  Future<void> initialize() async {
    // Initialize timezone data for scheduled notifications.
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: macos,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channels.
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      for (final channel in _channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    _tapController.add(response.payload);
  }

  /// Show a breach alert notification.
  Future<void> showBreachAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      title.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.breachAlerts,
          'Breach Alerts',
          channelDescription: 'Alerts when passwords appear in data breaches',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Show an expiry reminder notification.
  Future<void> showExpiryReminder({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      title.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.expiryReminders,
          'Expiry Reminders',
          channelDescription: 'Reminders when passwords are due for rotation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Show a sharing notification.
  Future<void> showSharingNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      title.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.sharing,
          'Sharing',
          channelDescription:
              'Notifications for shared items and vault invitations',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Show an emergency access notification.
  Future<void> showEmergencyNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      title.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.emergencyAccess,
          'Emergency Access',
          channelDescription: 'Emergency access requests and approvals',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Schedule an expiry check notification for a future date.
  Future<void> scheduleExpiryCheck({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.expiryReminders,
          'Expiry Reminders',
          channelDescription: 'Reminders when passwords are due for rotation',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// Cancel all pending notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Dispose resources.
  void dispose() {
    _tapController.close();
  }
}
