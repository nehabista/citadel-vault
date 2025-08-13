import 'package:cryptography/cryptography.dart';

import '../entities/vault_item.dart';

/// Abstract repository interface for vault item operations.
///
/// All operations accept a vault key for encrypt-at-boundary pattern:
/// - Write operations encrypt plaintext entities before storage
/// - Read operations decrypt stored blobs to plaintext entities
abstract class VaultRepository {
  /// Get all items in a vault, decrypted.
  Future<List<VaultItemEntity>> getItems(String vaultId, SecretKey vaultKey);

  /// Watch items in a vault as a reactive stream, decrypted.
  Stream<List<VaultItemEntity>> watchItems(String vaultId, SecretKey vaultKey);

  /// Create a new vault item: encrypt -> write local -> enqueue sync.
  Future<void> createItem(VaultItemEntity item, SecretKey vaultKey);

  /// Update an existing vault item: re-encrypt -> update local -> enqueue sync.
  Future<void> updateItem(VaultItemEntity item, SecretKey vaultKey);

  /// Delete a vault item: soft-delete local -> enqueue sync.
  Future<void> deleteItem(String itemId);
}
