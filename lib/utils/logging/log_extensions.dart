import 'app_logger.dart';

extension LogX on Object {
  void logT([String? msg, dynamic error, StackTrace? st]) =>
      AppLogger.t(_fmt(msg), error: error, st: st);

  void logD([String? msg, dynamic error, StackTrace? st]) =>
      AppLogger.d(_fmt(msg), error: error, st: st);

  void logI([String? msg, dynamic error, StackTrace? st]) =>
      AppLogger.i(_fmt(msg), error: error, st: st);

  void logW([String? msg, dynamic error, StackTrace? st]) =>
      AppLogger.w(_fmt(msg), error: error, st: st);

  void logE([String? msg, dynamic error, StackTrace? st]) =>
      AppLogger.e(_fmt(msg), error: error, st: st);

  void logF([String? msg, dynamic error, StackTrace? st]) =>
      AppLogger.f(_fmt(msg), error: error, st: st);

  String _fmt(String? msg) => '$runtimeType: ${msg ?? ''}'.trim();
}

/// Optional: log directly from strings
extension StringLogX on String {
  void logD() => AppLogger.d(this);
  void logI() => AppLogger.i(this);
  void logW() => AppLogger.w(this);
  void logE([dynamic error, StackTrace? st]) =>
      AppLogger.e(this, error: error, st: st);
}
