import 'package:drift/drift.dart';

import 'vault_items_table.dart';

/// PasswordHistory table - tracks previous passwords for vault items.
class PasswordHistory extends Table {
  /// Auto-incrementing primary key
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to the vault item
  TextColumn get vaultItemId => text().references(VaultItems, #id)();

  /// Previous password encrypted with vault key
  BlobColumn get encryptedPassword => blob()();

  /// When the password was changed
  DateTimeColumn get changedAt => dateTime()();
}
