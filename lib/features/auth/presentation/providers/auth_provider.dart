// File: lib/features/auth/presentation/providers/auth_provider.dart
// Auth state management using Riverpod
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../data/services/auth/auth_service.dart';
import '../../../../utils/exceptions/auth_exception.dart';

/// Auth UI state
class AuthState {
  final bool isLoadingLogin;
  final bool isLoadingSignUp;
  final bool isLoadingPin;
  final bool isLoadingBiometrics;
  final bool showPinAfterBioFailure;
  final int slidingIndex;
  final Map<String, bool> passwordVisibility;
  final String? errorMessage;

  const AuthState({
    this.isLoadingLogin = false,
    this.isLoadingSignUp = false,
    this.isLoadingPin = false,
    this.isLoadingBiometrics = false,
    this.showPinAfterBioFailure = false,
    this.slidingIndex = 0,
    this.passwordVisibility = const {
      'login': true,
      'master': true,
      'signUp': true,
      'masterLogin': true,
    },
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoadingLogin,
    bool? isLoadingSignUp,
    bool? isLoadingPin,
    bool? isLoadingBiometrics,
    bool? showPinAfterBioFailure,
    int? slidingIndex,
    Map<String, bool>? passwordVisibility,
    String? errorMessage,
  }) {
    return AuthState(
      isLoadingLogin: isLoadingLogin ?? this.isLoadingLogin,
      isLoadingSignUp: isLoadingSignUp ?? this.isLoadingSignUp,
      isLoadingPin: isLoadingPin ?? this.isLoadingPin,
      isLoadingBiometrics: isLoadingBiometrics ?? this.isLoadingBiometrics,
      showPinAfterBioFailure:
          showPinAfterBioFailure ?? this.showPinAfterBioFailure,
      slidingIndex: slidingIndex ?? this.slidingIndex,
      passwordVisibility: passwordVisibility ?? this.passwordVisibility,
      errorMessage: errorMessage,
    );
  }
}

/// Auth notifier managing login/signup/unlock flows
class AuthNotifier extends Notifier<AuthState> {
  // Text controllers managed outside Riverpod state (they are UI objects)
  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();
  final emailSignUpController = TextEditingController();
  final nameSignUpController = TextEditingController();
  final passwordSignUpController = TextEditingController();
  final masterPasswordController = TextEditingController();
  final pinController = TextEditingController();

  @override
  AuthState build() => const AuthState();

  AuthService get _authService => ref.read(authServiceProvider);

  void changeSlidingValue(int value) {
    state = state.copyWith(slidingIndex: value);
  }

  void togglePasswordVisibility(String key) {
    final vis = Map<String, bool>.from(state.passwordVisibility);
    if (vis.containsKey(key)) {
      vis[key] = !vis[key]!;
      state = state.copyWith(passwordVisibility: vis);
    }
  }

  Future<({bool success, String? error, bool needsVerification, String? email})>
      register() async {
    state = state.copyWith(isLoadingSignUp: true, errorMessage: null);
    try {
      final email = emailSignUpController.text.trim();
      await _authService.register(
        name: nameSignUpController.text.trim(),
        email: email,
        accountPassword: passwordSignUpController.text,
        masterPassword: masterPasswordController.text,
      );
      state = state.copyWith(isLoadingSignUp: false);
      return (
        success: true,
        error: null,
        needsVerification: true,
        email: email
      );
    } catch (e) {
      state = state.copyWith(
          isLoadingSignUp: false, errorMessage: e.toString());
      return (
        success: false,
        error: e.toString(),
        needsVerification: false,
        email: null
      );
    }
  }

  Future<({bool success, String? error, bool needsVerification, String? email})>
      login() async {
    state = state.copyWith(isLoadingLogin: true, errorMessage: null);
    try {
      await _authService.loginWithMasterPassword(
        email: emailLoginController.text.trim(),
        password: passwordLoginController.text,
        masterPassword: masterPasswordController.text,
      );

      // Unlock the session via the new SessionNotifier
      final sessionNotifier = ref.read(sessionProvider.notifier);
      await sessionNotifier.unlock(
        masterPasswordController.text,
        _authService.currentUser!.salt,
      );

      state = state.copyWith(isLoadingLogin: false);
      return (
        success: true,
        error: null,
        needsVerification: false,
        email: null
      );
    } on ClientException catch (e) {
      state = state.copyWith(isLoadingLogin: false);
      final friendlyError = AuthException.fromClientException(e);
      if (friendlyError.message.toLowerCase().contains('verify your email')) {
        return (
          success: false,
          error: friendlyError.message,
          needsVerification: true,
          email: emailLoginController.text.trim()
        );
      }
      return (
        success: false,
        error: friendlyError.message,
        needsVerification: false,
        email: null
      );
    } catch (e) {
      state = state.copyWith(isLoadingLogin: false, errorMessage: e.toString());
      return (
        success: false,
        error: 'An unexpected error occurred. Please contact support.',
        needsVerification: false,
        email: null
      );
    }
  }

  Future<bool> unlockWithPin() async {
    state = state.copyWith(isLoadingPin: true);
    try {
      final success = await _authService.unlockWithPin(pinController.text);
      state = state.copyWith(isLoadingPin: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoadingPin: false);
      return false;
    }
  }

  Future<bool> unlockWithBiometrics() async {
    state = state.copyWith(
        isLoadingBiometrics: true, showPinAfterBioFailure: false);
    try {
      final success = await _authService.unlockWithBiometrics();
      state = state.copyWith(isLoadingBiometrics: false);
      return success;
    } catch (e) {
      state = state.copyWith(
          isLoadingBiometrics: false, showPinAfterBioFailure: true);
      return false;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    if (email.isEmpty) return;
    await _authService.resendVerification(email);
  }

  void logout() {
    _authService.logout();
    ref.read(sessionProvider.notifier).lock();
  }

  void dispose() {
    emailLoginController.dispose();
    passwordLoginController.dispose();
    emailSignUpController.dispose();
    nameSignUpController.dispose();
    passwordSignUpController.dispose();
    masterPasswordController.dispose();
    pinController.dispose();
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
