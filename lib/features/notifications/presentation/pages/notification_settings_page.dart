// File: lib/features/notifications/presentation/pages/notification_settings_page.dart
// Per-type notification settings with toggle switches.
// Per D-19: toggle per notification type.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/repositories/notification_repository.dart';
import '../providers/notification_providers.dart';

/// Settings page allowing users to enable/disable each notification category.
///
/// Provides toggles for:
/// - Breach Alerts
/// - Expiry Reminders
/// - Sharing Notifications
/// - Emergency Access
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  static const _primaryColor = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToggleTile(
            title: 'Breach Alerts',
            subtitle: 'Get notified when passwords appear in data breaches',
            icon: Icons.shield_outlined,
            enabledProvider: notifBreachEnabledProvider,
            notificationType: NotificationRepository.breachAlert,
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Expiry Reminders',
            subtitle: 'Reminders when passwords are due for rotation',
            icon: Icons.schedule_outlined,
            enabledProvider: notifExpiryEnabledProvider,
            notificationType: NotificationRepository.expiryReminder,
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Sharing Notifications',
            subtitle: 'Notifications for shared items and vault invitations',
            icon: Icons.share_outlined,
            enabledProvider: notifSharingEnabledProvider,
            notificationType: NotificationRepository.sharedItem,
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Emergency Access',
            subtitle: 'Emergency access requests and status updates',
            icon: Icons.emergency_outlined,
            enabledProvider: notifEmergencyEnabledProvider,
            notificationType: NotificationRepository.emergencyRequest,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required FutureProvider<bool> enabledProvider,
    required String notificationType,
  }) {
    final enabledAsync = ref.watch(enabledProvider);
    final isEnabled = enabledAsync.value ?? true;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SwitchListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Icon(icon, color: _primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        value: isEnabled,
        activeColor: _primaryColor,
        onChanged: (value) async {
          await ref
              .read(notificationRepositoryProvider)
              .setEnabled(notificationType, value);
          // Invalidate the provider to refresh the UI.
          ref.invalidate(enabledProvider);
          if (mounted) {
            showCitadelSnackBar(context, 'Settings saved');
          }
        },
      ),
    );
  }
}
