import 'package:drift/drift.dart';

/// Vaults table - represents a collection/folder of vault items.
/// Each user can have multiple vaults (personal, work, shared family).
class Vaults extends Table {
  /// UUID primary key
  TextColumn get id => text()();

  /// Encrypted vault name
  TextColumn get name => text()();

  /// Encrypted description (optional)
  TextColumn get description => text().nullable()();

  /// Display sort order
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When the vault was created
  DateTimeColumn get createdAt => dateTime()();

  /// When the vault was last updated
  DateTimeColumn get updatedAt => dateTime()();

  /// PocketBase record ID for sync
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
