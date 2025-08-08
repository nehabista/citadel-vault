import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:citadel_password_manager/core/crypto/legacy_crypto.dart';

void main() {
  late LegacyCrypto legacyCrypto;

  setUp(() {
    legacyCrypto = LegacyCrypto();
  });

  group('LegacyCrypto - Key Derivation', () {
    test('deriveKey produces a 32-byte key from password + salt', () async {
      final salt = base64.encode(List.generate(16, (i) => i));
      final key = await legacyCrypto.deriveKey('testPassword', salt);
      final keyBytes = await key.extractBytes();
      expect(keyBytes.length, 32);
    });

    test('deriveKey with same inputs produces same key', () async {
      final salt = base64.encode(List.generate(16, (i) => i + 5));
      final key1 = await legacyCrypto.deriveKey('samePassword', salt);
      final key2 = await legacyCrypto.deriveKey('samePassword', salt);
      final bytes1 = await key1.extractBytes();
      final bytes2 = await key2.extractBytes();
      expect(bytes1, bytes2);
    });

    test('deriveKey with different passwords produces different keys', () async {
      final salt = base64.encode(List.generate(16, (i) => i));
      final key1 = await legacyCrypto.deriveKey('password1', salt);
      final key2 = await legacyCrypto.deriveKey('password2', salt);
      final bytes1 = await key1.extractBytes();
      final bytes2 = await key2.extractBytes();
      expect(bytes1, isNot(equals(bytes2)));
    });
  });

  group('LegacyCrypto - Decryption', () {
    test('decrypt with invalid format (no colon) throws FormatException', () async {
      final salt = base64.encode(List.generate(16, (i) => i));
      final key = await legacyCrypto.deriveKey('testPassword', salt);

      expect(
        () => legacyCrypto.decrypt('invalidformatwithoutcolon', key),
        throwsA(isA<FormatException>()),
      );
    });

    test('decrypt with known v1 ciphertext returns correct plaintext', () async {
      // We'll use the LegacyCrypto itself to generate a known v1 ciphertext
      // by encrypting with the same AES-CBC algorithm internally for testing.
      // This tests the core decrypt path with a controlled input.
      final salt = base64.encode(List.generate(16, (i) => i));
      final key = await legacyCrypto.deriveKey('testPassword', salt);

      // Create a known v1 format ciphertext using internal encrypt helper
      final plaintext = 'Hello, Legacy World!';
      final encrypted = await legacyCrypto.encryptForTesting(plaintext, key);

      // Now decrypt should return the original plaintext
      final decrypted = await legacyCrypto.decrypt(encrypted, key);
      expect(decrypted, plaintext);
    });

    test('decrypt roundtrip with JSON data preserves structure', () async {
      final salt = base64.encode(List.generate(16, (i) => i + 10));
      final key = await legacyCrypto.deriveKey('myPassword', salt);

      final jsonData = jsonEncode({
        'username': 'test@example.com',
        'password': 'secret123',
        'notes': 'Some notes',
      });

      final encrypted = await legacyCrypto.encryptForTesting(jsonData, key);
      final decrypted = await legacyCrypto.decrypt(encrypted, key);
      final parsed = jsonDecode(decrypted) as Map<String, dynamic>;

      expect(parsed['username'], 'test@example.com');
      expect(parsed['password'], 'secret123');
      expect(parsed['notes'], 'Some notes');
    });
  });
}
