// File: lib/core/session/pin_rate_limiter.dart
// In-memory PIN attempt rate limiter (resets on app restart — acceptable for v1).

/// Tracks failed PIN attempts and enforces progressive lockout:
///   - 5 failures  -> 30-second lockout
///   - 10 failures -> 5-minute lockout
///   - 15 failures -> PIN disabled for session (master password required)
class PinRateLimiter {
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  /// Number of consecutive failed attempts.
  int get failedAttempts => _failedAttempts;

  /// Whether the user is currently locked out.
  bool get isLockedOut =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  /// Whether PIN is permanently disabled for this session (15+ failures).
  bool get isPinDisabledForSession => _failedAttempts >= 15;

  /// Remaining lockout duration, or [Duration.zero] if not locked out.
  Duration get remainingLockout {
    if (_lockoutUntil == null) return Duration.zero;
    final remaining = _lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Record a failed PIN attempt and apply lockout if needed.
  /// Returns the lockout duration (zero if no lockout triggered).
  Duration recordFailure() {
    _failedAttempts++;

    if (_failedAttempts >= 15) {
      // PIN disabled for this session — no timer, just blocked.
      _lockoutUntil = null;
      return Duration.zero;
    } else if (_failedAttempts >= 10) {
      _lockoutUntil = DateTime.now().add(const Duration(minutes: 5));
      return const Duration(minutes: 5);
    } else if (_failedAttempts >= 5) {
      _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
      return const Duration(seconds: 30);
    }

    return Duration.zero;
  }

  /// Reset after a successful unlock.
  void reset() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }
}
