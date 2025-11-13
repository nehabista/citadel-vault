// File: lib/core/providers/session_provider.dart
// Session state notifier with lock/unlock lifecycle
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_state.dart';
import 'core_providers.dart';

/// Riverpod provider for session state management.
final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

/// Manages the session lifecycle: lock, unlock, auto-lock on background.
class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const Locked();

  /// Derives the vault key from master password + salt and transitions to Unlocked.
  Future<void> unlock(String masterPassword, String salt) async {
    final crypto = ref.read(cryptoEngineProvider);
    final saltBytes = base64.decode(salt);
    final key = await crypto.deriveKey(masterPassword, saltBytes);
    final keyBytes = await key.extractBytes();
    state = Unlocked(
      vaultKey: Uint8List.fromList(keyBytes),
      unlockedAt: DateTime.now(),
    );
  }

  /// Locks the session, clearing the key reference.
  void lock() {
    state = const Locked();
  }
}

/// Observes app lifecycle and auto-locks on pause (D-21).
/// [lockOnBackground] controls whether pausing the app triggers a lock.
class AppLifecycleObserver extends WidgetsBindingObserver {
  final SessionNotifier _notifier;
  bool lockOnBackground;

  AppLifecycleObserver(this._notifier, {this.lockOnBackground = true});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && lockOnBackground) {
      _notifier.lock();
    }
  }
}

/// Exception thrown when vault data is accessed while locked.
class VaultLockedException implements Exception {
  final String message;
  const VaultLockedException([this.message = 'Vault is locked']);

  @override
  String toString() => 'VaultLockedException: $message';
}
