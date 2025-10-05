import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/autofill_index_table.dart';

part 'autofill_index_dao.g.dart';

/// Data access object for AutofillIndex table lookups by domainHash/packageHash.
///
/// Per D-05: queries use SHA-256 hashes only, no plaintext domains stored.
/// This DAO supports the autofill bridge in looking up vault items that match
/// the requesting app's domain or package name.
@DriftAccessor(tables: [AutofillIndex])
class AutofillIndexDao extends DatabaseAccessor<AppDatabase>
    with _$AutofillIndexDaoMixin {
  AutofillIndexDao(super.db);

  /// Find all autofill index entries matching a domain hash.
  Future<List<AutofillIndexData>> findByDomainHash(String hash) {
    return (select(autofillIndex)
          ..where((t) => t.domainHash.equals(hash)))
        .get();
  }

  /// Find all autofill index entries matching a package hash.
  Future<List<AutofillIndexData>> findByPackageHash(String hash) {
    return (select(autofillIndex)
          ..where((t) => t.packageHash.equals(hash)))
        .get();
  }

  /// Insert or update an autofill index entry for a vault item.
  ///
  /// Deletes existing entries for the vault item first (upsert pattern),
  /// then inserts the new entry.
  Future<void> upsertIndex(
    String vaultItemId,
    String domainHash,
    String? packageHash,
  ) async {
    await deleteByVaultItemId(vaultItemId);
    await into(autofillIndex).insert(
      AutofillIndexCompanion.insert(
        vaultItemId: vaultItemId,
        domainHash: domainHash,
        packageHash: Value(packageHash),
      ),
    );
  }

  /// Delete all autofill index entries for a vault item.
  Future<void> deleteByVaultItemId(String vaultItemId) {
    return (delete(autofillIndex)
          ..where((t) => t.vaultItemId.equals(vaultItemId)))
        .go();
  }
}
