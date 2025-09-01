import 'package:drift/drift.dart';

import 'vault_items_table.dart';

/// AutofillIndex table - maps domain/package hashes to vault items for autofill.
/// Per D-11: stores SHA-256 hashes of domains, not plaintext, to protect metadata.
class AutofillIndex extends Table {
  /// Auto-incrementing primary key
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to the vault item
  TextColumn get vaultItemId => text().references(VaultItems, #id)();

  /// SHA-256 hash of the domain (not plaintext per D-11)
  TextColumn get domainHash => text()();

  /// SHA-256 hash of Android package name (optional)
  TextColumn get packageHash => text().nullable()();
}
