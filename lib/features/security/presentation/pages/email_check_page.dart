import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/models/breach_record.dart';

/// Standalone Email Check page accessible from Watchtower Quick Actions.
///
/// Queries HIBP breached-account API for the entered email and displays
/// breach results as premium styled cards with data-class chips.
class EmailCheckPage extends ConsumerStatefulWidget {
  const EmailCheckPage({super.key});

  @override
  ConsumerState<EmailCheckPage> createState() => _EmailCheckPageState();
}

class _EmailCheckPageState extends ConsumerState<EmailCheckPage>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF4D4DCD);
  static const _error = Color(0xFFE53935);
  static const _success = Color(0xFF43A047);
  static const _radius = 14.0;

  final _emailController = TextEditingController();
  bool _loading = false;
  bool _hasChecked = false;
  List<BreachRecord> _breaches = [];
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
    _emailController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showCitadelSnackBar(
        context,
        'Please enter a valid email address.',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _loading = true;
      _hasChecked = false;
      _errorMessage = null;
      _breaches = [];
    });

    _pulseController.repeat();

    try {
      final breachService = ref.read(breachServiceProvider);
      final breaches = await breachService.breachedAccount(email);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasChecked = true;
        _breaches = breaches;
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
          'Email Check',
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
              else if (_breaches.isEmpty)
                _buildResultBox(
                  icon: Icons.verified_rounded,
                  text:
                      'No breaches found for this email. Your email appears clean!',
                  bgColor: _success.withValues(alpha: 0.08),
                  borderColor: _success.withValues(alpha: 0.25),
                  fgColor: _success,
                )
              else ...[
                _buildResultBox(
                  icon: Icons.warning_amber_rounded,
                  text:
                      'Found ${_breaches.length} breach${_breaches.length == 1 ? '' : 'es'} linked to this email.',
                  bgColor: _error.withValues(alpha: 0.08),
                  borderColor: _error.withValues(alpha: 0.25),
                  fgColor: _error,
                ),
                const SizedBox(height: 16),
                ..._breaches.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BreachCard(breach: b),
                    )),
              ],
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
            child: const Icon(Icons.email_rounded, color: _primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have I Been Pwned?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Check if your email appears in known data breaches via HIBP.',
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

  Widget _buildInputSection(ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontFamily: 'Poppins'),
          onSubmitted: (_) => _checkEmail(),
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(Icons.alternate_email, size: 20),
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
            onPressed: _loading ? null : _checkEmail,
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
}

// ---------------------------------------------------------------------------
// Breach Card
// ---------------------------------------------------------------------------

class _BreachCard extends StatelessWidget {
  const _BreachCard({required this.breach});

  final BreachRecord breach;

  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateStr = breach.breachDate.toIso8601String().split('T').first;

    final subtitle = [
      if (breach.domain.isNotEmpty) breach.domain else breach.name,
      dateStr,
      if (breach.pwnCount != null) '${_fmtCount(breach.pwnCount!)} affected',
    ].join('  \u2022  ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: logo + title + verified
          Row(
            children: [
              _Logo(url: breach.logoUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  breach.displayTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _VerifiedPill(verified: breach.verified),
            ],
          ),
          const SizedBox(height: 6),

          // Subtitle: domain, date, count
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Poppins',
              color: cs.onSurfaceVariant,
            ),
          ),

          // Description
          if (breach.descriptionPlain.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              breach.descriptionPlain,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Poppins',
                color: cs.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],

          // Data classes
          if (breach.dataClasses.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: breach.dataClasses
                  .map((d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                          color: cs.surfaceContainerHighest
                              .withValues(alpha: 0.15),
                        ),
                        child: Text(
                          d,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(10);

    if (url == null || url!.isEmpty) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: const Icon(Icons.shield_rounded, size: 18),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Image.network(
          url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.shield_rounded, size: 18),
        ),
      ),
    );
  }
}

class _VerifiedPill extends StatelessWidget {
  const _VerifiedPill({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final color = verified ? const Color(0xFF43A047) : Colors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.help_outline_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            verified ? 'Verified' : 'Unverified',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: color,
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
