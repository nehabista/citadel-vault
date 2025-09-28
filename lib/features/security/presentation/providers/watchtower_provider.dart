import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../../vault/presentation/providers/multi_vault_provider.dart';
import '../../data/models/health_score.dart';

/// Watchtower provider that computes the vault health score.
///
/// Watches session state (must be Unlocked) and computes the score
/// via WatchtowerService. Initially scores without breach data,
/// which is merged asynchronously via [updateWithBreachedItems].
final watchtowerProvider =
    AsyncNotifierProvider<WatchtowerNotifier, HealthScore>(
  WatchtowerNotifier.new,
);

/// Notifier that manages the Watchtower health score lifecycle.
class WatchtowerNotifier extends AsyncNotifier<HealthScore> {
  @override
  Future<HealthScore> build() async {
    final session = ref.watch(sessionProvider);

    // Watch vault items so watchtower refreshes when items change.
    ref.watch(multiVaultProvider);

    return switch (session) {
      Locked() => HealthScore.empty(),
      Unlocked() => _computeScore(),
    };
  }

  Future<HealthScore> _computeScore() async {
    final vaultRepo = ref.read(vaultRepositoryProvider);
    final watchtower = ref.read(watchtowerServiceProvider);

    // Fetch all vault items
    final session = ref.read(sessionProvider);
    if (session is! Unlocked) return HealthScore.empty();

    final items = await vaultRepo.getAllItems(SecretKey(session.vaultKey));
    return watchtower.computeScore(items);
  }

  /// Recompute the health score (e.g., after vault changes).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _computeScore());
  }

  /// Update the current health score with breach check results.
  void updateWithBreachedItems(List<VaultItemEntity> breachedItems) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.withBreachedItems(breachedItems));
  }
}

/// Provider for expired/old items (for badge count on D-19).
final expiredItemsProvider = FutureProvider<List<VaultItemEntity>>((ref) async {
  final session = ref.watch(sessionProvider);
  return switch (session) {
    Locked() => <VaultItemEntity>[],
    Unlocked(:final vaultKey) => () async {
        final vaultRepo = ref.read(vaultRepositoryProvider);
        final watchtower = ref.read(watchtowerServiceProvider);
        final items = await vaultRepo.getAllItems(SecretKey(vaultKey));
        return watchtower.getExpiredItems(items);
      }(),
  };
});
