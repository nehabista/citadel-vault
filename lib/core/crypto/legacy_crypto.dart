import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Legacy v1 decryption. PBKDF2 (SHA256, 1M iterations) + AES-256-CBC.
/// Used ONLY for v1->v2 migration. Do not use for new encryption.
///
/// The v1 format stores data as "iv_base64:ciphertext_base64" where:
/// - IV is 16 bytes (AES block size)
/// - Ciphertext is PKCS7-padded AES-256-CBC encrypted data
/// - No MAC/authentication (this is why we're migrating to v2 AES-GCM)
class LegacyCrypto {
  static const int _keyLength = 32;
  static const int _pbkdf2Iterations = 1000000;

  final Pbkdf2 _pbkdf2;

  LegacyCrypto()
      : _pbkdf2 = Pbkdf2(
          macAlgorithm: Hmac.sha256(),
          iterations: _pbkdf2Iterations,
          bits: _keyLength * 8, // 256 bits
        );

  /// Derive a 32-byte key from password + base64-encoded salt using PBKDF2.
  ///
  /// Matches the key derivation of the legacy EncryptionService exactly:
  /// PBKDF2 with HMAC-SHA256, 1M iterations, 32-byte output.
  Future<SecretKey> deriveKey(String masterPassword, String salt) async {
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(masterPassword)),
      nonce: base64.decode(salt),
    );
  }

  /// Decrypt a v1 format encrypted string: "iv_base64:ciphertext_base64".
  ///
  /// Uses AES-256-CBC with PKCS7 padding removal. No MAC verification
  /// (v1 format has no authentication -- that's why we're migrating).
  ///
  /// Throws [FormatException] if the input doesn't contain a ':' separator.
  Future<String> decrypt(String encryptedText, SecretKey key) async {
    final colonIndex = encryptedText.indexOf(':');
    if (colonIndex < 0) {
      throw const FormatException(
        'Invalid v1 encrypted data format: missing colon separator',
      );
    }

    final ivBytes = base64.decode(encryptedText.substring(0, colonIndex));
    final ciphertextBytes =
        base64.decode(encryptedText.substring(colonIndex + 1));

    final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final secretBox = SecretBox(
      ciphertextBytes,
      nonce: ivBytes,
      mac: Mac.empty,
    );

    final decrypted = await algorithm.decrypt(secretBox, secretKey: key);

    // Remove PKCS7 padding
    final unpadded = _removePkcs7Padding(Uint8List.fromList(decrypted));
    return utf8.decode(unpadded);
  }

  /// Encrypt plaintext using AES-256-CBC for testing purposes only.
  ///
  /// This method is marked @visibleForTesting and exists solely to create
  /// known v1 ciphertext for verifying the decrypt method.
  /// It is NOT exposed as a public API for production use.
  Future<String> encryptForTesting(String plainText, SecretKey key) async {
    final random = Random.secure();
    final iv = Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );

    // Add PKCS7 padding
    final plaintextBytes = utf8.encode(plainText);
    final padded = _addPkcs7Padding(Uint8List.fromList(plaintextBytes));

    final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final secretBox = await algorithm.encrypt(
      padded,
      secretKey: key,
      nonce: iv,
    );

    return '${base64.encode(iv)}:${base64.encode(secretBox.cipherText)}';
  }

  /// Remove PKCS7 padding from decrypted data.
  Uint8List _removePkcs7Padding(Uint8List data) {
    if (data.isEmpty) return data;

    final padByte = data.last;
    if (padByte < 1 || padByte > 16) return data;

    // Verify all padding bytes are correct
    for (int i = data.length - padByte; i < data.length; i++) {
      if (data[i] != padByte) return data; // invalid padding, return as-is
    }

    return Uint8List.sublistView(data, 0, data.length - padByte);
  }

  /// Add PKCS7 padding to plaintext data.
  Uint8List _addPkcs7Padding(Uint8List data) {
    final blockSize = 16;
    final padLength = blockSize - (data.length % blockSize);
    final padded = Uint8List(data.length + padLength);
    padded.setRange(0, data.length, data);
    for (int i = data.length; i < padded.length; i++) {
      padded[i] = padLength;
    }
    return padded;
  }
}
