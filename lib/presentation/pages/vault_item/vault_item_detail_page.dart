import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../widgets/citadel_snackbar.dart';
import '../../../core/utils/error_sanitizer.dart';
import '../../../features/file_vault/presentation/pages/file_vault_page.dart';
import '../../../features/sharing/presentation/pages/share_bottom_sheet.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/session/session_state.dart';
import '../../../features/security/data/models/breach_record.dart';
import '../../../features/security/presentation/pages/breach_timeline_page.dart';
import '../../../features/security/domain/entities/breach_result.dart';
import '../../../features/security/presentation/providers/breach_catalog_provider.dart';
import '../../../features/security/presentation/providers/breach_provider.dart';
import '../../../features/security/presentation/providers/totp_provider.dart';
import '../../../features/security/presentation/widgets/totp_add_dialog.dart';
import '../../../features/security/presentation/widgets/totp_display.dart';
import '../../../features/vault/domain/entities/custom_field.dart';
import '../../../features/vault/domain/entities/vault_item.dart';
import '../../../features/vault/presentation/providers/multi_vault_provider.dart';
import 'vault_item_edit_page.dart';
import 'widgets/password_history_section.dart';

/// Provider that loads a single vault item by ID from the repository.
/// Returns the item as a VaultItemEntity or null if not found.
final vaultItemDetailProvider =
    FutureProvider.family<VaultItemEntity?, String>((ref, itemId) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) return null;

  final vaultKey = SecretKey(session.vaultKey);
  final repo = ref.read(vaultRepositoryProvider);

  // Search across all vaults to find the item by ID.
  final allItems = await repo.getAllItems(vaultKey);
  return allItems.where((i) => i.id == itemId).firstOrNull;
});

/// Detail page for viewing a vault item.
///
/// Displays credentials, custom fields, password history,
/// and metadata in Material Design 3 section cards. Per D-21.
class VaultItemDetailPage extends ConsumerStatefulWidget {
  const VaultItemDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<VaultItemDetailPage> createState() =>
      _VaultItemDetailPageState();
}

class _VaultItemDetailPageState extends ConsumerState<VaultItemDetailPage> {
  bool _passwordRevealed = false;
  final Set<int> _revealedCustomFields = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemAsync = ref.watch(vaultItemDetailProvider(widget.itemId));

    // Pre-warm breach catalog and password history for timeline.
    ref.watch(breachCatalogProvider);
    ref.watch(passwordHistoryProvider(widget.itemId));

