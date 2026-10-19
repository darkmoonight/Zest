import 'package:flutter/foundation.dart';

/// Debug-only logging. No-ops in release/profile so logcat/os_log stay clean.
abstract final class AppLog {
  /// Prints [message] when [kDebugMode] is true.
  static void d(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
