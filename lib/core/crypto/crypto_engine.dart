import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'encrypted_blob.dart';

/// Core cryptographic engine for Citadel Password Manager.
///
/// Provides Argon2id key derivation and AES-256-GCM authenticated encryption.
/// This is a plain Dart class (not a GetxService) for testability and
/// framework independence.
///
/// v2 encrypted blob format: [0x02][12-byte nonce][ciphertext][16-byte GCM tag]
class CryptoEngine {
  static const int _saltLength = 16;
  static const int _argon2Memory = 32 * 1024; // 32MB in KB
  static const int _argon2Iterations = 3;
  static const int _argon2Parallelism = 1;
  static const int _keyLength = 32;

  final Argon2id _argon2id;
  final AesGcm _aesGcm;

  CryptoEngine()
      : _argon2id = Argon2id(
          memory: _argon2Memory,
          iterations: _argon2Iterations,
          parallelism: _argon2Parallelism,
          hashLength: _keyLength,
        ),
        _aesGcm = AesGcm.with256bits();

  /// Derive a 32-byte secret key from a master password and salt using Argon2id.
  Future<SecretKey> deriveKey(String masterPassword, List<int> salt) async {
    return _argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(masterPassword)),
      nonce: salt,
    );
  }

  /// Generate a cryptographically secure random salt of [_saltLength] bytes.
  Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(_saltLength, (_) => random.nextInt(256)),
    );
  }

  /// Encrypt plaintext using AES-256-GCM and return a v2 encrypted blob.
  ///
  /// Output format: [0x02][12-byte nonce][ciphertext][16-byte GCM auth tag]
  Future<Uint8List> encrypt(Uint8List plaintext, SecretKey key) async {
    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: key,
    );

    return EncryptedBlob(
      version: CryptoVersion.v2,
      nonce: Uint8List.fromList(secretBox.nonce),
      ciphertext: Uint8List.fromList(secretBox.cipherText),
      tag: Uint8List.fromList(secretBox.mac.bytes),
    ).toBytes();
  }

  /// Decrypt a v2 encrypted blob using AES-256-GCM.
  ///
  /// Throws [SecretBoxAuthenticationError] if the key is wrong or data is tampered.
  Future<Uint8List> decrypt(Uint8List blob, SecretKey key) async {
    final parsed = EncryptedBlob.fromBytes(blob);

    final secretBox = SecretBox(
      parsed.ciphertext,
      nonce: parsed.nonce,
      mac: Mac(parsed.tag),
    );

    final decrypted = await _aesGcm.decrypt(secretBox, secretKey: key);
    return Uint8List.fromList(decrypted);
  }

  /// Encrypt a map of fields as a JSON blob using AES-256-GCM.
  ///
  /// The map MUST include metadata keys: name, url, folder, type, favorite,
  /// notes, and any custom fields. All metadata is encrypted together per D-11.
  Future<Uint8List> encryptFields(
    Map<String, dynamic> fields,
    SecretKey key,
  ) async {
    final json = jsonEncode(fields);
    final plaintext = Uint8List.fromList(utf8.encode(json));
    return encrypt(plaintext, key);
  }

  /// Decrypt a v2 encrypted blob back to a map of fields.
  Future<Map<String, dynamic>> decryptFields(
    Uint8List encryptedBlob,
    SecretKey key,
  ) async {
    final decrypted = await decrypt(encryptedBlob, key);
    final json = utf8.decode(decrypted);
    return jsonDecode(json) as Map<String, dynamic>;
  }
}
