import 'package:flutter/material.dart';

import '../../domain/entities/watchtower_category.dart';

/// Expandable category card for the Watchtower dashboard (D-03).
///
/// Shows icon + category name + count badge. Tap to expand and show
/// the list of affected VaultItemEntity items.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.onItemTap,
  });

  /// The watchtower category to display.
  final WatchtowerCategory category;

  /// Callback when an individual item in the expanded list is tapped.
  /// Receives the vault item ID.
  final void Function(String itemId)? onItemTap;

  IconData _categoryIcon(WatchtowerCategoryType type) {
    switch (type) {
      case WatchtowerCategoryType.weak:
        return Icons.shield_outlined;
      case WatchtowerCategoryType.reused:
        return Icons.copy_rounded;
      case WatchtowerCategoryType.old:
        return Icons.access_time_rounded;
      case WatchtowerCategoryType.breached:
        return Icons.warning_amber_rounded;
    }
  }

  Color _categoryColor(WatchtowerCategoryType type) {
    switch (type) {
      case WatchtowerCategoryType.weak:
        return Colors.orange;
      case WatchtowerCategoryType.reused:
        return Colors.deepPurple;
      case WatchtowerCategoryType.old:
        return Colors.blueGrey;
      case WatchtowerCategoryType.breached:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _categoryIcon(category.type);
    final color = _categoryColor(category.type);
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
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          category.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: category.count > 0
                    ? color.withValues(alpha: 0.12)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${category.count}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: category.count > 0 ? color : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 20),
          ],
        ),
        children: category.items.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No issues found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ]
            : category.items.map((item) {
                return ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  leading: Icon(
                    Icons.key_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: item.username != null && item.username!.isNotEmpty
                      ? Text(
                          item.username!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => onItemTap?.call(item.id),
                );
              }).toList(),
      ),
    );
  }
}
