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
  /// Defaults to true.
  final bool playImmediately;

  /// Whether the video should loop continuously.
  /// Defaults to true.
  final bool looping;

  /// An optional callback that provides the initialized [VideoPlayerController].
  /// This can be used for advanced control if needed.
  final Function(VideoPlayerController controller)? onControllerInitialized;
}
