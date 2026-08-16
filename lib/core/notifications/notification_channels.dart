import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest/data/models/db.dart' as db;
import 'package:zest/i18n/tr.dart';

/// Stable Android notification channel ids for each [db.Priority].
abstract final class NotificationChannelIds {
  /// Channel id prefix shared by all priority channels.
  static const String prefix = 'zest_priority_';

  /// High-priority reminders channel.
  static const String high = '${prefix}high';

  /// Medium-priority reminders channel.
  static const String medium = '${prefix}medium';

  /// Low-priority reminders channel.
  static const String low = '${prefix}low';

  /// No-priority / silent reminders channel.
  static const String none = '${prefix}none';
}

/// Android notification channel metadata for a list item [db.Priority].
///
/// Defaults (importance, sound, vibration) apply only until the user changes
/// them in system settings. After creation, open system UI via
/// [NotificationSettingsLauncher] to let the user edit a channel.
class NotificationChannelConfig {
  /// Creates channel metadata used at registration and show time.
  const NotificationChannelConfig({
    required this.id,
    required this.priority,
    required this.importance,
    required this.enableVibration,
    required this.playSound,
    this.vibrationPattern,
  });

  /// Stable Android channel id (ASCII), see [NotificationChannelIds].
  final String id;

  /// Item priority this channel is bound to.
  final db.Priority priority;

  /// Default importance before user overrides in system settings.
  final Importance importance;

  /// Whether the channel vibrates by default.
  final bool enableVibration;

  /// Whether the channel plays sound by default.
  final bool playSound;

  /// Optional vibration pattern; null uses system default.
  final Int64List? vibrationPattern;

  /// Slang key for the user-visible channel name.
  String get nameKey => switch (priority) {
    db.Priority.high => 'notificationChannelHigh',
    db.Priority.medium => 'notificationChannelMedium',
    db.Priority.low => 'notificationChannelLow',
    db.Priority.none => 'notificationChannelNone',
  };

  /// Slang key for a short default-importance subtitle.
  String get hintKey => switch (priority) {
    db.Priority.high => 'notificationChannelHintHigh',
    db.Priority.medium => 'notificationChannelHintMedium',
    db.Priority.low => 'notificationChannelHintLow',
    db.Priority.none => 'notificationChannelHintNone',
  };

  /// Localized channel name for [nameKey].
  String get localizedName => nameKey.tr;

  /// Localized default-importance hint for [hintKey].
  String get localizedHint => hintKey.tr;
}

/// Returns the Android channel config for [priority].
NotificationChannelConfig notificationChannelForPriority(db.Priority priority) {
  return switch (priority) {
    db.Priority.high => NotificationChannelConfig(
      id: NotificationChannelIds.high,
      priority: db.Priority.high,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(const [0, 400, 200, 400]),
    ),
    db.Priority.medium => NotificationChannelConfig(
      id: NotificationChannelIds.medium,
      priority: db.Priority.medium,
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(const [0, 250, 150, 250]),
    ),
    db.Priority.low => NotificationChannelConfig(
      id: NotificationChannelIds.low,
      priority: db.Priority.low,
      importance: Importance.low,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(const [0, 100]),
    ),
    db.Priority.none => const NotificationChannelConfig(
      id: NotificationChannelIds.none,
      priority: db.Priority.none,
      importance: Importance.min,
      enableVibration: false,
      playSound: false,
    ),
  };
}

/// All priority channel configs in [db.Priority] declaration order.
List<NotificationChannelConfig> get allNotificationChannelConfigs =>
    db.Priority.values.map(notificationChannelForPriority).toList();

/// Registers Android notification channels for each item priority.
///
/// Safe to call repeatedly; Android keeps user overrides for existing channel
/// ids. No-op on non-Android platforms.
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
