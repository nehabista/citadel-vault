import 'package:flutter_test/flutter_test.dart';

import 'package:citadel_password_manager/features/password_generator/data/password_strength_service.dart';
import 'package:citadel_password_manager/features/password_generator/domain/entities/password_strength.dart';

void main() {
  group('estimateEntropyBits', () {
    test('returns 0.0 for empty string', () {
      expect(estimateEntropyBits(''), 0.0);
    });

    test('returns low bits for weak password', () {
      final bits = estimateEntropyBits('password123');
      expect(bits, lessThan(60));
    });

    test('returns high bits for random 20-char string', () {
      // A truly random-looking string should score high.
      final bits = estimateEntropyBits('kX9#mP2\$vL7!nQ4@wR6&');
      expect(bits, greaterThan(60));
    });
  });

  group('classifyStrength', () {
    test('returns strong when passedCount>=4 and bits>=80', () {
      const checks = PasswordChecks(
        longEnough: true,
        hasUpper: true,
        hasLower: true,
        hasDigit: true,
        hasSpecial: false,
      );
      expect(classifyStrength(checks, 80), Strength.strong);
    });

    test('returns moderate when passedCount>=3 and bits>=40', () {
      const checks = PasswordChecks(
        longEnough: true,
        hasUpper: true,
        hasLower: true,
        hasDigit: false,
        hasSpecial: false,
      );
      expect(classifyStrength(checks, 45), Strength.moderate);
    });

    test('returns weak when passedCount<3 or bits<40', () {
      const checks = PasswordChecks(
        longEnough: false,
        hasUpper: false,
        hasLower: true,
        hasDigit: true,
        hasSpecial: false,
      );
      expect(classifyStrength(checks, 10), Strength.weak);
    });
  });

  group('runChecks', () {
    test('detects character types correctly', () {
      final c = runChecks('Abc1!');
      expect(c.longEnough, isFalse, reason: 'Abc1! is < 12 chars');
      expect(c.hasUpper, isTrue);
      expect(c.hasLower, isTrue);
      expect(c.hasDigit, isTrue);
      expect(c.hasSpecial, isTrue);
    });

    test('respects custom minLen', () {
      final c = runChecks('short', minLen: 3);
      expect(c.longEnough, isTrue);
    });
  });

  group('estimateCrackTimes', () {
    test('returns < 1 second for 0 bits', () {
      final times = estimateCrackTimes(0);
      expect(times.length, 4);
      for (final v in times.values) {
        expect(v, '< 1 second');
      }
    });

    test('returns map with 4 scenarios', () {
      final times = estimateCrackTimes(50);
      expect(times.length, 4);
      expect(times.keys, contains('Offline (fast hash, powerful GPU)'));
      expect(times.keys, contains('Online (throttled)'));
    });
  });

  group('estimateCrackTimeShort', () {
    test('returns <1s for 0 bits', () {
      expect(estimateCrackTimeShort(0), '<1s');
    });

    test('returns non-trivial string for high entropy', () {
      // 80 bits requires ~10^24 guesses; even at 10T/s that's years.
      final result = estimateCrackTimeShort(80);
      expect(result, isNotEmpty);
      expect(result, isNot('<1s'));
    });
  });

  group('improvementTips', () {
    test('returns congratulatory message when all checks pass', () {
      const checks = PasswordChecks(
        longEnough: true,
        hasUpper: true,
        hasLower: true,
        hasDigit: true,
        hasSpecial: true,
      );
      final tips = improvementTips(checks);
      expect(tips.length, 1);
      expect(tips.first, contains('All checks passed'));
    });

    test('returns specific tips for missing checks', () {
      const checks = PasswordChecks(
        longEnough: false,
        hasUpper: false,
        hasLower: true,
        hasDigit: true,
        hasSpecial: false,
      );
      final tips = improvementTips(checks);
      expect(tips.length, greaterThan(1));
      expect(tips.any((t) => t.contains('12 characters')), isTrue);
      expect(tips.any((t) => t.contains('uppercase')), isTrue);
    });
  });
}
