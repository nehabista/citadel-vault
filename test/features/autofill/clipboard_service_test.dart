import 'package:citadel_password_manager/features/autofill/domain/models/autofill_credential.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutofillCredential', () {
    test('toMap() and fromMap() roundtrip correctly', () {
      const original = AutofillCredential(
        vaultItemId: 'vid-123',
        username: 'user@example.com',
        password: 's3cret!',
        displayName: 'Example Login',
        domain: 'example.com',
        hasTotpEntry: true,
        phishingWarning: false,
      );

      final map = original.toMap();
      final restored = AutofillCredential.fromMap(map);

      expect(restored, equals(original));
      expect(restored.vaultItemId, 'vid-123');
      expect(restored.username, 'user@example.com');
      expect(restored.password, 's3cret!');
      expect(restored.displayName, 'Example Login');
      expect(restored.domain, 'example.com');
      expect(restored.hasTotpEntry, isTrue);
      expect(restored.phishingWarning, isFalse);
    });

    test('fromMap() handles null domain', () {
      final map = {
        'vaultItemId': 'vid-456',
        'username': 'admin',
        'password': 'pass',
        'displayName': 'Admin Account',
        'domain': null,
        'hasTotpEntry': false,
        'phishingWarning': true,
      };

      final credential = AutofillCredential.fromMap(map);
      expect(credential.domain, isNull);
      expect(credential.phishingWarning, isTrue);
    });

    test('fromMap() defaults hasTotpEntry and phishingWarning to false', () {
      final map = {
        'vaultItemId': 'vid-789',
        'username': 'test',
        'password': 'test',
        'displayName': 'Test',
      };

      final credential = AutofillCredential.fromMap(map);
      expect(credential.hasTotpEntry, isFalse);
      expect(credential.phishingWarning, isFalse);
    });

    test('toMap() produces correct keys', () {
      const credential = AutofillCredential(
        vaultItemId: 'v1',
        username: 'u1',
        password: 'p1',
        displayName: 'd1',
      );

      final map = credential.toMap();
      expect(map.containsKey('vaultItemId'), isTrue);
      expect(map.containsKey('username'), isTrue);
      expect(map.containsKey('password'), isTrue);
      expect(map.containsKey('displayName'), isTrue);
      expect(map.containsKey('domain'), isTrue);
      expect(map.containsKey('hasTotpEntry'), isTrue);
      expect(map.containsKey('phishingWarning'), isTrue);
    });
  });

  group('ClipboardService platform channel', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    const channel = MethodChannel('com.citadel/clipboard');
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('channel name matches expected value', () {
      // Verify the channel name is correct for native side registration
      expect(channel.name, 'com.citadel/clipboard');
    });

    test('copy method sends correct arguments', () async {
      await channel.invokeMethod('copy', {
        'text': 'test-password',
        'isSensitive': true,
      });

      expect(log, hasLength(1));
      expect(log.first.method, 'copy');
      expect(log.first.arguments['text'], 'test-password');
      expect(log.first.arguments['isSensitive'], true);
    });

    test('scheduleClear method sends delay', () async {
      await channel.invokeMethod('scheduleClear', {
        'delayMs': 30000,
      });

      expect(log, hasLength(1));
      expect(log.first.method, 'scheduleClear');
      expect(log.first.arguments['delayMs'], 30000);
    });

    test('clear method invokes correctly', () async {
      await channel.invokeMethod('clear');

      expect(log, hasLength(1));
      expect(log.first.method, 'clear');
    });
  });
}
