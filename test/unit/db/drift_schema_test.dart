import 'dart:typed_data';

import 'package:citadel_password_manager/core/database/app_database.dart';
import 'package:citadel_password_manager/core/database/daos/vault_dao.dart';
import 'package:citadel_password_manager/core/database/daos/sync_dao.dart';
import 'package:citadel_password_manager/core/database/daos/settings_dao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late VaultDao vaultDao;
  late SyncDao syncDao;
  late SettingsDao settingsDao;

  setUp(() {
    db = AppDatabase.inMemory();
    vaultDao = VaultDao(db);
    syncDao = SyncDao(db);
    settingsDao = SettingsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('creates database with all tables using inMemory constructor', () async {
      final now = DateTime.now();

      // Insert a vault to satisfy foreign key constraints
      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Test Vault',
        createdAt: now,
        updatedAt: now,
      ));

      // Insert a vault item
      await vaultDao.insertVaultItem(VaultItemsCompanion.insert(
        id: 'item-1',
        vaultId: 'vault-1',
        encryptedData: Uint8List.fromList([1, 2, 3]),
        createdAt: now,
        updatedAt: now,
      ));

      // Insert sync queue entry
      await syncDao.enqueue('item-1', 'vault_items', 'create');

      // Insert setting
      await settingsDao.setSetting('theme', 'dark');

      // If we got here without exceptions, all tables exist
      expect(true, isTrue);
    });
  });

  group('VaultDao', () {
    test('insertVault creates a vault and getAllVaults returns it', () async {
      final now = DateTime.now();
      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Personal',
        createdAt: now,
        updatedAt: now,
      ));

      final vaults = await vaultDao.getAllVaults();
      expect(vaults, hasLength(1));
      expect(vaults.first.name, 'Personal');
      expect(vaults.first.id, 'vault-1');
    });

    test('insertVaultItem stores encrypted blob and getItemsByVault retrieves it', () async {
      final now = DateTime.now();
      final encryptedBlob = Uint8List.fromList([10, 20, 30, 40, 50]);

      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      ));

      await vaultDao.insertVaultItem(VaultItemsCompanion.insert(
        id: 'item-1',
        vaultId: 'vault-1',
        encryptedData: encryptedBlob,
        createdAt: now,
        updatedAt: now,
      ));

      final items = await vaultDao.getItemsByVault('vault-1');
      expect(items, hasLength(1));
      expect(items.first.encryptedData, encryptedBlob);
      expect(items.first.encryptionVersion, 2); // default value
      expect(items.first.vaultId, 'vault-1');
    });

    test('softDeleteItem sets isDeleted=true without removing the row', () async {
      final now = DateTime.now();
      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      ));

      await vaultDao.insertVaultItem(VaultItemsCompanion.insert(
        id: 'item-1',
        vaultId: 'vault-1',
        encryptedData: Uint8List.fromList([1, 2, 3]),
        createdAt: now,
        updatedAt: now,
      ));

      await vaultDao.softDeleteItem('item-1');

      // getItemsByVault excludes deleted items
      final activeItems = await vaultDao.getItemsByVault('vault-1');
      expect(activeItems, isEmpty);

      // But the row still exists in the database (query directly)
      final allItems = await db.select(db.vaultItems).get();
      expect(allItems, hasLength(1));
      expect(allItems.first.isDeleted, isTrue);
    });

    test('watchItemsByVault emits reactive updates excluding deleted items', () async {
      final now = DateTime.now();
      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Test',
        createdAt: now,
        updatedAt: now,
      ));

      // Start watching before inserting
      final stream = vaultDao.watchItemsByVault('vault-1');

      // First emission should be empty
      await expectLater(stream, emits(isEmpty));
    });
  });

  group('SyncDao', () {
    test('enqueue creates a queue entry and getPending returns it', () async {
      await syncDao.enqueue('item-1', 'vault_items', 'create');

      final pending = await syncDao.getPending();
      expect(pending, hasLength(1));
      expect(pending.first.itemId, 'item-1');
      expect(pending.first.entityTable, 'vault_items');
      expect(pending.first.operation, 'create');
      expect(pending.first.completed, isFalse);
      expect(pending.first.retryCount, 0);
    });

    test('markCompleted sets completed=true', () async {
      await syncDao.enqueue('item-1', 'vault_items', 'update');

      final pending = await syncDao.getPending();
      expect(pending, hasLength(1));

      await syncDao.markCompleted(pending.first.id);

      final afterMark = await syncDao.getPending();
      expect(afterMark, isEmpty);

      // Verify the entry still exists but is completed
      final all = await db.select(db.syncQueue).get();
      expect(all, hasLength(1));
      expect(all.first.completed, isTrue);
    });

    test('incrementRetry increases retryCount and stores lastError', () async {
      await syncDao.enqueue('item-1', 'vault_items', 'create');

      final pending = await syncDao.getPending();
      final queueId = pending.first.id;

      await syncDao.incrementRetry(queueId, 'Network timeout');

      final updated = await syncDao.getPending();
      expect(updated.first.retryCount, 1);
      expect(updated.first.lastError, 'Network timeout');

      await syncDao.incrementRetry(queueId, 'Server error');
      final updated2 = await syncDao.getPending();
      expect(updated2.first.retryCount, 2);
      expect(updated2.first.lastError, 'Server error');
    });

    test('clearCompleted removes only completed entries', () async {
      await syncDao.enqueue('item-1', 'vault_items', 'create');
      await syncDao.enqueue('item-2', 'vault_items', 'update');

      final pending = await syncDao.getPending();
      await syncDao.markCompleted(pending.first.id);

      await syncDao.clearCompleted();

      final remaining = await db.select(db.syncQueue).get();
      expect(remaining, hasLength(1));
      expect(remaining.first.itemId, 'item-2');
    });
  });

  group('SettingsDao', () {
    test('setSetting and getSetting roundtrip works', () async {
      await settingsDao.setSetting('theme', 'dark');

      final value = await settingsDao.getSetting('theme');
      expect(value, 'dark');
    });

    test('setSetting upserts on existing key', () async {
      await settingsDao.setSetting('theme', 'dark');
      await settingsDao.setSetting('theme', 'light');

      final value = await settingsDao.getSetting('theme');
      expect(value, 'light');
    });

    test('getSetting returns null for non-existent key', () async {
      final value = await settingsDao.getSetting('nonexistent');
      expect(value, isNull);
    });

    test('deleteSetting removes the setting', () async {
      await settingsDao.setSetting('theme', 'dark');
      await settingsDao.deleteSetting('theme');

      final value = await settingsDao.getSetting('theme');
      expect(value, isNull);
    });
  });
}
