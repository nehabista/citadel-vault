import '../../../../presentation/widgets/citadel_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/totp_entry_entity.dart';
import '../providers/totp_provider.dart';

/// Displays a TOTP code with a circular countdown ring.
///
/// Per D-11: monospace code, 30s countdown ring, tap to copy.
/// Ring color transitions from green to red when < 5 seconds remain.
class TotpDisplay extends ConsumerWidget {
  const TotpDisplay({super.key, required this.entry});

  final TotpEntryEntity entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = TotpDisplayParams(
      entryId: entry.id,
      base32Secret: entry.secret,
      digits: entry.digits,
      period: entry.period,
      algorithm: entry.algorithm,
    );

    final asyncState = ref.watch(totpDisplayProvider(params));

    return asyncState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (displayState) => _buildDisplay(context, displayState),
    );
  }

  Widget _buildDisplay(BuildContext context, TotpDisplayState displayState) {
    final progress = displayState.totalPeriod > 0
        ? displayState.remainingSeconds / displayState.totalPeriod
        : 0.0;

    final isUrgent = displayState.remainingSeconds <= 5;
    final ringColor = isUrgent ? Colors.red : Colors.green;

    // Format code with a space in the middle for readability (e.g., "123 456").
    final code = displayState.code;
    final formattedCode = code.length > 3
        ? '${code.substring(0, code.length ~/ 2)} ${code.substring(code.length ~/ 2)}'
        : code;

    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        showCitadelSnackBar(context, 'TOTP code copied',
            type: SnackBarType.success);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Circular countdown ring
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: ringColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  ),
                  Text(
                    '${displayState.remainingSeconds}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ringColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Code display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  if (entry.algorithm != 'SHA1' || entry.digits != 6)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${entry.digits}-digit / ${entry.algorithm}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Copy icon hint
            Icon(
              Icons.copy_rounded,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
