import '../../../password_generator/data/password_strength_service.dart';
import '../../../password_generator/domain/entities/password_strength.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../models/health_score.dart';

/// Service that analyzes vault items to compute a health score and
/// identify security issues.
///
/// The health score is 0-100, computed from:
/// - 30% strong password percentage (via classifyStrength)
/// - 30% unique password percentage (no duplicates)
/// - 25% not-breached percentage (initially 100%, updated async)
/// - 15% not-old percentage (updated within 90 days)
class WatchtowerService {
  /// Compute a health score for the given vault items.
  ///
  /// Filters items to only those with non-null, non-empty passwords.
  /// Initially sets notBreachedPct to 1.0 (breach check is async and
  /// merged later via [HealthScore.withBreachedItems]).
  HealthScore computeScore(List<VaultItemEntity> items) {
    // Filter to items with actual passwords
    final passwordItems = items
        .where((item) => item.password != null && item.password!.isNotEmpty)
        .toList();

    if (passwordItems.isEmpty) {
      return HealthScore.empty();
    }

    final total = passwordItems.length;

    // Weak detection
    final weakItems = <VaultItemEntity>[];
    for (final item in passwordItems) {
      final checks = runChecks(item.password!);
      final bits = estimateEntropyBits(item.password!);
      final strength = classifyStrength(checks, bits);
      if (strength == Strength.weak) {
        weakItems.add(item);
      }
    }

    // Reuse detection: group by password, items in groups of size > 1
    final passwordGroups = <String, List<VaultItemEntity>>{};
    for (final item in passwordItems) {
      passwordGroups.putIfAbsent(item.password!, () => []).add(item);
    }
    final reusedItems = <VaultItemEntity>[];
    for (final group in passwordGroups.values) {
      if (group.length > 1) {
        reusedItems.addAll(group);
      }
    }

    // Old detection: updatedAt > 90 days ago
    final now = DateTime.now();
    final oldItems = passwordItems
        .where((item) => now.difference(item.updatedAt).inDays > 90)
        .toList();

    // Compute percentages
    final strongPct = 1.0 - (weakItems.length / total);
    final uniquePct = 1.0 - (reusedItems.length / total);
    const notBreachedPct = 1.0; // Updated later via withBreachedItems
    final notOldPct = 1.0 - (oldItems.length / total);

    // Formula per D-02
    final score = ((strongPct * 0.3) +
            (uniquePct * 0.3) +
            (notBreachedPct * 0.25) +
            (notOldPct * 0.15)) *
        100;

    return HealthScore(
      score: score.round().clamp(0, 100),
      weakItems: weakItems,
      reusedItems: reusedItems,
      oldItems: oldItems,
      breachedItems: const [],
      totalItemCount: total,
    );
  }

  /// Get items whose passwords are older than 90 days.
  ///
  /// Per SEC-11 / D-18: items where the password hasn't been updated
  /// in over 90 days are considered expired.
  List<VaultItemEntity> getExpiredItems(List<VaultItemEntity> items) {
    final now = DateTime.now();
    return items
        .where((item) =>
            item.password != null &&
            item.password!.isNotEmpty &&
            now.difference(item.updatedAt).inDays > 90)
        .toList();
  }
}
