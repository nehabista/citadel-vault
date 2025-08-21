import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/password_history_table.dart';

part 'password_history_dao.g.dart';

/// Data access object for password history tracking.
///
/// Per D-14: stores encrypted previous passwords for each vault item,
/// enabling users to view and recover old passwords.
@DriftAccessor(tables: [PasswordHistory])
class PasswordHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$PasswordHistoryDaoMixin {
  PasswordHistoryDao(super.db);

  /// Insert a new password history entry.
  Future<void> insert(
    String vaultItemId,
    Uint8List encryptedPassword,
    DateTime changedAt,
  ) {
    return into(passwordHistory).insert(
      PasswordHistoryCompanion.insert(
        vaultItemId: vaultItemId,
        encryptedPassword: encryptedPassword,
        changedAt: changedAt,
      ),
    );
  }

  /// Get all password history entries for a vault item,
  /// ordered by changedAt descending (most recent first).
  Future<List<PasswordHistoryData>> getByItem(String vaultItemId) {
    return (select(passwordHistory)
          ..where((t) => t.vaultItemId.equals(vaultItemId))
          ..orderBy([(t) => OrderingTerm.desc(t.changedAt)]))
        .get();
  }

  /// Prune password history for an item, keeping only the most recent
  /// [keepCount] entries (default: 25). Deletes older entries.
  Future<void> prune(String vaultItemId, {int keepCount = 25}) async {
    // Get all entries ordered by most recent first.
    final entries = await getByItem(vaultItemId);
    if (entries.length <= keepCount) return;

    // Delete entries beyond the keep count.
    final toDelete = entries.sublist(keepCount);
    for (final entry in toDelete) {
      await (delete(passwordHistory)..where((t) => t.id.equals(entry.id))).go();
    }
  }
}
