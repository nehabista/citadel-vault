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

  /// Hex color code for vault display (default: brand purple)
  TextColumn get colorHex =>
      text().withDefault(const Constant('#4D4DCD'))();

  /// Icon name for vault display (default: shield)
  TextColumn get iconName =>
      text().withDefault(const Constant('shield'))();

  /// Whether this vault is visible in travel mode. Default: true (visible).
  /// Per D-01: stored encrypted in metadata blob as source of truth.
  /// This plaintext column is a mirror for query filtering per D-04.
  BoolColumn get isTravelSafe =>
      boolean().withDefault(const Constant(true))();

  /// Whether this vault is currently hidden by an active travel mode session.
  /// When true, the vault is soft-hidden from normal queries but NOT deleted.
  /// Flipped back to false when travel mode is deactivated.
  BoolColumn get isHiddenByTravel =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
