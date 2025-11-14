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

  /// Get all visible vaults ordered by sort order.
  /// Excludes vaults hidden by travel mode.
  Future<List<Vault>> getAllVaults() {
    return (select(vaults)
          ..where((t) => t.isHiddenByTravel.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Get ALL vaults including those hidden by travel mode.
  /// Used by the travel mode settings page so users can see and toggle
  /// travel-safe status for every vault.
  Future<List<Vault>> getAllVaultsIncludingHidden() {
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

  /// Get all vaults where isTravelSafe is false (hidden during travel mode).
  Future<List<Vault>> getNonTravelSafeVaults() {
    return (select(vaults)..where((t) => t.isTravelSafe.equals(false))).get();
  }

  /// Update the travel-safe flag for a specific vault.
  Future<void> updateTravelSafe(String vaultId, bool isSafe) {
    return (update(vaults)..where((t) => t.id.equals(vaultId)))
        .write(VaultsCompanion(isTravelSafe: Value(isSafe)));
  }

  /// Soft-hide a vault for travel mode (sets isHiddenByTravel = true).
  /// The vault and its items remain in the database but are excluded from
  /// normal queries.
  Future<void> hideVaultForTravel(String vaultId) {
    return (update(vaults)..where((t) => t.id.equals(vaultId)))
        .write(const VaultsCompanion(isHiddenByTravel: Value(true)));
  }

  /// Unhide all travel-hidden vaults (sets isHiddenByTravel = false for all).
  /// Called when travel mode is deactivated.
  Future<void> unhideAllTravelVaults() {
    return (update(vaults)..where((t) => t.isHiddenByTravel.equals(true)))
        .write(const VaultsCompanion(isHiddenByTravel: Value(false)));
  }
}
