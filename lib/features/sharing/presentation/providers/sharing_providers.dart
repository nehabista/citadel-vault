// File: lib/features/sharing/presentation/providers/sharing_providers.dart
// Riverpod providers for sharing services, repository, and derived state.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../data/models/shared_item.dart' as pb_models;
import '../../data/models/vault_member.dart' as pb_models;
import '../../data/repositories/sharing_repository.dart';
import '../../data/services/shared_vault_service.dart';
import '../../data/services/sharing_crypto_service.dart';
import '../../data/services/sharing_service.dart';

/// Provides a singleton [SharingCryptoService] for X25519/AES-256-GCM operations.
final sharingCryptoServiceProvider = Provider<SharingCryptoService>((ref) {
  return SharingCryptoService();
});

/// Provides the [SharingService] for PocketBase CRUD on shared_items/links/keys.
final sharingServiceProvider = Provider<SharingService>((ref) {
  return SharingService(pb: ref.watch(pocketBaseClientProvider));
});

/// Provides the [SharedVaultService] for vault member management and key rotation.
final sharedVaultServiceProvider = Provider<SharedVaultService>((ref) {
  return SharedVaultService(
    pb: ref.watch(pocketBaseClientProvider),
    crypto: ref.watch(sharingCryptoServiceProvider),
  );
});

/// Provides the [SharingRepository] that coordinates crypto + PB + cache + notifications.
final sharingRepositoryProvider = Provider<SharingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SharingRepository(
    service: ref.watch(sharingServiceProvider),
    crypto: ref.watch(sharingCryptoServiceProvider),
    dao: db.sharingDao,
    notificationService: ref.watch(notificationServiceProvider),
  );
});

/// Fetches the list of shared items received by the current user.
final receivedItemsProvider =
    FutureProvider<List<pb_models.SharedItem>>((ref) async {
  final repo = ref.watch(sharingRepositoryProvider);
  // Current user ID comes from PocketBase auth state.
  final pb = ref.watch(pocketBaseClientProvider);
  final userId = pb.authStore.record?.id ?? '';
  if (userId.isEmpty) return [];
  return repo.getReceivedItems(userId);
});

/// Fetches the list of shared items sent by the current user.
final sentItemsProvider =
    FutureProvider<List<pb_models.SharedItem>>((ref) async {
  final service = ref.watch(sharingServiceProvider);
  final pb = ref.watch(pocketBaseClientProvider);
  final userId = pb.authStore.record?.id ?? '';
  if (userId.isEmpty) return [];
  final records = await service.getSentItems(userId);
  return records.map((r) => pb_models.SharedItem.fromRecord(r)).toList();
});

/// Fetches the shared vaults the current user is a member of.
final userSharedVaultsProvider =
    FutureProvider<List<pb_models.VaultMember>>((ref) async {
  final service = ref.watch(sharedVaultServiceProvider);
  final pb = ref.watch(pocketBaseClientProvider);
  final userId = pb.authStore.record?.id ?? '';
  if (userId.isEmpty) return [];
  final records = await service.getUserSharedVaults(userId);
  return records.map((r) => pb_models.VaultMember.fromRecord(r)).toList();
});
