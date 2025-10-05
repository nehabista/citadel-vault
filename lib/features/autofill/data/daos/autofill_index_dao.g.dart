// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autofill_index_dao.dart';

// ignore_for_file: type=lint
mixin _$AutofillIndexDaoMixin on DatabaseAccessor<AppDatabase> {
  $VaultsTable get vaults => attachedDatabase.vaults;
  $VaultItemsTable get vaultItems => attachedDatabase.vaultItems;
  $AutofillIndexTable get autofillIndex => attachedDatabase.autofillIndex;
  AutofillIndexDaoManager get managers => AutofillIndexDaoManager(this);
}

class AutofillIndexDaoManager {
  final _$AutofillIndexDaoMixin _db;
  AutofillIndexDaoManager(this._db);
  $$VaultsTableTableManager get vaults =>
      $$VaultsTableTableManager(_db.attachedDatabase, _db.vaults);
  $$VaultItemsTableTableManager get vaultItems =>
      $$VaultItemsTableTableManager(_db.attachedDatabase, _db.vaultItems);
  $$AutofillIndexTableTableManager get autofillIndex =>
      $$AutofillIndexTableTableManager(_db.attachedDatabase, _db.autofillIndex);
}
