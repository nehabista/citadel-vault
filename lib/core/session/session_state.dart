// File: lib/core/session/session_state.dart
// Sealed SessionState class for compile-time safety (D-20)
import 'dart:typed_data';

/// Sealed class representing the session state of the vault.
/// Uses Dart 3 sealed classes for exhaustive pattern matching.
sealed class SessionState {
  const SessionState();
}

/// The vault is locked -- no encryption key is available.
class Locked extends SessionState {
  const Locked();
}

/// The vault is unlocked -- the derived encryption key is in memory.
class Unlocked extends SessionState {
  final Uint8List vaultKey;
  final DateTime unlockedAt;

  const Unlocked({required this.vaultKey, required this.unlockedAt});
}
