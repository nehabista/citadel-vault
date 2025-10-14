import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Cryptographic service for secure sharing operations.
///
/// Provides X25519 key exchange, HKDF-SHA256 key derivation,
/// and AES-256-GCM authenticated encryption for:
/// - User-to-user item sharing (X25519 ECDH + HKDF derived key)
/// - Link-based sharing (random AES-256-GCM key in URL fragment)
/// - Vault key wrapping for shared vaults
/// - Emergency access key escrow
class SharingCryptoService {
  final X25519 _x25519;
  final Hkdf _hkdf;
  final AesGcm _aesGcm;

  SharingCryptoService()
      : _x25519 = X25519(),
        _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32),
        _aesGcm = AesGcm.with256bits();

  /// Generate a new X25519 keypair for key exchange.
  Future<SimpleKeyPair> generateKeyPair() async {
    return await _x25519.newKeyPair();
  }

  /// Extract the public key bytes from a keypair.
  Future<SimplePublicKey> extractPublicKey(SimpleKeyPair keyPair) async {
    return await keyPair.extractPublicKey();
  }

  /// Derive a shared AES-256-GCM key using X25519 ECDH + HKDF-SHA256.
  ///
  /// [localKeyPair] - This user's X25519 private key.
  /// [remotePublicKey] - The other party's X25519 public key.
  /// [context] - Domain separation bytes (e.g., utf8.encode('citadel-share-v1')).
  ///
  /// Context values by use case:
  /// - Sharing: utf8.encode('citadel-share-v1')
  /// - Vault key wrapping: utf8.encode('citadel-vault-key-v1')
  /// - Emergency access: utf8.encode('citadel-emergency-v1')
  Future<SecretKey> deriveSharedKey({
    required SimpleKeyPair localKeyPair,
    required SimplePublicKey remotePublicKey,
    required List<int> context,
  }) async {
    // X25519 ECDH to get raw shared secret
    final sharedSecretKey = await _x25519.sharedSecretKey(
      keyPair: localKeyPair,
      remotePublicKey: remotePublicKey,
    );

    final sharedSecretBytes = await sharedSecretKey.extractBytes();

    // HKDF-SHA256 to derive a 32-byte AES-256-GCM key with domain separation
    final derivedKey = await _hkdf.deriveKey(
      secretKey: SecretKey(sharedSecretBytes),
      nonce: context,
      info: context,
    );

    return derivedKey;
  }

  /// Encrypt item data for user-to-user sharing.
  ///
  /// Output format: [12-byte nonce][ciphertext][16-byte GCM tag]
  Future<Uint8List> encryptForSharing(
    Map<String, dynamic> itemData,
    SecretKey sharedKey,
  ) async {
    final json = jsonEncode(itemData);
    final plaintext = utf8.encode(json);

    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: sharedKey,
    );

    // Concatenate: nonce(12) + ciphertext + mac(16)
    final result = Uint8List(
      secretBox.nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length,
    );
    var offset = 0;
    result.setRange(offset, offset + secretBox.nonce.length, secretBox.nonce);
    offset += secretBox.nonce.length;
    result.setRange(offset, offset + secretBox.cipherText.length, secretBox.cipherText);
    offset += secretBox.cipherText.length;
    result.setRange(offset, offset + secretBox.mac.bytes.length, secretBox.mac.bytes);

    return result;
  }

  /// Decrypt shared item data from another user.
  ///
  /// Input format: [12-byte nonce][ciphertext][16-byte GCM tag]
  Future<Map<String, dynamic>> decryptFromSharing(
    Uint8List encryptedBlob,
    SecretKey sharedKey,
  ) async {
    const nonceLength = 12;
    const macLength = 16;

    final nonce = encryptedBlob.sublist(0, nonceLength);
    final cipherText = encryptedBlob.sublist(nonceLength, encryptedBlob.length - macLength);
    final mac = encryptedBlob.sublist(encryptedBlob.length - macLength);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(mac),
    );

    final decrypted = await _aesGcm.decrypt(secretBox, secretKey: sharedKey);
    final json = utf8.decode(decrypted);
    return jsonDecode(json) as Map<String, dynamic>;
  }

  /// Encrypt item data for link-based sharing.
  ///
  /// Generates a random AES-256-GCM key (not X25519-derived).
  /// Returns both the encrypted blob and the key bytes.
  /// The key bytes are intended to be placed in the URL fragment (per D-04).
  Future<({Uint8List encryptedBlob, Uint8List keyBytes})> encryptForLink(
    Map<String, dynamic> itemData,
  ) async {
    // Generate a random 256-bit key
    final key = await _aesGcm.newSecretKey();
    final keyBytes = Uint8List.fromList(await key.extractBytes());

    final encryptedBlob = await encryptForSharing(itemData, key);

    return (encryptedBlob: encryptedBlob, keyBytes: keyBytes);
  }

  /// Decrypt a link-shared item using the key from the URL fragment.
  Future<Map<String, dynamic>> decryptFromLink(
    Uint8List encryptedBlob,
    Uint8List keyBytes,
  ) async {
    final key = SecretKey(keyBytes);
    return decryptFromSharing(encryptedBlob, key);
  }
}
