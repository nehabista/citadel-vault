import 'dart:developer' as dev;

import '../../../../core/database/daos/vault_dao.dart';
import '../../../../core/database/daos/settings_dao.dart';

/// Service for activating and deactivating travel mode.
///
/// Travel mode soft-hides sensitive vaults by setting isHiddenByTravel = true
/// on non-travel-safe vaults. No data is deleted — vaults remain in the local
/// Drift database but are excluded from normal queries.
///
/// On deactivation, the flag is flipped back to false — no server sync needed.
///
/// Per D-02: Activation soft-hides non-travel-safe vaults from local queries.
/// Per D-03: Deactivation unhides all travel-hidden vaults instantly.
/// Per D-04: isTravelSafe column used for filtering which vaults to hide.
class TravelModeService {
  final VaultDao _vaultDao;
  final SettingsDao _settingsDao;

  TravelModeService(this._vaultDao, this._settingsDao);

  static const _travelModeKey = 'travel_mode_active';

  /// Check if travel mode is currently active.
  Future<bool> isActive() async {
    final value = await _settingsDao.getSetting(_travelModeKey);
    return value == 'true';
  }

  /// Activate travel mode:
  /// 1. Find all vaults where isTravelSafe == false
  /// 2. Set isHiddenByTravel = true on those vaults (soft-hide, NOT delete)
  /// 3. Set travel_mode_active = 'true' in settings
  ///
  /// No data is lost — vaults and their items remain in the database.
  /// They are simply excluded from normal queries via the isHiddenByTravel
  /// filter in getAllVaults().
  Future<void> activate() async {
    final nonSafeVaults = await _vaultDao.getNonTravelSafeVaults();
    dev.log(
      '[TravelMode] Activating -- soft-hiding ${nonSafeVaults.length} '
      'non-travel-safe vaults',
    );

    for (final vault in nonSafeVaults) {
      await _vaultDao.hideVaultForTravel(vault.id);
    }

    await _settingsDao.setSetting(_travelModeKey, 'true');
    dev.log('[TravelMode] Travel mode activated');
  }

  /// Deactivate travel mode:
  /// 1. Unhide all travel-hidden vaults (flip isHiddenByTravel back to false)
  /// 2. Clear travel mode flag
  ///
  /// No server sync needed — data was never deleted, just hidden locally.
  /// Works instantly and offline.
  Future<void> deactivate() async {
    dev.log('[TravelMode] Deactivating -- unhiding all travel-hidden vaults');
    await _vaultDao.unhideAllTravelVaults();
    await _settingsDao.setSetting(_travelModeKey, 'false');
    dev.log('[TravelMode] Travel mode deactivated, vaults unhidden');
  }

  /// Toggle a vault's travel-safe status per D-01.
  /// When isSafe is false, the vault will be hidden during travel mode.
  Future<void> setVaultTravelSafe(String vaultId, bool isSafe) async {
    await _vaultDao.updateTravelSafe(vaultId, isSafe);
    dev.log('[TravelMode] Vault $vaultId travel-safe set to $isSafe');
  }
}
