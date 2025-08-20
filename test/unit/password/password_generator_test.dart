import 'package:flutter_test/flutter_test.dart';

import 'package:citadel_password_manager/features/password_generator/data/password_generator_service.dart';

void main() {
  group('generatePassword', () {
    test('produces a password of the requested length', () {
      final pwd = generatePassword(
        length: 16,
        upper: true,
        lower: true,
        digits: true,
        symbols: false,
        pronounceable: false,
      );
      expect(pwd.length, 16);
    });

    test('contains chars from each selected pool', () {
      // Run several times to account for randomness.
      for (var i = 0; i < 10; i++) {
        final pwd = generatePassword(
          length: 16,
          upper: true,
          lower: true,
          digits: true,
          symbols: false,
          pronounceable: false,
        );
        expect(pwd, matches(RegExp(r'[A-Z]')), reason: 'should have upper');
        expect(pwd, matches(RegExp(r'[a-z]')), reason: 'should have lower');
        expect(pwd, matches(RegExp(r'[0-9]')), reason: 'should have digit');
      }
    });

    test('pronounceable mode generates hyphen-separated passphrase', () {
      final pwd = generatePassword(
        length: 20,
        upper: true,
        lower: true,
        digits: true,
        symbols: true,
        pronounceable: true,
      );
      expect(pwd.contains('-'), isTrue,
          reason: 'passphrase should contain hyphens');
      // Should have at least 4 word segments
      expect(pwd.split('-').length, greaterThanOrEqualTo(4));
    });

    test('falls back to lowercase+digits when all pools false', () {
      final pwd = generatePassword(
        length: 12,
        upper: false,
        lower: false,
        digits: false,
        symbols: false,
        pronounceable: false,
      );
      expect(pwd.length, 12);
      // Should only contain lowercase and digits (fallback pools)
      expect(pwd, matches(RegExp(r'^[a-z0-9]+$')));
    });
  });

  group('generatePassphrase', () {
    test('generates words joined by separator', () {
      final pp = generatePassphrase(
        wordCount: 4,
        separator: '-',
        addDigit: false,
        addSymbol: false,
        randomCapitalization: false,
      );
      expect(pp.split('-').length, 4);
    });

    test('appends digit segment when addDigit is true', () {
      final pp = generatePassphrase(
        wordCount: 3,
        separator: '-',
        addDigit: true,
        addSymbol: false,
        randomCapitalization: false,
      );
      // 3 words + 1 digit segment = 4 parts
      final parts = pp.split('-');
      expect(parts.length, 4);
      // last part should be a 2-digit number (10-99)
      expect(int.tryParse(parts.last), isNotNull);
    });
  });
}
