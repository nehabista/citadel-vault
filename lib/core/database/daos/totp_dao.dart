import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/totp_entries_table.dart';

part 'totp_dao.g.dart';

/// Data Access Object for TOTP entries table.
///
/// Provides CRUD operations for TOTP authenticator secrets.
/// Secrets are stored encrypted (BlobColumn) -- encryption/decryption
/// happens at the repository boundary per D-10.
@DriftAccessor(tables: [TotpEntries])
class TotpDao extends DatabaseAccessor<AppDatabase> with _$TotpDaoMixin {
  TotpDao(super.db);

  /// Get all TOTP entries linked to a specific vault item.
  Future<List<TotpEntry>> getByVaultItemId(String vaultItemId) {
    return (select(totpEntries)
          ..where((t) => t.vaultItemId.equals(vaultItemId)))
        .get();
  }

  /// Get a single TOTP entry by its ID.
  Future<TotpEntry?> getById(String id) {
    return (select(totpEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert a new TOTP entry.
  Future<void> insertEntry(TotpEntriesCompanion entry) {
    return into(totpEntries).insert(entry);
  }

  /// Update an existing TOTP entry.
  Future<void> updateEntry(TotpEntriesCompanion entry) {
    return (update(totpEntries)
          ..where(
              (t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  /// Delete a TOTP entry by its ID.
  Future<void> deleteEntry(String id) {
    return (delete(totpEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Get all TOTP entries (for Watchtower TOTP count).
  Future<List<TotpEntry>> getAllEntries() {
    return select(totpEntries).get();
  }
}
