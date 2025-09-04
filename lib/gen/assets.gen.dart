// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart' as _lottie;

class $AssetsAnimationsGen {
  const $AssetsAnimationsGen();

  /// File path: assets/animations/ads_show.json
  LottieGenImage get adsShow =>
      const LottieGenImage('assets/animations/ads_show.json');

  /// File path: assets/animations/car_to_screen.json
  LottieGenImage get carToScreen =>
      const LottieGenImage('assets/animations/car_to_screen.json');

  /// File path: assets/animations/devices_sync_citadel.json
  LottieGenImage get devicesSyncCitadel =>
      const LottieGenImage('assets/animations/devices_sync_citadel.json');

  /// File path: assets/animations/face_id_citadel.json
  LottieGenImage get faceIdCitadel =>
      const LottieGenImage('assets/animations/face_id_citadel.json');

  /// File path: assets/animations/nepal_flag.json
  LottieGenImage get nepalFlag =>
      const LottieGenImage('assets/animations/nepal_flag.json');

  /// File path: assets/animations/red_car_fast.json
  LottieGenImage get redCarFast =>
      const LottieGenImage('assets/animations/red_car_fast.json');

  /// File path: assets/animations/shield_citadel.json
  LottieGenImage get shieldCitadel =>
      const LottieGenImage('assets/animations/shield_citadel.json');

  /// File path: assets/animations/splash.json
  LottieGenImage get splash =>
      const LottieGenImage('assets/animations/splash.json');

  /// File path: assets/animations/two_cars_j.json
  LottieGenImage get twoCarsJ =>
      const LottieGenImage('assets/animations/two_cars_j.json');

  /// List of all assets
  List<LottieGenImage> get values => [
    adsShow,
    carToScreen,
    devicesSyncCitadel,
    faceIdCitadel,
    nepalFlag,
    redCarFast,
    shieldCitadel,
    splash,
    twoCarsJ,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/citadel_logo.png
  AssetGenImage get citadelLogo =>
      const AssetGenImage('assets/images/citadel_logo.png');

  /// File path: assets/images/driver.png
  AssetGenImage get driver => const AssetGenImage('assets/images/driver.png');

  /// File path: assets/images/partner.png
  AssetGenImage get partner => const AssetGenImage('assets/images/partner.png');

  /// List of all assets
  List<AssetGenImage> get values => [citadelLogo, driver, partner];
}

class $AssetsVideoGen {
  const $AssetsVideoGen();

  /// File path: assets/video/splash.mp4
  String get splash => 'assets/video/splash.mp4';

  /// List of all assets
  List<String> get values => [splash];
}

class Assets {
  const Assets._();

  static const $AssetsAnimationsGen animations = $AssetsAnimationsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsVideoGen video = $AssetsVideoGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class LottieGenImage {
  const LottieGenImage(this._assetName, {this.flavors = const {}});

  final String _assetName;
  final Set<String> flavors;

  _lottie.LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    _lottie.FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    _lottie.LottieDelegates? delegates,
    _lottie.LottieOptions? options,
    void Function(_lottie.LottieComposition)? onLoaded,
    _lottie.LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, _lottie.LottieComposition?)?
    frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
    _lottie.LottieDecoder? decoder,
    _lottie.RenderCache? renderCache,
    bool? backgroundLoading,
  }) {
    return _lottie.Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
      decoder: decoder,
      renderCache: renderCache,
      backgroundLoading: backgroundLoading,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
