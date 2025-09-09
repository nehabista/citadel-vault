import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../../../../core/crypto/crypto_engine.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/password_history_dao.dart';
import '../../../../core/database/daos/sync_dao.dart';
import '../../../../core/database/daos/vault_dao.dart';
import '../../domain/entities/password_history_entry.dart';
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
  final PasswordHistoryDao _passwordHistoryDao;

  /// Current encryption version for new writes.
  static const int _encryptionVersion = 2;

  VaultRepositoryImpl({
    required VaultDao vaultDao,
    required SyncDao syncDao,
    required CryptoEngine cryptoEngine,
    required PasswordHistoryDao passwordHistoryDao,
  })  : _vaultDao = vaultDao,
        _syncDao = syncDao,
        _cryptoEngine = cryptoEngine,
        _passwordHistoryDao = passwordHistoryDao;

  // --- Vault Item Operations ---

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
    // 1. Check if password changed and archive the old one.
    await _archivePasswordIfChanged(item, vaultKey);

    // 2. Re-encrypt updated fields at the boundary.
    final encryptedData = await _cryptoEngine.encryptFields(
      item.toFieldsMap(),
      vaultKey,
    );

    // 3. Update local Drift DB with new encrypted data.
    await _vaultDao.updateVaultItem(
      VaultItemsCompanion(
        id: Value(item.id),
        encryptedData: Value(encryptedData),
        encryptionVersion: Value(_encryptionVersion),
        updatedAt: Value(item.updatedAt),
      ),
    );

    // 4. Enqueue sync operation.
    await _syncDao.enqueue(item.id, 'vault_items', 'update');
  }

  /// Archive the current password to history if it has changed.
  Future<void> _archivePasswordIfChanged(
    VaultItemEntity updatedItem,
    SecretKey vaultKey,
  ) async {
    if (updatedItem.password == null) return;

    // Read the current item from DB and decrypt to compare passwords.
    final currentItems = await _vaultDao.getItemsByVault(updatedItem.vaultId);
    final currentDbItem = currentItems.where((i) => i.id == updatedItem.id);
    if (currentDbItem.isEmpty) return;

    final currentFields = await _cryptoEngine.decryptFields(
      currentDbItem.first.encryptedData,
      vaultKey,
    );
    final currentPassword = currentFields['password'] as String?;

    // Only archive if password actually changed.
    if (currentPassword != null &&
        currentPassword.isNotEmpty &&
        currentPassword != updatedItem.password) {
      // Encrypt the OLD password and store in history.
      final encryptedOldPwd = await _cryptoEngine.encrypt(
        Uint8List.fromList(utf8.encode(currentPassword)),
        vaultKey,
      );
      await _passwordHistoryDao.insert(
        updatedItem.id,
        encryptedOldPwd,
        DateTime.now(),
      );
      // Prune old entries beyond retention limit.
      await _passwordHistoryDao.prune(updatedItem.id);
    }
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
      decrypted.add(VaultItemEntity.fromFields(
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
  Future<List<VaultItemEntity>> getAllItems(SecretKey vaultKey) async {
    final vaults = await _vaultDao.getAllVaults();
    final allItems = <VaultItemEntity>[];
    for (final vault in vaults) {
      allItems.addAll(await getItems(vault.id, vaultKey));
    }
    return allItems;
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
        decrypted.add(VaultItemEntity.fromFields(
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

  // --- Vault Management ---

  @override
  Future<List<Vault>> getVaults() {
    return _vaultDao.getAllVaults();
  }

  @override
  Future<void> createVault({
    required String id,
    required String name,
    String? description,
    String colorHex = '#4D4DCD',
    String iconName = 'shield',
  }) async {
    final now = DateTime.now();
    await _vaultDao.insertVault(
      VaultsCompanion(
        id: Value(id),
        name: Value(name),
        description: Value(description),
        colorHex: Value(colorHex),
        iconName: Value(iconName),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _syncDao.enqueue(id, 'vaults', 'create');
  }

  @override
  Future<void> updateVault({
    required String id,
    String? name,
    String? description,
    String? colorHex,
    String? iconName,
  }) async {
    await _vaultDao.updateVault(
      VaultsCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
        colorHex: colorHex != null ? Value(colorHex) : const Value.absent(),
        iconName: iconName != null ? Value(iconName) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _syncDao.enqueue(id, 'vaults', 'update');
  }

  @override
  Future<void> deleteVault(String vaultId) async {
    await _vaultDao.deleteVault(vaultId);
    await _syncDao.enqueue(vaultId, 'vaults', 'delete');
  }

  // --- Password History ---

  @override
  Future<List<PasswordHistoryEntry>> getPasswordHistory(
    String itemId,
    SecretKey vaultKey,
  ) async {
    final entries = await _passwordHistoryDao.getByItem(itemId);
    final result = <PasswordHistoryEntry>[];

    for (final entry in entries) {
      final decryptedBytes = await _cryptoEngine.decrypt(
        entry.encryptedPassword,
        vaultKey,
      );
      final password = utf8.decode(decryptedBytes);
      result.add(PasswordHistoryEntry(
        password: password,
        changedAt: entry.changedAt,
      ));
    }

    return result;
  }
}
