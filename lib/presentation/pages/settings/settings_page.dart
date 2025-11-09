// File: lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/sync/sync_state.dart';
import '../../../data/services/auth/local_auth_service.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/autofill/presentation/providers/autofill_provider.dart';
import '../../../features/autofill/presentation/providers/clipboard_provider.dart';
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
    final autofillStatusAsync = ref.watch(autofillStatusProvider);
    final clipboardTimeoutAsync = ref.watch(clipboardTimeoutProvider);
    final syncStateAsync = ref.watch(syncStateProvider);

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
              onTap: () {
                final openSettings = ref.read(openAutofillSettingsProvider);
                openSettings();
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
              onTap: () {
                // TODO: navigate to travel mode page when available
              },
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
              onTap: () {
                // TODO: navigate to SSH key page when available
              },
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
          showCitadelSnackBar(context, 'PIN unlock enabled',
              type: SnackBarType.success);
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
