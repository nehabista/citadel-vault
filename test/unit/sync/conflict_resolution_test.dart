import 'dart:typed_data';

import 'package:citadel_password_manager/core/database/app_database.dart';
import 'package:citadel_password_manager/core/database/daos/settings_dao.dart';
import 'package:citadel_password_manager/core/database/daos/sync_dao.dart';
import 'package:citadel_password_manager/core/database/daos/vault_dao.dart';
import 'package:citadel_password_manager/core/network/connectivity_service.dart';
import 'package:citadel_password_manager/core/sync/sync_engine.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';

class MockSyncDao extends Mock implements SyncDao {}

class MockVaultDao extends Mock implements VaultDao {}

class MockSettingsDao extends Mock implements SettingsDao {}

class MockPocketBase extends Mock implements PocketBase {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockRecordService extends Mock implements RecordService {}

class FakeVaultItemsCompanion extends Fake implements VaultItemsCompanion {}

void main() {
  late SyncEngine syncEngine;
  late MockSyncDao mockSyncDao;
  late MockVaultDao mockVaultDao;
  late MockSettingsDao mockSettingsDao;
  late MockPocketBase mockPb;
  late MockConnectivityService mockConnectivity;
  late MockRecordService mockRecordService;

  setUpAll(() {
    registerFallbackValue(FakeVaultItemsCompanion());
  });

  setUp(() {
    mockSyncDao = MockSyncDao();
    mockVaultDao = MockVaultDao();
    mockSettingsDao = MockSettingsDao();
    mockPb = MockPocketBase();
    mockConnectivity = MockConnectivityService();
    mockRecordService = MockRecordService();

    syncEngine = SyncEngine(
      syncDao: mockSyncDao,
      vaultDao: mockVaultDao,
      settingsDao: mockSettingsDao,
      pb: mockPb,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() {
    syncEngine.dispose();
  });

  group('Conflict resolution - last-write-wins with local preference', () {
    // Helper to set up pull with a remote record and local item.
    Future<void> runPullWithConflict({
      required DateTime localUpdatedAt,
      required DateTime remoteUpdatedAt,
    }) async {
      final localItem = VaultItem(
        id: 'item-1',
        vaultId: 'vault-1',
        encryptedData: Uint8List.fromList([1, 2, 3]),
        encryptionVersion: 2,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: localUpdatedAt,
        remoteId: 'remote-1',
        isDeleted: false,
      );

      final remoteRecord = RecordModel({
        'id': 'remote-1',
        'item_id': 'item-1',
        'vault_id': 'vault-1',
        'encrypted_data': [4, 5, 6],
        'encryption_version': 2,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': remoteUpdatedAt.toIso8601String(),
      });

      when(() => mockSyncDao.getPending()).thenAnswer((_) async => []);
      when(() => mockSettingsDao.getSetting('lastSync'))
          .thenAnswer((_) async => null);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => [remoteRecord]);
      when(() => mockVaultDao.getItemsByVault(any()))
          .thenAnswer((_) async => [localItem]);
      when(() => mockVaultDao.updateVaultItem(any()))
          .thenAnswer((_) async => true);
      when(() => mockSettingsDao.setSetting(any(), any()))
          .thenAnswer((_) async {});

      await syncEngine.sync();
    }

    test('local wins when local.updatedAt > remote.updatedAt', () async {
      await runPullWithConflict(
        localUpdatedAt: DateTime(2026, 6, 15, 12, 0, 0),
        remoteUpdatedAt: DateTime(2026, 6, 15, 10, 0, 0),
      );

      // Local is newer -- remote update should be skipped.
      verifyNever(() => mockVaultDao.updateVaultItem(any()));
    });

    test('remote wins when remote.updatedAt > local.updatedAt', () async {
      await runPullWithConflict(
        localUpdatedAt: DateTime(2026, 6, 15, 10, 0, 0),
        remoteUpdatedAt: DateTime(2026, 6, 15, 12, 0, 0),
      );

      // Remote is newer -- should update local.
      verify(() => mockVaultDao.updateVaultItem(any())).called(1);
    });

    test('local wins on equal timestamps (local preference per D-17)', () async {
      final sameTime = DateTime(2026, 6, 15, 12, 0, 0);
      await runPullWithConflict(
        localUpdatedAt: sameTime,
        remoteUpdatedAt: sameTime,
      );

      // Same timestamp -- local preference, skip remote update.
      verifyNever(() => mockVaultDao.updateVaultItem(any()));
    });
  });
}
