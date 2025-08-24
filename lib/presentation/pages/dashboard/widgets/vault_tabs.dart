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
                borderRadius: BorderRadius.circular(14),
              ),
              title: const Text(
                'Create Vault',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Vault Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Color', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colors.map((c) {
                      final color = _parseColor(c);
                      final isSelected = c == selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Icon', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: icons.map((iconName) {
                      final isSelected = iconName == selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIcon = iconName),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _parseColor(selectedColor).withValues(alpha: 0.2)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: _parseColor(selectedColor))
                                : null,
                          ),
                          child: Icon(
                            _vaultIcon(iconName),
                            size: 20,
                            color: isSelected
                                ? _parseColor(selectedColor)
                                : Colors.grey.shade600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
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
                  ),
                  child: const Text('Create'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  vault.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
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
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Rename Vault'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
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
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Delete Vault?'),
          content: Text(
            'All items in "${vault.name}" will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(multiVaultProvider.notifier).deleteVault(vault.id);
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
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
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
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
                  fontFamily: 'Poppins',
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
                'New',
                style: TextStyle(
                  fontFamily: 'Poppins',
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
