import 'package:citadel_password_manager/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  group('AutofillIndexDao', () {
    /// Helper: insert a vault + vault item so FK constraint is satisfied.
    Future<void> _insertVaultItem(String itemId, String vaultId) async {
      final now = DateTime.now();
      await db.into(db.vaults).insert(VaultsCompanion.insert(
            id: vaultId,
            name: 'Test Vault',
            sortOrder: const Value(0),
            createdAt: now,
            updatedAt: now,
          ));
      await db.into(db.vaultItems).insert(VaultItemsCompanion.insert(
            id: itemId,
            vaultId: vaultId,
            encryptedData: Uint8List(0),
            createdAt: now,
            updatedAt: now,
          ));
    }

    test('upsertIndex then findByDomainHash returns match', () async {
      await _insertVaultItem('item-1', 'vault-1');
      await db.autofillIndexDao.upsertIndex('item-1', 'domain-hash-abc', null);

      final results =
          await db.autofillIndexDao.findByDomainHash('domain-hash-abc');
      expect(results, hasLength(1));
      expect(results.first.vaultItemId, 'item-1');
      expect(results.first.domainHash, 'domain-hash-abc');
    });

    test('findByPackageHash returns match', () async {
      await _insertVaultItem('item-2', 'vault-2');
      await db.autofillIndexDao
          .upsertIndex('item-2', 'domain-hash-xyz', 'pkg-hash-123');

      final results =
          await db.autofillIndexDao.findByPackageHash('pkg-hash-123');
      expect(results, hasLength(1));
      expect(results.first.vaultItemId, 'item-2');
      expect(results.first.packageHash, 'pkg-hash-123');
    });

    test('findByDomainHash returns empty for non-matching hash', () async {
      await _insertVaultItem('item-3', 'vault-3');
      await db.autofillIndexDao.upsertIndex('item-3', 'domain-hash-aaa', null);

      final results =
          await db.autofillIndexDao.findByDomainHash('non-existing-hash');
      expect(results, isEmpty);
    });

    test('deleteByVaultItemId removes entries', () async {
      await _insertVaultItem('item-4', 'vault-4');
      await db.autofillIndexDao.upsertIndex('item-4', 'domain-hash-del', null);

      // Verify it exists
      var results =
          await db.autofillIndexDao.findByDomainHash('domain-hash-del');
      expect(results, hasLength(1));

      // Delete
      await db.autofillIndexDao.deleteByVaultItemId('item-4');

      // Verify it's gone
      results =
          await db.autofillIndexDao.findByDomainHash('domain-hash-del');
      expect(results, isEmpty);
    });

    test('upsertIndex replaces existing entry for same vaultItemId', () async {
      await _insertVaultItem('item-5', 'vault-5');

      // Insert initial
      await db.autofillIndexDao
          .upsertIndex('item-5', 'old-domain-hash', 'old-pkg-hash');

      // Upsert with new values
      await db.autofillIndexDao
          .upsertIndex('item-5', 'new-domain-hash', 'new-pkg-hash');

      // Old hash should be gone
      final oldResults =
          await db.autofillIndexDao.findByDomainHash('old-domain-hash');
      expect(oldResults, isEmpty);

      // New hash should be present
      final newResults =
          await db.autofillIndexDao.findByDomainHash('new-domain-hash');
      expect(newResults, hasLength(1));
      expect(newResults.first.packageHash, 'new-pkg-hash');
    });
  });
}
