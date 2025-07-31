import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../logic/controllers/quick_unlock_setup_controller.dart';

/// A mandatory screen shown after the user's first successful login.
/// It forces the user to set up either a PIN or Biometric unlock method.
class SetupQuickUnlockScreen extends StatelessWidget {
  const SetupQuickUnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the dedicated controller for this screen.
    final QuickUnlockSetupController controller = Get.put(
      QuickUnlockSetupController(),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.shield_moon_outlined,
                size: 60,
                color: Get.theme.primaryColor,
              ),
              20.heightBox,
              'Set Up Quick Unlock'.text
                  .size(28)
                  .bold
                  .align(TextAlign.center)
                  .make(),
              15.heightBox,
              'For faster, secure access to your vault, please choose a quick unlock method. This is a mandatory one-time setup.'
                  .text
                  .size(16)
                  .align(TextAlign.center)
                  .gray500
                  .make(),
              40.heightBox,

              // The Biometrics button is only shown if the device supports it.
              Obx(() {
                if (!controller.isBiometricsAvailable.value) {
                  return const SizedBox.shrink();
                }
                return ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: 'Enable Biometric Unlock'.text.make(),
                  onPressed: controller.enableBiometrics,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              }),
              20.heightBox,

              // The PIN setup button
              ElevatedButton.icon(
                icon: const Icon(Icons.pin_outlined),
                label: 'Set a 6-Digit PIN'.text.make(),
                onPressed: controller.enablePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
