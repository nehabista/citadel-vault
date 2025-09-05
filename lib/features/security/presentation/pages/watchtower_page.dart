import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                // Health score ring centered
                Center(
                  child: HealthScoreRing(
                    score: healthScore.score,
                    color: healthScore.color,
                  ),
                ),
                const SizedBox(height: 8),

                // Score description
                Text(
                  _scoreDescription(healthScore.score),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Section header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Security Issues',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category cards
                ...healthScore.categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CategoryCard(
                      category: category,
                      onItemTap: (itemId) {
                        // Navigate to vault item detail
                        // TODO: Wire to GoRouter navigation when vault detail page is available
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _scoreDescription(int score) {
    if (score >= 80) return 'Your vault is in great shape!';
    if (score >= 50) return 'Some passwords need attention.';
    return 'Critical security issues detected.';
  }
}

/// Skeleton loading state for the Watchtower page.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerColor = theme.colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Ring placeholder
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: shimmerColor,
            ),
          ),
          const SizedBox(height: 32),

          // Card placeholders
          for (var i = 0; i < 4; i++) ...[
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 8),
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
