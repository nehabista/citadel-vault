import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/password_strength.dart';
import '../providers/generator_provider.dart';
import '../providers/strength_provider.dart';
import '../widgets/entropy_gauge.dart';

/// Premium password generator page -- Citadel Locksmith.
///
/// Layout (top to bottom):
/// 1. Character-colored password display with copy/regenerate
/// 2. Entropy gauge ring with strength label and crack time
/// 3. Improvement tips (contextual)
/// 4. Password checks (visual checklist)
/// 5. Generator config (length slider + character type chips)
class GeneratorPage extends ConsumerStatefulWidget {
  const GeneratorPage({super.key});

  @override
  ConsumerState<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends ConsumerState<GeneratorPage> {
  static const _primary = Color(0xFF4D4DCD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(passwordGeneratorProvider);
      if (s.generatedPassword.isEmpty) {
        ref.read(passwordGeneratorProvider.notifier).generate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(passwordGeneratorProvider);
    final password = genState.generatedPassword;
    final config = genState.config;

    // Sync generated password to strength provider.
    ref.listen(passwordGeneratorProvider, (prev, next) {
      if (next.generatedPassword.isNotEmpty &&
          next.generatedPassword != (prev?.generatedPassword ?? '')) {
        ref.read(currentPasswordProvider.notifier).set(next.generatedPassword);
      }
    });

    final bits = ref.watch(entropyBitsProvider);
    final strength = ref.watch(strengthProvider);
    final checks = ref.watch(passwordChecksProvider);
    final tips = ref.watch(tipsProvider);
    final crackTimes = ref.watch(crackTimesProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContentWidth = constraints.maxWidth > 640 ? 600.0 : double.infinity;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 16 : 20,
            8,
            isCompact ? 16 : 20,
            100,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Password Display
                  _PasswordDisplay(
                    password: password,
                    onCopy: password.isEmpty ? null : () => _copyPassword(password),
                    onRegenerate: () =>
                        ref.read(passwordGeneratorProvider.notifier).generate(),
                  ),
                  const SizedBox(height: 24),

                  // 2. Strength Section (gauge + label)
                  _StrengthSection(bits: bits, strength: strength),
                  const SizedBox(height: 20),

                  // 3. Improvement Tips
                  if (password.isNotEmpty) ...[
                    _TipsPanel(tips: tips, strength: strength),
                    const SizedBox(height: 20),
                  ],

                  // 4. Password Checks
                  if (password.isNotEmpty) ...[
                    _PasswordChecklist(checks: checks),
                    const SizedBox(height: 20),
                  ],

                  // 5. Attack Scenarios (collapsible)
                  if (password.isNotEmpty && crackTimes.isNotEmpty) ...[
                    _AttackScenarios(scenarios: crackTimes),
                    const SizedBox(height: 20),
                  ],

                  // 6. Generator Config
                  _GeneratorConfig(
                    config: config,
                    isCompact: isCompact,
                    onLengthChanged: (v) =>
                        ref.read(passwordGeneratorProvider.notifier).setLength(v),
                    onToggleUpper: () =>
                        ref.read(passwordGeneratorProvider.notifier).toggleUpper(),
                    onToggleLower: () =>
                        ref.read(passwordGeneratorProvider.notifier).toggleLower(),
                    onToggleDigits: () =>
                        ref.read(passwordGeneratorProvider.notifier).toggleDigits(),
                    onToggleSymbols: () =>
                        ref.read(passwordGeneratorProvider.notifier).toggleSymbols(),
                    onTogglePassphrase: () => ref
                        .read(passwordGeneratorProvider.notifier)
                        .togglePronounceable(),
                    onGenerate: () =>
                        ref.read(passwordGeneratorProvider.notifier).generate(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _copyPassword(String password) {
    Clipboard.setData(ClipboardData(text: password));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: _primary,
      ),
    );
  }
}

// =============================================================================
// 1. Password Display — character-colored monospace text
// =============================================================================

class _PasswordDisplay extends StatelessWidget {
  final String password;
  final VoidCallback? onCopy;
  final VoidCallback onRegenerate;

  const _PasswordDisplay({
    required this.password,
    required this.onCopy,
    required this.onRegenerate,
  });

  static const _primary = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Password text with character coloring
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: password.isEmpty
                ? Text(
                    'Tap Generate',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 17,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                : _ColoredPasswordText(password: password),
          ),
          const SizedBox(height: 14),

          // Action row
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Generate',
                  onTap: onRegenerate,
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: onCopy,
                  filled: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Renders each character in the password with a color based on its type:
/// uppercase = blue, lowercase = white, digit = orange, symbol = red.
class _ColoredPasswordText extends StatelessWidget {
  final String password;
  const _ColoredPasswordText({required this.password});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: password.split('').map((c) {
          return TextSpan(
            text: c,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: _charColor(c),
            ),
          );
        }).toList(),
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  static Color _charColor(String c) {
    if (RegExp(r'[A-Z]').hasMatch(c)) return const Color(0xFF64B5F6); // blue
    if (RegExp(r'[a-z]').hasMatch(c)) return const Color(0xFFE0E0E0); // light
    if (RegExp(r'\d').hasMatch(c)) return const Color(0xFFFFB74D); // orange
    return const Color(0xFFEF5350); // red for symbols
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.filled,
  });

  static const _primary = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: filled
                ? _primary.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled
                  ? _primary
                  : Colors.white.withValues(alpha: isDisabled ? 0.08 : 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: Colors.white.withValues(alpha: isDisabled ? 0.3 : 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isDisabled ? 0.3 : 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 2. Strength Section — gauge ring + label + crack time
// =============================================================================

class _StrengthSection extends StatelessWidget {
  final double bits;
  final Strength strength;
  const _StrengthSection({required this.bits, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          EntropyGauge(size: 130),
          SizedBox(height: 12),
          StrengthLabel(),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. Improvement Tips
// =============================================================================

class _TipsPanel extends StatelessWidget {
  final List<String> tips;
  final Strength strength;
  const _TipsPanel({required this.tips, required this.strength});

  @override
  Widget build(BuildContext context) {
    final isOk = tips.length == 1 && tips.first.startsWith('Nice!');

    final bgColor = isOk
        ? const Color(0xFF43A047).withValues(alpha: 0.06)
        : const Color(0xFFFFA726).withValues(alpha: 0.06);
    final borderColor = isOk
        ? const Color(0xFF43A047).withValues(alpha: 0.2)
        : const Color(0xFFFFA726).withValues(alpha: 0.2);
    final iconColor = isOk ? const Color(0xFF43A047) : const Color(0xFFFFA726);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOk ? Icons.verified_rounded : Icons.lightbulb_outline_rounded,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isOk ? 'Looks good' : 'Improvement Tips',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      isOk ? Icons.check_rounded : Icons.arrow_right_rounded,
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 4. Password Checks — visual checklist
// =============================================================================

class _PasswordChecklist extends StatelessWidget {
  final PasswordChecks checks;
  const _PasswordChecklist({required this.checks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, size: 18, color: Color(0xFF4D4DCD)),
              SizedBox(width: 8),
              Text(
                'Password Checks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _CheckItem(passed: checks.longEnough, label: '12+ chars'),
              _CheckItem(passed: checks.hasUpper, label: 'Uppercase'),
              _CheckItem(passed: checks.hasLower, label: 'Lowercase'),
              _CheckItem(passed: checks.hasDigit, label: 'Digit'),
              _CheckItem(passed: checks.hasSpecial, label: 'Special'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final bool passed;
  final String label;
  const _CheckItem({required this.passed, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = passed ? const Color(0xFF43A047) : const Color(0xFFBDBDBD);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: passed
                ? const Color(0xFF1A1A2E)
                : const Color(0xFF1A1A2E).withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 5. Attack Scenarios (collapsible)
// =============================================================================

class _AttackScenarios extends StatelessWidget {
  final Map<String, String> scenarios;
  const _AttackScenarios({required this.scenarios});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          leading: const Icon(Icons.security_rounded, size: 18, color: Color(0xFF4D4DCD)),
          title: const Text(
            'Attack Scenarios',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          children: scenarios.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// =============================================================================
// 6. Generator Config
// =============================================================================

class _GeneratorConfig extends StatelessWidget {
  final dynamic config;
  final bool isCompact;
  final ValueChanged<int> onLengthChanged;
  final VoidCallback onToggleUpper;
  final VoidCallback onToggleLower;
  final VoidCallback onToggleDigits;
  final VoidCallback onToggleSymbols;
  final VoidCallback onTogglePassphrase;
  final VoidCallback onGenerate;

  const _GeneratorConfig({
    required this.config,
    required this.isCompact,
    required this.onLengthChanged,
    required this.onToggleUpper,
    required this.onToggleLower,
    required this.onToggleDigits,
    required this.onToggleSymbols,
    required this.onTogglePassphrase,
    required this.onGenerate,
  });

  static const _primary = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: _primary),
              SizedBox(width: 8),
              Text(
                'Generator Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Length slider
          Row(
            children: [
              const Text(
                'Length',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${config.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _primary,
              inactiveTrackColor: _primary.withValues(alpha: 0.12),
              thumbColor: _primary,
              overlayColor: _primary.withValues(alpha: 0.08),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              showValueIndicator: ShowValueIndicator.onDrag,
              valueIndicatorColor: _primary,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            child: Slider(
              value: config.length.toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              label: '${config.length}',
              onChanged: (v) => onLengthChanged(v.toInt()),
            ),
          ),
          const SizedBox(height: 12),

          // Character type chips
          const Text(
            'Characters',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CharChip(
                label: 'A-Z',
                active: config.upper as bool,
                onTap: onToggleUpper,
              ),
              _CharChip(
                label: 'a-z',
                active: config.lower as bool,
                onTap: onToggleLower,
              ),
              _CharChip(
                label: '0-9',
                active: config.digits as bool,
                onTap: onToggleDigits,
              ),
              _CharChip(
                label: '!@#\$',
                active: config.symbols as bool,
                onTap: onToggleSymbols,
              ),
              _CharChip(
                label: 'Passphrase',
                active: config.pronounceable as bool,
                onTap: onTogglePassphrase,
                icon: Icons.text_fields_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CharChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  const _CharChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  static const _primary = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? _primary : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: active ? Colors.white : _primary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
