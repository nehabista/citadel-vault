import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:citadel_password_manager/core/crypto/encrypted_blob.dart';
import 'package:citadel_password_manager/core/crypto/legacy_crypto.dart';
import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';

void main() {
  group('v1 Compatibility', () {
    test('EncryptedBlob.isV1Format correctly identifies v1 format strings', () {
      final iv = base64.encode(List.generate(16, (i) => i));
      final ct = base64.encode(List.generate(32, (i) => i + 0x20));
      final v1String = '$iv:$ct';

      expect(EncryptedBlob.isV1Format(v1String), isTrue);
    });

    test('EncryptedBlob.isV1Format returns false for plain text', () {
      expect(EncryptedBlob.isV1Format('not:valid:base64'), isFalse);
      expect(EncryptedBlob.isV1Format('justtext'), isFalse);
      expect(EncryptedBlob.isV1Format(''), isFalse);
    });

    test('EncryptedBlob.isV1Format returns false for v2 binary blobs', () {
      final nonce = Uint8List.fromList(List.generate(12, (i) => i));
      final ciphertext = Uint8List.fromList(List.generate(20, (i) => i + 0x30));
      final tag = Uint8List.fromList(List.generate(16, (i) => i + 0x50));
      final v2Bytes = Uint8List.fromList([0x02, ...nonce, ...ciphertext, ...tag]);
      final v2Base64 = base64.encode(v2Bytes);

      expect(EncryptedBlob.isV1Format(v2Base64), isFalse);
    });

    test('v1 decrypt followed by v2 encrypt produces blob that v2 decrypt can read (migration roundtrip)', () async {
      final legacyCrypto = LegacyCrypto();
      final cryptoEngine = CryptoEngine();

      // Step 1: Create v1 encrypted data
      final v1Salt = base64.encode(List.generate(16, (i) => i));
      final v1Key = await legacyCrypto.deriveKey('migrationTest', v1Salt);
      final originalPlaintext = '{"name":"My Login","password":"secret123","url":"https://example.com"}';
      final v1Encrypted = await legacyCrypto.encryptForTesting(originalPlaintext, v1Key);

      // Verify it's v1 format
      expect(EncryptedBlob.isV1Format(v1Encrypted), isTrue);

      // Step 2: Decrypt with legacy crypto
      final decrypted = await legacyCrypto.decrypt(v1Encrypted, v1Key);
      expect(decrypted, originalPlaintext);

      // Step 3: Re-encrypt with v2 (CryptoEngine)
      final v2Salt = cryptoEngine.generateSalt();
      final v2Key = await cryptoEngine.deriveKey('migrationTest', v2Salt);
      final v2Encrypted = await cryptoEngine.encrypt(
        Uint8List.fromList(utf8.encode(decrypted)),
        v2Key,
      );

      // Verify it's v2 format
      expect(v2Encrypted[0], 0x02);

      // Step 4: Decrypt with CryptoEngine
      final v2Decrypted = await cryptoEngine.decrypt(v2Encrypted, v2Key);
      expect(utf8.decode(v2Decrypted), originalPlaintext);
    });

    test('v1 decrypt and v2 encrypt preserves JSON fields exactly', () async {
      final legacyCrypto = LegacyCrypto();
      final cryptoEngine = CryptoEngine();

      final fields = {
        'name': 'Bank Login',
        'url': 'https://bank.com',
        'folder': 'Finance',
        'type': 'password',
        'favorite': true,
        'notes': 'Primary checking account',
        'username': 'john@example.com',
        'password': 'b@nkP@ss!',
      };

      final jsonText = jsonEncode(fields);

      // Encrypt with v1
      final v1Salt = base64.encode(List.generate(16, (i) => i + 3));
      final v1Key = await legacyCrypto.deriveKey('testPass', v1Salt);
      final v1Encrypted = await legacyCrypto.encryptForTesting(jsonText, v1Key);

      // Decrypt with v1
      final decrypted = await legacyCrypto.decrypt(v1Encrypted, v1Key);

      // Re-encrypt with v2
      final v2Salt = cryptoEngine.generateSalt();
      final v2Key = await cryptoEngine.deriveKey('newPass', v2Salt);
      final v2Encrypted = await cryptoEngine.encryptFields(
        jsonDecode(decrypted) as Map<String, dynamic>,
        v2Key,
      );

      // Decrypt with v2
      final result = await cryptoEngine.decryptFields(v2Encrypted, v2Key);

      expect(result['name'], 'Bank Login');
      expect(result['url'], 'https://bank.com');
      expect(result['folder'], 'Finance');
      expect(result['type'], 'password');
      expect(result['favorite'], true);
      expect(result['notes'], 'Primary checking account');
      expect(result['username'], 'john@example.com');
      expect(result['password'], 'b@nkP@ss!');
    });
  });
}
