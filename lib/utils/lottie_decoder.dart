import 'package:lottie/lottie.dart';

class LottieDecode {
  static Future<LottieComposition?> customDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(bytes, filePicker: (files) {
      for (final f in files) {
        if (f.name.startsWith('animations/') && f.name.endsWith('.json')) {
          return f;
        }
      }
      return null;
    });
  }
}
