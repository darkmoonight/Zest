import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest/data/models/db.dart' as db;
import 'package:zest/i18n/tr.dart';

/// Android notification channel settings for a todo [db.Priority].
class NotificationChannelConfig {
  /// Creates channel metadata used at registration and show time.
  const NotificationChannelConfig({
    required this.id,
    required this.nameKey,
    required this.importance,
    required this.enableVibration,
    required this.playSound,
    this.vibrationPattern,
  });

  /// Stable Android channel id (ASCII).
  final String id;

  /// Slang key for the user-visible channel name.
  final String nameKey;

  /// Default importance before user overrides in system settings.
  final Importance importance;

  /// Whether the channel vibrates by default.
  final bool enableVibration;

  /// Whether the channel plays sound by default.
  final bool playSound;

  /// Optional vibration pattern; null uses system default.
  final Int64List? vibrationPattern;

  /// Localized channel name for [nameKey].
  String get localizedName => nameKey.tr;
}

/// Returns the Android channel config for [priority].
NotificationChannelConfig notificationChannelForPriority(db.Priority priority) {
  return switch (priority) {
    db.Priority.high => NotificationChannelConfig(
      id: 'zest_priority_high',
      nameKey: 'notificationChannelHigh',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
    ),
    db.Priority.medium => NotificationChannelConfig(
      id: 'zest_priority_medium',
      nameKey: 'notificationChannelMedium',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList([0, 250, 150, 250]),
    ),
    db.Priority.low => NotificationChannelConfig(
      id: 'zest_priority_low',
      nameKey: 'notificationChannelLow',
      importance: Importance.low,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList([0, 100]),
    ),
    db.Priority.none => const NotificationChannelConfig(
      id: 'zest_priority_none',
      nameKey: 'notificationChannelNone',
      importance: Importance.min,
      enableVibration: false,
      playSound: false,
    ),
  };
}

/// All priority channel configs in stable order.
List<NotificationChannelConfig> get allNotificationChannelConfigs => [
  notificationChannelForPriority(db.Priority.high),
  notificationChannelForPriority(db.Priority.medium),
  notificationChannelForPriority(db.Priority.low),
  notificationChannelForPriority(db.Priority.none),
];

/// Registers Android notification channels for each todo priority.
Future<void> registerAndroidNotificationChannels(
  FlutterLocalNotificationsPlugin plugin,
) async {
  if (defaultTargetPlatform != TargetPlatform.android) return;

  final android = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android == null) return;

  try {
    for (final config in allNotificationChannelConfigs) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          config.id,
          config.localizedName,
          importance: config.importance,
          playSound: config.playSound,
          enableVibration: config.enableVibration,
          vibrationPattern: config.vibrationPattern,
        ),
      );
    }
  } catch (e) {
    debugPrint('Error registering notification channels: $e');
  }
}
