// File: lib/features/sharing/presentation/providers/emergency_providers.dart
// Riverpod providers for emergency access feature.
// Wires EmergencyService, EmergencyRepository, and derived state providers.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../data/models/emergency_contact.dart';
import '../../data/repositories/emergency_repository.dart';
import '../../data/services/emergency_service.dart';
import '../../data/services/sharing_crypto_service.dart';

/// Provides the [SharingCryptoService] singleton.
final sharingCryptoServiceProvider = Provider<SharingCryptoService>((ref) {
  return SharingCryptoService();
});

/// Provides the [EmergencyService] with PocketBase client injection.
final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  return EmergencyService(pb: ref.watch(pocketBaseClientProvider));
});

/// Provides the [EmergencyRepository] with all dependencies injected.
final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return EmergencyRepository(
    service: ref.watch(emergencyServiceProvider),
    crypto: ref.watch(sharingCryptoServiceProvider),
    dao: ref.watch(appDatabaseProvider).sharingDao,
    notificationService: ref.watch(notificationServiceProvider),
  );
});

/// Emergency contacts where the current user is the grantor (they granted access).
final grantorContactsProvider =
    FutureProvider<List<EmergencyContact>>((ref) async {
  final pb = ref.watch(pocketBaseClientProvider);
  final userId = pb.authStore.record?.id;
  if (userId == null) return [];

  final repo = ref.watch(emergencyRepositoryProvider);
  return repo.getGrantorContacts(userId);
});

/// Emergency contacts where the current user is the grantee (they were granted access).
final granteeContactsProvider =
    FutureProvider<List<EmergencyContact>>((ref) async {
  final pb = ref.watch(pocketBaseClientProvider);
  final userId = pb.authStore.record?.id;
  if (userId == null) return [];

  final repo = ref.watch(emergencyRepositoryProvider);
  return repo.getGranteeContacts(userId);
});

/// Count of emergency contacts in 'waiting' status where user is grantor.
/// Per D-18: used for badge count on emergency access menu item.
final pendingEmergencyCountProvider = Provider<int>((ref) {
  final grantorContacts = ref.watch(grantorContactsProvider);
  return grantorContacts.whenOrNull(
        data: (contacts) =>
            contacts.where((c) => c.status == 'waiting').length,
      ) ??
      0;
});
