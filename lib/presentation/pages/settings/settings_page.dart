// File: lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/sync/sync_state.dart';
import '../../../data/services/auth/local_auth_service.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/autofill/presentation/widgets/autofill_settings_tile.dart';
import '../../../features/autofill/presentation/widgets/clipboard_settings_tile.dart';
import '../../../routing/app_router.dart';
import '../../widgets/citadel_snackbar.dart';
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

    final currentMethod =
        unlockMethodAsync.value ?? UnlockMethod.masterPassword;
    final biometricsAvailable = biometricsAvailableAsync.value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Security',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Unlock with Biometrics'),
            subtitle: !biometricsAvailable
                ? const Text('Not available on this device',
                    style: TextStyle(fontSize: 12, color: Colors.grey))
                : null,
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
          SwitchListTile(
            title: const Text('Unlock with PIN'),
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
          const SizedBox(height: 20),
          const Text(
            'Autofill',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          const AutofillSettingsTile(),
          const ClipboardSettingsTile(),
          const SizedBox(height: 20),
          const Text(
            'Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Import'),
            subtitle: const Text('Import credentials from CSV'),
            leading: const Icon(Icons.upload_file),
            onTap: () => context.push(AppRoutes.importPage),
          ),
          ListTile(
            title: const Text('Export'),
            subtitle: const Text('Export vault as CSV or encrypted backup'),
            leading: const Icon(Icons.download),
            onTap: () => context.push(AppRoutes.exportPage),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sync',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          _SyncStatusTile(),
          ListTile(
            title: const Text('Sync Now'),
            leading: const Icon(Icons.sync),
            onTap: () {
              ref.read(syncEngineProvider).syncNow();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sync started',
                      style: TextStyle(fontFamily: 'Poppins')),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF4D4DCD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Force Full Re-sync'),
            subtitle: const Text('Re-queue all data (troubleshooting)',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            leading: const Icon(Icons.refresh),
            onTap: () {
              ref.read(syncEngineProvider).forceFullResync();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Full re-sync started',
                      style: TextStyle(fontFamily: 'Poppins')),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF4D4DCD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Logout',
                style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Prompt for master password, then navigate to PIN setup page.
  void _setupPin(BuildContext context, WidgetRef ref) {
    _promptMasterPassword(
      context: context,
      title: 'Enter Master Password',
      subtitle: 'Required to set up PIN unlock',
      onSubmit: (masterPassword) async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PinSetupPage(masterPassword: masterPassword),
          ),
        );
        if (result == true && context.mounted) {
          ref.invalidate(_unlockMethodProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PIN unlock enabled',
                  style: TextStyle(fontFamily: 'Poppins')),
              backgroundColor: const Color(0xFF4D4DCD),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
    );
  }

  /// Prompt for master password, then enable biometric unlock.
  void _setupBiometrics(BuildContext context, WidgetRef ref) {
    _promptMasterPassword(
      context: context,
      title: 'Enter Master Password',
      subtitle: 'Required to set up biometric unlock',
      onSubmit: (masterPassword) async {
        final localAuth = ref.read(localAuthServiceProvider);
        final success = await localAuth.enableBiometricUnlock(masterPassword);
        if (context.mounted) {
          ref.invalidate(_unlockMethodProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Biometric unlock enabled'
                    : 'Biometric setup failed',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor:
                  success ? const Color(0xFF4D4DCD) : const Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quick unlock disabled',
              style: TextStyle(fontFamily: 'Poppins')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Shows a bottom sheet prompting for the master password.
  void _promptMasterPassword({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Future<void> Function(String masterPassword) onSubmit,
  }) {
    final controller = TextEditingController();
    bool obscure = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    obscureText: obscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Master Password',
                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8EDF5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF4D4DCD), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF4D4DCD)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setSheetState(() => obscure = !obscure);
                        },
                      ),
                    ),
                    onSubmitted: isSubmitting
                        ? null
                        : (_) async {
                            if (controller.text.trim().isEmpty) return;
                            setSheetState(() => isSubmitting = true);
                            Navigator.of(ctx).pop();
                            await onSubmit(controller.text.trim());
                          },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (controller.text.trim().isEmpty) return;
                              setSheetState(() => isSubmitting = true);
                              Navigator.of(ctx).pop();
                              await onSubmit(controller.text.trim());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D4DCD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Displays the last sync time from the sync state stream.
class _SyncStatusTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStateAsync = ref.watch(syncStateProvider);

    final String statusText = syncStateAsync.when(
      data: (state) => switch (state) {
        SyncIdle(:final lastSyncAt) => lastSyncAt != null
            ? 'Last synced: ${_formatSyncTime(lastSyncAt)}'
            : 'Never synced',
        Syncing(:final pendingCount) => 'Syncing ($pendingCount pending)...',
        SyncError(:final message) => 'Sync error: $message',
      },
      loading: () => 'Checking sync status...',
      error: (e, _) => 'Sync status unavailable',
    );

    return ListTile(
      title: const Text('Sync Status'),
      subtitle: Text(statusText,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      leading: const Icon(Icons.cloud_done_outlined),
    );
  }

  String _formatSyncTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
