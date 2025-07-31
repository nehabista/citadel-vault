import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  // Single, shared instance
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      stackTraceBeginIndex: 0,
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
      levelColors: {
        /*
          0:  Black,      8:  Grey
          1:  Red,        9:  Red Ascend
          2:  Green,      10: Green Ascend
          3:  Yellow      11: Yellow Ascend
          4:  Blue        12: Blue Ascend
          5:  Purple      13: Purple Ascend
          6:  Turquoise   14: Turquoise Ascend
          7:  White       15: Bright White
        */
        Level.trace: AnsiColor.fg(11),
        Level.debug: AnsiColor.fg(8),
        Level.info: AnsiColor.fg(2),
        Level.warning: AnsiColor.fg(5),
        Level.error: AnsiColor.fg(9),
        Level.fatal: AnsiColor.fg(1),
      },
    ),
    output:
        DeveloperConsoleOutput(), // or MultiOutput if you add file logging later
    filter: _ProdFilter(), // Only warn+ in release
  );

  /// Access to raw logger if you need the full API
  static Logger get raw => _logger;

  /// Convenience shorthands
  static void t(dynamic msg, {dynamic error, StackTrace? st}) =>
      _logger.t(msg, error: error, stackTrace: st);
  static void d(dynamic msg, {dynamic error, StackTrace? st}) =>
      _logger.d(msg, error: error, stackTrace: st);
  static void i(dynamic msg, {dynamic error, StackTrace? st}) =>
      _logger.i(msg, error: error, stackTrace: st);
  static void w(dynamic msg, {dynamic error, StackTrace? st}) =>
      _logger.w(msg, error: error, stackTrace: st);
  static void e(dynamic msg, {dynamic error, StackTrace? st}) =>
      _logger.e(msg, error: error, stackTrace: st);
  static void f(dynamic msg, {dynamic error, StackTrace? st}) =>
      _logger.f(msg, error: error, stackTrace: st);
}

/// Log all levels in debug; in release only WARNING and above.
class _ProdFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return kDebugMode || event.level.index >= Level.warning.index;
  }
}

class DeveloperConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();
    event.lines.forEach(buffer.writeln);
    if (kDebugMode) {
      log(buffer.toString());
    }
  }
}
