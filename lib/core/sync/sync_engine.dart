import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

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

  /// The current PocketBase user ID for populating the `owner` field.
  String? get _currentUserId => _pb.authStore.record?.id;

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

    // Don't sync if not authenticated
    if (!_pb.authStore.isValid || _currentUserId == null) {
      return;
    }

    _isSyncing = true;

    try {
      final pending = await _syncDao.getPending();
      if (pending.isEmpty) {
        _emitState(SyncIdle(lastSyncAt: DateTime.now()));
        return;
      }

      _emitState(Syncing(pendingCount: pending.length));
      dev.log('[Sync] Pushing ${pending.length} entries for user $_currentUserId');

      await _push(pending);
      await _pull();

      _emitState(SyncIdle(lastSyncAt: DateTime.now()));
      dev.log('[Sync] Complete');
    } catch (e) {
      dev.log('[Sync] Error: $e');
      _emitState(SyncError(message: e.toString(), failedAt: DateTime.now()));
    } finally {
      _isSyncing = false;
    }
  }

  /// Push all pending local changes to PocketBase.
  ///
  /// Vaults are pushed before items so that PocketBase has valid vault
  /// records when item relations reference them.
  Future<void> _push(List<SyncQueueData> pendingEntries) async {
    // Sort: vaults first, then vault_items (items reference vault IDs).
    final sorted = List.of(pendingEntries)
      ..sort((a, b) {
        const order = {'vaults': 0, 'vault_items': 1};
        return (order[a.entityTable] ?? 2).compareTo(order[b.entityTable] ?? 2);
      });

    for (final entry in sorted) {
      // Skip entries that exceeded max retries — but log it.
      if (entry.retryCount > maxRetries) {
        dev.log('[Sync] Skipping ${entry.entityTable}/${entry.itemId} — exceeded $maxRetries retries');
        continue;
      }

      try {
        dev.log('[Sync] Push ${entry.operation} ${entry.entityTable}/${entry.itemId}');
        switch (entry.operation) {
          case 'create':
            await _pushCreate(entry);
          case 'update':
            await _pushUpdate(entry);
          case 'delete':
            await _pushDelete(entry);
        }
        await _syncDao.markCompleted(entry.id);
        dev.log('[Sync] ✓ Pushed ${entry.entityTable}/${entry.itemId}');
      } catch (e) {
        dev.log('[Sync] ✗ Failed ${entry.entityTable}/${entry.itemId}: $e');
        await _syncDao.incrementRetry(entry.id, e.toString());
      }
    }
  }

  Future<void> _pushCreate(SyncQueueData entry) async {
    final userId = _currentUserId;
    if (userId == null) return;

    if (entry.entityTable == 'vault_items') {
      // Search across all vaults to find the item by its ID.
      VaultItem? localItem;
      final allVaults = await _vaultDao.getAllVaults();
      for (final vault in allVaults) {
        final vaultItems = await _vaultDao.getItemsByVault(vault.id);
        localItem = vaultItems.where((i) => i.id == entry.itemId).firstOrNull;
        if (localItem != null) break;
      }

      if (localItem == null) return; // Item deleted before sync.

      // Look up the vault's PB remote ID for the relation
      final vault = await _vaultDao.getVaultById(localItem.vaultId);
      final vaultRemoteId = vault?.remoteId ?? localItem.vaultId;

      final record = await _pb.collection('vault_items').create(
        body: {
          'vaultId': vaultRemoteId,
          'owner': userId,
          'encryptedData': base64Encode(localItem.encryptedData),
          'encryptionVersion': localItem.encryptionVersion,
        },
      );

      // Store the PB-assigned ID back locally for future updates.
      await _vaultDao.updateVaultItem(
        VaultItemsCompanion(
          id: Value(localItem.id),
          remoteId: Value(record.id),
        ),
      );
    } else if (entry.entityTable == 'vaults') {
      final vault = await _vaultDao.getVaultById(entry.itemId);
      if (vault == null) return;

      // Skip if already synced (has remoteId)
      if (vault.remoteId != null) return;

      final record = await _pb.collection('vault_collections').create(
        body: {
          'name': vault.name,
          'owner': userId,
          'colorHex': vault.colorHex,
          'iconName': vault.iconName,
        },
      );

      // Store PB-assigned ID back locally for vault_items relation
      await _vaultDao.updateVault(
        VaultsCompanion(
          id: Value(vault.id),
          remoteId: Value(record.id),
        ),
      );
    }
  }

  Future<void> _pushUpdate(SyncQueueData entry) async {
    final userId = _currentUserId;
    if (userId == null) return;

    if (entry.entityTable == 'vault_items') {
      VaultItem? localItem;
      final allVaults = await _vaultDao.getAllVaults();
      for (final vault in allVaults) {
        final vaultItems = await _vaultDao.getItemsByVault(vault.id);
        localItem = vaultItems.where((i) => i.id == entry.itemId).firstOrNull;
        if (localItem != null) break;
      }
      if (localItem == null || localItem.remoteId == null) return;

      await _pb.collection('vault_items').update(
        localItem.remoteId!,
        body: {
          'encryptedData': base64Encode(localItem.encryptedData),
          'encryptionVersion': localItem.encryptionVersion,
          'owner': userId,
        },
      );
    } else if (entry.entityTable == 'vaults') {
      final vault = await _vaultDao.getVaultById(entry.itemId);
      if (vault == null) return;

      // For vaults, we'd need a remoteId mapping too.
      // For now, skip vault updates until we add remote ID tracking for vaults.
    }
  }

  Future<void> _pushDelete(SyncQueueData entry) async {
    try {
      final collection =
          entry.entityTable == 'vaults' ? 'vault_collections' : entry.entityTable;
      await _pb.collection(collection).delete(entry.itemId);
    } catch (_) {
      // If the remote record doesn't exist, that's fine -- already deleted.
    }
  }

  /// Pull remote changes from PocketBase since last sync.
  Future<void> _pull() async {
    final userId = _currentUserId;
    if (userId == null) return;

    final lastSync = await _settingsDao.getSetting('lastSync');
    String filter = 'owner = "$userId"';
    if (lastSync != null) {
      filter += ' && updated > "$lastSync"';
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
    // ignore: deprecated_member_use
    final remoteUpdatedAt = DateTime.parse(record.updated);

    // Check if we have this item locally by remote ID.
    VaultItem? localItem;
    final allVaults = await _vaultDao.getAllVaults();
    for (final vault in allVaults) {
      final vaultItems = await _vaultDao.getItemsByVault(vault.id);
      localItem = vaultItems.where((i) => i.remoteId == record.id).firstOrNull;
      if (localItem != null) break;
    }

    // PocketBase stores encryptedData as base64 text.
    final encryptedDataB64 = record.getStringValue('encryptedData');
    final encryptedData = base64Decode(encryptedDataB64);
    final vaultId = record.getStringValue('vaultId');

    if (localItem == null) {
      // New remote item -- insert locally.
      await _vaultDao.insertVaultItem(
        VaultItemsCompanion(
          id: Value(record.id), // Use PB ID as local ID for new remote items.
          vaultId: Value(vaultId),
          encryptedData: Value(Uint8List.fromList(encryptedData)),
          encryptionVersion:
              Value(record.getIntValue('encryptionVersion')),
          // ignore: deprecated_member_use
          createdAt: Value(DateTime.parse(record.created)),
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
        encryptedData: Value(Uint8List.fromList(encryptedData)),
        encryptionVersion:
            Value(record.getIntValue('encryptionVersion')),
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

  /// Reset all failed sync entries so they can be retried.
  Future<void> resetFailedEntries() async {
    await _syncDao.resetRetries();
    dev.log('[Sync] Reset all failed entries for retry');
  }

  /// Force re-queue ALL local vaults and items for sync.
  /// Use after clearing PB data or when sync is out of sync.
  Future<void> forceFullResync() async {
    dev.log('[Sync] Force full re-sync — re-queuing all local data');

    // Clear completed entries
    await _syncDao.clearCompleted();

    // Re-queue all vaults
    final vaults = await _vaultDao.getAllVaults();
    for (final vault in vaults) {
      await _syncDao.enqueue(vault.id, 'vaults', 'create');
    }

    // Re-queue all items across all vaults
    for (final vault in vaults) {
      final items = await _vaultDao.getItemsByVault(vault.id);
      for (final item in items) {
        await _syncDao.enqueue(item.id, 'vault_items', 'create');
      }
    }

    dev.log('[Sync] Re-queued ${vaults.length} vaults and items');

    // Push immediately
    await syncNow();
  }

  /// Trigger an immediate sync attempt.
  /// Call this after creating/updating items for write-through behavior:
  /// local save is instant, then we try to push to PocketBase immediately.
  /// If it fails (offline), the periodic sync will retry.
  Future<void> syncNow() async {
    dev.log('[Sync] Immediate sync requested');
    await sync();
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
