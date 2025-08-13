import 'dart:async';
import 'dart:typed_data';

import 'package:citadel_password_manager/core/database/app_database.dart';
import 'package:citadel_password_manager/core/database/daos/settings_dao.dart';
import 'package:citadel_password_manager/core/database/daos/sync_dao.dart';
import 'package:citadel_password_manager/core/database/daos/vault_dao.dart';
import 'package:citadel_password_manager/core/network/connectivity_service.dart';
import 'package:citadel_password_manager/core/sync/sync_engine.dart';
import 'package:citadel_password_manager/core/sync/sync_state.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';

// Mocks
class MockSyncDao extends Mock implements SyncDao {}

class MockVaultDao extends Mock implements VaultDao {}

class MockSettingsDao extends Mock implements SettingsDao {}

class MockPocketBase extends Mock implements PocketBase {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockRecordService extends Mock implements RecordService {}

class FakeSyncQueueCompanion extends Fake implements SyncQueueCompanion {}

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
    registerFallbackValue(FakeSyncQueueCompanion());
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

  group('SyncEngine.push', () {
    test('sends pending queue entries to PocketBase', () async {
      final entry = SyncQueueData(
        id: 1,
        itemId: 'item-1',
        entityTable: 'vault_items',
        operation: 'create',
        queuedAt: DateTime.now(),
        retryCount: 0,
        lastError: null,
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
      when(() => mockVaultDao.getItemsByVault(any())).thenAnswer((_) async => [vaultItem]);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.create(body: any(named: 'body')))
          .thenAnswer((_) async => RecordModel({'id': 'remote-1'}));
      when(() => mockVaultDao.updateVaultItem(any())).thenAnswer((_) async => true);
      when(() => mockSyncDao.markCompleted(1)).thenAnswer((_) async {});
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      verify(() => mockRecordService.create(body: any(named: 'body'))).called(1);
    });

    test('marks entries as completed after successful remote write', () async {
      final entry = SyncQueueData(
        id: 1,
        itemId: 'item-1',
        entityTable: 'vault_items',
        operation: 'create',
        queuedAt: DateTime.now(),
        retryCount: 0,
        lastError: null,
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
      when(() => mockVaultDao.getItemsByVault(any())).thenAnswer((_) async => [vaultItem]);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.create(body: any(named: 'body')))
          .thenAnswer((_) async => RecordModel({'id': 'remote-1'}));
      when(() => mockVaultDao.updateVaultItem(any())).thenAnswer((_) async => true);
      when(() => mockSyncDao.markCompleted(1)).thenAnswer((_) async {});
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      verify(() => mockSyncDao.markCompleted(1)).called(1);
    });

    test('increments retryCount and stores error on failure', () async {
      final entry = SyncQueueData(
        id: 1,
        itemId: 'item-1',
        entityTable: 'vault_items',
        operation: 'create',
        queuedAt: DateTime.now(),
        retryCount: 0,
        lastError: null,
        completed: false,
      );

      when(() => mockSyncDao.getPending()).thenAnswer((_) async => [entry]);
      when(() => mockVaultDao.getItemsByVault(any())).thenAnswer((_) async => []);
      // Item not found locally, but PB create will fail anyway
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      // Simulate the item existing but PB failing
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
      when(() => mockVaultDao.getItemsByVault(any()))
          .thenAnswer((_) async => [vaultItem]);
      when(() => mockRecordService.create(body: any(named: 'body')))
          .thenThrow(Exception('Network error'));
      when(() => mockSyncDao.incrementRetry(1, any())).thenAnswer((_) async {});
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      verify(() => mockSyncDao.incrementRetry(1, any())).called(1);
    });
  });

  group('SyncEngine.pull', () {
    test('fetches records updated since lastSync timestamp', () async {
      when(() => mockSyncDao.getPending()).thenAnswer((_) async => []);
      when(() => mockSettingsDao.getSetting('lastSync'))
          .thenAnswer((_) async => '2026-01-01T00:00:00.000Z');
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.getFullList(
            filter: 'updated > "2026-01-01T00:00:00.000Z"',
          )).thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      verify(() => mockRecordService.getFullList(
            filter: 'updated > "2026-01-01T00:00:00.000Z"',
          )).called(1);
    });

    test('writes remote records to local DB', () async {
      final remoteRecord = RecordModel({
        'id': 'remote-1',
        'item_id': 'item-remote-1',
        'vault_id': 'vault-1',
        'encrypted_data': [4, 5, 6],
        'encryption_version': 2,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T12:00:00.000Z',
      });

      when(() => mockSyncDao.getPending()).thenAnswer((_) async => []);
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => [remoteRecord]);
      // No local items matching the remote ID -- will insert.
      when(() => mockVaultDao.getItemsByVault(any())).thenAnswer((_) async => []);
      when(() => mockVaultDao.insertVaultItem(any())).thenAnswer((_) async {});
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await syncEngine.sync();

      verify(() => mockVaultDao.insertVaultItem(any())).called(1);
    });
  });

  group('SyncEngine mutex', () {
    test('prevents concurrent sync operations', () async {
      final completer = Completer<List<SyncQueueData>>();
      when(() => mockSyncDao.getPending()).thenAnswer((_) => completer.future);

      // Start first sync (will block on getPending).
      final firstSync = syncEngine.sync();

      // Start second sync -- should return immediately (mutex).
      final secondSync = syncEngine.sync();

      // Complete the first sync.
      completer.complete([]);
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      await firstSync;
      await secondSync;

      // getPending should only be called once (second sync was dropped).
      verify(() => mockSyncDao.getPending()).called(1);
    });
  });

  group('SyncEngine state transitions', () {
    test('transitions through SyncIdle -> Syncing -> SyncIdle', () async {
      when(() => mockSyncDao.getPending()).thenAnswer((_) async => []);
      when(() => mockSettingsDao.getSetting('lastSync')).thenAnswer((_) async => null);
      when(() => mockPb.collection('vault_items')).thenReturn(mockRecordService);
      when(() => mockRecordService.getFullList(filter: any(named: 'filter')))
          .thenAnswer((_) async => <RecordModel>[]);
      when(() => mockSettingsDao.setSetting(any(), any())).thenAnswer((_) async {});

      expect(syncEngine.state, isA<SyncIdle>());

      // Use expectLater with stream matcher to capture all events.
      final statesFuture = syncEngine.stateStream.take(2).toList();

      await syncEngine.sync();

      final states = await statesFuture;

      expect(states.length, 2);
      expect(states[0], isA<Syncing>());
      expect(states[1], isA<SyncIdle>());
    });

    test('emits SyncError on failure', () async {
      when(() => mockSyncDao.getPending()).thenThrow(Exception('DB error'));

      final statesFuture = syncEngine.stateStream.first;

      await syncEngine.sync();

      final state = await statesFuture;
      expect(state, isA<SyncError>());
      expect(syncEngine.state, isA<SyncError>());
    });
  });
}
