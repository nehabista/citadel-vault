import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/generator_provider.dart';
import '../providers/strength_provider.dart';
import '../widgets/entropy_gauge.dart';

/// Standalone password generator page for the Locksmith tab.
class GeneratorPage extends ConsumerStatefulWidget {
  const GeneratorPage({super.key});

  @override
  ConsumerState<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends ConsumerState<GeneratorPage> {
  @override
  void initState() {
    super.initState();
    // Generate initial password on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final genState = ref.read(passwordGeneratorProvider);
      if (genState.generatedPassword.isEmpty) {
        ref.read(passwordGeneratorProvider.notifier).generate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(passwordGeneratorProvider);
    final password = genState.generatedPassword;
    final config = genState.config;

    // Sync generated password into strength provider
    ref.listen(passwordGeneratorProvider, (prev, next) {
      if (next.generatedPassword.isNotEmpty &&
          next.generatedPassword != (prev?.generatedPassword ?? '')) {
        ref.read(currentPasswordProvider.notifier).set(
            next.generatedPassword);
      }
    });

    final bits = ref.watch(entropyBitsProvider);
    final strength = ref.watch(strengthProvider);
    final crackTime = ref.watch(crackTimeShortProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Generated password display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SelectableText(
                password.isEmpty ? 'Tap Generate' : password,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: password.isEmpty
                        ? null
                        : () {
                            Clipboard.setData(ClipboardData(text: password));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'Generate',
                    onTap: () => ref
                        .read(passwordGeneratorProvider.notifier)
                        .generate(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Strength display
        if (password.isNotEmpty) ...[
          Center(
            child: SizedBox(
              width: 130,
              height: 130,
              child: EntropyGauge(overrideEntropy: bits),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Text(
                  strength.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _strengthColor(strength.name),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crack time: $crackTime',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Configuration section
        const Text(
          'Configuration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Length slider
        Row(
          children: [
            const Text('Length', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Slider(
                value: config.length.toDouble(),
                min: 8,
                max: 64,
                divisions: 56,
                label: '${config.length}',
                activeColor: const Color(0xFF4D4DCD),
                onChanged: (v) => ref
                    .read(passwordGeneratorProvider.notifier)
                    .setLength(v.toInt()),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${config.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        // Character toggles
        SwitchListTile(
          title: const Text('Uppercase (A-Z)'),
          value: config.upper,
          activeThumbColor: const Color(0xFF4D4DCD),
          onChanged: (_) =>
              ref.read(passwordGeneratorProvider.notifier).toggleUpper(),
        ),
        SwitchListTile(
          title: const Text('Lowercase (a-z)'),
          value: config.lower,
          activeThumbColor: const Color(0xFF4D4DCD),
          onChanged: (_) =>
              ref.read(passwordGeneratorProvider.notifier).toggleLower(),
        ),
        SwitchListTile(
          title: const Text('Digits (0-9)'),
          value: config.digits,
          activeThumbColor: const Color(0xFF4D4DCD),
          onChanged: (_) =>
              ref.read(passwordGeneratorProvider.notifier).toggleDigits(),
        ),
        SwitchListTile(
          title: const Text('Symbols (!@#\$)'),
          value: config.symbols,
          activeThumbColor: const Color(0xFF4D4DCD),
          onChanged: (_) =>
              ref.read(passwordGeneratorProvider.notifier).toggleSymbols(),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Passphrase Mode'),
          subtitle: const Text('Generate memorable word-based passwords'),
          value: config.pronounceable,
          activeThumbColor: const Color(0xFF4D4DCD),
          onChanged: (_) => ref
              .read(passwordGeneratorProvider.notifier)
              .togglePronounceable(),
        ),
      ],
    );
  }

  Color _strengthColor(String label) {
    return switch (label.toLowerCase()) {
      'weak' => Colors.red,
      'fair' => Colors.orange,
      'moderate' => Colors.amber.shade700,
      'strong' => Colors.green,
      'very strong' => Colors.green.shade800,
      _ => Colors.grey,
    };
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF4D4DCD).withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4D4DCD)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF4D4DCD), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
