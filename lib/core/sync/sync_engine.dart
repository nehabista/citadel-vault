// P2: Enhanced real-time sync with conflict resolution
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart';

import '../crypto/crypto_engine.dart';
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
  final CryptoEngine _cryptoEngine;

  /// Callback that returns the current vault key bytes, or null if locked.
  /// Sync only runs when session is Unlocked, so this should always return
  /// a value during active sync operations.
  final Uint8List? Function() _getVaultKeyBytes;

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
    required CryptoEngine cryptoEngine,
    required Uint8List? Function() getVaultKeyBytes,
  })  : _syncDao = syncDao,
        _vaultDao = vaultDao,
        _settingsDao = settingsDao,
        _pb = pb,
        _connectivity = connectivity,
        _cryptoEngine = cryptoEngine,
        _getVaultKeyBytes = getVaultKeyBytes;

  /// Get the current vault key as a [SecretKey], or null if session is locked.
  SecretKey? get _vaultKey {
    final bytes = _getVaultKeyBytes();
    return bytes != null ? SecretKey(bytes) : null;
  }

  /// Encrypt a vault name before sending to PocketBase.
  ///
  /// Per D-11 / D-18: all metadata must be encrypted. Vault names are
  /// identifying information that must not be stored as plaintext on the server.
  /// Returns a base64-encoded encrypted blob.
  Future<String> _encryptVaultName(String name, SecretKey key) async {
    final plaintext = Uint8List.fromList(utf8.encode(name));
    final encrypted = await _cryptoEngine.encrypt(plaintext, key);
    return base64Encode(encrypted);
  }

  /// Decrypt a vault name received from PocketBase.
  ///
  /// Returns the plaintext vault name. If decryption fails (e.g. the name
  /// was stored as plaintext before this fix), returns the raw value as-is
  /// for backward compatibility.
  Future<String> _decryptVaultName(String encodedName, SecretKey key) async {
    try {
      final encrypted = base64Decode(encodedName);
      final decrypted = await _cryptoEngine.decrypt(encrypted, key);
      return utf8.decode(decrypted);
    } catch (_) {
      // Backward compatibility: if the name can't be decrypted, it was likely
      // stored as plaintext before this encryption was added. Return as-is.
      dev.log('[Sync] Vault name not encrypted (legacy) — using as plaintext');
      return encodedName;
    }
  }

  /// Run a full sync cycle: push local changes, then pull remote changes.
  ///
  /// Per Pitfall 6: if already syncing, drops the request to prevent races.
  Future<void> sync() async {
    if (_isSyncing) return;

    // Don't sync if not authenticated or vault is locked (key required for
    // encrypting/decrypting vault names per D-11).
    if (!_pb.authStore.isValid || _currentUserId == null) {
      return;
    }
    if (_vaultKey == null) {
      dev.log('[Sync] Skipping — vault is locked (no encryption key)');
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
      final vaultRemoteId = vault?.remoteId;
      dev.log('[Sync] Item vaultId=${localItem.vaultId}, vault remoteId=$vaultRemoteId');

      if (vaultRemoteId == null) {
        dev.log('[Sync] ✗ Vault not yet synced — skipping item ${entry.itemId}');
        return; // Vault must sync first
      }

      final record = await _pb.collection('vault_items').create(
        body: {
          'vaultRef': vaultRemoteId, // PB relation field name
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

      final key = _vaultKey;
      if (key == null) {
        dev.log('[Sync] ✗ Session locked — cannot encrypt vault name');
        return;
      }

      // D-11: encrypt vault name before sending to PocketBase
      final encryptedName = await _encryptVaultName(vault.name, key);

      final record = await _pb.collection('vault_collections').create(
        body: {
          'name': encryptedName,
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
      if (vault == null || vault.remoteId == null) return;

      final key = _vaultKey;
      if (key == null) {
        dev.log('[Sync] ✗ Session locked — cannot encrypt vault name');
        return;
      }

      // D-11: encrypt vault name before sending to PocketBase
      final encryptedName = await _encryptVaultName(vault.name, key);

      await _pb.collection('vault_collections').update(
        vault.remoteId!,
        body: {
          'name': encryptedName,
          'owner': userId,
          'colorHex': vault.colorHex,
          'iconName': vault.iconName,
        },
      );
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

    // Pull vault collections first (items reference them).
    final vaultRecords = await _pb.collection('vault_collections').getFullList(
      filter: filter,
    );
    for (final record in vaultRecords) {
      await _applyRemoteVaultRecord(record);
    }

    // Pull vault items.
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

  /// Apply a remote vault collection record to the local database.
  ///
  /// Decrypts the vault name (D-11) before storing locally.
  Future<void> _applyRemoteVaultRecord(RecordModel record) async {
    final key = _vaultKey;
    if (key == null) {
      dev.log('[Sync] ✗ Session locked — cannot decrypt vault name');
      return;
    }

    final rawName = record.getStringValue('name');
    final decryptedName = await _decryptVaultName(rawName, key);
    final colorHex = record.getStringValue('colorHex');
    final iconName = record.getStringValue('iconName');

    // Check if we have this vault locally by remote ID.
    final allVaults = await _vaultDao.getAllVaults();
    final localVault = allVaults.where((v) => v.remoteId == record.id).firstOrNull;

    if (localVault == null) {
      // New remote vault — insert locally with decrypted name.
      await _vaultDao.insertVault(
        VaultsCompanion(
          id: Value(record.id),
          name: Value(decryptedName),
          colorHex: Value(colorHex.isNotEmpty ? colorHex : '#4D4DCD'),
          iconName: Value(iconName.isNotEmpty ? iconName : 'shield'),
          // ignore: deprecated_member_use
          createdAt: Value(DateTime.parse(record.created)),
          // ignore: deprecated_member_use
          updatedAt: Value(DateTime.parse(record.updated)),
          remoteId: Value(record.id),
        ),
      );
      return;
    }

    // Conflict resolution: last-write-wins with local preference on tie (D-17).
    // ignore: deprecated_member_use
    final remoteUpdatedAt = DateTime.parse(record.updated);
    if (_localWins(localVault.updatedAt, remoteUpdatedAt)) {
      return;
    }

    // Remote wins — update local vault with decrypted name.
    await _vaultDao.updateVault(
      VaultsCompanion(
        id: Value(localVault.id),
        name: Value(decryptedName),
        colorHex: Value(colorHex.isNotEmpty ? colorHex : localVault.colorHex),
        iconName: Value(iconName.isNotEmpty ? iconName : localVault.iconName),
        updatedAt: Value(remoteUpdatedAt),
      ),
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
    final vaultId = record.getStringValue('vaultRef');

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
    dev.log('[Sync] Force full re-sync — clearing ALL queue, re-queuing all local data');

    // Wipe the entire sync queue (completed + pending + failed)
    await _syncDao.clearAll();

    // Also clear all remoteIds so vaults get new PB records
    final vaults = await _vaultDao.getAllVaults();
    for (final vault in vaults) {
      await _vaultDao.updateVault(
        VaultsCompanion(id: Value(vault.id), remoteId: const Value(null)),
      );
    }
    // Clear item remoteIds too
    for (final vault in vaults) {
      final items = await _vaultDao.getItemsByVault(vault.id);
      for (final item in items) {
        await _vaultDao.updateVaultItem(
          VaultItemsCompanion(id: Value(item.id), remoteId: const Value(null)),
        );
      }
    }

    // Re-queue all vaults FIRST
    for (final vault in vaults) {
      await _syncDao.enqueue(vault.id, 'vaults', 'create');
    }

    // Then re-queue all items
    for (final vault in vaults) {
      final items = await _vaultDao.getItemsByVault(vault.id);
      for (final item in items) {
        await _syncDao.enqueue(item.id, 'vault_items', 'create');
      }
    }

    dev.log('[Sync] Re-queued ${vaults.length} vaults and items — all clean');

    // Push immediately
    await syncNow();
  }

  /// Pull ALL vaults and items from PocketBase into the local database.
  ///
  /// This is a pull-only sync: it fetches every vault_collection and
  /// vault_item owned by the current user from PocketBase and
  /// inserts/updates them locally. No local data is pushed to the server.
  ///
  /// Primary use-case: restoring vaults after travel mode deactivation.
  /// Travel mode purges non-travel-safe vaults from the local DB, so a
  /// push-based resync would have nothing to push. This method restores
  /// the full vault set from the server.
  Future<void> pullFromServer() async {
    if (_isSyncing) return;

    final userId = _currentUserId;
    if (userId == null || !_pb.authStore.isValid) {
      dev.log('[Sync] pullFromServer — not authenticated, aborting');
      return;
    }
    if (_vaultKey == null) {
      dev.log('[Sync] pullFromServer — vault locked (no key), aborting');
      return;
    }

    _isSyncing = true;

    try {
      _emitState(const Syncing(pendingCount: 0));
      dev.log('[Sync] Pull-only sync — fetching all data from server');

      final filter = 'owner = "$userId"';

      // 1. Pull ALL vault collections (no date filter — we want everything).
      final vaultRecords = await _pb.collection('vault_collections').getFullList(
        filter: filter,
      );
      dev.log('[Sync] Pulled ${vaultRecords.length} vault(s) from server');
      for (final record in vaultRecords) {
        await _applyRemoteVaultRecord(record);
      }

      // 2. Pull ALL vault items.
      final itemRecords = await _pb.collection('vault_items').getFullList(
        filter: filter,
      );
      dev.log('[Sync] Pulled ${itemRecords.length} item(s) from server');
      for (final record in itemRecords) {
        await _applyRemoteRecord(record);
      }

      await _settingsDao.setSetting(
        'lastSync',
        DateTime.now().toUtc().toIso8601String(),
      );

      _emitState(SyncIdle(lastSyncAt: DateTime.now()));
      dev.log('[Sync] Pull-only sync complete');
    } catch (e) {
      dev.log('[Sync] Pull-only sync error: $e');
      _emitState(SyncError(message: e.toString(), failedAt: DateTime.now()));
    } finally {
      _isSyncing = false;
    }
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
