// File: lib/presentation/widgets/watchtower_nav_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/security/presentation/providers/expiry_provider.dart';

/// Watchtower bottom nav item with expiry badge.
class WatchtowerNavItem extends ConsumerWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const WatchtowerNavItem({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  static const _selectedColor = Color(0xFF4D4DCD);
  static const _unselectedColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeCount = ref.watch(combinedBadgeCountProvider);
    final color = isSelected ? _selectedColor : _unselectedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? _selectedColor.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(
                  '$badgeCount',
                  style: const TextStyle(fontSize: 9),
                ),
                child: Icon(
                  isSelected ? Icons.shield : Icons.shield_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Watch',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
