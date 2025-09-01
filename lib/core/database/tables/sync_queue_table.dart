import 'package:drift/drift.dart';

/// SyncQueue table - tracks pending changes for PocketBase sync.
/// Per D-19: tracks create/update/delete operations with retry count and error state.
class SyncQueue extends Table {
  /// Auto-incrementing primary key
  IntColumn get id => integer().autoIncrement()();

  /// ID of the item that changed
  TextColumn get itemId => text()();

  /// Which table the item belongs to (vault_items, vaults, etc.)
  TextColumn get entityTable => text()();

  /// Operation type: 'create', 'update', 'delete'
  TextColumn get operation => text()();

  /// When the change was queued
  DateTimeColumn get queuedAt => dateTime()();

  /// Number of sync retry attempts
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Last error message from sync attempt
  TextColumn get lastError => text().nullable()();

  /// Whether this queue entry has been synced
  BoolColumn get completed =>
      boolean().withDefault(const Constant(false))();
}
