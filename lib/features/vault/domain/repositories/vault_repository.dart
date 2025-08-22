import 'package:cryptography/cryptography.dart';

import '../../../../core/database/app_database.dart';
import '../entities/password_history_entry.dart';
import '../entities/vault_item.dart';

/// Abstract repository interface for vault and vault item operations.
///
/// All item operations accept a vault key for encrypt-at-boundary pattern:
/// - Write operations encrypt plaintext entities before storage
/// - Read operations decrypt stored blobs to plaintext entities
abstract class VaultRepository {
  // --- Vault Item Operations ---

  /// Get all items in a vault, decrypted.
  Future<List<VaultItemEntity>> getItems(String vaultId, SecretKey vaultKey);

  /// Watch items in a vault as a reactive stream, decrypted.
  Stream<List<VaultItemEntity>> watchItems(String vaultId, SecretKey vaultKey);

  /// Create a new vault item: encrypt -> write local -> enqueue sync.
  Future<void> createItem(VaultItemEntity item, SecretKey vaultKey);

  /// Update an existing vault item: re-encrypt -> update local -> enqueue sync.
  /// If the password changed, the old password is archived to history.
  Future<void> updateItem(VaultItemEntity item, SecretKey vaultKey);

  /// Delete a vault item: soft-delete local -> enqueue sync.
  Future<void> deleteItem(String itemId);

  // --- Vault Management ---

  /// Get all vaults.
  Future<List<Vault>> getVaults();

  /// Create a new vault.
  Future<void> createVault({
    required String id,
    required String name,
    String? description,
    String colorHex = '#4D4DCD',
    String iconName = 'shield',
  });

  /// Update an existing vault's properties.
  Future<void> updateVault({
    required String id,
    String? name,
    String? description,
    String? colorHex,
    String? iconName,
  });

  /// Delete a vault and all its items.
  Future<void> deleteVault(String vaultId);

  // --- Password History ---

  /// Get decrypted password history for a vault item.
  Future<List<PasswordHistoryEntry>> getPasswordHistory(
    String itemId,
    SecretKey vaultKey,
  );
}
