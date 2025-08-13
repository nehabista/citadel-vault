import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/vault_dao.dart';

/// Local data source wrapping VaultDao for vault item persistence.
///
/// Handles Drift Companion creation from encrypted data.
/// Works exclusively with encrypted blobs -- no plaintext handling here.
class LocalVaultDatasource {
  final VaultDao _vaultDao;

  LocalVaultDatasource({required VaultDao vaultDao}) : _vaultDao = vaultDao;

  /// Insert a new vault item with encrypted data.
  Future<void> insertItem({
    required String id,
    required String vaultId,
    required Uint8List encryptedData,
    required int encryptionVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return _vaultDao.insertVaultItem(
      VaultItemsCompanion(
        id: Value(id),
        vaultId: Value(vaultId),
        encryptedData: Value(encryptedData),
        encryptionVersion: Value(encryptionVersion),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Update an existing vault item with new encrypted data.
  Future<bool> updateItem({
    required String id,
    required Uint8List encryptedData,
    required int encryptionVersion,
    required DateTime updatedAt,
  }) {
    return _vaultDao.updateVaultItem(
      VaultItemsCompanion(
        id: Value(id),
        encryptedData: Value(encryptedData),
        encryptionVersion: Value(encryptionVersion),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Soft-delete a vault item.
  Future<void> softDeleteItem(String itemId) {
    return _vaultDao.softDeleteItem(itemId);
  }

  /// Get all non-deleted items for a vault.
  Future<List<VaultItem>> getItemsByVault(String vaultId) {
    return _vaultDao.getItemsByVault(vaultId);
  }

  /// Watch non-deleted items for a vault as a reactive stream.
  Stream<List<VaultItem>> watchItemsByVault(String vaultId) {
    return _vaultDao.watchItemsByVault(vaultId);
  }
}
