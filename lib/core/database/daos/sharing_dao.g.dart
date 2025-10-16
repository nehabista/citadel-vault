// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_dao.dart';

// ignore_for_file: type=lint
mixin _$SharingDaoMixin on DatabaseAccessor<AppDatabase> {
  $SharedItemsTable get sharedItems => attachedDatabase.sharedItems;
  $VaultMembersTable get vaultMembers => attachedDatabase.vaultMembers;
  $EmergencyContactsTable get emergencyContacts =>
      attachedDatabase.emergencyContacts;
  SharingDaoManager get managers => SharingDaoManager(this);
}

class SharingDaoManager {
  final _$SharingDaoMixin _db;
  SharingDaoManager(this._db);
  $$SharedItemsTableTableManager get sharedItems =>
      $$SharedItemsTableTableManager(_db.attachedDatabase, _db.sharedItems);
  $$VaultMembersTableTableManager get vaultMembers =>
      $$VaultMembersTableTableManager(_db.attachedDatabase, _db.vaultMembers);
  $$EmergencyContactsTableTableManager get emergencyContacts =>
      $$EmergencyContactsTableTableManager(
        _db.attachedDatabase,
        _db.emergencyContacts,
      );
}
