import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/password_strength_service.dart';
import '../../domain/entities/password_strength.dart';

/// Tracks the password currently being analyzed (typed or generated).
class CurrentPasswordNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String password) => state = password;
}

/// Provider for the password being analyzed.
final currentPasswordProvider =
    NotifierProvider<CurrentPasswordNotifier, String>(
  CurrentPasswordNotifier.new,
);

/// Derived provider: entropy bits of the current password.
final entropyBitsProvider = Provider<double>((ref) {
  final pwd = ref.watch(currentPasswordProvider);
  return estimateEntropyBits(pwd);
});

/// Derived provider: character-pool checks for the current password.
final passwordChecksProvider = Provider<PasswordChecks>((ref) {
  final pwd = ref.watch(currentPasswordProvider);
  return runChecks(pwd);
});

/// Derived provider: overall strength classification.
final strengthProvider = Provider<Strength>((ref) {
  final checks = ref.watch(passwordChecksProvider);
  final bits = ref.watch(entropyBitsProvider);
  return classifyStrength(checks, bits);
});

/// Derived provider: detailed crack times for all scenarios.
final crackTimesProvider = Provider<Map<String, String>>((ref) {
  final bits = ref.watch(entropyBitsProvider);
  return estimateCrackTimes(bits);
});

/// Derived provider: short crack time string for gauge display.
final crackTimeShortProvider = Provider<String>((ref) {
  final bits = ref.watch(entropyBitsProvider);
  return estimateCrackTimeShort(bits);
});

/// Derived provider: improvement tips based on checks.
final tipsProvider = Provider<List<String>>((ref) {
  final checks = ref.watch(passwordChecksProvider);
  return improvementTips(checks);
});
