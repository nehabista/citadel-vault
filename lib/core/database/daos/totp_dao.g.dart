// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_dao.dart';

// ignore_for_file: type=lint
mixin _$TotpDaoMixin on DatabaseAccessor<AppDatabase> {
  $VaultsTable get vaults => attachedDatabase.vaults;
  $VaultItemsTable get vaultItems => attachedDatabase.vaultItems;
  $TotpEntriesTable get totpEntries => attachedDatabase.totpEntries;
  TotpDaoManager get managers => TotpDaoManager(this);
}

class TotpDaoManager {
  final _$TotpDaoMixin _db;
  TotpDaoManager(this._db);
  $$VaultsTableTableManager get vaults =>
      $$VaultsTableTableManager(_db.attachedDatabase, _db.vaults);
  $$VaultItemsTableTableManager get vaultItems =>
      $$VaultItemsTableTableManager(_db.attachedDatabase, _db.vaultItems);
  $$TotpEntriesTableTableManager get totpEntries =>
      $$TotpEntriesTableTableManager(_db.attachedDatabase, _db.totpEntries);
}
