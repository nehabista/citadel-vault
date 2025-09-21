// File: lib/presentation/pages/dashboard/widgets/vault_item_card.dart
// Premium vault item card widget with colored type indicators
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// Returns the color associated with a vault item type.
Color _itemTypeColor(VaultItemType type) {
  return switch (type) {
    VaultItemType.password => const Color(0xFF4D4DCD),
    VaultItemType.secureNote => const Color(0xFF43A047),
    VaultItemType.bankAccount => const Color(0xFF1565C0),
    VaultItemType.paymentCard => const Color(0xFFE65100),
    VaultItemType.wifiPassword => const Color(0xFF00897B),
    VaultItemType.contactInfo => const Color(0xFF5E35B1),
    VaultItemType.softwareLicense => const Color(0xFF795548),
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

/// Premium card widget for displaying a vault item.
/// Features a colored left border, type-colored icon container,
/// title/subtitle/modified text, and trailing copy + favorite actions.
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
    final typeColor = _itemTypeColor(item.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap ?? () => context.push('/vault-item/${item.id}'),
          onLongPress: () => _showContextMenu(context, ref),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8EDF5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  // Colored left border strip
                  Container(
                    width: 4,
                    height: 76,
                    color: typeColor,
                  ),
                  const SizedBox(width: 12),
                  // Type icon in rounded square container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _itemTypeIcon(item.type),
                      color: typeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title, subtitle, modified
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
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
                              color: Colors.grey.shade400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Trailing actions: copy + favorite
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: item.isFavorite ? const Color(0xFFFFA726) : Colors.grey.shade300,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _copyPassword(context),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4D4DCD).withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              color: Color(0xFF4D4DCD),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    const baseStyle = TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: Color(0xFF1A1A2E),
    );
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return SearchHighlight(
        text: item.name,
        query: searchQuery!,
        baseStyle: baseStyle,
      );
    }
    return Text(
      item.name,
      style: baseStyle,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(String subtitle) {
    final baseStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      color: Colors.grey.shade500,
    );
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return SearchHighlight(
        text: subtitle,
        query: searchQuery!,
        baseStyle: baseStyle,
      );
    }
    return Text(
      subtitle,
      style: baseStyle,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _copyPassword(BuildContext context) {
    if (item.password != null && item.password!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: item.password!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Password copied to clipboard',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4D4DCD),
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
                        backgroundColor: const Color(0xFF4D4DCD),
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
