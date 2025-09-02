import '../../../vault/domain/entities/vault_item.dart';
import '../../domain/entities/watchtower_category.dart';

/// Color classification for the health score gauge.
enum ScoreColor {
  /// Score 80-100: vault is in good shape.
  green,

  /// Score 50-79: some issues need attention.
  yellow,

  /// Score 0-49: critical issues detected.
  red,
}

/// Computed health score for the user's vault.
///
/// Score is 0-100, computed from:
/// - 30% strong password percentage
/// - 30% unique password percentage
/// - 25% not-breached percentage
/// - 15% not-old percentage
class HealthScore {
  final int score;
  final List<VaultItemEntity> weakItems;
  final List<VaultItemEntity> reusedItems;
  final List<VaultItemEntity> oldItems;
  final List<VaultItemEntity> breachedItems;

  /// Total items used in the score calculation (needed for withBreachedItems).
  final int totalItemCount;

  const HealthScore({
    required this.score,
    required this.weakItems,
    required this.reusedItems,
    required this.oldItems,
    required this.breachedItems,
    this.totalItemCount = 0,
  });

  /// Empty score representing a vault with no items (perfect score).
  factory HealthScore.empty() => const HealthScore(
        score: 100,
        weakItems: [],
        reusedItems: [],
        oldItems: [],
        breachedItems: [],
      );

  /// Color classification based on score value.
  ScoreColor get color {
    if (score >= 80) return ScoreColor.green;
    if (score >= 50) return ScoreColor.yellow;
    return ScoreColor.red;
  }

  /// Create a new HealthScore with breach data merged in.
  ///
  /// Recalculates the score incorporating the breached items percentage.
  HealthScore withBreachedItems(List<VaultItemEntity> breached) {
    if (totalItemCount == 0) {
      return HealthScore(
        score: 100,
        weakItems: weakItems,
        reusedItems: reusedItems,
        oldItems: oldItems,
        breachedItems: breached,
        totalItemCount: totalItemCount,
      );
    }

    final strongPct = 1.0 - (weakItems.length / totalItemCount);
    final uniquePct = 1.0 - (reusedItems.length / totalItemCount);
    final notBreachedPct = 1.0 - (breached.length / totalItemCount);
    final notOldPct = 1.0 - (oldItems.length / totalItemCount);

    final newScore = ((strongPct * 0.3) +
            (uniquePct * 0.3) +
            (notBreachedPct * 0.25) +
            (notOldPct * 0.15)) *
        100;

    return HealthScore(
      score: newScore.round().clamp(0, 100),
      weakItems: weakItems,
      reusedItems: reusedItems,
      oldItems: oldItems,
      breachedItems: breached,
      totalItemCount: totalItemCount,
    );
  }

  /// Returns the 4 watchtower categories for UI display.
  List<WatchtowerCategory> get categories => [
        WatchtowerCategory(
          type: WatchtowerCategoryType.weak,
          items: weakItems,
        ),
        WatchtowerCategory(
          type: WatchtowerCategoryType.reused,
          items: reusedItems,
        ),
        WatchtowerCategory(
          type: WatchtowerCategoryType.old,
          items: oldItems,
        ),
        WatchtowerCategory(
          type: WatchtowerCategoryType.breached,
          items: breachedItems,
        ),
      ];
}
