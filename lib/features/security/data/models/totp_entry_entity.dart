/// Plaintext domain entity for a TOTP authenticator entry.
///
/// This holds the decrypted TOTP secret and configuration.
/// Encryption/decryption happens at the repository boundary per D-10.
class TotpEntryEntity {
  final String id;
  final String vaultItemId;

  /// Base32-encoded TOTP secret (plaintext).
  final String secret;

  /// Number of digits in generated code (typically 6 or 8).
  final int digits;

  /// Time period in seconds (typically 30).
  final int period;

  /// Hash algorithm: SHA1, SHA256, or SHA512.
  final String algorithm;

  const TotpEntryEntity({
    required this.id,
    required this.vaultItemId,
    required this.secret,
    this.digits = 6,
    this.period = 30,
    this.algorithm = 'SHA1',
  });

  TotpEntryEntity copyWith({
    String? id,
    String? vaultItemId,
    String? secret,
    int? digits,
    int? period,
    String? algorithm,
  }) {
    return TotpEntryEntity(
      id: id ?? this.id,
      vaultItemId: vaultItemId ?? this.vaultItemId,
      secret: secret ?? this.secret,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      algorithm: algorithm ?? this.algorithm,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TotpEntryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vaultItemId == other.vaultItemId &&
          secret == other.secret &&
          digits == other.digits &&
          period == other.period &&
          algorithm == other.algorithm;

  @override
  int get hashCode =>
      id.hashCode ^
      vaultItemId.hashCode ^
      secret.hashCode ^
      digits.hashCode ^
      period.hashCode ^
      algorithm.hashCode;

  @override
  String toString() =>
      'TotpEntryEntity(id: $id, vaultItemId: $vaultItemId, digits: $digits, period: $period, algorithm: $algorithm)';
}
