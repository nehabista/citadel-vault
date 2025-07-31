// File: lib/presentation/pages/auth/unlock_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../data/services/auth/local_auth_service.dart';
import '../../../logic/controllers/auth_controller.dart';
import '../../../logic/controllers/settings_controller.dart'; // To check available methods

class UnlockScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final SettingsController settingsController = Get.find();

  UnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.blue),
              20.heightBox,
              'Vault Locked'.text.size(28).bold.align(TextAlign.center).make(),
              40.heightBox,
              Obx(() {
                // Show different unlock options based on user's settings
                final unlockMethod =
                    settingsController.currentUnlockMethod.value;
                if (unlockMethod == UnlockMethod.biometrics) {
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    label: 'Unlock with Biometrics'.text.make(),
                    onPressed: authController.unlockWithBiometrics,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                }
                if (unlockMethod == UnlockMethod.pin) {
                  return Column(
                    children: [
                      TextField(
                        controller: authController.pinController,
                        decoration: const InputDecoration(
                          labelText: 'Enter PIN',
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                      ),
                      20.heightBox,
                      ElevatedButton(
                        onPressed: authController.unlockWithPin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: 'Unlock'.text.make(),
                      ),
                    ],
                  );
                }
                // Default to master password if no quick unlock is set
                return 'Please login with your master password.'.text
                    .align(TextAlign.center)
                    .make();
              }),
              20.heightBox,
              TextButton(
                onPressed: authController.logout,
                child: 'Logout'.text.red500.make(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
