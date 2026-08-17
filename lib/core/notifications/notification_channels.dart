import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest/core/services/notification_plugin.dart';
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

  /// Channel id for [priority], matching [high]/[medium]/[low]/[none].
  static String idFor(db.Priority priority) => switch (priority) {
    db.Priority.high => high,
    db.Priority.medium => medium,
    db.Priority.low => low,
    db.Priority.none => none,
  };
}

/// Android notification channel metadata for a list item [db.Priority].
///
/// Sound, vibration, and importance can only be changed in system Settings
/// after a channel is created.
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

  String get _prioritySuffix {
    final token = id.substring(NotificationChannelIds.prefix.length);
    return '${token[0].toUpperCase()}${token.substring(1)}';
  }

  /// Slang key for the user-visible channel name.
  String get nameKey => 'notificationChannel$_prioritySuffix';

  /// Slang key for a short default-importance subtitle.
  String get hintKey => 'notificationChannelHint$_prioritySuffix';

  /// Localized channel name for [nameKey].
  String get localizedName => nameKey.tr;

  /// Localized default-importance hint for [hintKey].
  String get localizedHint => hintKey.tr;

  /// Android channel used at registration time.
  AndroidNotificationChannel toAndroidChannel() {
    return AndroidNotificationChannel(
      id,
      localizedName,
      description: localizedHint,
      importance: importance,
      playSound: playSound,
      enableVibration: enableVibration,
      vibrationPattern: vibrationPattern,
    );
  }
}

NotificationChannelConfig _channel(
  db.Priority priority, {
  required Importance importance,
  bool enableVibration = true,
  bool playSound = true,
  List<int>? vibrationPattern,
}) {
  return NotificationChannelConfig(
    id: NotificationChannelIds.idFor(priority),
    priority: priority,
    importance: importance,
    enableVibration: enableVibration,
    playSound: playSound,
    vibrationPattern: vibrationPattern == null
        ? null
        : Int64List.fromList(vibrationPattern),
  );
}

/// Returns the Android channel config for [priority].
NotificationChannelConfig notificationChannelForPriority(db.Priority priority) {
  return switch (priority) {
    db.Priority.high => _channel(
      db.Priority.high,
      importance: Importance.max,
      vibrationPattern: const [0, 400, 200, 400],
    ),
    db.Priority.medium => _channel(
      db.Priority.medium,
      importance: Importance.defaultImportance,
      vibrationPattern: const [0, 250, 150, 250],
    ),
    db.Priority.low => _channel(
      db.Priority.low,
      importance: Importance.low,
      vibrationPattern: const [0, 100],
    ),
    db.Priority.none => _channel(
      db.Priority.none,
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
  final android = plugin.android;
  if (android == null) return;

  try {
    for (final config in allNotificationChannelConfigs) {
      await android.createNotificationChannel(config.toAndroidChannel());
    }
  } catch (e) {
    debugPrint('Error registering notification channels: $e');
  }
}
