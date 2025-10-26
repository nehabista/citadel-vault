/// SSH key data stored within a VaultItemEntity's encrypted blob.
///
/// Per D-14: SSH keys are stored as a typed vault item (VaultItemType.sshKey)
/// with the key material encrypted in the standard vault item blob.
class SshKeyData {
  /// PEM-encoded private key
  final String privateKey;

  /// OpenSSH-format public key
  final String publicKey;

  /// Key algorithm: 'rsa4096' or 'ed25519'
  final String keyType;

  /// Optional passphrase protecting the private key
  final String? passphrase;

  /// Key fingerprint in `SHA256:<base64>` format
  final String fingerprint;

  /// Optional comment (typically user@host)
  final String? comment;

  const SshKeyData({
    required this.privateKey,
    required this.publicKey,
    required this.keyType,
    this.passphrase,
    required this.fingerprint,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'privateKey': privateKey,
        'publicKey': publicKey,
        'keyType': keyType,
        'passphrase': passphrase,
        'fingerprint': fingerprint,
        'comment': comment,
      };

  factory SshKeyData.fromJson(Map<String, dynamic> json) => SshKeyData(
        privateKey: json['privateKey'] as String,
        publicKey: json['publicKey'] as String,
        keyType: json['keyType'] as String,
        passphrase: json['passphrase'] as String?,
        fingerprint: json['fingerprint'] as String,
        comment: json['comment'] as String?,
      );
}
