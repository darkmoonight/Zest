import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/domain/enums/priority.dart' as zest;
import 'package:zest/i18n/tr.dart';

/// Stable Android notification channel ids for each [zest.Priority].
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
  static String idFor(zest.Priority priority) => switch (priority) {
    zest.Priority.high => high,
    zest.Priority.medium => medium,
    zest.Priority.low => low,
    zest.Priority.none => none,
  };
}

/// Android notification channel metadata for a list item [zest.Priority].
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
  final zest.Priority priority;

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
  zest.Priority priority, {
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
NotificationChannelConfig notificationChannelForPriority(
  zest.Priority priority,
) {
  return switch (priority) {
    zest.Priority.high => _channel(
      zest.Priority.high,
      importance: Importance.max,
      vibrationPattern: const [0, 400, 200, 400],
    ),
    zest.Priority.medium => _channel(
      zest.Priority.medium,
      importance: Importance.defaultImportance,
      vibrationPattern: const [0, 250, 150, 250],
    ),
    zest.Priority.low => _channel(
      zest.Priority.low,
      importance: Importance.low,
      vibrationPattern: const [0, 100],
    ),
    zest.Priority.none => _channel(
      zest.Priority.none,
      importance: Importance.min,
      enableVibration: false,
      playSound: false,
    ),
  };
}

/// All priority channel configs in [zest.Priority] declaration order.
List<NotificationChannelConfig> get allNotificationChannelConfigs =>
    zest.Priority.values.map(notificationChannelForPriority).toList();

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
