// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationRecordsTable get notificationRecords =>
      attachedDatabase.notificationRecords;
  NotificationDaoManager get managers => NotificationDaoManager(this);
}

class NotificationDaoManager {
  final _$NotificationDaoMixin _db;
  NotificationDaoManager(this._db);
  $$NotificationRecordsTableTableManager get notificationRecords =>
      $$NotificationRecordsTableTableManager(
        _db.attachedDatabase,
        _db.notificationRecords,
      );
}
