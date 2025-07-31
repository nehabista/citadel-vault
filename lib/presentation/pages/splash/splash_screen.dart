import 'package:citadel_password_manager/logic/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:video_player/video_player.dart';

/// Provides configuration options for the video splash screen.
/// Inspired by the flexible design of the Splash Master package.
class VideoConfig {
  const VideoConfig({
    this.playImmediately = true,
    this.looping = true,
    this.onControllerInitialized,
  });

  /// Whether the video should start playing as soon as it's loaded.
  final bool playImmediately;

  /// Whether the video should loop continuously.
  final bool looping;

  /// An optional callback that provides the initialized [VideoPlayerController].
  final Function(VideoPlayerController controller)? onControllerInitialized;
}

/// The very first screen the user sees.
/// It plays a video animation while the SplashController determines
/// the user's authentication state and routes them accordingly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.videoConfig = const VideoConfig()});

  final VideoConfig videoConfig;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // The SplashController handles all navigation logic.
    Get.put(SplashController());

    // Initialize the video player from the asset path.
    _videoController = VideoPlayerController.asset(
        'assets/video/splash.mp4', // IMPORTANT: Use your video path
      )
      ..initialize().then((_) {
        // This block runs once the video is loaded.
        if (!mounted) return;

        setState(() {}); // Rebuild the widget to show the video.

        // Pass the controller to the optional callback.
        widget.videoConfig.onControllerInitialized?.call(_videoController);

        // Apply configuration settings from the VideoConfig class.
        _videoController.setLooping(widget.videoConfig.looping);
        _videoController.setVolume(0.0); // Mute the video by default.

        // start after a short seconds
        if (widget.videoConfig.playImmediately) {
          _videoController.play();
        }
      });
  }

  @override
  void dispose() {
    // A small delay can prevent a flicker on dispose.
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _videoController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using ColoredBox as the root and SizedBox.shrink() for the loading state.
    return ColoredBox(
      color: Colors.white, // Match your brand's background color
      child: Center(
        child:
            _videoController.value.isInitialized
                ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: Container(
                    color: Colors.black, // Fallback color while loading
                    child: VideoPlayer(_videoController)),
                ).px(20)
                : const SizedBox.expand(),
      ),
    );
  }
}
