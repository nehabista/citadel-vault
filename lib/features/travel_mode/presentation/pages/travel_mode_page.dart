// File: lib/features/travel_mode/presentation/pages/travel_mode_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../providers/travel_mode_providers.dart';

/// Travel Mode settings page.
///
/// Allows users to hide selected vaults when crossing borders.
/// When Travel Mode is active, hidden vaults are removed from local storage
/// and can only be restored after disabling Travel Mode and re-syncing.
class TravelModePage extends ConsumerStatefulWidget {
  const TravelModePage({super.key});

  @override
  ConsumerState<TravelModePage> createState() => _TravelModePageState();
}

class _TravelModePageState extends ConsumerState<TravelModePage> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    final travelModeAsync = ref.watch(travelModeActiveProvider);
    final isActive = travelModeAsync.value ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Travel Mode',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(25),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.flight_rounded,
              size: 44,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Travel Mode',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'When enabled, selected vaults are hidden from your device. '
            'This protects sensitive data when crossing borders or in '
            'situations where your device may be inspected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Travel mode toggle card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? Colors.orange.withValues(alpha: 0.4)
                    : const Color(0xFFE8EDF5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.orange.withValues(alpha: 0.1)
                        : const Color(0xFFF4F6FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive
                        ? Icons.flight_takeoff_rounded
                        : Icons.flight_land_rounded,
                    color: isActive ? Colors.orange : Colors.grey.shade400,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Travel Mode',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: isActive
                              ? Colors.orange
                              : Colors.grey.shade500,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isToggling)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  )
                else
                  Switch.adaptive(
                    value: isActive,
                    activeTrackColor: Colors.orange,
                    onChanged: (value) => _onToggleTravelMode(value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Vault travel-safe list
          _VaultTravelSafeList(isActive: isActive),
        ],
      ),
    );
  }

  Future<void> _onToggleTravelMode(bool activate) async {
    if (_isToggling) return;

    final service = ref.read(travelModeServiceProvider);

    if (activate) {
      // Show warning dialog before activating
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Activate Travel Mode?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Hidden vaults will be removed from this device. '
            'They can be restored when you deactivate travel mode and re-sync.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Activate'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      setState(() => _isToggling = true);
      try {
        await service.activate();
        ref.invalidate(travelModeActiveProvider);
        if (!mounted) return;
        showCitadelSnackBar(
          context,
          'Travel mode activated -- hidden vaults removed',
          type: SnackBarType.success,
        );
      } catch (e) {
        if (!mounted) return;
        showCitadelSnackBar(
          context,
          'Failed to activate travel mode: $e',
          type: SnackBarType.error,
        );
      } finally {
        if (mounted) setState(() => _isToggling = false);
      }
    } else {
      // Deactivate
      setState(() => _isToggling = true);
      try {
        showCitadelSnackBar(
          context,
          'Restoring hidden vaults...',
          type: SnackBarType.info,
        );
        await service.deactivate();
        ref.invalidate(travelModeActiveProvider);
        if (!mounted) return;
        showCitadelSnackBar(
          context,
          'Travel mode deactivated -- vaults restored',
          type: SnackBarType.success,
        );
      } catch (e) {
        if (!mounted) return;
        showCitadelSnackBar(
          context,
          'Failed to deactivate travel mode: $e',
          type: SnackBarType.error,
        );
      } finally {
        if (mounted) setState(() => _isToggling = false);
      }
    }
  }
}

/// Provider that loads all vaults for the travel-safe list.
final _allVaultsProvider = FutureProvider((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.vaultDao.getAllVaults();
});

/// List of vaults with toggles showing travel-safe status.
class _VaultTravelSafeList extends ConsumerWidget {
  const _VaultTravelSafeList({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultsAsync = ref.watch(_allVaultsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vault Visibility',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vaults marked "Travel Safe" remain visible during travel mode.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        vaultsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (err, _) => Text(
            'Error loading vaults: $err',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: 13,
            ),
          ),
          data: (vaults) {
            if (vaults.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8EDF5)),
                ),
                child: Text(
                  'No vaults found',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8EDF5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: List.generate(
                  vaults.length * 2 - 1,
                  (i) {
                    if (i.isOdd) {
                      return const Divider(
                          height: 1, indent: 56, endIndent: 0);
                    }
                    final vault = vaults[i ~/ 2];
                    return _VaultTravelTile(
                      vault: vault,
                      isDisabled: isActive,
                    );
                  },
                ),
              ),
            );
          },
        ),
        if (isActive) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.orange.shade700, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Deactivate travel mode to change vault visibility.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Individual vault tile with travel-safe toggle.
class _VaultTravelTile extends ConsumerWidget {
  const _VaultTravelTile({required this.vault, required this.isDisabled});

  final dynamic vault; // Drift Vault type
  final bool isDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSafe = vault.isTravelSafe as bool;
    final name = vault.name as String;
    final iconName = vault.iconName as String;
    final colorHex = vault.colorHex as String;

    // Parse color from hex
    final color = _parseColor(colorHex);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _iconForName(iconName),
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Color(0xFF1A1A2E),
        ),
      ),
      subtitle: Text(
        isSafe ? 'Travel safe' : 'Hidden in travel mode',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: isSafe ? const Color(0xFF43A047) : Colors.orange.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch.adaptive(
        value: isSafe,
        activeTrackColor: const Color(0xFF43A047),
        onChanged: isDisabled
            ? null
            : (value) async {
                try {
                  final service = ref.read(travelModeServiceProvider);
                  await service.setVaultTravelSafe(
                    vault.id as String,
                    value,
                  );
                  ref.invalidate(_allVaultsProvider);
                } catch (e) {
                  if (!context.mounted) return;
                  showCitadelSnackBar(
                    context,
                    'Failed to update vault: $e',
                    type: SnackBarType.error,
                  );
                }
              },
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final cleaned = hex.replaceFirst('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return const Color(0xFF4D4DCD);
    }
  }

  IconData _iconForName(String name) {
    return switch (name) {
      'shield' => Icons.shield_rounded,
      'work' => Icons.work_rounded,
      'home' => Icons.home_rounded,
      'person' => Icons.person_rounded,
      'lock' => Icons.lock_rounded,
      'key' => Icons.vpn_key_rounded,
      'star' => Icons.star_rounded,
      'folder' => Icons.folder_rounded,
      'credit_card' => Icons.credit_card_rounded,
      'cloud' => Icons.cloud_rounded,
      'code' => Icons.code_rounded,
      'wifi' => Icons.wifi_rounded,
      'email' => Icons.email_rounded,
      'bank' => Icons.account_balance_rounded,
      'health' => Icons.health_and_safety_rounded,
      'travel' => Icons.flight_rounded,
      _ => Icons.shield_rounded,
    };
  }
}
