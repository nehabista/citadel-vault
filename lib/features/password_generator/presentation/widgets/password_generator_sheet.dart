import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../providers/generator_provider.dart';
import '../providers/strength_provider.dart';
import 'entropy_gauge.dart';

/// Bottom sheet widget for generating passwords with configurable options.
///
/// Shows a generated password, live strength meter (EntropyGauge),
/// crack time, configuration toggles, and a "Use Password" button.
/// Per design specs D-05, D-06, D-07.
class PasswordGeneratorSheet extends ConsumerWidget {
  const PasswordGeneratorSheet({super.key, this.onPasswordSelected});

  /// Called when the user taps "Use Password" with the generated password.
  final ValueChanged<String>? onPasswordSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genState = ref.watch(passwordGeneratorProvider);
    final genNotifier = ref.read(passwordGeneratorProvider.notifier);
    final crackTime = ref.watch(crackTimeShortProvider);
    final theme = Theme.of(context);

    // Auto-generate on first build if empty.
    if (genState.generatedPassword.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        genNotifier.generate();
      });
    }

    // Sync generated password with strength analyzer.
    if (genState.generatedPassword.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(currentPasswordProvider.notifier)
            .set(genState.generatedPassword);
      });
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Text(
              'Password Generator',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Generated password display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      genState.generatedPassword.isEmpty
                          ? '...'
                          : genState.generatedPassword,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (genState.generatedPassword.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(text: genState.generatedPassword),
                        );
                        showCitadelSnackBar(context, 'Password copied',
                            type: SnackBarType.success);
                      }
                    },
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    tooltip: 'Copy',
                  ),
                  IconButton(
                    onPressed: () => genNotifier.generate(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Regenerate',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Entropy gauge
            const EntropyGauge(),
            const SizedBox(height: 8),

            // Crack time
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  'Crack time: $crackTime',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Length slider
            Row(
              children: [
                Text(
                  'Length: ${genState.config.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: genState.config.length.toDouble(),
                    min: 8,
                    max: 64,
                    divisions: 56,
                    activeColor: const Color(0xFF4D4DCD),
                    onChanged: (value) => genNotifier.setLength(value.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Toggle chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ToggleChip(
                  label: 'A-Z',
                  selected: genState.config.upper,
                  onTap: genNotifier.toggleUpper,
                ),
                _ToggleChip(
                  label: 'a-z',
                  selected: genState.config.lower,
                  onTap: genNotifier.toggleLower,
                ),
                _ToggleChip(
                  label: '0-9',
                  selected: genState.config.digits,
                  onTap: genNotifier.toggleDigits,
                ),
                _ToggleChip(
                  label: '!@#',
                  selected: genState.config.symbols,
                  onTap: genNotifier.toggleSymbols,
                ),
                _ToggleChip(
                  label: 'Passphrase',
                  selected: genState.config.pronounceable,
                  onTap: genNotifier.togglePronounceable,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Use Password button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: genState.generatedPassword.isEmpty
                    ? null
                    : () {
                        onPasswordSelected?.call(genState.generatedPassword);
                        Navigator.of(context).pop();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4D4DCD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Use Password',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF4D4DCD).withValues(alpha: 0.15),
      checkmarkColor: const Color(0xFF4D4DCD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
