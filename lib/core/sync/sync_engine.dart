import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart';

import '../database/app_database.dart';
import '../database/daos/settings_dao.dart';
import '../database/daos/sync_dao.dart';
import '../database/daos/vault_dao.dart';
import '../network/connectivity_service.dart';
import 'sync_state.dart';

/// Offline-first sync engine with push/pull phases.
///
/// Per D-16: all writes go to local Drift database first, then queue for sync.
/// Per D-17: conflict resolution uses last-write-wins with local preference.
/// Per D-18: PocketBase stores opaque encrypted blobs -- no server-side decryption.
/// Per Pitfall 6: mutex prevents concurrent sync operations.
class SyncEngine {
  final SyncDao _syncDao;
  final VaultDao _vaultDao;
  final SettingsDao _settingsDao;
  final PocketBase _pb;
  final ConnectivityService _connectivity;

  /// Maximum number of retries before skipping a queue entry.
  static const int maxRetries = 5;

  /// Default periodic sync interval (30 seconds per D-16).
  static const Duration defaultSyncInterval = Duration(seconds: 30);

  bool _isSyncing = false;
  Timer? _periodicTimer;

  SyncState _state = const SyncIdle();
  final _stateController = StreamController<SyncState>.broadcast();

  /// Current sync state.
  SyncState get state => _state;

  /// Stream of sync state changes for UI observation.
  Stream<SyncState> get stateStream => _stateController.stream;

  /// Whether a sync operation is currently in progress.
  bool get isSyncing => _isSyncing;

  SyncEngine({
    required SyncDao syncDao,
    required VaultDao vaultDao,
    required SettingsDao settingsDao,
    required PocketBase pb,
    required ConnectivityService connectivity,
  })  : _syncDao = syncDao,
        _vaultDao = vaultDao,
        _settingsDao = settingsDao,
        _pb = pb,
        _connectivity = connectivity;

  /// Run a full sync cycle: push local changes, then pull remote changes.
  ///
  /// Per Pitfall 6: if already syncing, drops the request to prevent races.
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _syncDao.getPending();
      _emitState(Syncing(pendingCount: pending.length));

      await _push(pending);
      await _pull();

