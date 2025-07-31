// File: lib/logic/bindings/initial_bindings.dart
import 'package:citadel_password_manager/logic/controllers/home_page_controller.dart';
import 'package:citadel_password_manager/logic/controllers/splash_controller.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/vault_controller.dart';

/// Binds all the controllers to the GetX dependency management system.
/// This makes them available to any UI that needs them.
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => VaultController());
    Get.lazyPut(() => HomePageController());
    Get.lazyPut(() => SettingsController());
  }
}
