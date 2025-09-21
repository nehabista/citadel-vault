// File: lib/presentation/pages/dashboard/widgets/vault_tabs.dart
// Horizontal vault tabs with selection, creation, and management (D-08, D-09, D-11)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../features/vault/presentation/providers/multi_vault_provider.dart';

/// Maps vault icon names to IconData.
IconData _vaultIcon(String iconName) {
  return switch (iconName) {
    'shield' => Icons.shield_outlined,
    'work' => Icons.work_outline,
    'home' => Icons.home_outlined,
    'star' => Icons.star_outline,
    'lock' => Icons.lock_outline,
    'person' => Icons.person_outline,
    'folder' => Icons.folder_outlined,
    'cloud' => Icons.cloud_outlined,
    'key' => Icons.key_outlined,
    'favorite' => Icons.favorite_outline,
    _ => Icons.shield_outlined,
  };
}

/// Parses a hex color string to a Color.
Color _parseColor(String hex) {
  final buffer = StringBuffer();
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 6) buffer.write('FF');
  buffer.write(hex);
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Horizontal scrollable vault tabs.
class VaultTabs extends ConsumerWidget {
  const VaultTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultState = ref.watch(multiVaultProvider);
    final vaults = vaultState.vaults;
    final selectedId = vaultState.selectedVaultId;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: vaults.length + 1, // +1 for the add button
        itemBuilder: (context, index) {
          if (index == vaults.length) {
            return _AddVaultButton(
              onTap: () => _showCreateVaultDialog(context, ref),
            );
          }
          final vault = vaults[index];
          final isSelected = vault.id == selectedId;
          final color = _parseColor(vault.colorHex);

          return _VaultTab(
            vault: vault,
            isSelected: isSelected,
            color: color,
            onTap: () {
              ref.read(multiVaultProvider.notifier).selectVault(vault.id);
            },
            onLongPress: () {
              _showVaultMenu(context, ref, vault);
            },
          );
        },
      ),
    );
  }

  void _showCreateVaultDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedColor = '#4D4DCD';
    String selectedIcon = 'shield';

    final colors = [
      '#4D4DCD', '#E53935', '#43A047', '#FB8C00',
      '#1E88E5', '#8E24AA', '#00897B', '#F4511E',
    ];

    final icons = [
      'shield', 'work', 'home', 'star',
      'lock', 'person', 'folder', 'cloud',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.black.withAlpha(40),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              title: const Text(
                'Create Vault',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Vault Name',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF4D4DCD),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: colors.map((c) {
                      final color = _parseColor(c);
                      final isSelected = c == selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withAlpha(120),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              else
                                BoxShadow(
                                  color: color.withAlpha(40),
                                  blurRadius: 4,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Icon',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: icons.map((iconName) {
                      final isSelected = iconName == selectedIcon;
                      final activeColor = _parseColor(selectedColor);
                      return GestureDetector(
                        onTap: () => setState(() => selectedIcon = iconName),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeColor.withAlpha(30)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? activeColor
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            _vaultIcon(iconName),
                            size: 22,
                            color: isSelected
                                ? activeColor
                                : Colors.grey.shade500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      ref.read(multiVaultProvider.notifier).createVault(
                        name,
                        colorHex: selectedColor,
                        iconName: selectedIcon,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4DCD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showVaultMenu(BuildContext context, WidgetRef ref, Vault vault) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  vault.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRenameDialog(context, ref, vault);
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Change Color'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Implement color change dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Change Icon'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Implement icon change dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Vault',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmation(context, ref, vault);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Vault vault) {
    final controller = TextEditingController(text: vault.name);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Rename Vault'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4D4DCD),
                  width: 2,
                ),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(vaultRepositoryProvider).updateVault(
                    id: vault.id,
                    name: name,
                  );
                  ref.read(multiVaultProvider.notifier).refreshItems();
                  Navigator.pop(ctx);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4D4DCD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Vault vault) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Vault?'),
          content: Text(
            'All items in "${vault.name}" will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(multiVaultProvider.notifier).deleteVault(vault.id);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _VaultTab extends StatelessWidget {
  final Vault vault;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _VaultTab({
    required this.vault,
    required this.isSelected,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(25) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _vaultIcon(vault.iconName),
                size: 18,
                color: isSelected ? color : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                vault.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddVaultButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddVaultButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'New Vault',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
