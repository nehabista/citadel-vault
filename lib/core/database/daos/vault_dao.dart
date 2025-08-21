import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/vaults_table.dart';
import '../tables/vault_items_table.dart';

part 'vault_dao.g.dart';

/// Data access object for Vault and VaultItem CRUD operations.
@DriftAccessor(tables: [Vaults, VaultItems])
class VaultDao extends DatabaseAccessor<AppDatabase> with _$VaultDaoMixin {
  VaultDao(super.db);

  /// Insert a new vault.
  Future<void> insertVault(VaultsCompanion vault) {
    return into(vaults).insert(vault);
  }

  /// Get all vaults ordered by sort order.
  Future<List<Vault>> getAllVaults() {
    return (select(vaults)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Insert a new vault item.
  Future<void> insertVaultItem(VaultItemsCompanion item) {
    return into(vaultItems).insert(item);
  }

  /// Get all non-deleted items for a specific vault.
  Future<List<VaultItem>> getItemsByVault(String vaultId) {
    return (select(vaultItems)
          ..where(
            (t) => t.vaultId.equals(vaultId) & t.isDeleted.equals(false),
          ))
        .get();
  }

  /// Update an existing vault item.
  Future<bool> updateVaultItem(VaultItemsCompanion item) {
    return (update(vaultItems)..where((t) => t.id.equals(item.id.value)))
        .write(item)
        .then((rows) => rows > 0);
  }

  /// Soft-delete a vault item by setting isDeleted=true and updating timestamp.
  /// Per D-17: tombstone strategy for sync conflict resolution.
  Future<void> softDeleteItem(String itemId) {
    return (update(vaultItems)..where((t) => t.id.equals(itemId))).write(
      VaultItemsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Watch non-deleted items for a specific vault (reactive stream).
  Stream<List<VaultItem>> watchItemsByVault(String vaultId) {
    return (select(vaultItems)
          ..where(
            (t) => t.vaultId.equals(vaultId) & t.isDeleted.equals(false),
          ))
        .watch();
  }

  /// Get a single vault by ID.
  Future<Vault?> getVaultById(String vaultId) {
    return (select(vaults)..where((t) => t.id.equals(vaultId)))
        .getSingleOrNull();
  }

  /// Update an existing vault.
  Future<bool> updateVault(VaultsCompanion vault) {
    return (update(vaults)..where((t) => t.id.equals(vault.id.value)))
        .write(vault)
        .then((rows) => rows > 0);
  }

  /// Delete a vault and all its items by vault ID.
  Future<void> deleteVault(String vaultId) async {
    // Delete all items belonging to this vault first.
    await (delete(vaultItems)..where((t) => t.vaultId.equals(vaultId))).go();
    // Then delete the vault itself.
    await (delete(vaults)..where((t) => t.id.equals(vaultId))).go();
  }
}
