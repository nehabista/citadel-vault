// File: lib/features/sharing/data/services/shared_vault_service.dart
// Service for shared vault creation, member management, and key rotation.
// Per D-07, D-08, D-09.

import 'package:pocketbase/pocketbase.dart';

import 'sharing_crypto_service.dart';

/// Service for managing shared vaults (family/team vaults).
///
/// Handles PocketBase CRUD for `vault_collections` and `vault_members`
/// collections. Supports owner/editor/viewer roles with X25519 encrypted
/// vault key distribution and key rotation on member removal.
class SharedVaultService {
  final PocketBase _pb;
  final SharingCryptoService _crypto;

  SharedVaultService({
    required PocketBase pb,
    required SharingCryptoService crypto,
  })  : _pb = pb,
        _crypto = crypto;

  /// Reference to crypto for external callers that need key operations.
  SharingCryptoService get crypto => _crypto;

  /// Create a new shared vault in the `vault_collections` PocketBase collection.
  ///
  /// The creator becomes the owner automatically. The [ownerPublicKey] is
  /// the base64-encoded X25519 public key used for vault key encryption.
  Future<RecordModel> createSharedVault({
    required String name,
    required String ownerId,
    required String ownerPublicKey,
  }) async {
    try {
      final vault = await _pb.collection('vault_collections').create(body: {
        'name': name,
        'ownerId': ownerId,
        'ownerPublicKey': ownerPublicKey,
        'type': 'shared',
      });

      // Create owner membership so getUserSharedVaults() finds this vault.
      final now = DateTime.now().toUtc().toIso8601String();
      await _pb.collection('vault_members').create(body: {
        'vaultId': vault.id,
        'userId': ownerId,
        'role': 'owner',
        'encryptedVaultKey': '',
        'ownerPublicKey': ownerPublicKey,
        'invitedAt': now,
        'acceptedAt': now,
      });

      return vault;
    } catch (e) {
      throw SharedVaultServiceException('Failed to create shared vault: $e');
    }
  }

  /// Add a member to a shared vault.
  ///
  /// The [encryptedVaultKey] is the vault's AES-256-GCM key encrypted
  /// with the shared secret derived from the owner's and member's X25519 keys.
  /// The [role] must be one of: 'owner', 'editor', 'viewer'.
  Future<RecordModel> addMember({
    required String vaultId,
    required String userId,
    required String role,
    required String encryptedVaultKey,
    required String ownerPublicKey,
  }) async {
    try {
      _validateRole(role);
      return await _pb.collection('vault_members').create(body: {
        'vaultId': vaultId,
        'userId': userId,
        'role': role,
        'encryptedVaultKey': encryptedVaultKey,
        'ownerPublicKey': ownerPublicKey,
        'invitedAt': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      if (e is SharedVaultServiceException) rethrow;
      throw SharedVaultServiceException('Failed to add member: $e');
    }
  }

  /// Remove a member from a shared vault by their membership record ID.
  Future<void> removeMember(String memberId) async {
    try {
      await _pb.collection('vault_members').delete(memberId);
    } catch (e) {
      throw SharedVaultServiceException('Failed to remove member: $e');
    }
  }

  /// Update a member's role in a shared vault.
  ///
  /// The [newRole] must be one of: 'owner', 'editor', 'viewer'.
  Future<void> updateMemberRole(String memberId, String newRole) async {
    try {
      _validateRole(newRole);
      await _pb.collection('vault_members').update(memberId, body: {
        'role': newRole,
      });
    } catch (e) {
      if (e is SharedVaultServiceException) rethrow;
      throw SharedVaultServiceException('Failed to update member role: $e');
    }
  }

  /// Get all members of a shared vault.
  Future<List<RecordModel>> getVaultMembers(String vaultId) async {
    try {
      return await _pb.collection('vault_members').getFullList(
        filter: 'vaultId = "$vaultId"',
      );
    } catch (e) {
      throw SharedVaultServiceException('Failed to get vault members: $e');
    }
  }

  /// Get all shared vaults a user belongs to, with expanded vault details.
  Future<List<RecordModel>> getUserSharedVaults(String userId) async {
    try {
      return await _pb.collection('vault_members').getFullList(
        filter: 'userId = "$userId"',
        expand: 'vaultId',
      );
    } catch (e) {
      throw SharedVaultServiceException('Failed to get user shared vaults: $e');
    }
  }

  /// Rotate the vault key after a member is removed.
  ///
  /// Per D-09: when a member is removed, generate a new vault key,
  /// re-encrypt it for each remaining member using their X25519 shared
  /// secret, and batch-update all membership records.
  Future<void> rotateVaultKey({
    required String vaultId,
    required List<({String memberId, String encryptedVaultKey})>
        reEncryptedKeys,
  }) async {
    try {
      // Batch update all remaining members' encrypted vault keys.
      for (final entry in reEncryptedKeys) {
        await _pb.collection('vault_members').update(entry.memberId, body: {
          'encryptedVaultKey': entry.encryptedVaultKey,
        });
      }
    } catch (e) {
      throw SharedVaultServiceException('Failed to rotate vault key: $e');
    }
  }

  /// Validate that a role string is one of the allowed values.
  void _validateRole(String role) {
    const allowedRoles = ['owner', 'editor', 'viewer'];
    if (!allowedRoles.contains(role)) {
      throw SharedVaultServiceException(
        'Invalid role "$role". Must be one of: ${allowedRoles.join(', ')}',
      );
    }
  }
}

/// Exception type for [SharedVaultService] errors.
class SharedVaultServiceException implements Exception {
  final String message;
  const SharedVaultServiceException(this.message);

  @override
  String toString() => 'SharedVaultServiceException: $message';
}
