import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Global holder for the local notifications plugin, set during app bootstrap.
class NotificationPlugin {
  /// Private constructor; access via [instance] or [getOrCreate].
  NotificationPlugin._();

  /// Shared plugin instance, initialized during bootstrap.
  static FlutterLocalNotificationsPlugin? instance;

  /// Returns the shared plugin, creating it when called from a background isolate.
  static FlutterLocalNotificationsPlugin getOrCreate() {
    return instance ??= FlutterLocalNotificationsPlugin();
  }
}
