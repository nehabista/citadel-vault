import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/crypto/encrypted_blob.dart';
import 'package:cryptography/cryptography.dart';

void main() {
  late CryptoEngine engine;

  setUp(() {
    engine = CryptoEngine();
  });

  group('CryptoEngine - Key Derivation', () {
    test('deriveKey produces a 32-byte key from password + salt', () async {
      final salt = List.generate(16, (i) => i);
      final key = await engine.deriveKey('testPassword123', salt);
      final keyBytes = await key.extractBytes();
      expect(keyBytes.length, 32);
    });

    test('deriveKey with same inputs produces same key', () async {
      final salt = List.generate(16, (i) => i + 5);
      final key1 = await engine.deriveKey('samePassword', salt);
      final key2 = await engine.deriveKey('samePassword', salt);
      final bytes1 = await key1.extractBytes();
      final bytes2 = await key2.extractBytes();
      expect(bytes1, bytes2);
    });

    test('deriveKey with different passwords produces different keys', () async {
      final salt = List.generate(16, (i) => i);
      final key1 = await engine.deriveKey('password1', salt);
      final key2 = await engine.deriveKey('password2', salt);
      final bytes1 = await key1.extractBytes();
      final bytes2 = await key2.extractBytes();
      expect(bytes1, isNot(equals(bytes2)));
    });
  });

  group('CryptoEngine - AES-256-GCM Encrypt/Decrypt', () {
    test('encrypt then decrypt roundtrip returns original plaintext', () async {
      final salt = List.generate(16, (i) => i);
      final key = await engine.deriveKey('testPassword', salt);
      final plaintext = utf8.encode('Hello, Citadel!');

      final encrypted = await engine.encrypt(Uint8List.fromList(plaintext), key);
      final decrypted = await engine.decrypt(encrypted, key);

      expect(utf8.decode(decrypted), 'Hello, Citadel!');
    });

    test('encrypt output starts with version byte 0x02 followed by 12-byte nonce', () async {
      final salt = List.generate(16, (i) => i);
      final key = await engine.deriveKey('testPassword', salt);
      final plaintext = utf8.encode('test data');

      final encrypted = await engine.encrypt(Uint8List.fromList(plaintext), key);

      expect(encrypted[0], 0x02); // version byte
      // Next 12 bytes are the nonce
      expect(encrypted.length, greaterThan(1 + 12 + 16)); // version + nonce + tag minimum
    });

    test('encrypt output ends with 16-byte GCM auth tag', () async {
      final salt = List.generate(16, (i) => i);
      final key = await engine.deriveKey('testPassword', salt);
      final plaintext = utf8.encode('test data for tag check');

      final encrypted = await engine.encrypt(Uint8List.fromList(plaintext), key);
      final blob = EncryptedBlob.fromBytes(encrypted);

      expect(blob.tag.length, 16);
    });

    test('decrypt with wrong key throws error', () async {
      final salt = List.generate(16, (i) => i);
      final rightKey = await engine.deriveKey('rightPassword', salt);
      final wrongKey = await engine.deriveKey('wrongPassword', salt);
      final plaintext = utf8.encode('secret data');

      final encrypted =
          await engine.encrypt(Uint8List.fromList(plaintext), rightKey);

      expect(
        () => engine.decrypt(encrypted, wrongKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('decrypt with corrupted ciphertext throws authentication error', () async {
      final salt = List.generate(16, (i) => i);
      final key = await engine.deriveKey('testPassword', salt);
      final plaintext = utf8.encode('data to corrupt');

      final encrypted = await engine.encrypt(Uint8List.fromList(plaintext), key);

      // Flip a bit in the ciphertext portion (after version byte + 12-byte nonce)
      final corrupted = Uint8List.fromList(encrypted);
      if (corrupted.length > 14) {
        corrupted[14] ^= 0xFF; // flip bits in ciphertext
      }

      expect(
        () => engine.decrypt(corrupted, key),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });

  group('CryptoEngine - Field Encryption', () {
    test('encryptFields serializes Map with all metadata fields to JSON then encrypts', () async {
      final salt = List.generate(16, (i) => i);
      final key = await engine.deriveKey('testPassword', salt);
      final fields = <String, dynamic>{
        'name': 'My Login',
        'url': 'https://example.com',
        'folder': 'Personal',
        'type': 'password',
        'favorite': true,
        'notes': 'Some notes',
        'username': 'user@example.com',
        'password': 'secret123',
      };

      final encrypted = await engine.encryptFields(fields, key);

      // Should be a v2 blob
      expect(encrypted[0], 0x02);
    });

    test('decryptFields returns the original Map with all metadata fields preserved', () async {
      final salt = List.generate(16, (i) => i);
      final key = await engine.deriveKey('testPassword', salt);
      final fields = <String, dynamic>{
        'name': 'My Login',
        'url': 'https://example.com',
        'folder': 'Personal',
        'type': 'password',
        'favorite': true,
        'notes': 'Some notes here',
        'customField1': 'value1',
      };

      final encrypted = await engine.encryptFields(fields, key);
      final decrypted = await engine.decryptFields(encrypted, key);

      expect(decrypted['name'], 'My Login');
      expect(decrypted['url'], 'https://example.com');
      expect(decrypted['folder'], 'Personal');
      expect(decrypted['type'], 'password');
      expect(decrypted['favorite'], true);
      expect(decrypted['notes'], 'Some notes here');
      expect(decrypted['customField1'], 'value1');
    });
  });

  group('CryptoEngine - Salt Generation', () {
    test('generateSalt returns 16 random bytes', () {
      final salt = engine.generateSalt();
      expect(salt.length, 16);
    });

    test('generateSalt produces different values each call', () {
      final salt1 = engine.generateSalt();
      final salt2 = engine.generateSalt();
      expect(salt1, isNot(equals(salt2)));
    });
  });
}
