import 'package:pocketbase/pocketbase.dart';

/// Model representing a member of a shared vault.
///
/// Maps to the `vault_members` PocketBase collection (per D-07, D-08).
/// The [encryptedVaultKey] is the vault's AES-256-GCM key encrypted
/// with a shared secret derived from the owner's and member's X25519 keys.
class VaultMember {
  /// Unique identifier (PocketBase record ID).
  final String id;

  /// ID of the shared vault.
  final String vaultId;

  /// Human-readable vault name (populated from expanded relation).
  final String vaultName;

  /// ID of the member user.
  final String userId;

  /// Role in the vault: owner, editor, viewer.
  final String role;

  /// Base64-encoded vault key encrypted with the shared X25519 secret.
  final String encryptedVaultKey;

  /// Base64-encoded X25519 public key of the vault owner.
  final String ownerPublicKey;

  /// When the invitation was sent.
  final DateTime invitedAt;

  /// When the member accepted (null if still pending).
  final DateTime? acceptedAt;

  const VaultMember({
    required this.id,
    required this.vaultId,
    this.vaultName = '',
    required this.userId,
    this.role = 'viewer',
    required this.encryptedVaultKey,
    required this.ownerPublicKey,
    required this.invitedAt,
    this.acceptedAt,
  });

  /// Deserialize from a PocketBase RecordModel.
  factory VaultMember.fromRecord(RecordModel record) {
    // Extract vault name from expanded vaultId relation when available.
    String vaultName = '';
    try {
      vaultName = record.get<String>('expand.vaultId.name');
    } catch (_) {
      // Expansion not present — vaultName stays empty.
    }

    return VaultMember(
      id: record.id,
      vaultId: record.getStringValue('vaultId'),
      vaultName: vaultName,
      userId: record.getStringValue('userId'),
      role: record.getStringValue('role'),
      encryptedVaultKey: record.getStringValue('encryptedVaultKey'),
      ownerPublicKey: record.getStringValue('ownerPublicKey'),
      invitedAt: DateTime.parse(record.getStringValue('invitedAt')),
      acceptedAt: record.getStringValue('acceptedAt').isNotEmpty
          ? DateTime.parse(record.getStringValue('acceptedAt'))
          : null,
    );
  }

  /// Serialize to a PocketBase request body.
  Map<String, dynamic> toBody() {
    return {
      'vaultId': vaultId,
      'userId': userId,
      'role': role,
      'encryptedVaultKey': encryptedVaultKey,
      'ownerPublicKey': ownerPublicKey,
      'invitedAt': invitedAt.toUtc().toIso8601String(),
      'acceptedAt': acceptedAt?.toUtc().toIso8601String(),
    };
  }

  VaultMember copyWith({
    String? id,
    String? vaultId,
    String? vaultName,
    String? userId,
    String? role,
    String? encryptedVaultKey,
    String? ownerPublicKey,
    DateTime? invitedAt,
    DateTime? acceptedAt,
  }) {
    return VaultMember(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      vaultName: vaultName ?? this.vaultName,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      encryptedVaultKey: encryptedVaultKey ?? this.encryptedVaultKey,
      ownerPublicKey: ownerPublicKey ?? this.ownerPublicKey,
      invitedAt: invitedAt ?? this.invitedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}
