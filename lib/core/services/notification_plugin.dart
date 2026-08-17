import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Global holder for the local notifications plugin, set during app bootstrap.
class NotificationPlugin {
  /// Private constructor; access via [instance] or [getOrCreate].
  NotificationPlugin._();

  /// Shared plugin instance, initialized during bootstrap.
  static FlutterLocalNotificationsPlugin? instance;

  /// Android implementation of [instance], or null when unavailable.
  static AndroidFlutterLocalNotificationsPlugin? get android =>
      instance?.android;

  /// Returns the shared plugin, creating it when called from a background isolate.
  static FlutterLocalNotificationsPlugin getOrCreate() {
    return instance ??= FlutterLocalNotificationsPlugin();
  }

  /// Clears [instance] after a failed initialize so callers retry cleanly.
  static void clear() {
    instance = null;
  }
}

/// Android-specific implementation of a notifications plugin.
extension AndroidNotificationsPlugin on FlutterLocalNotificationsPlugin {
  /// Returns the Android plugin, or null on other platforms.
  AndroidFlutterLocalNotificationsPlugin? get android =>
      resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
}
