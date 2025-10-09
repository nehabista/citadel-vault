/// Data transfer model for credentials sent over platform channels.
///
/// Used to serialize vault item credentials for the native autofill service.
/// Per D-02: this is the format exchanged between Dart and native Android/macOS
/// autofill implementations via MethodChannel.
class AutofillCredential {
  /// The vault item ID this credential belongs to.
  final String vaultItemId;

  /// Username or email for the credential.
  final String username;

  /// Password for the credential.
  final String password;

  /// Display name shown in the autofill picker (vault item name).
  final String displayName;

  /// The domain associated with this credential (optional).
  final String? domain;

  /// Whether this credential has an associated TOTP entry.
  final bool hasTotpEntry;

  /// Whether a phishing warning should be shown (domain mismatch).
  final bool phishingWarning;

  const AutofillCredential({
    required this.vaultItemId,
    required this.username,
    required this.password,
    required this.displayName,
    this.domain,
    this.hasTotpEntry = false,
    this.phishingWarning = false,
  });

  /// Serialize to a map for platform channel transport.
  Map<String, dynamic> toMap() {
    return {
      'vaultItemId': vaultItemId,
      'username': username,
      'password': password,
      'displayName': displayName,
      'domain': domain,
      'hasTotpEntry': hasTotpEntry,
      'phishingWarning': phishingWarning,
    };
  }

  /// Deserialize from a platform channel map.
  factory AutofillCredential.fromMap(Map<String, dynamic> map) {
    return AutofillCredential(
      vaultItemId: map['vaultItemId'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      displayName: map['displayName'] as String,
      domain: map['domain'] as String?,
      hasTotpEntry: map['hasTotpEntry'] as bool? ?? false,
      phishingWarning: map['phishingWarning'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutofillCredential &&
          runtimeType == other.runtimeType &&
          vaultItemId == other.vaultItemId &&
          username == other.username &&
          password == other.password &&
          displayName == other.displayName &&
          domain == other.domain &&
          hasTotpEntry == other.hasTotpEntry &&
          phishingWarning == other.phishingWarning;

  @override
  int get hashCode =>
      vaultItemId.hashCode ^
      username.hashCode ^
      password.hashCode ^
      displayName.hashCode ^
      domain.hashCode ^
      hasTotpEntry.hashCode ^
      phishingWarning.hashCode;

  @override
  String toString() =>
      'AutofillCredential(vaultItemId: $vaultItemId, username: $username, '
      'displayName: $displayName, domain: $domain, '
      'hasTotpEntry: $hasTotpEntry, phishingWarning: $phishingWarning)';
}
