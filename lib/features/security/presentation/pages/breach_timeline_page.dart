import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../vault/domain/entities/vault_item.dart';
import '../../data/models/breach_record.dart';

// ---------------------------------------------------------------------------
// Timeline event model
// ---------------------------------------------------------------------------

/// Represents a single event on the breach timeline.
class TimelineEvent implements Comparable<TimelineEvent> {
  final DateTime date;
  final TimelineEventType type;
  final String title;
  final String? subtitle;
  final List<String> details;

  const TimelineEvent({
    required this.date,
    required this.type,
    required this.title,
    this.subtitle,
    this.details = const [],
  });

  @override
  int compareTo(TimelineEvent other) => date.compareTo(other.date);
}

enum TimelineEventType { breach, passwordChange }

// ---------------------------------------------------------------------------
// Utility: merge and compute gaps
// ---------------------------------------------------------------------------

/// Merge breach records and password change timestamps into a
/// chronologically sorted timeline with exposure gap annotations.
List<TimelineEvent> buildTimeline({
  required List<BreachRecord> breaches,
  required List<DateTime> passwordChangeDates,
}) {
  final events = <TimelineEvent>[];

  for (final breach in breaches) {
    events.add(TimelineEvent(
      date: breach.breachDate,
      type: TimelineEventType.breach,
      title: breach.displayTitle,
      subtitle: breach.domain.isNotEmpty ? breach.domain : null,
      details: breach.dataClasses,
    ));
  }

  for (final changeDate in passwordChangeDates) {
    events.add(TimelineEvent(
      date: changeDate,
      type: TimelineEventType.passwordChange,
      title: 'Password changed',
    ));
  }

  events.sort();
  return events;
}

/// Calculate the duration a credential was exposed after a breach
/// before the next password change (or until now if no change).
String exposureGapLabel(DateTime breachDate, DateTime? nextChangeDate) {
  final end = nextChangeDate ?? DateTime.now();
  final diff = end.difference(breachDate);

  if (diff.inDays > 365) {
    final years = (diff.inDays / 365).floor();
    final months = ((diff.inDays % 365) / 30).floor();
    return months > 0 ? '$years yr $months mo exposed' : '$years yr exposed';
  } else if (diff.inDays > 30) {
    final months = (diff.inDays / 30).floor();
    return '$months month${months == 1 ? '' : 's'} exposed';
  } else if (diff.inDays > 0) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} exposed';
  } else {
    return 'Changed same day';
  }
}

// ---------------------------------------------------------------------------
// Page widget
// ---------------------------------------------------------------------------

/// Breach timeline visualization showing exposure dates versus
/// password change dates for a vault item.
///
/// Per D-20: vertical list with date markers, color-coded events.
class BreachTimelinePage extends ConsumerWidget {
  const BreachTimelinePage({
    super.key,
    required this.item,
    required this.breaches,
    required this.passwordChangeDates,
  });

  final VaultItemEntity item;
  final List<BreachRecord> breaches;
  final List<DateTime> passwordChangeDates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final events = buildTimeline(
      breaches: breaches,
      passwordChangeDates: passwordChangeDates,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Breach Timeline',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: events.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                // Find the next password change after a breach for gap.
                String? gapLabel;
                if (event.type == TimelineEventType.breach) {
                  final nextChange = _findNextPasswordChange(events, index);
                  gapLabel = exposureGapLabel(event.date, nextChange);
                }
                return _TimelineEntry(
                  event: event,
                  gapLabel: gapLabel,
                  isLast: index == events.length - 1,
                );
              },
            ),
    );
  }

  DateTime? _findNextPasswordChange(List<TimelineEvent> events, int fromIdx) {
    for (var i = fromIdx + 1; i < events.length; i++) {
      if (events[i].type == TimelineEventType.passwordChange) {
        return events[i].date;
      }
    }
    return null; // No password change after this breach.
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No timeline data available',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No breach records or password history found for this item.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual timeline entry
// ---------------------------------------------------------------------------

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.event,
    this.gapLabel,
    this.isLast = false,
  });

  final TimelineEvent event;
  final String? gapLabel;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBreach = event.type == TimelineEventType.breach;

    final markerColor = isBreach ? Colors.red : Colors.green;
    final dateStr = DateFormat('MMM d, yyyy').format(event.date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline spine
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: markerColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date label
                  Text(
                    dateStr,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Event title
                  Text(
                    event.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: isBreach ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                  // Subtitle (domain for breaches)
                  if (event.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  // Data classes for breaches
                  if (event.details.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: event.details
                            .map((dc) => Chip(
                                  label: Text(dc, style: const TextStyle(fontSize: 11)),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  labelPadding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                ))
                            .toList(),
                      ),
                    ),
                  // Exposure gap label
                  if (gapLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          gapLabel!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.red.shade700,
                          ),
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
