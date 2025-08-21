import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:citadel_password_manager/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper to create a vault and vault item for testing password history.
  Future<void> seedVaultAndItem(String vaultId, String itemId) async {
    await db.into(db.vaults).insert(VaultsCompanion.insert(
          id: vaultId,
          name: 'Test Vault',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
    await db.into(db.vaultItems).insert(VaultItemsCompanion.insert(
          id: itemId,
          vaultId: vaultId,
          encryptedData: Uint8List.fromList([1, 2, 3]),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));
  }

  group('PasswordHistoryDao', () {
    test('insert creates a new history entry', () async {
      await seedVaultAndItem('v1', 'item1');

      await db.passwordHistoryDao.insert(
        'item1',
        Uint8List.fromList([10, 20, 30]),
        DateTime(2024, 1, 1),
      );

      final entries = await db.passwordHistoryDao.getByItem('item1');
      expect(entries.length, 1);
      expect(entries[0].vaultItemId, 'item1');
      expect(entries[0].encryptedPassword, Uint8List.fromList([10, 20, 30]));
    });

    test('getByItem returns entries ordered by changedAt descending', () async {
      await seedVaultAndItem('v1', 'item1');

      await db.passwordHistoryDao.insert(
        'item1',
        Uint8List.fromList([1]),
        DateTime(2024, 1, 1),
      );
      await db.passwordHistoryDao.insert(
        'item1',
        Uint8List.fromList([2]),
        DateTime(2024, 3, 1),
      );
      await db.passwordHistoryDao.insert(
        'item1',
        Uint8List.fromList([3]),
        DateTime(2024, 2, 1),
      );

      final entries = await db.passwordHistoryDao.getByItem('item1');

      expect(entries.length, 3);
      // Most recent first
      expect(entries[0].encryptedPassword, Uint8List.fromList([2]));
      expect(entries[1].encryptedPassword, Uint8List.fromList([3]));
      expect(entries[2].encryptedPassword, Uint8List.fromList([1]));
    });

    test('getByItem returns empty list for unknown item', () async {
      final entries = await db.passwordHistoryDao.getByItem('nonexistent');
      expect(entries, isEmpty);
    });

    test('prune with keepCount=3 deletes entries beyond 3 most recent', () async {
      await seedVaultAndItem('v1', 'item1');

      // Insert 5 entries with different timestamps.
      for (int i = 1; i <= 5; i++) {
        await db.passwordHistoryDao.insert(
          'item1',
          Uint8List.fromList([i]),
          DateTime(2024, i, 1),
        );
      }

      // Verify 5 entries exist.
      var entries = await db.passwordHistoryDao.getByItem('item1');
      expect(entries.length, 5);

      // Prune to keep only 3.
      await db.passwordHistoryDao.prune('item1', keepCount: 3);

      entries = await db.passwordHistoryDao.getByItem('item1');
      expect(entries.length, 3);

      // Should keep the 3 most recent (months 5, 4, 3).
      expect(entries[0].encryptedPassword, Uint8List.fromList([5]));
      expect(entries[1].encryptedPassword, Uint8List.fromList([4]));
      expect(entries[2].encryptedPassword, Uint8List.fromList([3]));
    });

    test('prune does nothing when entries are within keepCount', () async {
      await seedVaultAndItem('v1', 'item1');

      await db.passwordHistoryDao.insert(
        'item1',
        Uint8List.fromList([1]),
        DateTime(2024, 1, 1),
      );
      await db.passwordHistoryDao.insert(
        'item1',
        Uint8List.fromList([2]),
        DateTime(2024, 2, 1),
      );

      await db.passwordHistoryDao.prune('item1', keepCount: 3);

      final entries = await db.passwordHistoryDao.getByItem('item1');
      expect(entries.length, 2);
    });

    test('entries for different items are isolated', () async {
      await seedVaultAndItem('v1', 'item1');
      await db.into(db.vaultItems).insert(VaultItemsCompanion.insert(
            id: 'item2',
            vaultId: 'v1',
            encryptedData: Uint8List.fromList([1, 2, 3]),
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ));

      await db.passwordHistoryDao.insert(
        'item1',
        Uint8List.fromList([10]),
        DateTime(2024, 1, 1),
      );
      await db.passwordHistoryDao.insert(
        'item2',
        Uint8List.fromList([20]),
        DateTime(2024, 1, 1),
      );

      final item1Entries = await db.passwordHistoryDao.getByItem('item1');
      final item2Entries = await db.passwordHistoryDao.getByItem('item2');

      expect(item1Entries.length, 1);
      expect(item2Entries.length, 1);
      expect(item1Entries[0].encryptedPassword, Uint8List.fromList([10]));
      expect(item2Entries[0].encryptedPassword, Uint8List.fromList([20]));
    });
  });
}
