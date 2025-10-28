import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../providers/travel_mode_providers.dart';

/// Settings toggle widget for activating/deactivating travel mode.
///
/// Shows a SwitchListTile that:
/// - On toggle ON: shows a red-accent warning dialog (D-18)
/// - On toggle OFF: requires master password re-entry (D-03)
class TravelModeToggle extends ConsumerWidget {
  const TravelModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travelModeAsync = ref.watch(travelModeActiveProvider);
    final isActive = travelModeAsync.value ?? false;

    return SwitchListTile(
      title: const Text(
        'Travel Mode',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        isActive
            ? 'Active -- hidden vaults removed from device'
            : 'Hide sensitive vaults when crossing borders',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: isActive ? Colors.red.shade400 : Colors.grey.shade500,
        ),
      ),
      secondary: Icon(
        Icons.flight_takeoff,
        color: isActive ? Colors.red.shade400 : const Color(0xFF4D4DCD),
      ),
      value: isActive,
      activeTrackColor: Colors.red.shade300,
      activeThumbColor: Colors.red.shade600,
      onChanged: (value) {
        if (value) {
          _showActivateWarning(context, ref);
        } else {
          _showDeactivateDialog(context, ref);
        }
      },
    );
  }

  /// Shows a warning AlertDialog with red accent before activating travel mode.
  /// Per D-18: red accent warning.
  void _showActivateWarning(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'Activate Travel Mode',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'This will remove hidden vaults from this device. '
          'They remain safe on the server and will be restored '
          'when you deactivate travel mode.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _activateTravelMode(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Activate',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Activate travel mode and show feedback.
  Future<void> _activateTravelMode(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(travelModeServiceProvider);
      await service.activate();
      ref.invalidate(travelModeActiveProvider);
      if (context.mounted) {
        showCitadelSnackBar(context, 'Travel mode activated',
            type: SnackBarType.success);
      }
    } catch (e) {
      if (context.mounted) {
        showCitadelSnackBar(context, 'Failed to activate travel mode: $e',
            type: SnackBarType.error);
      }
    }
  }

  /// Shows a master password re-entry dialog before deactivating travel mode.
  /// Per D-03: master password required for deactivation.
  void _showDeactivateDialog(BuildContext context, WidgetRef ref) {
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
                  const Text(
                    'Deactivate Travel Mode',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your master password to restore hidden vaults',
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
                            await _verifyAndDeactivate(
                              context,
                              ref,
                              controller.text.trim(),
                            );
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
                              await _verifyAndDeactivate(
                                context,
                                ref,
                                controller.text.trim(),
                              );
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
                              'Deactivate & Restore',
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

  /// Verify the master password matches the session key, then deactivate.
  Future<void> _verifyAndDeactivate(
    BuildContext context,
    WidgetRef ref,
    String masterPassword,
  ) async {
    try {
      // Verify master password by attempting to derive key and comparing
      // with the current session key.
      final session = ref.read(sessionProvider);
      if (session is! Unlocked) {
        if (context.mounted) {
          showCitadelSnackBar(context, 'Session is locked',
              type: SnackBarType.error);
        }
        return;
      }

      // Derive key from the entered password to verify it matches
      final crypto = ref.read(cryptoEngineProvider);
      final settingsDao = ref.read(appDatabaseProvider).settingsDao;
      final saltB64 = await settingsDao.getSetting('vault_salt');
      if (saltB64 == null) {
        if (context.mounted) {
          showCitadelSnackBar(context, 'Unable to verify password',
              type: SnackBarType.error);
        }
        return;
      }

      final saltBytes = Uint8List.fromList(base64.decode(saltB64));
      final derivedKey = await crypto.deriveKey(masterPassword, saltBytes);
      final derivedBytes = await derivedKey.extractBytes();

      // Compare derived key with session key
      if (!_constantTimeEquals(derivedBytes, session.vaultKey)) {
        if (context.mounted) {
          showCitadelSnackBar(context, 'Incorrect master password',
              type: SnackBarType.error);
        }
        return;
      }

      // Password verified -- deactivate travel mode
      final service = ref.read(travelModeServiceProvider);
      await service.deactivate();
      ref.invalidate(travelModeActiveProvider);
      if (context.mounted) {
        showCitadelSnackBar(
          context,
          'Travel mode deactivated -- restoring vaults...',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCitadelSnackBar(context, 'Failed to deactivate: $e',
            type: SnackBarType.error);
      }
    }
  }

  /// Constant-time comparison to prevent timing attacks.
  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

}
