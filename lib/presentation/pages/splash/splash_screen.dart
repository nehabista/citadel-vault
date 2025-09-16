// File: lib/presentation/pages/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/providers/core_providers.dart';
import '../../../logic/local_storage.dart';
import '../../../routing/app_router.dart';

/// The very first screen the user sees.
/// Plays a video animation while determining the user's auth state
/// and routes them accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _setupStartupFlow();
  }

  Future<void> _initVideo() async {
    try {
      final controller =
          VideoPlayerController.asset('assets/video/splash.mp4');
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      _videoController = controller;
      controller.setLooping(true);
      controller.setVolume(0.0);
      controller.play();
      setState(() => _videoInitialized = true);
    } catch (_) {
      // Video player unavailable (simulator, missing asset, platform issue)
      // Gracefully fall back to static splash
    }
  }

  Future<void> _setupStartupFlow() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final hasCompletedOnboarding =
        await LocalStorageSharedPref.getOnboardingStatus();

    if (!hasCompletedOnboarding) {
      if (mounted) context.go(AppRoutes.onboarding);
      return;
    }

    // Check PocketBase auth state
    try {
      final pbService = ref.read(pocketBaseServiceProvider);
      if (pbService.client.authStore.isValid) {
        // Load the current user so AuthService.currentUser is available
        ref.read(authServiceProvider).loadCurrentUser();

        // Check if user has set up PIN/biometric quick unlock
        final localAuth = ref.read(localAuthServiceProvider);
        final hasQuickUnlock = await localAuth.hasQuickUnlockSetup();

        if (hasQuickUnlock) {
          // User has PIN/biometric set up -> go to PIN/biometric unlock
          if (mounted) context.go(AppRoutes.unlock);
        } else {
          // No PIN/biometric, but PB session is valid.
          // Go to unlock screen which will show master password field
          // instead of full login (email+password+master).
          if (mounted) context.go(AppRoutes.unlock);
        }
      } else {
        if (mounted) context.go(AppRoutes.login);
      }
    } catch (_) {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: controller != null && _videoInitialized
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: Container(
                    color: Colors.black,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 80,
                    color: const Color(0xFF4D4DCD),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Citadel',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4D4DCD),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
