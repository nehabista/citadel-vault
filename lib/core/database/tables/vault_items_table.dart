import 'package:drift/drift.dart';

import 'vaults_table.dart';

/// VaultItems table - stores encrypted credential entries.
/// Per D-05: each item stores ALL fields as an AES-256-GCM encrypted JSON blob,
/// allowing flexible custom fields without schema changes.
class VaultItems extends Table {
  /// UUID primary key
  TextColumn get id => text()();

  /// Foreign key to the parent vault
  TextColumn get vaultId => text().references(Vaults, #id)();

  /// The AES-256-GCM encrypted JSON blob containing ALL fields:
  /// name, url, type, favorite, notes, username, password, custom fields
  BlobColumn get encryptedData => blob()();

  /// Encryption format version: 1=v1 (PBKDF2+AES-CBC), 2=v2 (Argon2id+AES-256-GCM)
  IntColumn get encryptionVersion =>
      integer().withDefault(const Constant(2))();

  /// When the item was created
  DateTimeColumn get createdAt => dateTime()();

  /// When the item was last updated
  DateTimeColumn get updatedAt => dateTime()();

  /// PocketBase record ID for sync
  TextColumn get remoteId => text().nullable()();

  /// Soft delete flag per D-17 tombstone strategy
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
