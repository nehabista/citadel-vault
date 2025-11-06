import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../domain/entities/breach_result.dart';

/// Standalone Password Check page accessible from Watchtower Quick Actions.
///
/// Checks a password against HIBP Pwned Passwords using k-anonymity
/// (only the first 5 chars of the SHA-1 hash are transmitted).
class PasswordCheckPage extends ConsumerStatefulWidget {
  const PasswordCheckPage({super.key});

  @override
  ConsumerState<PasswordCheckPage> createState() => _PasswordCheckPageState();
}

class _PasswordCheckPageState extends ConsumerState<PasswordCheckPage>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF4D4DCD);
  static const _error = Color(0xFFE53935);
  static const _success = Color(0xFF43A047);
  static const _radius = 14.0;

  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _hasChecked = false;
  BreachResult? _result;
  String? _errorMessage;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      showCitadelSnackBar(
        context,
        'Please enter a password to check.',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _loading = true;
      _hasChecked = false;
      _errorMessage = null;
      _result = null;
    });

    _pulseController.repeat();

    try {
      final breachRepo = ref.read(breachRepositoryProvider);
      final result = await breachRepo.checkPasswordCached(password);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasChecked = true;
        _result = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasChecked = true;
        _errorMessage = e.toString();
      });
    } finally {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Password Check',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            _buildHeaderCard(theme, cs),
            const SizedBox(height: 20),

            // Privacy notice
            _buildPrivacyNotice(theme, cs),
            const SizedBox(height: 20),

            // Input section
            _buildInputSection(theme, cs),
            const SizedBox(height: 20),

            // Loading state
            if (_loading) _buildScanningIndicator(theme),

            // Results
            if (!_loading && _hasChecked) ...[
              if (_errorMessage != null)
                _buildResultBox(
                  icon: Icons.error_outline_rounded,
                  text: _errorMessage!,
                  bgColor: _error.withValues(alpha: 0.08),
                  borderColor: _error.withValues(alpha: 0.25),
                  fgColor: _error,
                )
              else if (_result is BreachResultBreached) ...[
                _buildResultBox(
                  icon: Icons.warning_amber_rounded,
                  text:
                      'Oh no -- this password has been seen ${_fmtCount((_result as BreachResultBreached).count)} times in data breaches!',
                  bgColor: _error.withValues(alpha: 0.08),
                  borderColor: _error.withValues(alpha: 0.25),
                  fgColor: _error,
                ),
                const SizedBox(height: 16),
                _buildRecommendations(theme, cs),
              ] else if (_result is BreachResultClean)
                _buildResultBox(
                  icon: Icons.verified_rounded,
                  text:
                      'Good news! This password was not found in any known data breaches.',
                  bgColor: _success.withValues(alpha: 0.08),
                  borderColor: _success.withValues(alpha: 0.25),
                  fgColor: _success,
                ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
        color: _primary.withValues(alpha: 0.04),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.lock_rounded, color: _primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pwned Passwords',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Check if a password has appeared in any known data breaches.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        color: _primary.withValues(alpha: 0.06),
        border: Border.all(
          color: _primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: _primary.withValues(alpha: 0.8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your password is never sent over the network. We use k-anonymity: '
              'only the first 5 characters of its SHA-1 hash are transmitted.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Poppins',
                color: _primary.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          style: const TextStyle(fontFamily: 'Poppins'),
          onSubmitted: (_) => _checkPassword(),
          decoration: InputDecoration(
            hintText: 'Type or paste password...',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              tooltip: _obscure ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: const BorderSide(color: _primary, width: 2),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _loading ? null : _checkPassword,
            icon: const Icon(Icons.search_rounded, size: 20),
            label: Text(
              _loading ? 'Checking...' : 'Check',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.12),
                child: Opacity(
                  opacity: 1.0 - (_pulseController.value * 0.3),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withValues(alpha: 0.10),
                      border: Border.all(
                        color: _primary.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.wifi_tethering_rounded,
                      color: _primary,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Scanning breach databases...',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              color: _primary,
              backgroundColor: Color(0x1A4D4DCD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color borderColor,
    required Color fgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fgColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: fgColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(ThemeData theme, ColorScheme cs) {
    const recommendations = [
      'Change this password immediately on all accounts where it is used.',
      'Use a unique, randomly generated password for each account.',
      'Enable two-factor authentication (2FA) wherever possible.',
      'Use Citadel\'s password generator for strong, random passwords.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                color: Colors.amber.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommendations',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Poppins',
                        color: cs.onSurface.withValues(alpha: 0.8),
                        height: 1.4,
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

String _fmtCount(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    b.write(s[i]);
    if (pos > 1 && pos % 3 == 1) b.write(',');
  }
  return b.toString();
}
