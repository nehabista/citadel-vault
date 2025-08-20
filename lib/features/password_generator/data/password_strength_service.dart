import 'dart:math';

import 'package:intl/intl.dart';
import 'package:zxcvbnm/languages/en.dart' as en;
import 'package:zxcvbnm/zxcvbnm.dart';

import '../domain/entities/password_strength.dart';

/// One global instance so dictionaries aren't reloaded repeatedly.
final _zxcvbnm = Zxcvbnm(dictionaries: en.dictionaries);

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
// Entropy (zxcvbnm)
// ---------------------------------------------------------------------------

/// Estimate entropy in bits using zxcvbnm's guessesLog10 -> bits (log2).
double estimateEntropyBits(String password) {
  if (password.isEmpty) return 0.0;
  final result = _zxcvbnm(password);
  const log10of2 = 0.30102999566; // log10(2)
  return result.guessesLog10 / log10of2;
}

/// A pragmatic classifier that balances rules + entropy.
Strength classifyStrength(PasswordChecks c, double bits) {
  if (c.passedCount >= 4 && bits >= 80) return Strength.strong;
  if (c.passedCount >= 3 && bits >= 40) return Strength.moderate;
  return Strength.weak;
}

// ---------------------------------------------------------------------------
// Crack time (realistic)
// ---------------------------------------------------------------------------

/// Internal: attack scenarios in guesses/sec.
Map<String, double> _attackScenarios() => {
      'Offline (fast hash, powerful GPU)': 1.0e13, // 10T g/s
      'Offline (slow hash, consumer GPU)': 1.0e5, // 100k g/s
      'Online (unthrottled)': 10.0, // 10 g/s
      'Online (throttled)': 100.0 / 3600.0,
    };

/// Detailed breakdown: scenario -> human-readable time.
Map<String, String> estimateCrackTimes(double bits) {
  final out = <String, String>{};
  if (bits <= 0) {
    for (final k in _attackScenarios().keys) {
      out[k] = '< 1 second';
    }
    return out;
  }
  final possibilities = pow(2, bits);
  _attackScenarios().forEach((scenario, gps) {
    final seconds = possibilities / gps;
    out[scenario] = _humanizeDurationVerbose(seconds.toDouble());
  });
  return out;
}

/// Single-line summary used by the gauge.
/// Shows the **worst-case** time (minimum across scenarios) to be conservative.
String estimateCrackTimeShort(double bits) {
  if (bits <= 0) return '<1s';
  final possibilities = pow(2, bits);
  double minSeconds = double.infinity;
  for (final gps in _attackScenarios().values) {
    minSeconds = min(minSeconds, possibilities / gps);
  }
  return _humanizeDurationShort(minSeconds);
}

// ---------------------------------------------------------------------------
// Duration formatting
// ---------------------------------------------------------------------------

String _humanizeDurationShort(double seconds) {
  if (seconds.isNaN || seconds.isInfinite || seconds <= 1) return '<1s';
  const minute = 60.0, hour = 3600.0, day = 86400.0, year = 31536000.0;

  if (seconds < minute) return '${seconds.toStringAsFixed(0)}s';
  if (seconds < hour) return '${(seconds / minute).toStringAsFixed(0)}m';
  if (seconds < day) return '${(seconds / hour).toStringAsFixed(0)}h';
  if (seconds < year) return '${(seconds / day).toStringAsFixed(0)}d';
  if (seconds < year * 100) return '${(seconds / year).toStringAsFixed(1)}y';
  if (seconds < year * 100000) {
    return '${(seconds / year).toStringAsFixed(0)} years';
  }
  return 'billions of years';
}

String _humanizeDurationVerbose(double seconds) {
  if (seconds.isNaN || seconds.isInfinite || seconds < 1) return '< 1 second';

  final formatter = NumberFormat.compact(locale: 'en_US');
  final precise = NumberFormat('#,##0.0', 'en_US');

  const minute = 60.0;
  const hour = 60 * minute;
  const day = 24 * hour;
  const month = 30.44 * day;
  const year = 365.25 * day;
  const millennium = 1000 * year;
  const millionYears = 1e6 * year;
  const billionYears = 1e9 * year;
  const trillionYears = 1e12 * year;
  const ageOfUniverse = 13.8 * billionYears;

  if (seconds >= ageOfUniverse * 1000) {
    return 'longer than the age of the universe';
  }
  if (seconds >= trillionYears) {
    return '~${formatter.format(seconds / trillionYears)} trillion years';
  }
  if (seconds >= billionYears) {
    return '~${formatter.format(seconds / billionYears)} billion years';
  }
  if (seconds >= millionYears) {
    return '~${formatter.format(seconds / millionYears)} million years';
  }
  if (seconds >= millennium * 10) {
    final yrs = (seconds / year).round();
    final s = yrs.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '~$s years';
  }
  if (seconds >= millennium) {
    return '~${precise.format(seconds / millennium)} millennia';
  }
  if (seconds >= year * 2) return '~${precise.format(seconds / year)} years';
  if (seconds >= month) return '~${precise.format(seconds / month)} months';
  if (seconds >= day) return '~${precise.format(seconds / day)} days';
  if (seconds >= hour) return '~${precise.format(seconds / hour)} hours';
  if (seconds >= minute) {
    return '~${precise.format(seconds / minute)} minutes';
  }
  return '${seconds.toStringAsFixed(0)} seconds';
}

// ---------------------------------------------------------------------------
// Tips
// ---------------------------------------------------------------------------

/// Improvement tips based on which checks failed.
List<String> improvementTips(PasswordChecks c, {int minLen = 12}) {
  final allGood =
      c.longEnough && c.hasUpper && c.hasLower && c.hasDigit && c.hasSpecial;
  if (allGood) {
    return const ["Nice! All checks passed -- you're good to go."];
  }

  final tips = <String>[];
  if (!c.longEnough) tips.add('Use at least $minLen characters.');
  if (!c.hasUpper) tips.add('Add uppercase letters (A-Z).');
  if (!c.hasLower) tips.add('Add lowercase letters (a-z).');
  if (!c.hasDigit) tips.add('Include digits (0-9).');
  if (!c.hasSpecial) tips.add('Include special characters (!@#...).');
  tips.add(
    'Consider a 4+ word random passphrase. Add numbers/case/symbols if needed. '
    'Example: glowering-armour-permanently-jacketS-@\$73.',
  );
  return tips;
}
