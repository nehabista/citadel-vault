import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_service.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_state.dart';
import 'core_providers.dart';

/// Provides ConnectivityService for network monitoring.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Provides the SyncEngine with all dependencies injected.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncEngine = SyncEngine(
    syncDao: db.syncDao,
    vaultDao: db.vaultDao,
    settingsDao: db.settingsDao,
    pb: ref.watch(pocketBaseClientProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );

  // Listen to connectivity changes -- trigger sync when coming online.
  final subscription = syncEngine.listenToConnectivity();

  // Reset any entries that previously failed, then sync immediately.
  syncEngine.resetFailedEntries().then((_) => syncEngine.syncNow());

  // Start periodic sync (30 seconds).
  syncEngine.startPeriodicSync();

  ref.onDispose(() {
    subscription.cancel();
    syncEngine.dispose();
  });

  return syncEngine;
});

/// Stream provider for observing sync state changes in UI.
final syncStateProvider = StreamProvider<SyncState>((ref) {
  return ref.watch(syncEngineProvider).stateStream;
});
