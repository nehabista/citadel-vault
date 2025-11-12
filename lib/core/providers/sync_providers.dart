import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_service.dart';
import '../session/session_state.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_state.dart';
import 'core_providers.dart';
import 'session_provider.dart';

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
    cryptoEngine: ref.watch(cryptoEngineProvider),
    getVaultKeyBytes: () {
      // Read the current session state to get vault key bytes.
      // Returns null if session is locked (sync will skip encryption).
      final session = ref.read(sessionProvider);
      return switch (session) {
        Unlocked(:final vaultKey) => vaultKey,
        Locked() => null,
      };
    },
  );

  // Listen to connectivity changes -- trigger sync when coming online.
  final subscription = syncEngine.listenToConnectivity();

  // Normal sync on startup (not forceFullResync which re-queues everything).
  syncEngine.syncNow();

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
