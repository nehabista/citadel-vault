// File: lib/features/ssh_keys/data/services/ssh_key_service.dart
// SSH key generation (RSA 4096, Ed25519), import, fingerprint computation.
// Per D-14: keys stored as VaultItemEntity with type sshKey.
// Per D-15: Ed25519 via cryptography, RSA via pointycastle in isolate.
// Manual OpenSSH encoding (ssh_key package skipped per 06-01 decision).

import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:pointycastle/export.dart' as pc;

import '../../data/models/ssh_key_data.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../../vault/domain/repositories/vault_repository.dart';

class SshKeyService {
  final VaultRepository _vaultRepo;

  SshKeyService(this._vaultRepo);

  // ---------------------------------------------------------------------------
  // Ed25519 generation (D-15)
  // ---------------------------------------------------------------------------

  /// Generate an Ed25519 key pair using the cryptography package.
  Future<SshKeyData> generateEd25519({String? comment}) async {
    final algorithm = crypto.Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final privateKeyData = await keyPair.extract();
    final publicKey = await keyPair.extractPublicKey();

    final privBytes = privateKeyData.bytes;
    final pubBytes = publicKey.bytes;
    final commentStr = comment ?? '';

    final publicKeyStr = _encodeOpenSshEd25519Public(pubBytes, commentStr);
    final privateKeyStr =
        _encodeOpenSshEd25519Private(privBytes, pubBytes, commentStr);
    final fingerprint = _computeFingerprint(pubBytes, 'ssh-ed25519');

    return SshKeyData(
      privateKey: privateKeyStr,
      publicKey: publicKeyStr,
      keyType: 'ed25519',
      fingerprint: fingerprint,
      comment: comment,
    );
  }

  // ---------------------------------------------------------------------------
  // RSA 4096 generation (D-15, isolate per pitfall 4)
  // ---------------------------------------------------------------------------

  /// Generate an RSA 4096 key pair. Runs key generation in an isolate
  /// to avoid blocking the UI thread (2-10s for 4096-bit).
  Future<SshKeyData> generateRsa4096({String? comment}) async {
    final result = await Isolate.run(() => _generateRsaInIsolate());
    final commentStr = comment ?? '';

    final rsaPublic = result['public'] as pc.RSAPublicKey;
    final rsaPrivate = result['private'] as pc.RSAPrivateKey;

    final publicKeyStr = _encodeOpenSshRsaPublic(rsaPublic, commentStr);
    final privateKeyStr =
        _encodeOpenSshRsaPrivate(rsaPrivate, rsaPublic, commentStr);
    final fingerprint = _computeRsaFingerprint(rsaPublic);

    return SshKeyData(
      privateKey: privateKeyStr,
      publicKey: publicKeyStr,
      keyType: 'rsa4096',
      fingerprint: fingerprint,
      comment: comment,
    );
  }

