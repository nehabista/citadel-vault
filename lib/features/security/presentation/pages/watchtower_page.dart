import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
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
                        if (category.type ==
                            WatchtowerCategoryType.breached) {
                          // Find the item for the breach info sheet
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

                // Quick actions
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.shield_rounded,
                        label: 'Explore Breaches',
                        subtitle: 'Browse known data breaches',
                        onTap: () =>
                            context.push(AppRoutes.breachCatalog),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.email_rounded,
                        label: 'Check Email',
                        subtitle: 'See if your email was leaked',
                        onTap: () =>
                            _showCheckEmailDialog(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
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

// ---------------------------------------------------------------------------
// Quick Action Card
// ---------------------------------------------------------------------------

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  static const _primary = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'Poppins',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

// ---------------------------------------------------------------------------
// Check Email Dialog
// ---------------------------------------------------------------------------

void _showCheckEmailDialog(BuildContext context, WidgetRef ref) {
  final emailController = TextEditingController();
  const primary = Color(0xFF4D4DCD);

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.email_rounded, color: primary, size: 24),
            SizedBox(width: 10),
            Text(
              'Check Email',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter an email address to check if it has appeared '
              'in any known data breaches.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: const TextStyle(fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.alternate_email, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: primary, width: 2),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                showCitadelSnackBar(
                  context,
                  'Please enter a valid email address.',
                  type: SnackBarType.error,
                );
                return;
              }

              Navigator.of(dialogContext).pop();

              showCitadelSnackBar(
                context,
                'Checking breaches for $email...',
                type: SnackBarType.info,
              );

              try {
                final breachService = ref.read(breachServiceProvider);
                final breaches = await breachService.breachedAccount(email);

                if (!context.mounted) return;

                if (breaches.isEmpty) {
                  showCitadelSnackBar(
                    context,
                    'Good news! $email was not found in any breaches.',
                    type: SnackBarType.success,
                  );
                } else {
                  showCitadelSnackBar(
                    context,
                    '$email found in ${breaches.length} breach${breaches.length == 1 ? '' : 'es'}.',
                    type: SnackBarType.error,
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                showCitadelSnackBar(
                  context,
                  e.toString(),
                  type: SnackBarType.error,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Check',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      );
    },
  );
}
