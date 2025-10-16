import 'package:drift/drift.dart';

/// Local notification records for in-app notification center.
/// Named NotificationRecords to avoid conflicts with Flutter's Notification class.
class NotificationRecords extends Table {
  /// Unique notification ID
  TextColumn get id => text()();

  /// Notification type: breach_alert, emergency_request, emergency_approved,
  /// emergency_rejected, shared_item, expiry_reminder
  TextColumn get type => text()();

  /// Human-readable notification title
  TextColumn get title => text()();

  /// Human-readable notification body
  TextColumn get body => text()();

  /// Optional reference to a source record (shared item ID, breach ID, etc.)
  TextColumn get referenceId => text().nullable()();

  /// Whether the user has read this notification
  BoolColumn get read =>
      boolean().withDefault(const Constant(false))();

  /// When the notification was created
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
