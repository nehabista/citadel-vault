// File: lib/features/sharing/presentation/widgets/shared_vault_selector.dart
// Horizontal scrollable chip selector for shared vaults on the dashboard.
// Per D-21: separate tab/section in vault selector with teal accent.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vault_member.dart';
import '../providers/sharing_providers.dart';

/// Horizontal chip selector for switching between shared vaults.
///
/// Appears in the dashboard as a separate section from personal vaults,
/// using a teal accent color (Color(0xFF26A69A)) to distinguish shared
/// vaults from personal purple vaults.
class SharedVaultSelector extends ConsumerWidget {
  /// Callback when a shared vault is selected. Passes the vault ID.
  final void Function(String vaultId)? onVaultSelected;

  /// Currently selected vault ID, if any.
  final String? selectedVaultId;

  const SharedVaultSelector({
    super.key,
    this.onVaultSelected,
    this.selectedVaultId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultsAsync = ref.watch(userSharedVaultsProvider);

    return vaultsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (vaults) {
        if (vaults.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_shared,
                    color: Color(0xFF26A69A),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Shared Vaults',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vaults.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) =>
                    _buildChip(context, vaults[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChip(BuildContext context, VaultMember member) {
    final isSelected = selectedVaultId == member.vaultId;

    return FilterChip(
      label: Text(
        member.vaultId,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF26A69A),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onVaultSelected?.call(member.vaultId),
      backgroundColor: const Color(0xFF26A69A).withValues(alpha: 0.08),
      selectedColor: const Color(0xFF26A69A),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF26A69A)
            : const Color(0xFF26A69A).withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
