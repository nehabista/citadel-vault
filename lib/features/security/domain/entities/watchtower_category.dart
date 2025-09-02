import '../../../vault/domain/entities/vault_item.dart';

/// Types of security categories tracked by Watchtower.
enum WatchtowerCategoryType {
  weak,
  reused,
  old,
  breached,
}

/// A category of security issues detected by Watchtower.
///
/// Each category contains a list of vault items that fall into that category.
/// Used by the UI to render category cards in the Watchtower dashboard.
class WatchtowerCategory {
  final WatchtowerCategoryType type;
  final List<VaultItemEntity> items;

  const WatchtowerCategory({
    required this.type,
    required this.items,
  });

  /// The number of items in this category.
  int get count => items.length;

  /// Human-readable label for this category.
  String get label {
    switch (type) {
      case WatchtowerCategoryType.weak:
        return 'Weak Passwords';
      case WatchtowerCategoryType.reused:
        return 'Reused Passwords';
      case WatchtowerCategoryType.old:
        return 'Old Passwords';
      case WatchtowerCategoryType.breached:
        return 'Breached Passwords';
    }
  }
}
