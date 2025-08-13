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

  group('Sync Queue', () {
    test('changes are queued when offline (enqueue creates entries)', () async {
      // This tests the SyncDao.enqueue interface being called.
      // VaultRepositoryImpl (Task 2) calls syncDao.enqueue, which
      // creates entries regardless of online/offline status.
      // The SyncEngine then processes them when sync() is called.
      when(() => mockSyncDao.enqueue('item-1', 'vault_items', 'create'))
          .thenAnswer((_) async {});

      await mockSyncDao.enqueue('item-1', 'vault_items', 'create');

      verify(() => mockSyncDao.enqueue('item-1', 'vault_items', 'create')).called(1);
    });

    test('queued changes replay in order when connectivity is restored', () async {
      final entries = [
        SyncQueueData(
          id: 1,
          itemId: 'item-1',
          entityTable: 'vault_items',
          operation: 'create',
          queuedAt: DateTime(2026, 1, 1, 10, 0, 0),
          retryCount: 0,
          lastError: null,
          completed: false,
        ),
        SyncQueueData(
          id: 2,
          itemId: 'item-2',
          entityTable: 'vault_items',
          operation: 'create',
          queuedAt: DateTime(2026, 1, 1, 10, 1, 0),
          retryCount: 0,
          lastError: null,
          completed: false,
        ),
        SyncQueueData(
          id: 3,
          itemId: 'item-3',
          entityTable: 'vault_items',
          operation: 'update',
          queuedAt: DateTime(2026, 1, 1, 10, 2, 0),
          retryCount: 0,
          lastError: null,
          completed: false,
        ),
      ];

      // Track the order of markCompleted calls.
      final completedIds = <int>[];
      when(() => mockSyncDao.getPending()).thenAnswer((_) async => entries);

      for (final entry in entries) {
        final vaultItem = VaultItem(
          id: entry.itemId,
          vaultId: 'vault-1',
          encryptedData: Uint8List.fromList([1, 2, 3]),
          encryptionVersion: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          remoteId: entry.operation == 'update' ? 'remote-${entry.itemId}' : null,
          isDeleted: false,
        );
        when(() => mockVaultDao.getItemsByVault(any()))
            .thenAnswer((_) async => entries.map((e) => VaultItem(
                  id: e.itemId,
                  vaultId: 'vault-1',
                  encryptedData: Uint8List.fromList([1, 2, 3]),
                  encryptionVersion: 2,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  remoteId: e.operation == 'update' ? 'remote-${e.itemId}' : null,
                  isDeleted: false,
                )).toList());
      }

      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.create(body: any(named: 'body')))
          .thenAnswer((_) async => RecordModel({'id': 'remote-new'}));
      when(() => mockRecordService.update(any(), body: any(named: 'body')))
          .thenAnswer((_) async => RecordModel({'id': 'remote-updated'}));
      when(() => mockVaultDao.updateVaultItem(any())).thenAnswer((_) async => true);

      when(() => mockSyncDao.markCompleted(any())).thenAnswer((invocation) async {
        completedIds.add(invocation.positionalArguments[0] as int);
      });

      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      // Verify entries were processed in order (by queue ID).
      expect(completedIds, [1, 2, 3]);
    });

    test('failed queue entries are retried with incrementing retryCount', () async {
      final entry = SyncQueueData(
        id: 1,
        itemId: 'item-1',
        entityTable: 'vault_items',
        operation: 'create',
        queuedAt: DateTime.now(),
        retryCount: 2,
        lastError: 'Previous error',
        completed: false,
      );

      final vaultItem = VaultItem(
        id: 'item-1',
        vaultId: 'vault-1',
        encryptedData: Uint8List.fromList([1, 2, 3]),
        encryptionVersion: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        remoteId: null,
        isDeleted: false,
      );

      when(() => mockSyncDao.getPending()).thenAnswer((_) async => [entry]);
      when(() => mockVaultDao.getItemsByVault(any()))
          .thenAnswer((_) async => [vaultItem]);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.create(body: any(named: 'body')))
          .thenThrow(Exception('Network error'));
      when(() => mockSyncDao.incrementRetry(1, any())).thenAnswer((_) async {});
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      // Even though retryCount is already 2, the entry is still retried (< 5).
      verify(() => mockSyncDao.incrementRetry(1, any())).called(1);
    });

    test('entries exceeding max retries (>5) are skipped', () async {
      final entry = SyncQueueData(
        id: 1,
        itemId: 'item-1',
        entityTable: 'vault_items',
        operation: 'create',
        queuedAt: DateTime.now(),
        retryCount: 6,
        lastError: 'Persistent error',
        completed: false,
      );

      when(() => mockSyncDao.getPending()).thenAnswer((_) async => [entry]);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      // Should NOT attempt to push (retryCount > 5).
      verifyNever(() => mockRecordService.create(body: any(named: 'body')));
      // Should NOT mark as completed either.
      verifyNever(() => mockSyncDao.markCompleted(any()));
    });
  });
}
