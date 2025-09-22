import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_dao.g.dart';

/// Data access object for sync queue management.
/// Per D-19: tracks pending create/update/delete operations for PocketBase sync.
@DriftAccessor(tables: [SyncQueue])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  /// Add a new entry to the sync queue.
  Future<void> enqueue(String itemId, String entityTable, String operation) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        itemId: itemId,
        entityTable: entityTable,
        operation: operation,
        queuedAt: DateTime.now(),
      ),
    );
  }

  /// Get all pending (not completed) sync entries ordered by queue time.
  Future<List<SyncQueueData>> getPending() {
    return (select(syncQueue)
          ..where((t) => t.completed.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.queuedAt)]))
        .get();
  }

  /// Mark a sync queue entry as completed.
  Future<void> markCompleted(int queueId) {
    return (update(syncQueue)..where((t) => t.id.equals(queueId))).write(
      const SyncQueueCompanion(completed: Value(true)),
    );
  }

  /// Increment retry count and store the error message.
  Future<void> incrementRetry(int queueId, String error) async {
    final entry = await (select(syncQueue)..where((t) => t.id.equals(queueId)))
        .getSingle();
    await (update(syncQueue)..where((t) => t.id.equals(queueId))).write(
      SyncQueueCompanion(
        retryCount: Value(entry.retryCount + 1),
        lastError: Value(error),
      ),
    );
  }

  /// Reset retry counts on all failed entries so they can be retried.
  Future<void> resetRetries() {
    return (update(syncQueue)..where((t) => t.completed.equals(false))).write(
      const SyncQueueCompanion(
        retryCount: Value(0),
        lastError: Value(null),
      ),
    );
  }

  /// Remove all completed entries from the queue.
  Future<void> clearCompleted() {
    return (delete(syncQueue)..where((t) => t.completed.equals(true))).go();
  }
}
