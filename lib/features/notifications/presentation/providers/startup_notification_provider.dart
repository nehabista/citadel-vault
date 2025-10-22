// File: lib/features/notifications/presentation/providers/startup_notification_provider.dart
// Triggers breach/expiry/emergency checks on session unlock.
// Per D-14, NOTIF-01, NOTIF-03: All triggers are local/client-side, run on app open.
// Zero external push service imports.

import 'dart:developer' as dev;

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../security/presentation/providers/expiry_provider.dart';
import '../../../sharing/presentation/providers/emergency_providers.dart';
import '../../../sharing/presentation/providers/sharing_providers.dart';
import 'notification_providers.dart';

/// Provider that runs once on session unlock to trigger local notifications
/// for breach alerts, expiry reminders, and emergency access auto-grants.
///
/// Watches [sessionProvider]; when session transitions to [Unlocked],
/// performs background checks and fires local notifications as needed.
final startupNotificationProvider = FutureProvider<void>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) return;

  final notificationService = ref.read(notificationServiceProvider);
  final notificationRepo = ref.read(notificationRepositoryProvider);

  // 1. Breach check trigger (NOTIF-01)
  try {
    final breachEnabled = await notificationRepo.isEnabled('breach_alert');
    if (breachEnabled) {
      final vaultKey = SecretKey(session.vaultKey);
      final vaultRepo = ref.read(vaultRepositoryProvider);
      final breachService = ref.read(breachServiceProvider);

      final items = await vaultRepo.getAllItems(vaultKey);
      int breachCount = 0;

      for (final item in items) {
        if (item.password != null && item.password!.isNotEmpty) {
          try {
            final count = await breachService.pwnedPasswordCount(item.password!);
            if (count > 0) breachCount++;
          } catch (_) {
            // Network errors should not block startup
          }
        }
      }

      if (breachCount > 0) {
        await notificationService.showBreachAlert(
          title: 'Breach Alert',
          body: '$breachCount password(s) found in data breaches',
          payload: '/watchtower',
        );

        await notificationRepo.recordNotification(
          type: 'breach_alert',
          title: 'Breach Alert',
          body: '$breachCount password(s) found in data breaches',
        );
      }
    }
  } catch (e) {
    dev.log('Startup breach check failed: $e', name: 'StartupNotification');
  }

  // 2. Expiry check trigger (NOTIF-03)
  try {
    final expiryEnabled = await notificationRepo.isEnabled('expiry_reminder');
    if (expiryEnabled) {
      final expiredItems = await ref.read(expiredItemsProvider.future);
      if (expiredItems.isNotEmpty) {
        await notificationService.showExpiryReminder(
          title: 'Password Expiry',
          body: '${expiredItems.length} password(s) need rotation',
          payload: '/watchtower',
        );

        await notificationRepo.recordNotification(
          type: 'expiry_reminder',
          title: 'Password Expiry',
          body: '${expiredItems.length} password(s) need rotation',
        );
      }
    }
  } catch (e) {
    dev.log('Startup expiry check failed: $e', name: 'StartupNotification');
  }

  // 3. Start real-time sharing listener
  try {
    final pb = ref.read(pocketBaseClientProvider);
    final userId = pb.authStore.record?.id;
    if (userId != null) {
      final sharingRepo = ref.read(sharingRepositoryProvider);
      sharingRepo.startListening(userId);
    }
  } catch (e) {
    dev.log('Sharing listener startup failed: $e', name: 'StartupNotification');
  }

  // 4. Start real-time emergency listener with alert callback
  try {
    final pb = ref.read(pocketBaseClientProvider);
    final userId = pb.authStore.record?.id;
    if (userId != null) {
      final emergencyRepo = ref.read(emergencyRepositoryProvider);
      emergencyRepo.startListening(
        userId: userId,
        showAlert: ({
          required String message,
          required String actionLabel,
          required String route,
        }) {
          // Emergency events trigger local notifications
          notificationService.showEmergencyNotification(
            title: 'Emergency Access',
            body: message,
            payload: route,
          );
        },
      );
    }
  } catch (e) {
    dev.log('Emergency listener startup failed: $e', name: 'StartupNotification');
  }
});
