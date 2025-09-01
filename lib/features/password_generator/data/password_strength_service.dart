import 'dart:math';

import '../domain/entities/password_strength.dart';

// ---------------------------------------------------------------------------
// Regex helpers
// ---------------------------------------------------------------------------
final _upper = RegExp(r'[A-Z]');
final _lower = RegExp(r'[a-z]');
final _digit = RegExp(r'\d');
final _special = RegExp(r'[^\w\s]');

// ---------------------------------------------------------------------------
// Checks
// ---------------------------------------------------------------------------

/// Run basic character-pool checks on [input].
PasswordChecks runChecks(String input, {int minLen = 12}) {
  return PasswordChecks(
    longEnough: input.length >= minLen,
    hasUpper: _upper.hasMatch(input),
    hasLower: _lower.hasMatch(input),
    hasDigit: _digit.hasMatch(input),
    hasSpecial: _special.hasMatch(input),
  );
}

// ---------------------------------------------------------------------------
// Entropy estimation (simplified - no zxcvbnm dependency for this worktree)
// ---------------------------------------------------------------------------

/// Estimate entropy in bits based on character pool size and length.
double estimateEntropyBits(String password) {
  if (password.isEmpty) return 0.0;
  int poolSize = 0;
  if (_lower.hasMatch(password)) poolSize += 26;
  if (_upper.hasMatch(password)) poolSize += 26;
  if (_digit.hasMatch(password)) poolSize += 10;
  if (_special.hasMatch(password)) poolSize += 32;
  if (poolSize == 0) poolSize = 26; // fallback
  return password.length * (log(poolSize) / log(2));
}

/// A pragmatic classifier that balances rules + entropy.
Strength classifyStrength(PasswordChecks c, double bits) {
  if (c.passedCount >= 4 && bits >= 80) return Strength.strong;
  if (c.passedCount >= 3 && bits >= 40) return Strength.moderate;
  return Strength.weak;
}
