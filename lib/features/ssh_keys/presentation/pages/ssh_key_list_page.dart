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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keysAsync = ref.watch(sshKeyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SSH Keys',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
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
        backgroundColor: const Color(0xFF4D4DCD),
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
            Icon(Icons.vpn_key_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No SSH keys yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate or import SSH keys to store them securely in your vault.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showGenerateSheet(context, ref),
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4DCD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showImportSheet(context, ref),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Import'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4D4DCD),
                    side: const BorderSide(color: Color(0xFF4D4DCD)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
        final typeBadgeLabel =
            isEd25519 ? 'Ed25519' : 'RSA 4096';

        // Truncate fingerprint for display
        final shortFingerprint = sshData.fingerprint.length > 30
            ? '${sshData.fingerprint.substring(0, 30)}...'
            : sshData.fingerprint;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          color: const Color(0xFFF8FAFC),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.push('/ssh-keys/${item.id}', extra: item),
            onLongPress: () => _showDeleteDialog(context, ref, item),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    shortFingerprint,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
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
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.auto_fix_high, color: Color(0xFF4D4DCD)),
              title: const Text('Generate Key',
                  style: TextStyle(fontFamily: 'Poppins')),
              subtitle: const Text('Create a new SSH key pair',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _showGenerateSheet(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined,
                  color: Color(0xFF4D4DCD)),
              title: const Text('Import Key',
                  style: TextStyle(fontFamily: 'Poppins')),
              subtitle: const Text('Import from file or paste text',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _showImportSheet(context, ref);
              },
            ),
            const SizedBox(height: 16),
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
            style: TextStyle(fontFamily: 'Poppins')),
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
