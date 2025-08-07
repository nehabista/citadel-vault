import 'package:drift/drift.dart';

import 'vault_items_table.dart';

/// TotpEntries table - stores TOTP authenticator secrets linked to vault items.
class TotpEntries extends Table {
  /// UUID primary key
  TextColumn get id => text()();

  /// Foreign key to the parent vault item
  TextColumn get vaultItemId => text().references(VaultItems, #id)();

  /// TOTP secret encrypted with vault key
  BlobColumn get encryptedSecret => blob()();

  /// Number of digits in the TOTP code (default 6)
  IntColumn get digits => integer().withDefault(const Constant(6))();

  /// Time period in seconds (default 30)
  IntColumn get period => integer().withDefault(const Constant(30))();

  /// Hash algorithm: SHA1, SHA256, SHA512
  TextColumn get algorithm =>
      text().withDefault(const Constant('SHA1'))();

  @override
  Set<Column> get primaryKey => {id};
}
