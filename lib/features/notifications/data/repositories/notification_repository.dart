// File: lib/features/notifications/data/repositories/notification_repository.dart
// Repository for notification settings and in-memory notification records.
// Uses SettingsDao for persistent per-type enable/disable preferences.

import 'dart:async';

import '../../../../core/database/daos/settings_dao.dart';

/// Represents a recorded notification for in-app display.
class NotificationRecord {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? referenceId;
  final DateTime createdAt;
  bool isRead;

  NotificationRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    required this.createdAt,
    this.isRead = false,
  });
}

/// Repository managing notification preferences and in-app notification records.
///
/// Settings persistence uses [SettingsDao] (encrypted Drift database).
/// Notification records are held in-memory with a broadcast stream for
/// real-time UI updates. A future plan can add a NotificationDao for
/// persistent notification history if needed.
class NotificationRepository {
  NotificationRepository({
    required SettingsDao settingsDao,
  }) : _settingsDao = settingsDao;

  final SettingsDao _settingsDao;

  /// Notification type constants.
  static const breachAlert = 'breach_alert';
  static const expiryReminder = 'expiry_reminder';
  static const sharedItem = 'shared_item';
  static const emergencyRequest = 'emergency_request';
  static const emergencyApproved = 'emergency_approved';
  static const emergencyRejected = 'emergency_rejected';

  /// In-memory notification records.
  final List<NotificationRecord> _records = [];
  final StreamController<List<NotificationRecord>> _unreadController =
      StreamController<List<NotificationRecord>>.broadcast();

  // ─── Settings ────────────────────────────────────────────────────

  /// Check if a notification type is enabled (defaults to true).
  Future<bool> isEnabled(String notificationType) async {
    final value = await _settingsDao.getSetting('notif_${notificationType}_enabled');
    if (value == null) return true; // enabled by default
    return value == 'true';
  }

  /// Set whether a notification type is enabled.
  Future<void> setEnabled(String notificationType, bool enabled) async {
    await _settingsDao.setSetting(
      'notif_${notificationType}_enabled',
      enabled.toString(),
    );
  }

  // ─── Notification Records ────────────────────────────────────────

  /// Watch unread notifications as a stream.
  Stream<List<NotificationRecord>> watchUnread() {
    // Emit current state immediately then updates.
    _emitUnread();
    return _unreadController.stream;
  }

  /// Record a new notification.
  Future<void> recordNotification({
    required String type,
    required String title,
    required String body,
    String? referenceId,
  }) async {
    final record = NotificationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toRadixString(16),
      type: type,
      title: title,
      body: body,
      referenceId: referenceId,
      createdAt: DateTime.now(),
    );
    _records.insert(0, record);
    _emitUnread();
  }

  /// Mark a single notification as read.
  Future<void> markRead(String id) async {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _records[idx].isRead = true;
      _emitUnread();
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllRead() async {
    for (final r in _records) {
      r.isRead = true;
    }
    _emitUnread();
  }

  /// Count of unread notifications.
  Future<int> unreadCount() async {
    return _records.where((r) => !r.isRead).length;
  }

  void _emitUnread() {
    if (!_unreadController.isClosed) {
      _unreadController.add(
        _records.where((r) => !r.isRead).toList(),
      );
    }
  }

  /// Dispose resources.
  void dispose() {
    _unreadController.close();
  }
}
