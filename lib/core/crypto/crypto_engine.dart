// File: lib/core/crypto/crypto_engine.dart
// Stub CryptoEngine for plan 01-03 (Riverpod migration).
// The full implementation is provided by plan 01-01 (Wave 1).
// This stub provides the interface needed by session providers.
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Core cryptographic engine using Argon2id for KDF and AES-256-GCM.
class CryptoEngine {
  static const int _saltLength = 16;

  final Argon2id _argon2id = Argon2id(
    parallelism: 1,
    memory: 65536, // 64 MB
    iterations: 3,
    hashLength: 32,
  );

  /// Derives a 256-bit key from master password and salt using Argon2id.
  Future<List<int>> deriveKey(String masterPassword, String salt) async {
    final saltBytes = base64.decode(salt);
    final secretKey = await _argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(masterPassword)),
      nonce: saltBytes,
    );
    return await secretKey.extractBytes();
  }

  /// Generates a cryptographically secure random salt.
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    return base64.encode(saltBytes);
  }
}
