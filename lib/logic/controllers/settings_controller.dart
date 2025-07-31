// File: lib/logic/controllers/settings_controller.dart
import 'package:get/get.dart';
import '../../data/services/auth/local_auth_service.dart';

class SettingsController extends GetxController {
  final LocalAuthService _localAuthService = Get.find<LocalAuthService>();

  final Rx<UnlockMethod> currentUnlockMethod = UnlockMethod.masterPassword.obs;
  final Rx<bool> isBiometricsAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkCurrentSettings();
  }

  Future<void> checkCurrentSettings() async {
    isBiometricsAvailable.value = await _localAuthService.canUseBiometrics();
    currentUnlockMethod.value = await _localAuthService.getSavedUnlockMethod();
  }

  Future<void> enableBiometrics(String masterPassword) async {
    final success = await _localAuthService.enableBiometricUnlock(
      masterPassword,
    );
    if (success) {
      currentUnlockMethod.value = UnlockMethod.biometrics;
      Get.snackbar('Success', 'Biometric unlock enabled.');
    } else {
      Get.snackbar('Failed', 'Could not enable biometric unlock.');
    }
  }

  Future<void> enablePin(String newPin, String masterPassword) async {
    await _localAuthService.enablePinUnlock(newPin, masterPassword);
    currentUnlockMethod.value = UnlockMethod.pin;
    Get.snackbar('Success', 'PIN unlock enabled.');
  }

  Future<void> disableQuickUnlock() async {
    await _localAuthService.disableQuickUnlock();
    currentUnlockMethod.value = UnlockMethod.masterPassword;
    Get.snackbar('Success', 'Quick unlock disabled.');
  }
}