    return itemAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: ${sanitizeErrorMessage(err)}')),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Item not found')),
          );
        }
        return _buildDetailScaffold(context, theme, item);
      },
    );
  }

  Widget _buildDetailScaffold(
      BuildContext context, ThemeData theme, VaultItemEntity item) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareItem(context, item),
            icon: const Icon(Icons.share_rounded, color: Color(0xFF4D4DCD)),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: () => _navigateToEdit(item),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, item),
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Item logo + type badge
          Row(
            children: [
              _buildDetailLogo(item),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D4DCD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _itemTypeLabel(item.type),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF4D4DCD),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.isFavorite) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Breach warning banner
          _BreachWarningBanner(item: item),

          // Credentials section
          _SectionCard(
            title: 'Credentials',
            children: [
              if (item.url != null && item.url!.isNotEmpty)
                _DetailRow(
                  label: 'URL',
                  value: item.url!,
                  trailing: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.url!));
                      _showCopiedSnackbar(context, 'URL');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                  ),
                ),
              if (item.username != null && item.username!.isNotEmpty)
                _DetailRow(
                  label: 'Username',
                  value: item.username!,
                  trailing: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.username!));
                      _showCopiedSnackbar(context, 'Username');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                  ),
                ),
              if (item.password != null && item.password!.isNotEmpty)
                _DetailRow(
                  label: 'Password',
                  value: _passwordRevealed
                      ? item.password!
                      : '\u2022' * 12,
                  valueStyle: TextStyle(
                    fontFamily: _passwordRevealed ? 'monospace' : null,
                    letterSpacing: _passwordRevealed ? 0.5 : 2,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(
                              () => _passwordRevealed = !_passwordRevealed);
                        },
                        icon: Icon(
                          _passwordRevealed
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 18,
                          color: const Color(0xFF4D4DCD),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: item.password!),
                          );
                          _showCopiedSnackbar(context, 'Password');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              if (item.notes != null && item.notes!.isNotEmpty)
                _DetailRow(label: 'Notes', value: item.notes!),
            ],
          ),
          const SizedBox(height: 16),

          // Expiry warning
          if (item.expiryDays != null) _buildExpiryWarning(theme, item),

          // TOTP section — per D-14
          _TotpSection(vaultItemId: item.id),
          const SizedBox(height: 16),

          // Breach timeline button
          _SectionCard(
            title: 'Security',
            children: [
              OutlinedButton.icon(
                onPressed: () => _navigateToBreachTimeline(item),
                icon: const Icon(Icons.timeline_rounded),
                label: const Text('View Breach Timeline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4D4DCD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Encrypted files section per D-19
          FileVaultSection(vaultId: item.vaultId),
          const SizedBox(height: 16),

          // Custom fields section
          if (item.customFields != null && item.customFields!.isNotEmpty) ...[
            _SectionCard(
              title: 'Custom Fields',
              children: item.customFields!.asMap().entries.map((entry) {
                final idx = entry.key;
                final field = entry.value;
                return _buildCustomFieldRow(context, idx, field);
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Password history section
          _SectionCard(
            title: 'Password History',
            children: [
              PasswordHistorySection(itemId: widget.itemId),
            ],
          ),
          const SizedBox(height: 16),

          // Metadata section
          _SectionCard(
            title: 'Metadata',
            children: [
              _DetailRow(
                label: 'Created',
                value: DateFormat('MMM d, yyyy HH:mm').format(item.createdAt),
              ),
              _DetailRow(
                label: 'Last Modified',
                value: DateFormat('MMM d, yyyy HH:mm').format(item.updatedAt),
              ),
              _DetailRow(
                label: 'Type',
                value: _itemTypeLabel(item.type),
              ),
              _DetailRow(
                label: 'Vault',
                value: item.vaultId,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailLogo(VaultItemEntity item) {
    final logoUrl = item.customFields
        ?.where((f) => f.name == 'logoUrl')
        .firstOrNull
        ?.value;

    if (logoUrl == null || logoUrl.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          logoUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  void _shareItem(BuildContext context, VaultItemEntity item) {
    final itemData = <String, dynamic>{
      'id': item.id,
      'name': item.name,
      'type': item.type.name,
      'username': item.username,
      'password': item.password,
      'url': item.url,
      'notes': item.notes,
    };
    ShareBottomSheet.show(context, itemData: itemData);
  }

  void _navigateToEdit(VaultItemEntity item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VaultItemEditPage(existingItem: item),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext dialogContext, VaultItemEntity item) async {
    final errorColor = Theme.of(dialogContext).colorScheme.error;
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Item',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text('Are you sure you want to delete "${item.name}"?'),
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
            style: FilledButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(vaultRepositoryProvider).deleteItem(item.id);
      ref.read(multiVaultProvider.notifier).refreshItems();
      if (!mounted) return;
      GoRouter.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showCitadelSnackBar(context,
          'Error deleting item: ${sanitizeErrorMessage(e)}',
          type: SnackBarType.error);
    }
  }

  Widget _buildCustomFieldRow(
      BuildContext context, int index, CustomField field) {
    switch (field.type) {
      case CustomFieldType.text:
        return _DetailRow(label: field.name, value: field.value);
      case CustomFieldType.hidden:
        final isRevealed = _revealedCustomFields.contains(index);
        return _DetailRow(
          label: field.name,
          value: isRevealed ? field.value : '\u2022' * 8,
          valueStyle: TextStyle(
            fontFamily: isRevealed ? 'monospace' : null,
          ),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                if (isRevealed) {
                  _revealedCustomFields.remove(index);
                } else {
                  _revealedCustomFields.add(index);
                }
              });
            },
            icon: Icon(
              isRevealed
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 18,
              color: const Color(0xFF4D4DCD),
            ),
          ),
        );
      case CustomFieldType.boolean:
        return _DetailRow(
          label: field.name,
          value: field.value.toLowerCase() == 'true' ? 'On' : 'Off',
        );
    }
  }

  void _showCopiedSnackbar(BuildContext context, String what) {
    showCitadelSnackBar(context, '$what copied', type: SnackBarType.success);
  }

  Widget _buildExpiryWarning(ThemeData theme, VaultItemEntity item) {
    if (item.expiryDays == null) return const SizedBox.shrink();
    final expiresAt =
        item.updatedAt.add(Duration(days: item.expiryDays!));
    final now = DateTime.now();
    if (expiresAt.isAfter(now)) return const SizedBox.shrink();

    final daysExpired = now.difference(expiresAt).inDays;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.timer_off_rounded, color: Colors.amber.shade800, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Password expired $daysExpired day${daysExpired == 1 ? '' : 's'} ago',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToBreachTimeline(VaultItemEntity item) async {
    // Extract domain from the item's URL for matching against breach catalog.
    String itemDomain = '';
    if (item.url != null && item.url!.isNotEmpty) {
      try {
        final uri = Uri.parse(item.url!);
        itemDomain = (uri.host.isNotEmpty ? uri.host : item.url!)
            .toLowerCase()
            .replaceFirst(RegExp(r'^www\.'), '');
      } catch (_) {
        itemDomain = item.url!.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
      }
    }

    // Fetch breach catalog records matching the item's domain.
    List<BreachRecord> matchingBreaches = const [];
    if (itemDomain.isNotEmpty) {
      final catalogAsync = ref.read(breachCatalogProvider);
      final catalog = catalogAsync.whenData((v) => v).value ?? const [];
      matchingBreaches = catalog.where((breach) {
        final breachDomain =
            breach.domain.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
        return breachDomain.isNotEmpty &&
            (itemDomain.contains(breachDomain) ||
                breachDomain.contains(itemDomain));
      }).toList();
    }

    // Fetch password history dates for this item.
    final historyAsync = ref.read(passwordHistoryProvider(item.id));
    final history = historyAsync.whenData((v) => v).value ?? const [];
    final passwordChangeDates =
        history.map((entry) => entry.changedAt).toList();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BreachTimelinePage(
          item: item,
          breaches: matchingBreaches,
          passwordChangeDates: passwordChangeDates,
        ),
      ),
    );
  }

  String _itemTypeLabel(VaultItemType type) {
    switch (type) {
      case VaultItemType.password:
        return 'Password';
      case VaultItemType.secureNote:
        return 'Secure Note';
      case VaultItemType.contactInfo:
        return 'Contact Info';
      case VaultItemType.bankAccount:
        return 'Bank Account';
      case VaultItemType.paymentCard:
        return 'Payment Card';
      case VaultItemType.wifiPassword:
        return 'WiFi Password';
      case VaultItemType.softwareLicense:
        return 'Software License';
      case VaultItemType.sshKey:
        return 'SSH Key';
      case VaultItemType.driversLicense:
        return 'Drivers License';
      case VaultItemType.passport:
        return 'Passport';
      case VaultItemType.socialSecurityNumber:
        return 'Social Security Number';
      case VaultItemType.healthInsurance:
        return 'Health Insurance';
      case VaultItemType.insurancePolicy:
        return 'Insurance Policy';
      case VaultItemType.membershipCard:
        return 'Membership Card';
      case VaultItemType.emailAccount:
        return 'Email Account';
      case VaultItemType.instantMessenger:
        return 'Instant Messenger';
      case VaultItemType.database:
        return 'Database';
      case VaultItemType.server:
        return 'Server';
    }
  }
}

/// Breach warning banner that checks the item's password against HIBP.
///
/// Shows a red warning container if the password is found in data breaches.
/// Uses cached results from BreachRepository so repeat views are instant.
class _BreachWarningBanner extends ConsumerWidget {
  const _BreachWarningBanner({required this.item});

  final VaultItemEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.password == null || item.password!.isEmpty) {
      return const SizedBox.shrink();
    }

    final resultAsync = ref.watch(breachCheckProvider(item.password!));

    return resultAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (result) {
        if (result is! BreachResultBreached) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE53935).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFE53935),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This password was found in ${result.count} data breach${result.count == 1 ? '' : 'es'}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Change this password immediately',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VaultItemEditPage(existingItem: item),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// TOTP section that displays TOTP codes and an "Add TOTP" button.
///
/// Per D-14: shows TOTP display widgets for each entry linked to the item.
class _TotpSection extends ConsumerWidget {
  const _TotpSection({required this.vaultItemId});

  final String vaultItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(totpEntriesProvider(vaultItemId));

    return entriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_rounded,
                      color: Color(0xFF4D4DCD), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Two-Factor Authentication',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (entries.isNotEmpty) ...[
                for (final entry in entries) TotpDisplay(entry: entry),
              ] else
                Text(
                  'No TOTP configured',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        TotpAddDialog(vaultItemId: vaultItemId),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add TOTP'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4D4DCD),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Reusable section card with title and children.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// A label-value row for detail display.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.trailing,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: (theme.textTheme.bodyMedium ?? const TextStyle())
                      .merge(valueStyle),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
