import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../domain/entities/watchtower_category.dart';
import '../providers/breach_provider.dart';
import '../providers/watchtower_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/health_score_ring.dart';

/// Main Watchtower dashboard page (D-01).
///
/// Displays:
/// - Animated health score ring (0-100) centered at top
/// - Four category cards (weak, reused, old, breached) with expandable item lists
/// - Pull-to-refresh to recompute the score
/// - Loading/empty states
class WatchtowerPage extends ConsumerWidget {
  const WatchtowerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger background breach check on Watchtower load
    ref.watch(backgroundBreachCheckProvider);

    final scoreAsync = ref.watch(watchtowerProvider);
    final theme = Theme.of(context);

    return scoreAsync.when(
      loading: () => const _LoadingSkeleton(),
      error: (error, stack) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.read(watchtowerProvider.notifier).refresh(),
      ),
      data: (healthScore) {
        if (healthScore.totalItemCount == 0 && healthScore.score == 100) {
          return _EmptyState(
            onRefresh: () => ref.read(watchtowerProvider.notifier).refresh(),
          );
        }

        // Derive score label + color
        final scoreLabel = _scoreLabel(healthScore.score);
        final scoreLabelColor = _scoreLabelColor(healthScore.score);

        return RefreshIndicator(
          onRefresh: () => ref.read(watchtowerProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // ── 1. Quick Actions (pill row) ──────────────
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ActionPill(
                        icon: Icons.email_outlined,
                        label: 'Check Email',
                        onTap: () => context.push(AppRoutes.emailCheck),
                      ),
                      const SizedBox(width: 10),
                      _ActionPill(
                        icon: Icons.password_rounded,
                        label: 'Check Password',
                        onTap: () => context.push(AppRoutes.passwordCheck),
                      ),
                      const SizedBox(width: 10),
                      _ActionPill(
                        icon: Icons.shield_outlined,
                        label: 'Explore Breaches',
                        onTap: () => context.push(AppRoutes.breachCatalog),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── 1b. Dark Web Monitoring (feature card) ──
                _DarkWebMonitoringCard(
                  passwordsChecked: healthScore.totalItemCount,
                  breachedCount: healthScore.breachedItems.length,
                  onCheckEmail: () => context.push(AppRoutes.emailCheck),
                  onFullReport: () => context.push(AppRoutes.breachCatalog),
                ),
                const SizedBox(height: 16),

                // ── 1c. Monitoring Summary ──────────────────
                _MonitoringSummaryCard(
                  passwordsChecked: healthScore.totalItemCount,
                  breachedCount: healthScore.breachedItems.length,
                  hasRunBreachCheck: healthScore.breachedItems.isNotEmpty ||
                      healthScore.totalItemCount > 0,
                ),
                const SizedBox(height: 24),

                // ── 2. Health Score Ring (premium card) ──────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x0D4D4DCD), // 5% primary
                        Colors.white,
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D4DCD).withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      HealthScoreRing(
                        score: healthScore.score,
                        color: healthScore.color,
                        size: 170,
                        strokeWidth: 13,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scoreLabelColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          scoreLabel,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scoreLabelColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── 3. Vault Analysis (category cards) ───────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vault Analysis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Category cards
                ...healthScore.categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CategoryCard(
                      category: category,
                      onItemTap: (itemId) {
                        if (category.type ==
                            WatchtowerCategoryType.breached) {
                          final item = category.items.firstWhere(
                            (i) => i.id == itemId,
                          );
                          _showBreachInfoSheet(context, ref, item);
                        } else {
                          context.push('/vault-item/$itemId');
                        }
                      },
                    ),
                  ),
                ),

                // ── 4. Bottom padding ────────────────────────
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Color-coded label text for the score badge.
  String _scoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 25) return 'Needs Attention';
    return 'Critical';
  }

  /// Color for the score label badge.
  Color _scoreLabelColor(int score) {
    if (score >= 80) return const Color(0xFF43A047); // success green
    if (score >= 50) return const Color(0xFFFFA726); // warning amber
    return const Color(0xFFE53935); // danger red
  }
}

// ---------------------------------------------------------------------------
// Action Pill (iOS-style horizontal chip)
// ---------------------------------------------------------------------------

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const _primary = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _primary.withValues(alpha: 0.08),
            border: Border.all(
              color: _primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: _primary),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dark Web Monitoring Card
// ---------------------------------------------------------------------------

