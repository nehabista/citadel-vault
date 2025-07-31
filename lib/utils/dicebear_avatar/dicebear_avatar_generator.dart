class DiceBearAvatarGenerator {
  final String style;
  final Map<String, String> _params = {};

  DiceBearAvatarGenerator({required String seed, this.style = 'thumbs'}) {
    _params['seed'] = seed;
  }

  DiceBearAvatarGenerator setFlip(bool value) {
    _params['flip'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setRotate(int degree) {
    _params['rotate'] = degree.toString();
    return this;
  }

  DiceBearAvatarGenerator setScale(int scale) {
    _params['scale'] = scale.toString();
    return this;
  }

  DiceBearAvatarGenerator setRadius(int radius) {
    _params['radius'] = radius.toString();
    return this;
  }

  DiceBearAvatarGenerator setSize(int size) {
    _params['size'] = size.toString();
    return this;
  }

  DiceBearAvatarGenerator setBackgroundColor(List<String> colors) {
    _params['backgroundColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setBackgroundType(List<String> types) {
    _params['backgroundType'] = types.join(',');
    return this;
  }

  DiceBearAvatarGenerator setBackgroundRotation(int min, int max) {
    _params['backgroundRotation'] = '$min,$max';
    return this;
  }

  DiceBearAvatarGenerator setTranslateX(int value) {
    _params['translateX'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setTranslateY(int value) {
    _params['translateY'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setClip(bool value) {
    _params['clip'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setRandomizeIds(bool value) {
    _params['randomizeIds'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setEyes(List<String> variants) {
    _params['eyes'] = variants.join(',');
    return this;
  }

  DiceBearAvatarGenerator setEyesColor(List<String> colors) {
    _params['eyesColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setMouth(List<String> variants) {
    _params['mouth'] = variants.join(',');
    return this;
  }

  DiceBearAvatarGenerator setMouthColor(List<String> colors) {
    _params['mouthColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setFace(List<String> variants) {
    _params['face'] = variants.join(',');
    return this;
  }

  DiceBearAvatarGenerator setFaceOffsetX(int min, int max) {
    _params['faceOffsetX'] = '$min,$max';
    return this;
  }

  DiceBearAvatarGenerator setFaceOffsetY(int min, int max) {
    _params['faceOffsetY'] = '$min,$max';
    return this;
  }

  DiceBearAvatarGenerator setFaceRotation(int min, int max) {
    _params['faceRotation'] = '$min,$max';
    return this;
  }

  DiceBearAvatarGenerator setShape(List<String> variants) {
    _params['shape'] = variants.join(',');
    return this;
  }

  DiceBearAvatarGenerator setShapeColor(List<String> colors) {
    _params['shapeColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setShapeOffsetX(int min, int max) {
    _params['shapeOffsetX'] = '$min,$max';
    return this;
  }

  DiceBearAvatarGenerator setShapeOffsetY(int min, int max) {
    _params['shapeOffsetY'] = '$min,$max';
    return this;
  }

  DiceBearAvatarGenerator setShapeRotation(int min, int max) {
    _params['shapeRotation'] = '$min,$max';
    return this;
  }

  DiceBearAvatarGenerator setTop(List<String> styles) {
    _params['top'] = styles.join(',');
    return this;
  }

  DiceBearAvatarGenerator setEyebrows(List<String> styles) {
    _params['eyebrows'] = styles.join(',');
    return this;
  }

  DiceBearAvatarGenerator setFacialHair(List<String> styles) {
    _params['facialHair'] = styles.join(',');
    return this;
  }

  DiceBearAvatarGenerator setFacialHairColor(List<String> colors) {
    _params['facialHairColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setFacialHairProbability(int value) {
    _params['facialHairProbability'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setHatColor(List<String> colors) {
    _params['hatColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setHairColor(List<String> colors) {
    _params['hairColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setNose(List<String> types) {
    _params['nose'] = types.join(',');
    return this;
  }

  DiceBearAvatarGenerator setSkinColor(List<String> colors) {
    _params['skinColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setClothing(List<String> types) {
    _params['clothing'] = types.join(',');
    return this;
  }

  DiceBearAvatarGenerator setClothesColor(List<String> colors) {
    _params['clothesColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setClothingGraphic(List<String> graphics) {
    _params['clothingGraphic'] = graphics.join(',');
    return this;
  }

  DiceBearAvatarGenerator setAccessories(List<String> items) {
    _params['accessories'] = items.join(',');
    return this;
  }

  DiceBearAvatarGenerator setAccessoriesColor(List<String> colors) {
    _params['accessoriesColor'] = colors.join(',');
    return this;
  }

  DiceBearAvatarGenerator setAccessoriesProbability(int value) {
    _params['accessoriesProbability'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setTopProbability(int value) {
    _params['topProbability'] = value.toString();
    return this;
  }

  DiceBearAvatarGenerator setStyleType(String value) {
    _params['style'] = value;
    return this;
  }

  String buildUrl() {
    final base = 'https://api.dicebear.com/9.x/$style/svg';
    if (_params.isEmpty) return base;

    final query = _params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
    return '$base?$query';
  }

  String buildPngUrl() {
    return buildUrl().replaceFirst('/svg', '/png');
  }

  String? getSeed() => _params['seed'];
}
