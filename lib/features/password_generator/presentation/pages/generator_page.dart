import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/password_strength.dart';
import '../providers/generator_provider.dart';
import '../providers/strength_provider.dart';

/// Modern password generator — clean, minimal, premium feel.
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

    // Sync to strength provider
    ref.listen(passwordGeneratorProvider, (prev, next) {
      if (next.generatedPassword.isNotEmpty &&
          next.generatedPassword != (prev?.generatedPassword ?? '')) {
        ref.read(currentPasswordProvider.notifier).set(next.generatedPassword);
      }
    });

    final bits = ref.watch(entropyBitsProvider);
    final strength = ref.watch(strengthProvider);
    final crackTime = ref.watch(crackTimeShortProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Password Card ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, _primary.withAlpha(200)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Password display
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    password.isEmpty ? 'Tap Generate' : password,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Strength bar + label
                if (password.isNotEmpty) ...[
                  _StrengthBar(bits: bits, strength: strength),
                  const SizedBox(height: 8),
                  Text(
                    '${strength.name[0].toUpperCase()}${strength.name.substring(1)} · $crackTime',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(200),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _GlassButton(
                        icon: Icons.refresh_rounded,
                        label: 'Generate',
                        onTap: () => ref
                            .read(passwordGeneratorProvider.notifier)
                            .generate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassButton(
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        onTap: password.isEmpty
                            ? null
                            : () {
                                Clipboard.setData(
                                    ClipboardData(text: password));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Copied to clipboard'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Length Slider ──
          _SectionTitle('Length'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: _primary,
                    inactiveTrackColor: _primary.withAlpha(30),
                    thumbColor: _primary,
                    overlayColor: _primary.withAlpha(20),
                    trackHeight: 6,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: config.length.toDouble(),
                    min: 8,
                    max: 64,
                    divisions: 56,
                    onChanged: (v) => ref
                        .read(passwordGeneratorProvider.notifier)
                        .setLength(v.toInt()),
                  ),
                ),
              ),
              Container(
                width: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${config.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Character Options ──
          _SectionTitle('Characters'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OptionChip(
                label: 'A-Z',
                active: config.upper,
                onTap: () => ref
                    .read(passwordGeneratorProvider.notifier)
                    .toggleUpper(),
              ),
              _OptionChip(
                label: 'a-z',
                active: config.lower,
                onTap: () => ref
                    .read(passwordGeneratorProvider.notifier)
                    .toggleLower(),
              ),
              _OptionChip(
                label: '0-9',
                active: config.digits,
                onTap: () => ref
                    .read(passwordGeneratorProvider.notifier)
                    .toggleDigits(),
              ),
              _OptionChip(
                label: '!@#\$',
                active: config.symbols,
                onTap: () => ref
                    .read(passwordGeneratorProvider.notifier)
                    .toggleSymbols(),
              ),
              _OptionChip(
                label: 'Passphrase',
                active: config.pronounceable,
                onTap: () => ref
                    .read(passwordGeneratorProvider.notifier)
                    .togglePronounceable(),
                icon: Icons.text_fields_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Strength Bar ───
class _StrengthBar extends StatelessWidget {
  final double bits;
  final Strength strength;

  const _StrengthBar({required this.bits, required this.strength});

  @override
  Widget build(BuildContext context) {
    final fraction = (bits / 128).clamp(0.0, 1.0);
    final color = switch (strength) {
      Strength.weak => const Color(0xFFE53935),
      Strength.moderate => const Color(0xFFFFA726),
      Strength.strong => const Color(0xFF66BB6A),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: fraction,
          backgroundColor: Colors.white.withAlpha(30),
          color: color,
          minHeight: 6,
        ),
      ),
    );
  }
}

// ─── Glass Button ───
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _GlassButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withAlpha(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Title ───
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Option Chip ───
class _OptionChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  const _OptionChip({
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _primary : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _primary.withAlpha(30),
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
              Icon(icon, size: 16, color: active ? Colors.white : _primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
