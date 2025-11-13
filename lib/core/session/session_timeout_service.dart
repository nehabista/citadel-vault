// File: lib/core/session/session_timeout_service.dart
// Manages auto-lock timer that fires after user inactivity.
import 'dart:async';
import 'dart:ui' show VoidCallback;

/// Configurable session timeout that auto-locks the vault after inactivity.
///
/// Timer resets on every user interaction (tap, scroll, type).
/// A timeout of 0 means "Never" (no auto-lock).
class SessionTimeoutService {
  Timer? _timer;
  int _timeoutMinutes;
  final VoidCallback onTimeout;

  SessionTimeoutService({
    required this.onTimeout,
    int initialTimeoutMinutes = 5,
  }) : _timeoutMinutes = initialTimeoutMinutes;

  /// Current timeout in minutes. 0 = never.
  int get timeoutMinutes => _timeoutMinutes;

  /// Update the timeout duration. Resets the running timer.
  void configure(int minutes) {
    _timeoutMinutes = minutes;
    resetTimer();
  }

  /// Reset (restart) the inactivity timer.
  /// Call this on every user interaction.
  void resetTimer() {
    _timer?.cancel();
    if (_timeoutMinutes <= 0) return; // "Never" — no auto-lock
    _timer = Timer(Duration(minutes: _timeoutMinutes), onTimeout);
  }

  /// Stop the timer entirely (e.g. when session is already locked).
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether a timeout timer is actively running.
  bool get isRunning => _timer?.isActive ?? false;

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