class _DarkWebMonitoringCard extends StatelessWidget {
  const _DarkWebMonitoringCard({
    required this.passwordsChecked,
    required this.breachedCount,
    required this.onCheckEmail,
    required this.onFullReport,
  });

  final int passwordsChecked;
  final int breachedCount;
  final VoidCallback onCheckEmail;
  final VoidCallback onFullReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF2D2D5E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D4DCD).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Title row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.policy_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dark Web Monitoring',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monitor your credentials on the dark web',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'We scan breach databases and dark web marketplaces for your '
              'compromised credentials using the Have I Been Pwned service.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),

            // Stats row
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Passwords checked
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$passwordsChecked',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'checked',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  // Breached
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$breachedCount',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: breachedCount > 0
                                ? const Color(0xFFFF6B6B)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'breached',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  // Last scan
                  Expanded(
                    child: Column(
                      children: const [
                        Text(
                          'Just now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'last scan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0x8CFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action buttons
            Row(
              children: [
                // Check Email — filled white button
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: FilledButton(
                      onPressed: onCheckEmail,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Check Email'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Full Report — outlined white button
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: onFullReport,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Full Report'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monitoring Summary Card
// ---------------------------------------------------------------------------

class _MonitoringSummaryCard extends StatelessWidget {
  const _MonitoringSummaryCard({
    required this.passwordsChecked,
    required this.breachedCount,
    required this.hasRunBreachCheck,
  });

  final int passwordsChecked;
  final int breachedCount;
  final bool hasRunBreachCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.18),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Text(
              'Monitoring Summary',
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Email Monitoring
          _MonitoringRow(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF4D4DCD),
            label: 'Email Monitoring',
            trailing: _StatusBadge(
              label: hasRunBreachCheck ? 'Active' : 'Inactive',
              isActive: hasRunBreachCheck,
            ),
          ),
          Divider(
            height: 1,
            indent: 54,
            endIndent: 18,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),

          // Password Monitoring
          _MonitoringRow(
            icon: Icons.password_rounded,
            iconColor: const Color(0xFF43A047),
            label: 'Password Monitoring',
            trailing: Text(
              '$passwordsChecked checked',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF43A047),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 54,
            endIndent: 18,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),

          // Breach Alerts
          _MonitoringRow(
            icon: Icons.notifications_outlined,
            iconColor: breachedCount > 0
                ? const Color(0xFFE53935)
                : const Color(0xFFFFA726),
            label: 'Breach Alerts',
            trailing: breachedCount > 0
                ? Text(
                    '$breachedCount found',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE53935),
                    ),
                  )
                : const Text(
                    'All clear',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF43A047),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monitoring Row (used inside _MonitoringSummaryCard)
// ---------------------------------------------------------------------------

class _MonitoringRow extends StatelessWidget {
  const _MonitoringRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status Badge (Active / Inactive)
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? const Color(0xFF43A047) : const Color(0xFF9E9E9E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading state for the Watchtower page.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final shimmerColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Pills placeholder row
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Container(
                  width: 110,
                  height: 36,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                if (i < 2) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Score card placeholder
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 28),

          // Section header placeholder
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 130,
              height: 18,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Category card placeholders
          for (var i = 0; i < 4; i++) ...[
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Empty state when the vault has no password items.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No passwords to analyze',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some vault items to see your\nsecurity health score.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error state with retry button.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to compute health score',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Breach Info Bottom Sheet
// ---------------------------------------------------------------------------

void _showBreachInfoSheet(
  BuildContext context,
  WidgetRef ref,
  VaultItemEntity item,
) {
  const primary = Color(0xFF4D4DCD);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Warning icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),

              // Item name
              Text(
                item.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Warning message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This password was found in a data breach. '
                        'Change it immediately to protect your account.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent.shade700,
                          fontFamily: 'Poppins',
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Change Password button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/vault-item/${item.id}/edit');
                  },
                  icon: const Icon(Icons.lock_reset_rounded, size: 20),
                  label: const Text(
                    'Change Password',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // View Details button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/vault-item/${item.id}');
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  label: const Text(
                    'View Details',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Explore Breaches button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push(AppRoutes.breachCatalog);
                  },
                  icon: const Icon(Icons.shield_rounded, size: 20),
                  label: const Text(
                    'Explore Breaches',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Note: Check Email and Check Password dialogs have been replaced by
// standalone pages: EmailCheckPage and PasswordCheckPage.

