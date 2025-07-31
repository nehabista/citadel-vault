// File: lib/presentation/pages/settings/settings_page.dart
import 'package:citadel_password_manager/logic/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../logic/controllers/settings_controller.dart';
import '../../../data/services/auth/local_auth_service.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.find();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            'Security'.text.bold.lg.make(),
            10.heightBox,
            if (controller.isBiometricsAvailable.value)
              SwitchListTile(
                title: 'Unlock with Biometrics'.text.make(),
                value:
                    controller.currentUnlockMethod.value ==
                    UnlockMethod.biometrics,
                onChanged: (bool value) {
                  if (value) {
                    // In a real app, you'd show a dialog to ask for the master password
                    // For simplicity, we'll assume it's available or ask for it here.
                    // controller.enableBiometrics("USER_MASTER_PASSWORD");
                    Get.snackbar(
                      'TODO',
                      'Prompt for master password to enable biometrics.',
                    );
                  } else {
                    controller.disableQuickUnlock();
                  }
                },
              ),
            SwitchListTile(
              title: 'Unlock with PIN'.text.make(),
              value: controller.currentUnlockMethod.value == UnlockMethod.pin,
              onChanged: (bool value) {
                if (value) {
                  // TODO: Show a dialog to set up a new PIN and confirm master password
                  Get.snackbar('TODO', 'Show dialog to create a PIN.');
                } else {
                  controller.disableQuickUnlock();
                }
              },
            ),
            ListTile(
              title: 'Logout'.text.red500.make(),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () => Get.find<AuthController>().logout(),
            ),
          ],
        ),
      ),
    );
  }
}