  /// Isolate-safe RSA key generation using pointycastle.
  static Map<String, dynamic> _generateRsaInIsolate() {
    final secureRandom = pc.SecureRandom('Fortuna')
      ..seed(pc.KeyParameter(Uint8List.fromList(
          List.generate(32, (_) => Random.secure().nextInt(256)))));

    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(
        pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), 4096, 64),
        secureRandom,
      ));

    final pair = keyGen.generateKeyPair();
    return {
      'public': pair.publicKey,
      'private': pair.privateKey,
    };
  }

  // ---------------------------------------------------------------------------
  // Import (D-17)
  // ---------------------------------------------------------------------------

  /// Import an existing SSH key from PEM/OpenSSH private key text.
  /// Detects key type from header and extracts public key + fingerprint.
  SshKeyData importFromText(String privateKeyText, {String? comment}) {
    final trimmed = privateKeyText.trim();

    if (trimmed.startsWith('-----BEGIN OPENSSH PRIVATE KEY-----')) {
      return _parseOpenSshPrivateKey(trimmed, comment: comment);
    } else if (trimmed.startsWith('-----BEGIN RSA PRIVATE KEY-----')) {
      return _parsePkcs1RsaPrivateKey(trimmed, comment: comment);
    }

    throw FormatException(
      'Unsupported SSH key format. Expected OpenSSH or PEM RSA private key.',
    );
  }

  /// Import SSH key from a file path.
  /// [readFile] callback allows testability without dart:io dependency in tests.
  SshKeyData importFromFile(String fileContent, {String? comment}) {
    return importFromText(fileContent, comment: comment);
  }

  // ---------------------------------------------------------------------------
  // Vault persistence (D-14)
  // ---------------------------------------------------------------------------

  /// Save an SSH key as a VaultItemEntity with type sshKey.
  Future<void> saveKey(
    SshKeyData keyData,
    String name,
    String vaultId,
    crypto.SecretKey vaultKey,
  ) async {
    final now = DateTime.now();
    final id = _generateId();

    final item = VaultItemEntity(
      id: id,
      vaultId: vaultId,
      name: name,
      type: VaultItemType.sshKey,
      sshKeyData: keyData,
      createdAt: now,
      updatedAt: now,
    );

    await _vaultRepo.createItem(item, vaultKey);
  }

  /// Get all SSH keys from vault (filtered by type sshKey).
  Future<List<VaultItemEntity>> getAllSshKeys(crypto.SecretKey vaultKey) async {
    final allItems = await _vaultRepo.getAllItems(vaultKey);
    return allItems
        .where((item) => item.type == VaultItemType.sshKey)
        .toList();
  }

  /// Delete an SSH key by item ID.
  Future<void> deleteKey(String itemId) async {
    await _vaultRepo.deleteItem(itemId);
  }

  // ---------------------------------------------------------------------------
  // OpenSSH format encoding — Ed25519
  // ---------------------------------------------------------------------------

  String _encodeOpenSshEd25519Public(List<int> pubBytes, String comment) {
    // Wire format: [len][ssh-ed25519][len][pubkey-bytes]
    final wireBytes = _buildWireFormat('ssh-ed25519', [Uint8List.fromList(pubBytes)]);
    final b64 = base64.encode(wireBytes);
    final parts = ['ssh-ed25519', b64];
    if (comment.isNotEmpty) parts.add(comment);
    return parts.join(' ');
  }

  String _encodeOpenSshEd25519Private(
    List<int> privBytes,
    List<int> pubBytes,
    String comment,
  ) {
    // OpenSSH private key format (unencrypted)
    // AUTH_MAGIC || ciphername || kdfname || kdfoptions || number-of-keys
    // public-key-section || private-key-section (padded)
    const authMagic = 'openssh-key-v1\x00';
    final buf = BytesBuilder();

    // Auth magic
    buf.add(utf8.encode(authMagic));

    // Cipher: none (unencrypted)
    buf.add(_sshString('none'));
    // KDF: none
    buf.add(_sshString('none'));
    // KDF options: empty string
    buf.add(_sshUint32(0));
    // Number of keys: 1
    buf.add(_sshUint32(1));

    // Public key blob
    final pubBlob = _buildWireFormat('ssh-ed25519', [Uint8List.fromList(pubBytes)]);
    buf.add(_sshBytes(pubBlob));

    // Private key section
    final privBuf = BytesBuilder();
    // checkint (random, both must match)
    final rng = Random.secure();
    final checkInt = rng.nextInt(0xFFFFFFFF);
    privBuf.add(_sshUint32(checkInt));
    privBuf.add(_sshUint32(checkInt));
    // Key type
    privBuf.add(_sshString('ssh-ed25519'));
    // Public key
    privBuf.add(_sshBytes(pubBytes));
    // Private key (ed25519 private is 64 bytes: seed || public)
    final fullPriv = Uint8List(64);
    fullPriv.setAll(0, privBytes);
    fullPriv.setAll(32, pubBytes);
    privBuf.add(_sshBytes(fullPriv));
    // Comment
    privBuf.add(_sshString(comment));
    // Padding (1, 2, 3, ... until multiple of 8)
    final privBytes2 = privBuf.toBytes();
    final padLen = (8 - (privBytes2.length % 8)) % 8;
    final padded = BytesBuilder();
    padded.add(privBytes2);
    for (int i = 1; i <= padLen; i++) {
      padded.addByte(i);
    }

    buf.add(_sshBytes(padded.toBytes()));

    // PEM encode
    final pem = base64.encode(buf.toBytes());
    final lines = <String>['-----BEGIN OPENSSH PRIVATE KEY-----'];
    for (int i = 0; i < pem.length; i += 70) {
      lines.add(pem.substring(i, i + 70 > pem.length ? pem.length : i + 70));
    }
    lines.add('-----END OPENSSH PRIVATE KEY-----');
    return lines.join('\n');
  }

  // ---------------------------------------------------------------------------
  // OpenSSH format encoding — RSA
  // ---------------------------------------------------------------------------

  String _encodeOpenSshRsaPublic(pc.RSAPublicKey key, String comment) {
    final wireBytes = _buildWireFormat('ssh-rsa', [
      _bigIntToSshBytes(key.publicExponent!),
      _bigIntToSshBytes(key.modulus!),
    ]);
    final b64 = base64.encode(wireBytes);
    final parts = ['ssh-rsa', b64];
    if (comment.isNotEmpty) parts.add(comment);
    return parts.join(' ');
  }

  String _encodeOpenSshRsaPrivate(
    pc.RSAPrivateKey privKey,
    pc.RSAPublicKey pubKey,
    String comment,
  ) {
    const authMagic = 'openssh-key-v1\x00';
    final buf = BytesBuilder();

    buf.add(utf8.encode(authMagic));
    buf.add(_sshString('none'));
    buf.add(_sshString('none'));
    buf.add(_sshUint32(0));
    buf.add(_sshUint32(1));

    // Public key blob
    final pubBlob = _buildWireFormat('ssh-rsa', [
      _bigIntToSshBytes(pubKey.publicExponent!),
      _bigIntToSshBytes(pubKey.modulus!),
    ]);
    buf.add(_sshBytes(pubBlob));

    // Private key section
    final privBuf = BytesBuilder();
    final rng = Random.secure();
    final checkInt = rng.nextInt(0xFFFFFFFF);
    privBuf.add(_sshUint32(checkInt));
    privBuf.add(_sshUint32(checkInt));
    privBuf.add(_sshString('ssh-rsa'));
    privBuf.add(_sshMpint(pubKey.modulus!));
    privBuf.add(_sshMpint(pubKey.publicExponent!));
    privBuf.add(_sshMpint(privKey.privateExponent!));

    // iqmp = q^(-1) mod p
    final iqmp = privKey.q!.modInverse(privKey.p!);
    privBuf.add(_sshMpint(iqmp));
    privBuf.add(_sshMpint(privKey.p!));
    privBuf.add(_sshMpint(privKey.q!));
    privBuf.add(_sshString(comment));

    final privBytes = privBuf.toBytes();
    final padLen = (8 - (privBytes.length % 8)) % 8;
    final padded = BytesBuilder();
    padded.add(privBytes);
    for (int i = 1; i <= padLen; i++) {
      padded.addByte(i);
    }

    buf.add(_sshBytes(padded.toBytes()));

    final pem = base64.encode(buf.toBytes());
    final lines = <String>['-----BEGIN OPENSSH PRIVATE KEY-----'];
    for (int i = 0; i < pem.length; i += 70) {
      lines.add(pem.substring(i, i + 70 > pem.length ? pem.length : i + 70));
    }
    lines.add('-----END OPENSSH PRIVATE KEY-----');
    return lines.join('\n');
  }

  // ---------------------------------------------------------------------------
  // Fingerprint computation — SHA256:<base64> (pitfall 5)
  // ---------------------------------------------------------------------------

  /// Compute fingerprint for Ed25519 public key.
  /// Wire format: [len]"ssh-ed25519"[len][pubkey-bytes]
  /// SHA-256 hash, base64 no padding.
  String _computeFingerprint(List<int> pubBytes, String keyType) {
    final wireBytes = _buildWireFormat(keyType, [Uint8List.fromList(pubBytes)]);
    return _sha256Fingerprint(wireBytes);
  }

  /// Compute fingerprint for RSA public key.
  String _computeRsaFingerprint(pc.RSAPublicKey key) {
    final wireBytes = _buildWireFormat('ssh-rsa', [
      _bigIntToSshBytes(key.publicExponent!),
      _bigIntToSshBytes(key.modulus!),
    ]);
    return _sha256Fingerprint(wireBytes);
  }

  String _sha256Fingerprint(List<int> wireBytes) {
    // Use Dart's built-in SHA-256 from pointycastle
    final digest = pc.Digest('SHA-256');
    final hash = digest.process(Uint8List.fromList(wireBytes));
    // Base64 without trailing padding '='
    final b64 = base64.encode(hash).replaceAll('=', '');
    return 'SHA256:$b64';
  }

  // ---------------------------------------------------------------------------
  // OpenSSH key parsing (for import)
  // ---------------------------------------------------------------------------

  SshKeyData _parseOpenSshPrivateKey(String pem, {String? comment}) {
    final lines = pem.split('\n');
    final b64Lines = lines
        .where((l) =>
            !l.startsWith('-----') && l.trim().isNotEmpty)
        .join('');
    final bytes = base64.decode(b64Lines);

    const magic = 'openssh-key-v1\x00';
    final magicBytes = utf8.encode(magic);
    if (bytes.length < magicBytes.length ||
        !_listEquals(bytes.sublist(0, magicBytes.length), magicBytes)) {
      throw const FormatException('Invalid OpenSSH private key magic');
    }

    int offset = magicBytes.length;

    // ciphername
    final cipherResult = _readSshString(bytes, offset);
    offset = cipherResult.newOffset;

    // kdfname
    final kdfResult = _readSshString(bytes, offset);
    offset = kdfResult.newOffset;

    // kdfoptions
    final kdfOptsLen = _readUint32(bytes, offset);
    offset += 4 + kdfOptsLen;

    // number of keys
    final numKeys = _readUint32(bytes, offset);
    offset += 4;

    if (numKeys < 1) throw const FormatException('No keys in OpenSSH key');

    // Public key blob
    final pubBlobLen = _readUint32(bytes, offset);
    offset += 4;
    final pubBlob = bytes.sublist(offset, offset + pubBlobLen);
    offset += pubBlobLen;

    // Parse public key blob to get type
    int pubOffset = 0;
    final keyTypeResult = _readSshStringFromBytes(pubBlob, pubOffset);
    final keyTypeStr = keyTypeResult.value;
    pubOffset = keyTypeResult.newOffset;

    // Private section
    final privSectionLen = _readUint32(bytes, offset);
    offset += 4;
    final privSection = bytes.sublist(offset, offset + privSectionLen);

    if (cipherResult.value != 'none') {
      throw const FormatException(
          'Encrypted SSH keys not supported. Please decrypt the key first.');
    }

    // Parse private section
    int pOff = 0;
    final check1 = _readUint32(privSection, pOff);
    pOff += 4;
    final check2 = _readUint32(privSection, pOff);
    pOff += 4;
    if (check1 != check2) {
      throw const FormatException('Check integers do not match');
    }

    final privKeyType = _readSshStringFromBytes(privSection, pOff);
    pOff = privKeyType.newOffset;

    if (keyTypeStr == 'ssh-ed25519') {
      return _parseEd25519PrivateSection(
          privSection, pOff, pubBlob, pubOffset, comment);
    } else if (keyTypeStr == 'ssh-rsa') {
      return _parseRsaPrivateSection(
          privSection, pOff, pubBlob, comment);
    }

    throw FormatException('Unsupported key type: $keyTypeStr');
  }

  SshKeyData _parseEd25519PrivateSection(
    List<int> privSection,
    int offset,
    List<int> pubBlob,
    int pubKeyDataOffset,
    String? comment,
  ) {
    // ed25519 public key (32 bytes)
    final pubKeyLen = _readUint32(privSection, offset);
    offset += 4;
    final pubKeyBytes = privSection.sublist(offset, offset + pubKeyLen);
    offset += pubKeyLen;

    // ed25519 private key (64 bytes: seed || public)
    final privKeyLen = _readUint32(privSection, offset);
    offset += 4;
    final privKeyBytes = privSection.sublist(offset, offset + privKeyLen);
    offset += privKeyLen;

    // Comment from key
    final commentResult = _readSshStringFromBytes(privSection, offset);
    final keyComment = comment ?? commentResult.value;

    final fingerprint = _computeFingerprint(pubKeyBytes, 'ssh-ed25519');

    // Reconstruct the public key string
    final publicKeyStr =
        _encodeOpenSshEd25519Public(pubKeyBytes, keyComment);

    // Re-encode in standard OpenSSH form
    final seed = privKeyBytes.sublist(0, 32);
    final privateKeyStr =
        _encodeOpenSshEd25519Private(seed, pubKeyBytes, keyComment);

    return SshKeyData(
      privateKey: privateKeyStr,
      publicKey: publicKeyStr,
      keyType: 'ed25519',
      fingerprint: fingerprint,
      comment: keyComment.isEmpty ? null : keyComment,
    );
  }

  SshKeyData _parseRsaPrivateSection(
    List<int> privSection,
    int offset,
    List<int> pubBlob,
    String? comment,
  ) {
    // n (modulus)
    final nResult = _readSshMpint(privSection, offset);
    offset = nResult.newOffset;
    // e (public exponent)
    final eResult = _readSshMpint(privSection, offset);
    offset = eResult.newOffset;
    // d (private exponent)
    final dResult = _readSshMpint(privSection, offset);
    offset = dResult.newOffset;
    // iqmp
    final iqmpResult = _readSshMpint(privSection, offset);
    offset = iqmpResult.newOffset;
    // p
    final pResult = _readSshMpint(privSection, offset);
    offset = pResult.newOffset;
    // q
    final qResult = _readSshMpint(privSection, offset);
    offset = qResult.newOffset;

    // Comment
    final commentResult = _readSshStringFromBytes(privSection, offset);
    final keyComment = comment ?? commentResult.value;

    final rsaPub = pc.RSAPublicKey(nResult.value, eResult.value);
    final rsaPriv = pc.RSAPrivateKey(
        nResult.value, dResult.value, pResult.value, qResult.value);

    final fingerprint = _computeRsaFingerprint(rsaPub);
    final publicKeyStr = _encodeOpenSshRsaPublic(rsaPub, keyComment);
    final privateKeyStr =
        _encodeOpenSshRsaPrivate(rsaPriv, rsaPub, keyComment);

    final bitLength = nResult.value.bitLength;
    final keyType = bitLength >= 4000 ? 'rsa4096' : 'rsa$bitLength';

    return SshKeyData(
      privateKey: privateKeyStr,
      publicKey: publicKeyStr,
      keyType: keyType,
      fingerprint: fingerprint,
      comment: keyComment.isEmpty ? null : keyComment,
    );
  }

  SshKeyData _parsePkcs1RsaPrivateKey(String pem, {String? comment}) {
    // PKCS#1 PEM: -----BEGIN RSA PRIVATE KEY-----
    // Manual ASN.1 DER parsing to extract RSA parameters.
    final lines = pem.split('\n');
    final b64Lines = lines
        .where(
            (l) => !l.startsWith('-----') && l.trim().isNotEmpty)
        .join('');
    final bytes = base64.decode(b64Lines);

    // RSAPrivateKey ::= SEQUENCE {
    //   version INTEGER, n INTEGER, e INTEGER, d INTEGER,
    //   p INTEGER, q INTEGER, dp INTEGER, dq INTEGER, iqmp INTEGER
    // }
    int offset = 0;

    // Read outer SEQUENCE tag
    if (bytes[offset] != 0x30) {
      throw const FormatException('Expected SEQUENCE tag');
    }
    offset++;
    final seqResult = _readDerLength(bytes, offset);
    offset = seqResult.newOffset;

    // version (INTEGER)
    offset = _skipDerInteger(bytes, offset);
    // n
    final n = _readDerInteger(bytes, offset);
    offset = n.newOffset;
    // e
    final e = _readDerInteger(bytes, offset);
    offset = e.newOffset;
    // d
    final d = _readDerInteger(bytes, offset);
    offset = d.newOffset;
    // p
    final p = _readDerInteger(bytes, offset);
    offset = p.newOffset;
    // q
    final q = _readDerInteger(bytes, offset);

    final rsaPub = pc.RSAPublicKey(n.value, e.value);
    final rsaPriv = pc.RSAPrivateKey(n.value, d.value, p.value, q.value);
    final commentStr = comment ?? '';

    final fingerprint = _computeRsaFingerprint(rsaPub);
    final publicKeyStr = _encodeOpenSshRsaPublic(rsaPub, commentStr);
    final privateKeyStr =
        _encodeOpenSshRsaPrivate(rsaPriv, rsaPub, commentStr);

    final bitLength = n.value.bitLength;
    final keyType = bitLength >= 4000 ? 'rsa4096' : 'rsa$bitLength';

    return SshKeyData(
      privateKey: privateKeyStr,
      publicKey: publicKeyStr,
      keyType: keyType,
      fingerprint: fingerprint,
      comment: comment,
    );
  }

  /// Read DER length field (supports multi-byte lengths).
  _DerLengthResult _readDerLength(List<int> data, int offset) {
    final first = data[offset];
    offset++;
    if (first < 0x80) {
      return _DerLengthResult(first, offset);
    }
    final numBytes = first & 0x7F;
    int length = 0;
    for (int i = 0; i < numBytes; i++) {
      length = (length << 8) | data[offset];
      offset++;
    }
    return _DerLengthResult(length, offset);
  }

  /// Read a DER INTEGER and return its BigInt value.
  _DerBigIntResult _readDerInteger(List<int> data, int offset) {
    if (data[offset] != 0x02) {
      throw const FormatException('Expected INTEGER tag');
    }
    offset++;
    final lenResult = _readDerLength(data, offset);
    offset = lenResult.newOffset;
    final intBytes = data.sublist(offset, offset + lenResult.value);
    offset += lenResult.value;

    BigInt value = BigInt.zero;
    for (final b in intBytes) {
      value = (value << 8) | BigInt.from(b);
    }
    return _DerBigIntResult(value, offset);
  }

  /// Skip a DER INTEGER without parsing its value.
  int _skipDerInteger(List<int> data, int offset) {
    if (data[offset] != 0x02) {
      throw const FormatException('Expected INTEGER tag');
    }
    offset++;
    final lenResult = _readDerLength(data, offset);
    return lenResult.newOffset + lenResult.value;
  }

  // ---------------------------------------------------------------------------
  // SSH wire format helpers
  // ---------------------------------------------------------------------------

  /// Build SSH wire-format: [len][key-type][len][data1][len][data2]...
  Uint8List _buildWireFormat(String keyType, List<Uint8List> parts) {
    final buf = BytesBuilder();
    buf.add(_sshString(keyType));
    for (final part in parts) {
      buf.add(_sshBytes(part));
    }
    return buf.toBytes();
  }

  /// Encode a string as SSH wire string: [4-byte length][utf8 bytes]
  Uint8List _sshString(String s) {
    final bytes = utf8.encode(s);
    return _sshBytes(bytes);
  }

  /// Encode bytes with 4-byte length prefix.
  Uint8List _sshBytes(List<int> data) {
    final buf = BytesBuilder();
    buf.add(_sshUint32(data.length));
    buf.add(data);
    return buf.toBytes();
  }

  /// Encode a 32-bit unsigned integer in big-endian.
  Uint8List _sshUint32(int value) {
    return Uint8List(4)
      ..buffer.asByteData().setUint32(0, value, Endian.big);
  }

  /// Encode a BigInt as SSH mpint (with sign bit handling).
  Uint8List _sshMpint(BigInt value) {
    final bytes = _bigIntToSshBytes(value);
    return _sshBytes(bytes);
  }

  /// Convert BigInt to big-endian bytes with leading zero if high bit set.
  Uint8List _bigIntToSshBytes(BigInt value) {
    if (value == BigInt.zero) return Uint8List(0);

    final hex = value.toRadixString(16);
    final padded = hex.length.isOdd ? '0$hex' : hex;
    final bytes = <int>[];
    for (int i = 0; i < padded.length; i += 2) {
      bytes.add(int.parse(padded.substring(i, i + 2), radix: 16));
    }

    // Add leading zero byte if high bit is set (SSH mpint is signed)
    if (bytes.isNotEmpty && (bytes[0] & 0x80) != 0) {
      bytes.insert(0, 0);
    }

    return Uint8List.fromList(bytes);
  }

  // ---------------------------------------------------------------------------
  // SSH wire format readers (for import parsing)
  // ---------------------------------------------------------------------------

  int _readUint32(List<int> data, int offset) {
    return (data[offset] << 24) |
        (data[offset + 1] << 16) |
        (data[offset + 2] << 8) |
        data[offset + 3];
  }

  _SshStringResult _readSshString(List<int> data, int offset) {
    final len = _readUint32(data, offset);
    offset += 4;
    final value = utf8.decode(data.sublist(offset, offset + len));
    return _SshStringResult(value, offset + len);
  }

  _SshStringResult _readSshStringFromBytes(List<int> data, int offset) {
    return _readSshString(data, offset);
  }

  _SshMpintResult _readSshMpint(List<int> data, int offset) {
    final len = _readUint32(data, offset);
    offset += 4;
    final bytes = data.sublist(offset, offset + len);
    offset += len;

    // Convert bytes to BigInt
    BigInt value = BigInt.zero;
    for (final b in bytes) {
      value = (value << 8) | BigInt.from(b);
    }

    return _SshMpintResult(value, offset);
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _generateId() {
    final rng = Random.secure();
    return List.generate(16, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}

// ---------------------------------------------------------------------------
// Result classes for parsing
// ---------------------------------------------------------------------------

class _SshStringResult {
  final String value;
  final int newOffset;
  _SshStringResult(this.value, this.newOffset);
}

class _SshMpintResult {
  final BigInt value;
  final int newOffset;
  _SshMpintResult(this.value, this.newOffset);
}

class _DerLengthResult {
  final int value;
  final int newOffset;
  _DerLengthResult(this.value, this.newOffset);
}

class _DerBigIntResult {
  final BigInt value;
  final int newOffset;
  _DerBigIntResult(this.value, this.newOffset);
}
