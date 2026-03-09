// P2: Settings page with all configuration sections
// File: lib/presentation/pages/settings/settings_page.dart
import 'dart:convert' show Base64Decoder;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/session_timeout_provider.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/sync/sync_state.dart';
import '../../../data/services/auth/local_auth_service.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/autofill/presentation/providers/autofill_provider.dart';
import '../../../features/autofill/presentation/providers/clipboard_provider.dart';
import '../../../routing/app_router.dart';
import '../../widgets/citadel_snackbar.dart';
import '../../widgets/master_password_prompt.dart';
import 'pin_setup_page.dart';

/// Provider that fetches the current unlock method from LocalAuthService.
final _unlockMethodProvider = FutureProvider<UnlockMethod>((ref) async {
  final localAuth = ref.watch(localAuthServiceProvider);
  return localAuth.getSavedUnlockMethod();
});

/// Provider that checks if biometrics are available on device.
final _biometricsAvailableProvider = FutureProvider<bool>((ref) async {
  final localAuth = ref.watch(localAuthServiceProvider);
  return localAuth.canUseBiometrics();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockMethodAsync = ref.watch(_unlockMethodProvider);
    final biometricsAvailableAsync = ref.watch(_biometricsAvailableProvider);
    final autofillStatusAsync = ref.watch(autofillStatusProvider);
    final clipboardTimeoutAsync = ref.watch(clipboardTimeoutProvider);
    final syncStateAsync = ref.watch(syncStateProvider);
    final sessionTimeoutAsync = ref.watch(sessionTimeoutSettingProvider);
    final lockOnBackgroundAsync = ref.watch(lockOnBackgroundSettingProvider);

    final currentMethod =
        unlockMethodAsync.value ?? UnlockMethod.masterPassword;
    final biometricsAvailable = biometricsAvailableAsync.value ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        children: [
          // Large title
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Security ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF4D4DCD),
              title: 'Biometrics',
              subtitle: !biometricsAvailable
                  ? 'Not available on this device'
                  : null,
              trailing: Switch.adaptive(
                value: currentMethod == UnlockMethod.biometrics,
                activeTrackColor: const Color(0xFF4D4DCD),
                onChanged: biometricsAvailable
                    ? (bool value) {
                        if (value) {
                          _setupBiometrics(context, ref);
                        } else {
                          _disableQuickUnlock(context, ref);
                        }
                      }
                    : null,
              ),
            ),
            _SettingsTile(
              icon: Icons.pin,
              iconColor: const Color(0xFF4D4DCD),
              title: 'PIN Unlock',
              trailing: Switch.adaptive(
                value: currentMethod == UnlockMethod.pin,
                activeTrackColor: const Color(0xFF4D4DCD),
                onChanged: (bool value) {
                  if (value) {
                    _setupPin(context, ref);
                  } else {
                    _disableQuickUnlock(context, ref);
                  }
                },
              ),
            ),
            _SettingsTile(
              icon: Icons.lock_clock,
              iconColor: const Color(0xFF4D4DCD),
              title: 'Auto-Lock',
              trailing: sessionTimeoutAsync.when(
                data: (currentMinutes) {
                  final selectedValue =
                      autoLockOptions.containsKey(currentMinutes)
                          ? currentMinutes
                          : kDefaultTimeoutMinutes;

                  return DropdownButton<int>(
                    value: selectedValue,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    items: autoLockOptions.entries
                        .map((entry) => DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: (newValue) async {
                      if (newValue == null) return;
                      final db = ref.read(appDatabaseProvider);
                      await db.settingsDao.setSetting(
                        kSessionTimeoutKey,
                        newValue.toString(),
                      );
                      ref.invalidate(sessionTimeoutSettingProvider);
                    },
                  );
                },
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Text(
                  '5 minutes',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.phonelink_lock,
              iconColor: const Color(0xFF4D4DCD),
              title: 'Lock on Background',
              subtitle: 'Lock vault when app goes to background',
              trailing: Switch.adaptive(
                value: lockOnBackgroundAsync.value ?? true,
                activeTrackColor: const Color(0xFF4D4DCD),
                onChanged: (bool value) async {
                  final db = ref.read(appDatabaseProvider);
                  await db.settingsDao.setSetting(
                    kLockOnBackgroundKey,
                    value.toString(),
                  );
                  ref.invalidate(lockOnBackgroundSettingProvider);
                },
              ),
            ),
          ]),

          // ── Autofill ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.auto_awesome,
              iconColor: Colors.blue,
              title: 'Autofill Service',
              subtitle: autofillStatusAsync.when(
                data: (enabled) => enabled ? 'Enabled' : 'Not enabled',
                loading: () => 'Checking...',
                error: (_, __) => 'Not available',
              ),
              onTap: () async {
                if (kIsWeb) {
                  showCitadelSnackBar(
                    context,
                    'Autofill settings are not available on web',
                    type: SnackBarType.info,
                  );
                  return;
                }
                if (!Platform.isAndroid) {
                  showCitadelSnackBar(
                    context,
                    'Autofill settings are available on Android devices',
                    type: SnackBarType.info,
                  );
                  return;
                }
                try {
                  final openSettings =
                      ref.read(openAutofillSettingsProvider);
                  await openSettings();
                } catch (_) {
                  if (!context.mounted) return;
                  showCitadelSnackBar(
                    context,
                    'Could not open autofill settings',
                    type: SnackBarType.error,
                  );
                }
              },
            ),
            _SettingsTile(
              icon: Icons.content_paste_off,
              iconColor: Colors.teal,
              title: 'Clipboard Auto-Clear',
              trailing: clipboardTimeoutAsync.when(
                data: (duration) {
                  final currentSeconds = duration.inSeconds;
                  final selectedValue =
                      _clipboardTimeoutOptions
                              .containsKey(currentSeconds)
                          ? currentSeconds
                          : 30;

                  return DropdownButton<int>(
                    value: selectedValue,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    items: _clipboardTimeoutOptions.entries
                        .map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (newValue) async {
                      if (newValue == null) return;
                      final db = ref.read(appDatabaseProvider);
                      await db.settingsDao.setSetting(
                        'clipboard_timeout',
                        newValue.toString(),
                      );
                      ref.invalidate(clipboardTimeoutProvider);
                    },
                  );
                },
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Text(
                  '30 seconds',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ]),

          // ── Privacy ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.flight,
              iconColor: Colors.orange,
              title: 'Travel Mode',
              onTap: () => context.push(AppRoutes.travelMode),
            ),
            _SettingsTile(
              icon: Icons.alternate_email,
              iconColor: Colors.deepOrange,
              title: 'Email Aliases',
              subtitle: 'SimpleLogin integration',
              onTap: () => context.push(AppRoutes.emailAliases),
            ),
          ]),

          // ── Sharing & Access ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.health_and_safety,
              iconColor: Colors.purple,
              title: 'Emergency Access',
              subtitle: 'Manage trusted contacts',
              onTap: () => context.push(AppRoutes.emergencyAccess),
            ),
            _SettingsTile(
              icon: Icons.people,
              iconColor: Colors.teal,
              title: 'Shared Vaults',
              subtitle: 'Manage family and team vaults',
              onTap: () => context.push(AppRoutes.sharedVaults),
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              iconColor: Colors.blue,
              title: 'Notifications',
              subtitle: 'Configure alert preferences',
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
          ]),

          // ── Data ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.upload_file,
              iconColor: Colors.green,
              title: 'Import',
              subtitle: 'Import from CSV',
              onTap: () => context.push(AppRoutes.importPage),
            ),
            _SettingsTile(
              icon: Icons.download,
              iconColor: Colors.indigo,
              title: 'Export',
              subtitle: 'CSV or encrypted backup',
              onTap: () => context.push(AppRoutes.exportPage),
            ),
          ]),

          // ── Sync ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.cloud_done_outlined,
              iconColor: Colors.blue,
              title: 'Sync Status',
              subtitle: syncStateAsync.when(
                data: (state) => switch (state) {
                  SyncIdle(:final lastSyncAt) => lastSyncAt != null
                      ? 'Last synced: ${_formatSyncTime(lastSyncAt)}'
                      : 'Never synced',
                  Syncing(:final pendingCount) =>
                    'Syncing ($pendingCount pending)...',
                  SyncError(:final message) => 'Sync error: $message',
                },
                loading: () => 'Checking sync status...',
                error: (e, _) => 'Sync status unavailable',
              ),
            ),
            _SettingsTile(
              icon: Icons.sync,
              iconColor: Colors.purple,
              title: 'Sync Now',
              trailing: const SizedBox.shrink(),
              onTap: () {
                ref.read(syncEngineProvider).syncNow();
                showCitadelSnackBar(context, 'Sync started');
              },
            ),
            _SettingsTile(
              icon: Icons.refresh,
              iconColor: Colors.grey,
              title: 'Force Re-sync',
              subtitle: 'Re-queue all data',
              onTap: () {
                ref.read(syncEngineProvider).forceFullResync();
                showCitadelSnackBar(context, 'Full re-sync started');
              },
            ),
          ]),

          // ── Developer ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.vpn_key,
              iconColor: Colors.blueGrey,
              title: 'SSH Keys',
              onTap: () => context.push(AppRoutes.sshKeys),
            ),
          ]),

          // ── Danger Zone ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.delete_forever,
              iconColor: Colors.red,
              title: 'Delete All Vault Data',
              subtitle: 'Permanently erase all passwords and vaults',
              trailing: const SizedBox.shrink(),
              onTap: () => _deleteAllVaultData(context, ref),
            ),
            _SettingsTile(
              icon: Icons.person_remove,
              iconColor: Colors.red,
              title: 'Delete Account',
              subtitle: 'Remove your account and all data forever',
              trailing: const SizedBox.shrink(),
              onTap: () => _deleteAccount(context, ref),
            ),
          ]),

          // ── Account ──
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'Log Out',
              trailing: const SizedBox.shrink(),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
          ]),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _formatSyncTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Prompt for master password, then navigate to PIN setup page.
  void _setupPin(BuildContext context, WidgetRef ref) {
    showMasterPasswordPrompt(
      context: context,
      subtitle: 'Required to set up PIN unlock',
      onSubmit: (masterPassword) async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PinSetupPage(masterPassword: masterPassword),
          ),
        );
        if (result == true && context.mounted) {
          ref.invalidate(_unlockMethodProvider);
          showCitadelSnackBar(context, 'PIN unlock enabled',
              type: SnackBarType.success);
        }
      },
    );
  }

  /// Prompt for master password, then enable biometric unlock.
  void _setupBiometrics(BuildContext context, WidgetRef ref) {
    showMasterPasswordPrompt(
      context: context,
      subtitle: 'Required to set up biometric unlock',
      onSubmit: (masterPassword) async {
        final localAuth = ref.read(localAuthServiceProvider);
        final success = await localAuth.enableBiometricUnlock(masterPassword);
        if (context.mounted) {
          ref.invalidate(_unlockMethodProvider);
          showCitadelSnackBar(
            context,
            success ? 'Biometric unlock enabled' : 'Biometric setup failed',
            type: success ? SnackBarType.success : SnackBarType.error,
          );
        }
      },
    );
  }

  /// Disable quick unlock (PIN or biometrics).
  void _disableQuickUnlock(BuildContext context, WidgetRef ref) async {
    final localAuth = ref.read(localAuthServiceProvider);
    await localAuth.disableQuickUnlock();
    ref.invalidate(_unlockMethodProvider);
    if (context.mounted) {
      showCitadelSnackBar(context, 'Quick unlock disabled');
    }
  }

  /// Delete all vault data (vault items, collections, password history).
  void _deleteAllVaultData(BuildContext context, WidgetRef ref) {
    showMasterPasswordPrompt(
      context: context,
      title: 'Confirm Vault Deletion',
      subtitle: 'Enter your master password to delete ALL vault data',
      onSubmit: (masterPassword) async {
        // Verify master password by attempting key derivation
        final authService = ref.read(authServiceProvider);
        final user = authService.currentUser;
        if (user == null) return;

        try {
          final crypto = ref.read(cryptoEngineProvider);
          final saltBytes =
              const Base64Decoder().convert(user.salt);
          await crypto.deriveKey(masterPassword, saltBytes);
        } catch (_) {
          if (context.mounted) {
            showCitadelSnackBar(context, 'Incorrect master password',
                type: SnackBarType.error);
          }
          return;
        }

        if (!context.mounted) return;

        // Second confirmation: type "DELETE"
        final confirmed = await _showTypedConfirmationDialog(
          context: context,
          title: 'Delete All Vault Data?',
          description:
              'This action is IRREVERSIBLE. All passwords, vault collections, '
              'TOTP entries, and password history will be permanently deleted '
              'from this device and the server.',
          confirmationText: 'DELETE',
        );

        if (confirmed != true || !context.mounted) return;

        // Show progress
        _showProgressDialog(context, 'Deleting vault data...');

        try {
          final db = ref.read(appDatabaseProvider);
          final pb = ref.read(pocketBaseClientProvider);
          final userId = pb.authStore.record?.id;

          // Delete remote vault items
          if (userId != null) {
            try {
              final remoteItems = await pb
                  .collection('vault_items')
                  .getFullList(filter: 'owner = "$userId"');
              for (final item in remoteItems) {
                await pb.collection('vault_items').delete(item.id);
              }
              final remoteVaults = await pb
                  .collection('vault_collections')
                  .getFullList(filter: 'owner = "$userId"');
              for (final v in remoteVaults) {
                await pb.collection('vault_collections').delete(v.id);
              }
            } catch (_) {
              // Remote deletion failure is non-fatal
            }
          }

          // Delete local data
          await db.customStatement('DELETE FROM vault_items');
          await db.customStatement('DELETE FROM vaults');
          await db.customStatement('DELETE FROM totp_entries');
          await db.customStatement('DELETE FROM password_history');
          await db.customStatement('DELETE FROM sync_queue');

          if (context.mounted) {
            Navigator.of(context).pop(); // close progress dialog
            showCitadelSnackBar(context, 'All vault data deleted',
                type: SnackBarType.success);
            // Lock session and navigate to login
            ref.read(authProvider.notifier).logout();
            context.go(AppRoutes.login);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop(); // close progress dialog
            showCitadelSnackBar(
              context,
              'Failed to delete vault data: ${e.toString()}',
              type: SnackBarType.error,
            );
          }
        }
      },
    );
  }

  /// Delete the entire account and all associated data.
  void _deleteAccount(BuildContext context, WidgetRef ref) {
    showMasterPasswordPrompt(
      context: context,
      title: 'Confirm Account Deletion',
      subtitle: 'Enter your master password to delete your account',
      onSubmit: (masterPassword) async {
        // Verify master password
        final authService = ref.read(authServiceProvider);
        final user = authService.currentUser;
        if (user == null) return;

        try {
          final crypto = ref.read(cryptoEngineProvider);
          final saltBytes =
              const Base64Decoder().convert(user.salt);
          await crypto.deriveKey(masterPassword, saltBytes);
        } catch (_) {
          if (context.mounted) {
            showCitadelSnackBar(context, 'Incorrect master password',
                type: SnackBarType.error);
          }
          return;
        }

        if (!context.mounted) return;

        // Second confirmation: type "DELETE MY ACCOUNT"
        final confirmed = await _showTypedConfirmationDialog(
          context: context,
          title: 'Delete Your Account?',
          description:
              'This action is IRREVERSIBLE. Your account, all vault data, '
              'shared items, emergency contacts, and all associated data will '
              'be permanently deleted. You will not be able to recover anything.',
          confirmationText: 'DELETE MY ACCOUNT',
        );

        if (confirmed != true || !context.mounted) return;

        // Show progress
        _showProgressDialog(context, 'Deleting account...');

        try {
          final db = ref.read(appDatabaseProvider);
          final pb = ref.read(pocketBaseClientProvider);
          final userId = pb.authStore.record?.id;

          // Delete remote data
          if (userId != null) {
            try {
              // Delete vault items
              final remoteItems = await pb
                  .collection('vault_items')
                  .getFullList(filter: 'owner = "$userId"');
              for (final item in remoteItems) {
                await pb.collection('vault_items').delete(item.id);
              }
              // Delete vault collections
              final remoteVaults = await pb
                  .collection('vault_collections')
                  .getFullList(filter: 'owner = "$userId"');
              for (final v in remoteVaults) {
                await pb.collection('vault_collections').delete(v.id);
              }
              // Delete the PocketBase user record
              await pb.collection('users').delete(userId);
            } catch (_) {
              // Remote deletion failure is non-fatal
            }
          }

          // Clear all local data
          await db.customStatement('DELETE FROM vault_items');
          await db.customStatement('DELETE FROM vaults');
          await db.customStatement('DELETE FROM totp_entries');
          await db.customStatement('DELETE FROM password_history');
          await db.customStatement('DELETE FROM sync_queue');
          await db.customStatement('DELETE FROM settings');
          await db.customStatement('DELETE FROM shared_items');
          await db.customStatement('DELETE FROM vault_members');
          await db.customStatement('DELETE FROM emergency_contacts');
          await db.customStatement('DELETE FROM notification_records');
          await db.customStatement('DELETE FROM file_attachments');
          await db.customStatement('DELETE FROM autofill_index');

          // Clear secure storage
          final localAuth = ref.read(localAuthServiceProvider);
          await localAuth.disableQuickUnlock();

          // Clear auth state
          pb.authStore.clear();

          if (context.mounted) {
            Navigator.of(context).pop(); // close progress dialog
            showCitadelSnackBar(context, 'Account deleted successfully',
                type: SnackBarType.success);
            context.go(AppRoutes.onboarding);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop(); // close progress dialog
            showCitadelSnackBar(
              context,
              'Failed to delete account: ${e.toString()}',
              type: SnackBarType.error,
            );
          }
        }
      },
    );
  }

  /// Show a typed confirmation dialog requiring the user to type [confirmationText].
  Future<bool?> _showTypedConfirmationDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmationText,
  }) {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isMatch =
                controller.text.trim() == confirmationText;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                      children: [
                        const TextSpan(text: 'Type '),
                        TextSpan(
                          text: confirmationText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        const TextSpan(text: ' to confirm:'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: confirmationText,
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade300,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.red),
                      ),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade600,
                      )),
                ),
                FilledButton(
                  onPressed: isMatch
                      ? () => Navigator.pop(ctx, true)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor:
                        Colors.red.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Confirm Deletion',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      )),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Show a non-dismissible progress dialog.
  void _showProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const CircularProgressIndicator(
                color: Color(0xFF4D4DCD)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/// Clipboard auto-clear timeout options: seconds -> display label.
const Map<int, String> _clipboardTimeoutOptions = {
  0: 'Never',
  15: '15 seconds',
  30: '30 seconds',
  60: '1 minute',
  300: '5 minutes',
};

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(children.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Divider(height: 1, indent: 56, endIndent: 0);
          }
          return children[i ~/ 2];
        }),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Color(0xFF1A1A2E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 20),
    );
  }
}
