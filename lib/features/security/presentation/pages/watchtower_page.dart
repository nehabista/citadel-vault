import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../domain/entities/watchtower_category.dart';
import '../providers/breach_provider.dart';
import '../providers/watchtower_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/dark_web_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/score_card.dart';

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

        return RefreshIndicator(
          onRefresh: () => ref.read(watchtowerProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // ── 1. Quick Actions (pill row) ──────────────
                QuickActionsRow(
                  onCheckEmail: () => context.push(AppRoutes.emailCheck),
                  onCheckPassword: () =>
                      context.push(AppRoutes.passwordCheck),
                  onExploreBreaches: () =>
                      context.push(AppRoutes.breachCatalog),
                ),
                const SizedBox(height: 24),

                // ── 1b. Dark Web Monitoring (feature card) ──
                DarkWebMonitoringCard(
                  healthScore: healthScore,
                  onCheckEmail: () => context.push(AppRoutes.emailCheck),
                  onFullReport: () =>
                      context.push(AppRoutes.breachCatalog),
                ),
                const SizedBox(height: 16),

                // ── 1c. Monitoring Summary ──────────────────
                MonitoringSummaryCard(healthScore: healthScore),
                const SizedBox(height: 24),

                // ── 2. Health Score Ring (premium card) ──────
                ScoreCard(
                  score: healthScore.score,
                  color: healthScore.color,
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
}

// ---------------------------------------------------------------------------
// Loading Skeleton
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------

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
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
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
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
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

// ---------------------------------------------------------------------------
// Error State
// ---------------------------------------------------------------------------

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
