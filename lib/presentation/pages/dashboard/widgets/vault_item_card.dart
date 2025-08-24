// File: lib/presentation/pages/dashboard/widgets/vault_item_card.dart
// Vault item card widget per D-20 design spec
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/search/presentation/widgets/search_highlight.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';

/// Returns the appropriate icon for a vault item type.
IconData _itemTypeIcon(VaultItemType type) {
  return switch (type) {
    VaultItemType.password => Icons.lock_outline,
    VaultItemType.secureNote => Icons.sticky_note_2_outlined,
    VaultItemType.contactInfo => Icons.contact_page_outlined,
    VaultItemType.bankAccount => Icons.account_balance_outlined,
    VaultItemType.paymentCard => Icons.credit_card_outlined,
    VaultItemType.wifiPassword => Icons.wifi_outlined,
    VaultItemType.softwareLicense => Icons.code_outlined,
  };
}

/// Formats a DateTime as a relative time string.
String _relativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7}w ago';
  if (diff.inDays < 365) return '${diff.inDays ~/ 30}mo ago';
  return '${diff.inDays ~/ 365}y ago';
}

/// Card widget for displaying a vault item.
/// Shows type icon, name, username/url, favorite star, copy button, and modified time.
class VaultItemCard extends ConsumerWidget {
  final VaultItemEntity item;
  final String? searchQuery;
  final VoidCallback? onTap;

  const VaultItemCard({
    super.key,
    required this.item,
    this.searchQuery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = item.username ?? item.url;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap ?? () {
          debugPrint('Vault item tapped: ${item.name}');
        },
        onLongPress: () => _showContextMenu(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Leading icon
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF4D4DCD).withValues(alpha: 0.12),
                child: Icon(
                  _itemTypeIcon(item.type),
                  color: const Color(0xFF4D4DCD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      _buildSubtitle(subtitle),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Modified: ${_relativeTime(item.updatedAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing: favorite star + copy
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.isFavorite ? Icons.star : Icons.star_border,
                    color: item.isFavorite ? Colors.amber : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _copyPassword(context),
                    child: Icon(
                      Icons.copy_outlined,
                      color: const Color(0xFF4D4DCD),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return SearchHighlight(
        text: item.name,
        query: searchQuery!,
        baseStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      );
    }
    return Text(
      item.name,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(String subtitle) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return SearchHighlight(
        text: subtitle,
        query: searchQuery!,
        baseStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      );
    }
    return Text(
      subtitle,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  void _copyPassword(BuildContext context) {
    if (item.password != null && item.password!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: item.password!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
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
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy Password'),
                onTap: () {
                  Navigator.pop(ctx);
                  _copyPassword(context);
                },
              ),
              if (item.username != null)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Copy Username'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: item.username!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Username copied'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.drive_file_move_outlined),
                title: const Text('Move to Vault...'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Implement move-to-vault dialog (Plan 04)
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
