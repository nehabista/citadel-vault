// File: lib/features/ssh_keys/presentation/pages/ssh_key_list_page.dart
// SSH key list page with type badges, fingerprints, and FAB for generate/import.
// Per D-16: list shows name, type badge, fingerprint, date.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../providers/ssh_key_providers.dart';
import '../widgets/generate_key_sheet.dart';
import '../widgets/import_key_sheet.dart';

class SshKeyListPage extends ConsumerWidget {
  const SshKeyListPage({super.key});

  static const _primary = Color(0xFF4D4DCD);
  static const _darkText = Color(0xFF1A1A2E);
  static const _borderColor = Color(0xFFE8EDF5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keysAsync = ref.watch(sshKeyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SSH Keys',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              'Manage your SSH keys',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
      body: keysAsync.when(
        data: (keys) => keys.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildKeyList(context, ref, keys),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load SSH keys:\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primary,
        onPressed: () => _showAddMenu(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withValues(alpha: 0.08),
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                size: 44,
                color: _primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No SSH Keys',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate or import SSH keys to manage\nthem securely in your vault.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showGenerateSheet(context, ref),
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Generate Key',
                      style: TextStyle(fontFamily: 'Poppins')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showImportSheet(context, ref),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Import Key',
                      style: TextStyle(fontFamily: 'Poppins')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyList(
      BuildContext context, WidgetRef ref, List<VaultItemEntity> keys) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final item = keys[index];
        final sshData = item.sshKeyData;
        if (sshData == null) return const SizedBox.shrink();

        final isEd25519 = sshData.keyType == 'ed25519';
        final typeBadgeColor =
            isEd25519 ? const Color(0xFF43A047) : const Color(0xFF1E88E5);
        final typeBadgeLabel = isEd25519 ? 'Ed25519' : 'RSA 4096';
        final iconBgColor = isEd25519
            ? const Color(0xFF009688).withValues(alpha: 0.10)
            : const Color(0xFF607D8B).withValues(alpha: 0.10);
        final iconColor =
            isEd25519 ? const Color(0xFF009688) : const Color(0xFF607D8B);

        // Truncate fingerprint for display
        final shortFingerprint = sshData.fingerprint.length > 28
            ? '${sshData.fingerprint.substring(0, 28)}...'
            : sshData.fingerprint;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.push('/ssh-keys/${item.id}', extra: item),
            onLongPress: () => _showDeleteDialog(context, ref, item),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Key icon in colored circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.vpn_key_rounded,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name, fingerprint, date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: _darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          shortFingerprint,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDate(item.createdAt),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Type badge + chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeBadgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeBadgeLabel,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: typeBadgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add SSH Key',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how to add a new key',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_fix_high,
                    color: _primary, size: 20),
              ),
              title: const Text('Generate Key',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              subtitle: const Text('Create a new SSH key pair',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _showGenerateSheet(context, ref);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.file_download_outlined,
                    color: _primary, size: 20),
              ),
              title: const Text('Import Key',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              subtitle: const Text('Import from file or paste text',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _showImportSheet(context, ref);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showGenerateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => GenerateKeySheet(
        onGenerated: () {
          ref.invalidate(sshKeyListProvider);
          if (context.mounted) {
            showCitadelSnackBar(context, 'SSH key generated',
                type: SnackBarType.success);
          }
        },
      ),
    );
  }

  void _showImportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ImportKeySheet(
        onImported: () {
          ref.invalidate(sshKeyListProvider);
          if (context.mounted) {
            showCitadelSnackBar(context, 'SSH key imported',
                type: SnackBarType.success);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, VaultItemEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete SSH Key',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final service = ref.read(sshKeyServiceProvider);
              await service.deleteKey(item.id);
              ref.invalidate(sshKeyListProvider);
              if (context.mounted) {
                showCitadelSnackBar(context, 'SSH key deleted');
              }
            },
            child: const Text('Delete',
                style: TextStyle(
                    fontFamily: 'Poppins', color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