      _emitState(SyncIdle(lastSyncAt: DateTime.now()));
    } catch (e) {
      _emitState(SyncError(message: e.toString(), failedAt: DateTime.now()));
    } finally {
      _isSyncing = false;
    }
  }

  /// Push all pending local changes to PocketBase.
  Future<void> _push(List<SyncQueueData> pendingEntries) async {
    for (final entry in pendingEntries) {
      // Skip entries that exceeded max retries.
      if (entry.retryCount > maxRetries) continue;

      try {
        switch (entry.operation) {
          case 'create':
            await _pushCreate(entry);
          case 'update':
            await _pushUpdate(entry);
          case 'delete':
            await _pushDelete(entry);
        }
        await _syncDao.markCompleted(entry.id);
      } catch (e) {
        await _syncDao.incrementRetry(entry.id, e.toString());
      }
    }
  }

  Future<void> _pushCreate(SyncQueueData entry) async {
    // Read the local item to get encrypted data.
    // We search across all vaults since we only have the item ID.
    final items = await _vaultDao.getItemsByVault('');
    final localItem = items.where((i) => i.id == entry.itemId).firstOrNull;

    if (localItem == null) {
      // Item may have been created and immediately deleted, skip.
      return;
    }

    final record = await _pb.collection(entry.entityTable).create(
      body: {
        'item_id': localItem.id,
        'vault_id': localItem.vaultId,
        'encrypted_data': localItem.encryptedData,
        'encryption_version': localItem.encryptionVersion,
        'created_at': localItem.createdAt.toIso8601String(),
        'updated_at': localItem.updatedAt.toIso8601String(),
      },
    );

    // Store the remote ID in the local item for future updates.
    await _vaultDao.updateVaultItem(
      VaultItemsCompanion(
        id: Value(localItem.id),
        remoteId: Value(record.id),
      ),
    );
  }

  Future<void> _pushUpdate(SyncQueueData entry) async {
    final items = await _vaultDao.getItemsByVault('');
    final localItem = items.where((i) => i.id == entry.itemId).firstOrNull;
    if (localItem == null || localItem.remoteId == null) return;

    await _pb.collection(entry.entityTable).update(
      localItem.remoteId!,
      body: {
        'encrypted_data': localItem.encryptedData,
        'encryption_version': localItem.encryptionVersion,
        'updated_at': localItem.updatedAt.toIso8601String(),
      },
    );
  }

  Future<void> _pushDelete(SyncQueueData entry) async {
    try {
      await _pb.collection(entry.entityTable).delete(entry.itemId);
    } catch (_) {
      // If the remote record doesn't exist, that's fine -- already deleted.
    }
  }

  /// Pull remote changes from PocketBase since last sync.
  Future<void> _pull() async {
    final lastSync = await _settingsDao.getSetting('lastSync');
    String? filter;
    if (lastSync != null) {
      filter = 'updated > "$lastSync"';
    }

    final records = await _pb.collection('vault_items').getFullList(
      filter: filter,
    );

    for (final record in records) {
      await _applyRemoteRecord(record);
    }

    await _settingsDao.setSetting(
      'lastSync',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  /// Apply a remote record to the local database with conflict resolution.
  Future<void> _applyRemoteRecord(RecordModel record) async {
    final remoteUpdatedAt =
        DateTime.parse(record.data['updated_at'] as String);

    // Check if we have this item locally by remote ID.
    final items = await _vaultDao.getItemsByVault('');
    final localItem =
        items.where((i) => i.remoteId == record.id).firstOrNull;

    final rawEncryptedData = record.data['encrypted_data'];
    final encryptedData = rawEncryptedData is Uint8List
        ? rawEncryptedData
        : Uint8List.fromList(List<int>.from(rawEncryptedData as List));

    if (localItem == null) {
      // New remote item -- insert locally.
      await _vaultDao.insertVaultItem(
        VaultItemsCompanion(
          id: Value(record.data['item_id'] as String? ?? record.id),
          vaultId: Value(record.data['vault_id'] as String),
          encryptedData: Value(encryptedData),
          encryptionVersion:
              Value(record.data['encryption_version'] as int),
          createdAt:
              Value(DateTime.parse(record.data['created_at'] as String)),
          updatedAt: Value(remoteUpdatedAt),
          remoteId: Value(record.id),
        ),
      );
      return;
    }

    // Conflict resolution: last-write-wins with local preference on tie (D-17).
    if (_localWins(localItem.updatedAt, remoteUpdatedAt)) {
      return;
    }

    // Remote wins -- apply update.
    await _vaultDao.updateVaultItem(
      VaultItemsCompanion(
        id: Value(localItem.id),
        encryptedData: Value(encryptedData),
        encryptionVersion:
            Value(record.data['encryption_version'] as int),
        updatedAt: Value(remoteUpdatedAt),
      ),
    );
  }

  /// Determines if the local record wins over the remote record.
  ///
  /// Per D-17: local preference on tie (isAtSameMomentAs).
  bool _localWins(DateTime localUpdated, DateTime remoteUpdated) {
    return localUpdated.isAfter(remoteUpdated) ||
        localUpdated.isAtSameMomentAs(remoteUpdated);
  }

  /// Start periodic sync at the given interval.
  /// Default: 30 seconds per D-16.
  void startPeriodicSync([Duration interval = defaultSyncInterval]) {
    stopPeriodicSync();
    _periodicTimer = Timer.periodic(interval, (_) => sync());
  }

  /// Stop periodic sync.
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Listen to connectivity changes and trigger sync when coming online.
  StreamSubscription<bool> listenToConnectivity() {
    return _connectivity.onlineStream.listen((isOnline) {
      if (isOnline) {
        sync();
      }
    });
  }

  void _emitState(SyncState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Dispose resources.
  void dispose() {
    stopPeriodicSync();
    _stateController.close();
  }
}
