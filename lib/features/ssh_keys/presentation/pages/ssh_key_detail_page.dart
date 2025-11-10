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

  static const _primary = Color(0xFF4D4DCD);
  static const _darkText = Color(0xFF1A1A2E);
  static const _borderColor = Color(0xFFE8EDF5);
  static const _cardBg = Colors.white;

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
          // Header card
          _buildHeaderCard(context, sshData, isEd25519, item),
          const SizedBox(height: 16),

          // Public key section
          _buildKeySection(
            context,
            title: 'Public Key',
            icon: Icons.lock_open_rounded,
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
            icon: Icons.lock_rounded,
            value: sshData.privateKey,
            isObscured: !_showPrivateKey,
            onToggle: () => setState(() => _showPrivateKey = !_showPrivateKey),
            onCopy: () => _confirmCopyPrivateKey(sshData.privateKey),
          ),

          // Passphrase section (if set)
          if (sshData.passphrase != null &&
              sshData.passphrase!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildKeySection(
              context,
              title: 'Passphrase',
              icon: Icons.password_rounded,
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

          // Comment section
          if (sshData.comment != null && sshData.comment!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCommentCard(sshData.comment!),
          ],

          const SizedBox(height: 24),

          // Delete button
          _buildDeleteButton(context, item),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    SshKeyData sshData,
    bool isEd25519,
    VaultItemEntity item,
  ) {
    final typeBadgeColor =
        isEd25519 ? const Color(0xFF43A047) : const Color(0xFF1E88E5);
    final typeBadgeLabel = isEd25519 ? 'Ed25519' : 'RSA 4096';
    final iconBgColor = isEd25519
        ? const Color(0xFF009688).withValues(alpha: 0.10)
        : const Color(0xFF607D8B).withValues(alpha: 0.10);
    final iconColor =
        isEd25519 ? const Color(0xFF009688) : const Color(0xFF607D8B);

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
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
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: _borderColor),
          const SizedBox(height: 14),
          _infoRow('Fingerprint', sshData.fingerprint, mono: true),
          const SizedBox(height: 10),
          _infoRow('Created', _formatDate(item.createdAt)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool mono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        SelectableText(
          value,
          style: TextStyle(
            fontFamily: mono ? 'monospace' : 'Poppins',
            fontSize: 13,
            color: _darkText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildKeySection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
    required bool isObscured,
    VoidCallback? onToggle,
    required VoidCallback onCopy,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _darkText,
                ),
              ),
              const Spacer(),
              if (onToggle != null)
                _actionIconButton(
                  icon: isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  tooltip: isObscured ? 'Reveal' : 'Hide',
                  onPressed: onToggle,
                ),
              const SizedBox(width: 2),
              _actionIconButton(
                icon: Icons.copy_rounded,
                tooltip: 'Copy',
                onPressed: onCopy,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
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
                      color: _darkText,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(String comment) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment_outlined, size: 18, color: _primary),
              const SizedBox(width: 8),
              const Text(
                'Comment',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, VaultItemEntity item) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _deleteKey(context, item),
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: const Text('Delete Key',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _confirmCopyPrivateKey(String privateKey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy Private Key?',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: const Text(
          'Your private key is sensitive. Make sure you are in a secure environment before copying it to the clipboard.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Clipboard.setData(ClipboardData(text: privateKey));
              if (mounted) {
                showCitadelSnackBar(context, 'Private key copied',
                    type: SnackBarType.success);
              }
            },
            child: const Text('Copy',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: _primary)),
          ),
        ],
      ),
    );
  }

  void _deleteKey(BuildContext context, VaultItemEntity item) {
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
