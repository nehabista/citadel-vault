import 'dart:convert';
import 'dart:typed_data';

/// Crypto version identifiers for the versioned blob format.
///
/// v1 = legacy PBKDF2+AES-CBC format (iv_base64:ciphertext_base64)
/// v2 = Argon2id+AES-256-GCM format ([0x02][12-byte nonce][ciphertext][16-byte tag])
enum CryptoVersion {
  v1(0x01),
  v2(0x02);

  final int byteValue;
  const CryptoVersion(this.byteValue);

  static CryptoVersion fromByte(int byte) {
    for (final version in CryptoVersion.values) {
      if (version.byteValue == byte) return version;
    }
    throw FormatException('Unknown crypto version byte: 0x${byte.toRadixString(16)}');
  }
}

/// Versioned encrypted blob format.
///
/// v2 binary layout: [version_byte (1)][nonce (12)][ciphertext (N)][tag (16)]
/// v1 string layout: "iv_base64:ciphertext_base64"
class EncryptedBlob {
  final CryptoVersion version;
  final Uint8List nonce;
  final Uint8List ciphertext;
  final Uint8List tag;

  EncryptedBlob({
    required this.version,
    required this.nonce,
    required this.ciphertext,
    required this.tag,
  });

  /// Parse a v2 binary blob: [version_byte][12-byte nonce][ciphertext][16-byte tag]
  factory EncryptedBlob.fromBytes(Uint8List data) {
    if (data.length < 1 + 12 + 16) {
      throw FormatException(
        'Encrypted blob too short: ${data.length} bytes (minimum 29)',
      );
    }

    final version = CryptoVersion.fromByte(data[0]);
    final nonce = Uint8List.sublistView(data, 1, 13);
    final tag = Uint8List.sublistView(data, data.length - 16);
    final ciphertext = Uint8List.sublistView(data, 13, data.length - 16);

    return EncryptedBlob(
      version: version,
      nonce: Uint8List.fromList(nonce),
      ciphertext: Uint8List.fromList(ciphertext),
      tag: Uint8List.fromList(tag),
    );
  }

  /// Serialize to v2 binary format: [version_byte][nonce][ciphertext][tag]
  Uint8List toBytes() {
    final result = Uint8List(1 + nonce.length + ciphertext.length + tag.length);
    result[0] = version.byteValue;
    result.setRange(1, 1 + nonce.length, nonce);
    result.setRange(1 + nonce.length, 1 + nonce.length + ciphertext.length, ciphertext);
    result.setRange(
      1 + nonce.length + ciphertext.length,
      result.length,
      tag,
    );
    return result;
  }

  /// Detect v1 format: "iv_base64:ciphertext_base64"
  ///
  /// Returns true if the string contains exactly one ':' and both parts
  /// are valid base64.
  static bool isV1Format(String data) {
    final colonIndex = data.indexOf(':');
    if (colonIndex < 0) return false;

    // Must have exactly one colon
    if (data.indexOf(':', colonIndex + 1) >= 0) return false;

    final ivPart = data.substring(0, colonIndex);
    final ctPart = data.substring(colonIndex + 1);

    if (ivPart.isEmpty || ctPart.isEmpty) return false;

    try {
      base64.decode(ivPart);
      base64.decode(ctPart);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Decode a base64-encoded v2 blob.
  static EncryptedBlob fromBase64(String b64) {
    final bytes = base64.decode(b64);
    return EncryptedBlob.fromBytes(Uint8List.fromList(bytes));
  }
}
