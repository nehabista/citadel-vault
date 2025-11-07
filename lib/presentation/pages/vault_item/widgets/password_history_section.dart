import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../widgets/citadel_snackbar.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../../features/vault/domain/entities/password_history_entry.dart';

/// Per-item password history provider with Riverpod caching.
/// Replaces FutureBuilder anti-pattern in PasswordHistorySection.
final passwordHistoryProvider =
    FutureProvider.family<List<PasswordHistoryEntry>, String>((ref, itemId) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) return [];
  final vaultKey = SecretKey(session.vaultKey);
  final repo = ref.read(vaultRepositoryProvider);
  return repo.getPasswordHistory(itemId, vaultKey);
});

/// Displays the password history for a vault item.
///
/// Loads history via VaultRepository.getPasswordHistory and
/// renders each entry with a masked password (tap to reveal),
/// timestamp, and copy button. Per design spec D-14.
class PasswordHistorySection extends ConsumerWidget {
  const PasswordHistorySection({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    if (session is! Unlocked) {
      return const SizedBox.shrink();
    }

    final historyAsync = ref.watch(passwordHistoryProvider(itemId));

    return historyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No password changes recorded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            ...entries.map((entry) => _HistoryEntryTile(entry: entry)),
          ],
        );
      },
    );
  }
}

class _HistoryEntryTile extends StatefulWidget {
  const _HistoryEntryTile({required this.entry});

  final PasswordHistoryEntry entry;

  @override
  State<_HistoryEntryTile> createState() => _HistoryEntryTileState();
}

class _HistoryEntryTileState extends State<_HistoryEntryTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, yyyy HH:mm').format(widget.entry.changedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _revealed
                        ? widget.entry.password
                        : '\u2022' * 12,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: _revealed ? 0.5 : 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Changed: $dateStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => _revealed = !_revealed);
              },
              icon: Icon(
                _revealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: const Color(0xFF4D4DCD),
              ),
              tooltip: _revealed ? 'Hide' : 'Reveal',
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: widget.entry.password),
                );
                showCitadelSnackBar(context, 'Password copied',
                    type: SnackBarType.success);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              tooltip: 'Copy',
            ),
          ],
        ),
      ),
    );
  }
}
