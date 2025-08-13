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
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/video/splash.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
      });

    // Navigate after splash duration
    _setupStartupFlow();
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
        // User is logged in, go to unlock screen
        if (mounted) context.go(AppRoutes.home);
      } else {
        if (mounted) context.go(AppRoutes.login);
      }
    } catch (_) {
      // PocketBase not initialized yet, go to login
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _videoController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: _videoController.value.isInitialized
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: Container(
                    color: Colors.black,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
            : const SizedBox.expand(),
      ),
    );
  }
}
