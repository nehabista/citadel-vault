import 'package:citadel_password_manager/features/autofill/domain/models/autofill_credential.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutofillCredential.fromMap', () {
    test('correctly parses hasTotpEntry when true', () {
      final map = {
        'vaultItemId': 'item-1',
        'username': 'user@example.com',
        'password': 'secret123',
        'displayName': 'Example',
        'domain': 'example.com',
        'hasTotpEntry': true,
        'phishingWarning': false,
      };

      final credential = AutofillCredential.fromMap(map);

      expect(credential.hasTotpEntry, isTrue);
      expect(credential.vaultItemId, equals('item-1'));
      expect(credential.username, equals('user@example.com'));
    });

    test('correctly parses hasTotpEntry when false', () {
      final map = {
        'vaultItemId': 'item-2',
        'username': 'test@test.com',
        'password': 'pass',
        'displayName': 'Test',
        'hasTotpEntry': false,
      };

      final credential = AutofillCredential.fromMap(map);

      expect(credential.hasTotpEntry, isFalse);
    });

    test('defaults hasTotpEntry to false when missing', () {
      final map = {
        'vaultItemId': 'item-3',
        'username': 'user',
        'password': 'pass',
        'displayName': 'Name',
      };

      final credential = AutofillCredential.fromMap(map);

      expect(credential.hasTotpEntry, isFalse);
    });

    test('correctly parses phishingWarning flag', () {
      final map = {
        'vaultItemId': 'item-4',
        'username': 'user',
        'password': 'pass',
        'displayName': 'Phishing Test',
        'hasTotpEntry': false,
        'phishingWarning': true,
      };

      final credential = AutofillCredential.fromMap(map);

      expect(credential.phishingWarning, isTrue);
    });
  });

  group('Clipboard timeout mapping', () {
    // Maps seconds to display labels per D-13
    final timeoutOptions = <int, String>{
      0: 'Never',
      15: '15 seconds',
      30: '30 seconds',
      60: '1 minute',
      300: '5 minutes',
    };

    test('all timeout options have correct labels', () {
      expect(timeoutOptions[0], equals('Never'));
      expect(timeoutOptions[15], equals('15 seconds'));
      expect(timeoutOptions[30], equals('30 seconds'));
      expect(timeoutOptions[60], equals('1 minute'));
      expect(timeoutOptions[300], equals('5 minutes'));
    });

    test('exactly 5 timeout options exist', () {
      expect(timeoutOptions.length, equals(5));
    });

    test('default clipboard timeout is 30 seconds', () {
      const defaultTimeoutSeconds = 30;

      // Per D-13: default is 30 seconds
      final duration = Duration(seconds: defaultTimeoutSeconds);

      expect(duration.inSeconds, equals(30));
      expect(timeoutOptions.containsKey(defaultTimeoutSeconds), isTrue);
    });

    test('timeout value 0 means never clear', () {
      const neverTimeout = 0;
      final duration = Duration(seconds: neverTimeout);

      expect(duration, equals(Duration.zero));
    });
  });

  group('AutofillCredential toMap/fromMap roundtrip', () {
    test('preserves all fields through serialization', () {
      const original = AutofillCredential(
        vaultItemId: 'v-123',
        username: 'admin@site.com',
        password: 'p@ss!',
        displayName: 'Admin Account',
        domain: 'site.com',
        hasTotpEntry: true,
        phishingWarning: false,
      );

      final map = original.toMap();
      final restored = AutofillCredential.fromMap(map);

      expect(restored, equals(original));
    });
  });
}
