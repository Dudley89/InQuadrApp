import 'package:flutter/foundation.dart';

enum LogLevel { info, warn, error }

class AppLogger {
  static void info(String message) => _log(LogLevel.info, message);
  static void warn(String message) => _log(LogLevel.warn, message);
  static void error(String message) => _log(LogLevel.error, message);

  static void _log(LogLevel level, String message) {
    debugPrint('[${level.name.toUpperCase()}] $message');
  }
}
