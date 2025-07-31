import 'dart:async';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../data/services/api/pocketbase_service.dart';
import '../../data/services/auth/auth_service.dart';
import '../../routing/route_names.dart';
import '../local_storage.dart';

/// SplashController handles both onboarding status and authentication routing logic.
class SplashController extends GetxController {
  final PocketBaseService _pocketBaseService = Get.find();
    StreamSubscription<AuthStoreEvent>? _authSubscription;

  @override
  void onReady() {
    super.onReady();
    _setupStartupFlow();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  /// Orchestrates the entire splash startup logic with onboarding and auth checks.
  Future<void> _setupStartupFlow() async {
    // Let the splash video play for a short duration before transitioning.
    await Future.delayed(const Duration(seconds: 4));

    final hasCompletedOnboarding =
        await LocalStorageSharedPref.getOnboardingStatus();

    if (!hasCompletedOnboarding) {
      // Navigate to onboarding screen if it's not completed.
      Get.offAllNamed(AppRoutes.ONBOARDING);
      return;
    }

    // Set up the auth listener for real-time changes.
    _authSubscription = _pocketBaseService.authState.listen((event) {
      _handleAuthState(event.record);
    });

    // Also check the current auth state immediately.
    _handleAuthState(_pocketBaseService.client.authStore.record);
  }

  /// Determines routing based on current user's auth state.
  void _handleAuthState(dynamic user) {
    // Keep a small delay to prevent visual flicker during transition.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (user is RecordModel && Get.isPrepared<AuthService>()) {
        Get.find<AuthService>().loadCurrentUser();
        Get.offAllNamed(AppRoutes.UNLOCK);
      } else {
        Get.offAllNamed(AppRoutes.AUTH);
      }
    });
  }
}
