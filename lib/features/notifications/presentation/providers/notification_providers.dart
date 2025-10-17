// File: lib/features/notifications/presentation/providers/notification_providers.dart
// Riverpod providers for notification service, repository, and derived state.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/notification_service.dart';

/// Provides the singleton [NotificationService] instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provides the [NotificationRepository] with SettingsDao from the database.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationRepository(
    settingsDao: db.settingsDao,
  );
});

/// Stream of unread notification records.
final unreadNotificationsProvider =
    StreamProvider<List<NotificationRecord>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchUnread();
});

/// Count of unread notifications (derived from stream).
final unreadCountProvider = Provider<int>((ref) {
  final unread = ref.watch(unreadNotificationsProvider);
  return unread.whenOrNull(data: (items) => items.length) ?? 0;
});

/// Whether breach alert notifications are enabled.
final notifBreachEnabledProvider = FutureProvider<bool>((ref) {
  return ref
      .watch(notificationRepositoryProvider)
      .isEnabled(NotificationRepository.breachAlert);
});

/// Whether expiry reminder notifications are enabled.
final notifExpiryEnabledProvider = FutureProvider<bool>((ref) {
  return ref
      .watch(notificationRepositoryProvider)
      .isEnabled(NotificationRepository.expiryReminder);
});

/// Whether shared item notifications are enabled.
final notifSharingEnabledProvider = FutureProvider<bool>((ref) {
  return ref
      .watch(notificationRepositoryProvider)
      .isEnabled(NotificationRepository.sharedItem);
});

/// Whether emergency request notifications are enabled.
final notifEmergencyEnabledProvider = FutureProvider<bool>((ref) {
  return ref
      .watch(notificationRepositoryProvider)
      .isEnabled(NotificationRepository.emergencyRequest);
});
