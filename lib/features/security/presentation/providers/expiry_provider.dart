import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../sharing/presentation/providers/emergency_providers.dart';
import '../../../vault/domain/entities/vault_item.dart';

/// Provides the list of vault items whose passwords have expired.
///
/// An item is expired when:
///   expiryDays != null AND (updatedAt + Duration(days: expiryDays)) < now
///
/// Per D-19: used for the Watchtower tab badge count.
final expiredItemsProvider =
    FutureProvider<List<VaultItemEntity>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) return [];

  final vaultKey = SecretKey(session.vaultKey);
  final repo = ref.read(vaultRepositoryProvider);

  // Load all items from default vault.
  final items = await repo.getItems('default', vaultKey);
  final now = DateTime.now();

  return items.where((item) {
    if (item.expiryDays == null) return false;
    final expiresAt = item.updatedAt.add(Duration(days: item.expiryDays!));
    return expiresAt.isBefore(now);
  }).toList();
});

/// Badge count of expired items for the Watchtower tab.
///
/// Per D-19: displays badge on Watchtower tab with the number
/// of items that need password rotation.
final expiryBadgeCountProvider = Provider<int>((ref) {
  final expired = ref.watch(expiredItemsProvider);
  return expired.whenOrNull(data: (items) => items.length) ?? 0;
});

/// Combined badge count for Watchtower tab including expiry, emergency, and
/// unread notification counts.
///
/// Per D-18: Watchtower badge aggregates breach alerts, emergency pending,
/// and expiry count into a single badge number.
final combinedBadgeCountProvider = Provider<int>((ref) {
  final expiry = ref.watch(expiryBadgeCountProvider);
  final emergency = ref.watch(pendingEmergencyCountProvider);
  final unread = ref.watch(unreadCountProvider);
  return expiry + emergency + unread;
});
