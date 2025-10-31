// File: lib/features/ssh_keys/presentation/pages/ssh_key_detail_page.dart
// SSH key detail page with copy buttons for public/private keys.
// Per D-16: full key details, private key obscured by default with reveal toggle.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../data/models/ssh_key_data.dart';
import '../providers/ssh_key_providers.dart';

class SshKeyDetailPage extends ConsumerStatefulWidget {
  final String itemId;
  final VaultItemEntity? item;

  const SshKeyDetailPage({
    super.key,
    required this.itemId,
    this.item,
  });

  @override
  ConsumerState<SshKeyDetailPage> createState() => _SshKeyDetailPageState();
}

class _SshKeyDetailPageState extends ConsumerState<SshKeyDetailPage> {
  bool _showPrivateKey = false;
  bool _showPassphrase = false;

  VaultItemEntity? get _resolvedItem {
    // First try the directly passed item
    if (widget.item != null) return widget.item;
    // Otherwise look it up from the key list
    final keysAsync = ref.watch(sshKeyListProvider);
    return keysAsync.whenOrNull(
      data: (keys) {
        try {
          return keys.firstWhere((k) => k.id == widget.itemId);
        } catch (_) {
          return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _resolvedItem;

    if (item == null || item.sshKeyData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('SSH Key')),
        body: const Center(
          child: Text('SSH key not found',
              style: TextStyle(fontFamily: 'Poppins')),
        ),
      );
    }

    final sshData = item.sshKeyData!;
    final isEd25519 = sshData.keyType == 'ed25519';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete',
            onPressed: () => _deleteKey(context, item),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Key info header
          _buildInfoCard(context, sshData, isEd25519, item),
          const SizedBox(height: 16),

          // Public key section
          _buildKeySection(
            context,
            title: 'Public Key',
            value: sshData.publicKey,
            isObscured: false,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: sshData.publicKey));
              showCitadelSnackBar(context, 'Public key copied',
                  type: SnackBarType.success);
            },
          ),
          const SizedBox(height: 16),

          // Private key section
          _buildKeySection(
            context,
            title: 'Private Key',
            value: sshData.privateKey,
            isObscured: !_showPrivateKey,
            onToggle: () => setState(() => _showPrivateKey = !_showPrivateKey),
            onCopy: () {
              Clipboard.setData(ClipboardData(text: sshData.privateKey));
              showCitadelSnackBar(context, 'Private key copied',
                  type: SnackBarType.success);
            },
          ),

          // Passphrase section (if set)
          if (sshData.passphrase != null &&
              sshData.passphrase!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildKeySection(
              context,
              title: 'Passphrase',
              value: sshData.passphrase!,
              isObscured: !_showPassphrase,
              onToggle: () =>
                  setState(() => _showPassphrase = !_showPassphrase),
              onCopy: () {
                Clipboard.setData(
                    ClipboardData(text: sshData.passphrase!));
                showCitadelSnackBar(context, 'Passphrase copied',
                    type: SnackBarType.success);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    SshKeyData sshData,
    bool isEd25519,
    VaultItemEntity item,
  ) {
    final typeBadgeColor =
        isEd25519 ? const Color(0xFF43A047) : const Color(0xFF1E88E5);
    final typeBadgeLabel = isEd25519 ? 'Ed25519' : 'RSA 4096';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.vpn_key, color: Color(0xFF4D4DCD), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            const SizedBox(height: 12),
            _infoRow('Fingerprint', sshData.fingerprint, mono: true),
            if (sshData.comment != null && sshData.comment!.isNotEmpty)
              _infoRow('Comment', sshData.comment!),
            _infoRow('Created', _formatDate(item.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: TextStyle(
              fontFamily: mono ? 'monospace' : 'Poppins',
              fontSize: 13,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeySection(
    BuildContext context, {
    required String title,
    required String value,
    required bool isObscured,
    VoidCallback? onToggle,
    required VoidCallback onCopy,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                if (onToggle != null)
                  IconButton(
                    icon: Icon(
                      isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: onToggle,
                    tooltip: isObscured ? 'Reveal' : 'Hide',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.copy, size: 20, color: Colors.grey.shade600),
                  onPressed: onCopy,
                  tooltip: 'Copy',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8EDF5)),
              ),
              child: isObscured
                  ? const Text(
                      '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        letterSpacing: 2,
                        color: Color(0xFF6B7280),
                      ),
                    )
                  : SelectableText(
                      value,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF1A1A2E),
                        height: 1.5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteKey(BuildContext context, VaultItemEntity item) {
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
            child:
                const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final service = ref.read(sshKeyServiceProvider);
              await service.deleteKey(item.id);
              ref.invalidate(sshKeyListProvider);
              if (context.mounted) {
                showCitadelSnackBar(context, 'SSH key deleted');
                context.pop();
              }
            },
            child: const Text('Delete',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
