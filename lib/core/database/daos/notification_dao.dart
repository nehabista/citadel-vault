import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/notifications_table.dart';

part 'notification_dao.g.dart';

/// Data access object for the local notification records table.
@DriftAccessor(tables: [NotificationRecords])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  /// Watch unread notifications (reactive stream), newest first.
  Stream<List<NotificationRecord>> watchUnread() {
    return (select(notificationRecords)
          ..where((t) => t.read.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Get all notifications, newest first.
  Future<List<NotificationRecord>> getAll() {
    return (select(notificationRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Insert a new notification.
  Future<void> insertNotification(NotificationRecordsCompanion notif) {
    return into(notificationRecords).insert(notif);
  }

  /// Mark a single notification as read.
  Future<void> markRead(String id) {
    return (update(notificationRecords)..where((t) => t.id.equals(id)))
        .write(const NotificationRecordsCompanion(read: Value(true)));
  }

  /// Mark all notifications as read.
  Future<void> markAllRead() {
    return update(notificationRecords).write(
      const NotificationRecordsCompanion(read: Value(true)),
    );
  }

  /// Get the count of unread notifications.
  Future<int> unreadCount() async {
    final count = countAll();
    final query = selectOnly(notificationRecords)
      ..where(notificationRecords.read.equals(false))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
