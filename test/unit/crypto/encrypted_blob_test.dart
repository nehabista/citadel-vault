import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:citadel_password_manager/core/crypto/encrypted_blob.dart';

void main() {
  group('EncryptedBlob', () {
    test('fromBytes parses v2 format correctly (version, nonce, ciphertext, tag)', () {
      // Build a fake v2 blob: [0x02][12-byte nonce][N-byte ciphertext][16-byte tag]
      final nonce = Uint8List.fromList(List.generate(12, (i) => i + 1));
      final ciphertext = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]);
      final tag = Uint8List.fromList(List.generate(16, (i) => i + 0x10));

      final blob = Uint8List.fromList([0x02, ...nonce, ...ciphertext, ...tag]);
      final parsed = EncryptedBlob.fromBytes(blob);

      expect(parsed.version, CryptoVersion.v2);
      expect(parsed.nonce, nonce);
      expect(parsed.ciphertext, ciphertext);
      expect(parsed.tag, tag);
    });

    test('toBytes serializes back to correct v2 format', () {
      final nonce = Uint8List.fromList(List.generate(12, (i) => i + 1));
      final ciphertext = Uint8List.fromList([0xAA, 0xBB, 0xCC]);
      final tag = Uint8List.fromList(List.generate(16, (i) => i + 0x10));

      final blob = EncryptedBlob(
        version: CryptoVersion.v2,
        nonce: nonce,
        ciphertext: ciphertext,
        tag: tag,
      );

      final bytes = blob.toBytes();
      expect(bytes[0], 0x02);
      expect(bytes.sublist(1, 13), nonce);
      expect(bytes.sublist(13, 16), ciphertext);
      expect(bytes.sublist(16), tag);
    });

    test('fromBytes and toBytes roundtrip preserves data', () {
      final nonce = Uint8List.fromList(List.generate(12, (i) => i));
      final ciphertext = Uint8List.fromList(List.generate(50, (i) => i * 2));
      final tag = Uint8List.fromList(List.generate(16, (i) => 0xFF - i));

      final original = EncryptedBlob(
        version: CryptoVersion.v2,
        nonce: nonce,
        ciphertext: ciphertext,
        tag: tag,
      );

      final reconstructed = EncryptedBlob.fromBytes(original.toBytes());
      expect(reconstructed.version, original.version);
      expect(reconstructed.nonce, original.nonce);
      expect(reconstructed.ciphertext, original.ciphertext);
      expect(reconstructed.tag, original.tag);
    });

    test('isV1Format detects v1 "iv_base64:ciphertext_base64" strings', () {
      final iv = base64.encode(List.generate(16, (i) => i));
      final ct = base64.encode(List.generate(32, (i) => i + 0x20));
      final v1String = '$iv:$ct';

      expect(EncryptedBlob.isV1Format(v1String), isTrue);
    });

    test('isV1Format returns false for strings without colon', () {
      expect(EncryptedBlob.isV1Format('justbase64data'), isFalse);
    });

    test('isV1Format returns false for v2 binary blobs encoded as base64', () {
      final nonce = Uint8List.fromList(List.generate(12, (i) => i + 1));
      final ciphertext = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]);
      final tag = Uint8List.fromList(List.generate(16, (i) => i + 0x10));
      final v2Bytes = Uint8List.fromList([0x02, ...nonce, ...ciphertext, ...tag]);
      final v2Base64 = base64.encode(v2Bytes);

      // v2 base64 should not have a colon separator
      expect(EncryptedBlob.isV1Format(v2Base64), isFalse);
    });

    test('fromBase64 decodes base64 then parses as v2 blob', () {
      final nonce = Uint8List.fromList(List.generate(12, (i) => i + 1));
      final ciphertext = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]);
      final tag = Uint8List.fromList(List.generate(16, (i) => i + 0x10));
      final v2Bytes = Uint8List.fromList([0x02, ...nonce, ...ciphertext, ...tag]);
      final b64 = base64.encode(v2Bytes);

      final parsed = EncryptedBlob.fromBase64(b64);
      expect(parsed.version, CryptoVersion.v2);
      expect(parsed.nonce, nonce);
    });
  });
}
