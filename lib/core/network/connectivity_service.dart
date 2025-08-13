import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps connectivity_plus to provide a simple online/offline stream.
/// Used by SyncEngine to trigger sync on connectivity changes.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream that emits true when any network connection is available,
  /// false when disconnected.
  Stream<bool> get onlineStream {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((r) => r != ConnectivityResult.none),
    );
  }

  /// Check current connectivity status.
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
