// File: lib/presentation/pages/settings/settings_page.dart
import 'package:citadel_password_manager/logic/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../features/autofill/presentation/widgets/autofill_settings_tile.dart';
import '../../../features/autofill/presentation/widgets/clipboard_settings_tile.dart';
import '../../../logic/controllers/settings_controller.dart';
import '../../../data/services/auth/local_auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  final SettingsController controller = Get.find();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  Get.snackbar('TODO', 'Show dialog to create a PIN.');
                } else {
                  controller.disableQuickUnlock();
                }
              },
            ),
            20.heightBox,
            const Text(
              'Autofill',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            10.heightBox,
            const AutofillSettingsTile(),
            const ClipboardSettingsTile(),
            20.heightBox,
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
