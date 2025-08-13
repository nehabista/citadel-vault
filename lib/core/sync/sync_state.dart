/// Sealed class representing the current state of the sync engine.
/// Used by UI to show sync status indicators.
sealed class SyncState {
  const SyncState();
}

/// Sync is idle -- no active sync operation.
class SyncIdle extends SyncState {
  final DateTime? lastSyncAt;
  const SyncIdle({this.lastSyncAt});
}

/// Sync is in progress.
class Syncing extends SyncState {
  final int pendingCount;
  const Syncing({required this.pendingCount});
}

/// Sync encountered an error.
class SyncError extends SyncState {
  final String message;
  final DateTime failedAt;
  const SyncError({required this.message, required this.failedAt});
}
