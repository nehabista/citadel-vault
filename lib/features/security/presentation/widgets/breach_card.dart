import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/breach_record.dart';

/// Card widget displaying a breach record in the catalog list.
///
/// Shows: breach title, domain, breach date, pwnCount formatted,
/// verified badge, and data classes as chips (first 3 + "+N more").
class BreachCard extends StatelessWidget {
  const BreachCard({
    super.key,
    required this.breach,
    required this.onTap,
  });

  final BreachRecord breach;
  final VoidCallback onTap;

  String _formatPwnCount(int? count) {
    if (count == null) return 'Unknown';
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B accounts';
    }
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M accounts';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K accounts';
    }
    return '$count accounts';
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with verified badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      breach.displayTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (breach.verified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Domain and date row
              Row(
                children: [
                  if (breach.domain.isNotEmpty) ...[
                    Icon(
                      Icons.language,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      breach.domain,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(breach.breachDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatPwnCount(breach.pwnCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Data classes chips (first 3 + "+N more")
              if (breach.dataClasses.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...breach.dataClasses.take(3).map(
                          (dc) => _DataClassChip(label: dc),
                        ),
                    if (breach.dataClasses.length > 3)
                      _DataClassChip(
                        label: '+${breach.dataClasses.length - 3} more',
                        isOverflow: true,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small chip showing a data class name.
class _DataClassChip extends StatelessWidget {
  const _DataClassChip({
    required this.label,
    this.isOverflow = false,
  });

  final String label;
  final bool isOverflow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOverflow
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isOverflow
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
