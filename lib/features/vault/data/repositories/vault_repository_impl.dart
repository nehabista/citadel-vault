import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../../../../core/crypto/crypto_engine.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/sync_dao.dart';
import '../../../../core/database/daos/vault_dao.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/vault_repository.dart';

/// Implementation of VaultRepository with offline-first write path.
///
/// Pattern 3 from research: encrypt-at-boundary.
/// - Domain entities hold plaintext (VaultItemEntity)
/// - Repository encrypts on write, decrypts on read
/// - All writes go to local Drift DB first, then enqueue for sync
///
/// Per D-15: local database is the source of truth.
/// Per D-16: sync queue ensures data reaches PocketBase when online.
class VaultRepositoryImpl implements VaultRepository {
  final VaultDao _vaultDao;
  final SyncDao _syncDao;
  final CryptoEngine _cryptoEngine;

  /// Current encryption version for new writes.
  static const int _encryptionVersion = 2;

  VaultRepositoryImpl({
    required VaultDao vaultDao,
    required SyncDao syncDao,
    required CryptoEngine cryptoEngine,
  })  : _vaultDao = vaultDao,
        _syncDao = syncDao,
        _cryptoEngine = cryptoEngine;

  @override
  Future<void> createItem(VaultItemEntity item, SecretKey vaultKey) async {
    // 1. Encrypt plaintext fields at the boundary.
    final encryptedData = await _cryptoEngine.encryptFields(
      item.toFieldsMap(),
      vaultKey,
    );

    // 2. Write encrypted data to local Drift DB.
    await _vaultDao.insertVaultItem(
      VaultItemsCompanion(
        id: Value(item.id),
        vaultId: Value(item.vaultId),
        encryptedData: Value(encryptedData),
        encryptionVersion: Value(_encryptionVersion),
        createdAt: Value(item.createdAt),
        updatedAt: Value(item.updatedAt),
      ),
    );

    // 3. Enqueue sync operation for PocketBase.
    await _syncDao.enqueue(item.id, 'vault_items', 'create');
  }

  @override
  Future<void> updateItem(VaultItemEntity item, SecretKey vaultKey) async {
    // 1. Re-encrypt updated fields at the boundary.
    final encryptedData = await _cryptoEngine.encryptFields(
      item.toFieldsMap(),
      vaultKey,
    );

    // 2. Update local Drift DB with new encrypted data.
    await _vaultDao.updateVaultItem(
      VaultItemsCompanion(
        id: Value(item.id),
        encryptedData: Value(encryptedData),
        encryptionVersion: Value(_encryptionVersion),
        updatedAt: Value(item.updatedAt),
      ),
    );

    // 3. Enqueue sync operation.
    await _syncDao.enqueue(item.id, 'vault_items', 'update');
  }

  @override
  Future<void> deleteItem(String itemId) async {
    // 1. Soft-delete in local DB (tombstone for sync conflict resolution).
    await _vaultDao.softDeleteItem(itemId);

    // 2. Enqueue sync operation.
    await _syncDao.enqueue(itemId, 'vault_items', 'delete');
  }

  @override
  Future<List<VaultItemEntity>> getItems(
    String vaultId,
    SecretKey vaultKey,
  ) async {
    // 1. Read encrypted items from local DB.
    final items = await _vaultDao.getItemsByVault(vaultId);

    // 2. Decrypt each item at the boundary.
    final decrypted = <VaultItemEntity>[];
    for (final item in items) {
      final fields = await _cryptoEngine.decryptFields(
        item.encryptedData,
        vaultKey,
      );
      decrypted.add(VaultItemEntity.fromFieldsMap(
        id: item.id,
        vaultId: item.vaultId,
        fields: fields,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      ));
    }

    return decrypted;
  }

  @override
  Stream<List<VaultItemEntity>> watchItems(
    String vaultId,
    SecretKey vaultKey,
  ) {
    // Watch encrypted items and map through decryption.
    return _vaultDao.watchItemsByVault(vaultId).asyncMap((items) async {
      final decrypted = <VaultItemEntity>[];
      for (final item in items) {
        final fields = await _cryptoEngine.decryptFields(
          item.encryptedData,
          vaultKey,
        );
        decrypted.add(VaultItemEntity.fromFieldsMap(
          id: item.id,
          vaultId: item.vaultId,
          fields: fields,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
        ));
      }
      return decrypted;
    });
  }
}
