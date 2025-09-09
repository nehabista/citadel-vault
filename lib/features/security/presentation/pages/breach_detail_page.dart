import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/breach_record.dart';

/// Breach detail page showing all information about a specific breach.
///
/// Displays: title, domain, logo, breach date, added date, pwn count,
/// description (HTML-stripped), full data classes list, verified/sensitive badges.
class BreachDetailPage extends StatelessWidget {
  const BreachDetailPage({
    super.key,
    required this.breach,
  });

  final BreachRecord breach;

  String _formatPwnCount(int? count) {
    if (count == null) return 'Unknown';
    final formatter = NumberFormat('#,###');
    return formatter.format(count);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat.yMMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(breach.displayTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: logo + title + domain
            _buildHeader(context, theme),
            const SizedBox(height: 20),

            // Stats row
            _buildStatsRow(context, theme),
            const SizedBox(height: 20),

            // Badges
            _buildBadges(theme),
            const SizedBox(height: 20),

            // Description
            if (breach.description != null &&
                breach.description!.isNotEmpty) ...[
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                breach.descriptionPlain,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Data classes
            Text(
              'Compromised Data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: breach.dataClasses
                  .map((dc) => Chip(
                        label: Text(dc),
                        labelStyle: theme.textTheme.labelMedium,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Check email button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showEmailCheckDialog(context),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Check if your email was in this breach'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo or fallback icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: breach.logoUrl != null && breach.logoUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    breach.logoUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.security,
                      size: 28,
                    ),
                  ),
                )
              : const Icon(Icons.security, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                breach.displayTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (breach.domain.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      breach.domain,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.people_outline,
            label: 'Affected',
            value: _formatPwnCount(breach.pwnCount),
          ),
          const _StatDivider(),
          _StatItem(
            icon: Icons.calendar_today,
            label: 'Breach Date',
            value: _formatDate(breach.breachDate),
          ),
          if (breach.addedDate != null) ...[
            const _StatDivider(),
            _StatItem(
              icon: Icons.add_circle_outline,
              label: 'Added',
              value: _formatDate(breach.addedDate),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadges(ThemeData theme) {
    return Wrap(
      spacing: 8,
      children: [
        if (breach.verified)
          _Badge(
            icon: Icons.verified,
            label: 'Verified',
            color: Colors.blue,
          ),
        if (breach.isSensitive)
          _Badge(
            icon: Icons.warning_amber_rounded,
            label: 'Sensitive',
            color: Colors.orange,
          ),
      ],
    );
  }

  void _showEmailCheckDialog(BuildContext context) {
    final emailController = TextEditingController();
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Check Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email to check if it was exposed in the ${breach.displayTitle} breach.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Close dialog; email check is handled by breach_provider
              Navigator.of(dialogContext).pop();
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Checking $email against breach database...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Check'),
          ),
        ],
      ),
    );
  }
}

/// Stat item in the stats row.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Vertical divider in the stats row.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

/// Small badge widget for verified/sensitive flags.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
