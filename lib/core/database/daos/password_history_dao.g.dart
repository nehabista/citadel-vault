// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_history_dao.dart';

// ignore_for_file: type=lint
mixin _$PasswordHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $VaultsTable get vaults => attachedDatabase.vaults;
  $VaultItemsTable get vaultItems => attachedDatabase.vaultItems;
  $PasswordHistoryTable get passwordHistory => attachedDatabase.passwordHistory;
  PasswordHistoryDaoManager get managers => PasswordHistoryDaoManager(this);
}

class PasswordHistoryDaoManager {
  final _$PasswordHistoryDaoMixin _db;
  PasswordHistoryDaoManager(this._db);
  $$VaultsTableTableManager get vaults =>
      $$VaultsTableTableManager(_db.attachedDatabase, _db.vaults);
  $$VaultItemsTableTableManager get vaultItems =>
      $$VaultItemsTableTableManager(_db.attachedDatabase, _db.vaultItems);
  $$PasswordHistoryTableTableManager get passwordHistory =>
      $$PasswordHistoryTableTableManager(
        _db.attachedDatabase,
        _db.passwordHistory,
      );
}
