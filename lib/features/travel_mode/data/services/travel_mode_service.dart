import 'dart:developer' as dev;

import '../../../../core/database/daos/vault_dao.dart';
import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/sync/sync_engine.dart';

/// Service for activating and deactivating travel mode.
///
/// Travel mode hides sensitive vaults from the local device by deleting
/// non-travel-safe vaults (and their items) from the local Drift database.
/// On deactivation, vaults are restored via a full PocketBase re-sync.
///
/// Per D-02: Activation purges non-travel-safe vaults from local DB.
/// Per D-03: Deactivation requires master password re-entry + full re-sync.
/// Per D-04: isTravelSafe column used for filtering.
class TravelModeService {
  final VaultDao _vaultDao;
  final SettingsDao _settingsDao;
  final SyncEngine _syncEngine;

  TravelModeService(this._vaultDao, this._settingsDao, this._syncEngine);

  static const _travelModeKey = 'travel_mode_active';

  /// Check if travel mode is currently active.
  Future<bool> isActive() async {
    final value = await _settingsDao.getSetting(_travelModeKey);
    return value == 'true';
  }

  /// Activate travel mode per D-02:
  /// 1. Find all vaults where isTravelSafe == false
  /// 2. Delete those vaults (and their items) from local Drift DB
  /// 3. Set travel_mode_active = 'true' in settings
  ///
  /// Hidden vault data remains safe on the PocketBase server and will be
  /// restored when the user deactivates travel mode.
  Future<void> activate() async {
    final nonSafeVaults = await _vaultDao.getNonTravelSafeVaults();
    dev.log(
      '[TravelMode] Activating -- purging ${nonSafeVaults.length} '
      'non-travel-safe vaults from local DB',
    );

    for (final vault in nonSafeVaults) {
      await _vaultDao.deleteVault(vault.id);
    }

    await _settingsDao.setSetting(_travelModeKey, 'true');
    dev.log('[TravelMode] Travel mode activated');
  }

  /// Deactivate travel mode per D-03:
  /// 1. Clear travel mode flag
  /// 2. Force full re-sync from PocketBase to restore hidden vaults
  ///
  /// Caller must verify master password before calling this method.
  Future<void> deactivate() async {
    dev.log('[TravelMode] Deactivating -- will restore vaults via re-sync');
    await _settingsDao.setSetting(_travelModeKey, 'false');
    await _syncEngine.forceFullResync();
    dev.log('[TravelMode] Travel mode deactivated, re-sync initiated');
  }

  /// Toggle a vault's travel-safe status per D-01.
  /// When isSafe is false, the vault will be hidden during travel mode.
  Future<void> setVaultTravelSafe(String vaultId, bool isSafe) async {
    await _vaultDao.updateTravelSafe(vaultId, isSafe);
    dev.log('[TravelMode] Vault $vaultId travel-safe set to $isSafe');
  }
}
