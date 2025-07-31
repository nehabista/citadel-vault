// File: lib/logic/controllers/auth_controller.dart
import 'dart:developer';

import 'package:citadel_password_manager/presentation/pages/auth/verification_pending_screen.dart';
import 'package:citadel_password_manager/routing/route_names.dart';
import 'package:citadel_password_manager/utils/exceptions/auth_exception.dart';
import 'package:citadel_password_manager/utils/exceptions/biometric_auth_exception.dart';
import 'package:citadel_password_manager/utils/logging/app_logger.dart';
import 'package:citadel_password_manager/utils/logging/log_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../data/services/auth/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();
  static AuthController instance = Get.find();
  final RxBool showPinAfterBioFailure = false.obs;
  final formKeyLogin = GlobalKey<FormState>();
  final RxBool isLoadingForLogin = false.obs;
  final RxBool isLoadingForSignUp = false.obs;
  final RxBool isLoadingPin = false.obs;
  final RxBool isLoadingBiometrics = false.obs;

  final RxMap<String, bool> passwordVisibility =
      {'login': true, 'master': true, 'signUp': true, 'masterLogin': true}.obs;

  final sliding = 0.obs;
  final emailControllerForLogin = TextEditingController();
  final passwordControllerForLogin = TextEditingController();
  final emailControllerForSignUp = TextEditingController();
  final nameControllerForSignUp = TextEditingController();
  final passwordControllerForSignUp = TextEditingController();
  final masterPasswordController = TextEditingController();

  final pinController = TextEditingController();
  final PageController pageController = PageController();

  @override
  void onClose() {
    emailControllerForLogin.dispose();
    passwordControllerForLogin.dispose();
    emailControllerForSignUp.dispose();
    nameControllerForSignUp.dispose();
    passwordControllerForSignUp.dispose();
    masterPasswordController.dispose();
    pinController.dispose();
    pageController.dispose();
    super.onClose();
  }

  void changeSlidingValue(int value) {
    sliding.value = value;
  }

  /// Toggles the visibility of a specific password field.
  void togglePasswordVisibility(String key) {
    if (passwordVisibility.containsKey(key)) {
      passwordVisibility[key] = !passwordVisibility[key]!;
    }
  }

  Future<void> register() async {
    isLoadingForSignUp.value = true;
    try {
      final email = emailControllerForSignUp.text.trim();
      await _authService.register(
        name: nameControllerForSignUp.text.trim(),
        email: email,
        accountPassword: passwordControllerForSignUp.text,
        masterPassword: masterPasswordController.text,
      );
      Get.to(() => VerificationPendingScreen(email: email));
    } catch (e) {
      log(e.toString());
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingForSignUp.value = false;
    }
  }

  Future<void> login() async {
    isLoadingForLogin.value = true;
    try {
      await _authService.loginWithMasterPassword(
        email: emailControllerForLogin.text.trim(),
        password: passwordControllerForLogin.text,
        masterPassword: masterPasswordController.text,
      );
      Get.offAllNamed(AppRoutes.HOME);
    } on ClientException catch (e) {
      isLoadingForLogin.value = false;

      final friendlyError = AuthException.fromClientException(e);

      if (friendlyError.message.toLowerCase().contains('verify your email')) {
        Get.to(
          () => VerificationPendingScreen(
            email: emailControllerForLogin.text.trim(),
          ),
        );
        return;
      }
      Get.snackbar('Login Failed', friendlyError.message);
    } catch (e) {
      isLoadingForLogin.value = false;
      AppLogger.i('Auth success for ${emailControllerForLogin.text.trim()}');
      e.logE("Login failed with error", e.toString(), StackTrace.current);
      Get.snackbar(
        'Login Failed',
        "An unexpected error occurred. Please contact support.",
      );
    } finally {
      isLoadingForLogin.value = false;
    }
  }

  Future<void> unlockWithPin() async {
    isLoadingPin.value = true;
    try {
      final success = await _authService.unlockWithPin(pinController.text);
      if (success) {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      } else {
        Get.snackbar('Unlock Failed', 'Incorrect PIN.');
      }
    } catch (e) {
      Get.snackbar('Unlock Failed', e.toString());
    } finally {
      isLoadingPin.value = false;
    }
  }

  Future<void> unlockWithBiometrics() async {
    isLoadingBiometrics.value = true;
    // Reset the fallback state on each attempt.
    showPinAfterBioFailure.value = false;
    try {
      final success = await _authService.unlockWithBiometrics();
      if (success) {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      }
      // No snackbar on user cancellation.
    } on BiometricLockoutException {
      // This is the crucial fallback logic.
      Get.snackbar(
        'Biometrics Locked',
        'Too many attempts. Please use your PIN.',
      );
      showPinAfterBioFailure.value = true;
    } catch (e) {
      Get.snackbar('Unlock Failed', e.toString());
    } finally {
      isLoadingBiometrics.value = false;
    }
  }

  /// New method to handle resending the verification email.
  Future<void> resendVerificationEmail(String email) async {
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email field cannot be empty.');
      return;
    }
    try {
      await _authService.resendVerification(email);
      Get.snackbar(
        'Success',
        'Verification email sent to $email.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not send verification email. Please try again.',
      );
    }
  }

  void logout() {
    _authService.logout();
    Get.offAllNamed(AppRoutes.AUTH);
  }
}
