import 'package:citadel_password_manager/routing/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth/auth_service.dart';
import '../../data/services/auth/local_auth_service.dart';

/// Manages the logic for the mandatory quick unlock setup screen.
/// This version aligns with the mutually exclusive PIN/Biometric model.
class QuickUnlockSetupController extends GetxController {
  final LocalAuthService _localAuthService = Get.find();
  final AuthService _authService = Get.find();

  // The master password passed from the login screen.
  late final String _masterPassword;

  final RxBool isBiometricsAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Safely receive the master password argument from the previous screen.
    if (Get.arguments is String && (Get.arguments as String).isNotEmpty) {
      _masterPassword = Get.arguments;
    } else {
      // This is a critical fallback. If the password isn't passed, the user
      // cannot complete the setup. We must send them back to log in again.
      Get.snackbar(
        'Setup Error',
        'Could not retrieve master password. Please log in again.',
      );
      Get.offAllNamed(AppRoutes.AUTH);
    }
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    isBiometricsAvailable.value = await _localAuthService.canUseBiometrics();
  }

  /// Handles the "Enable Biometrics" flow.
  Future<void> enableBiometrics() async {
    final success = await _localAuthService.enableBiometricUnlock(
      _masterPassword,
    );
    if (success) {
      await _authService.markQuickUnlockAsComplete();
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else {
      Get.snackbar(
        'Setup Failed',
        'Could not enable biometric unlock. Please try again.',
      );
    }
  }

  /// Handles the "Set a PIN" flow.
  Future<void> enablePin() async {
    // We need to ask the user to create a PIN.
    final newPin = await _askForNewPin();
    if (newPin == null || newPin.isEmpty) return;

    await _localAuthService.enablePinUnlock(newPin, _masterPassword);
    await _authService.markQuickUnlockAsComplete();
    Get.offAllNamed(AppRoutes.DASHBOARD);
  }

  // --- UI Helper Dialog for PIN creation ---

  Future<String?> _askForNewPin() async {
    // In a production app, this would be a dedicated screen with PIN confirmation.
    final pinController = TextEditingController();
    return Get.dialog<String>(
      AlertDialog(
        title: const Text('Create a 6-Digit PIN'),
        content: TextField(
          controller: pinController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length == 6) {
                Get.back(result: pinController.text);
              } else {
                Get.snackbar('Invalid PIN', 'PIN must be exactly 6 digits.');
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }
}
