import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show Importance;
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/data/models/db.dart';

void main() {
  group('notificationChannelForPriority', () {
    test('maps high priority to max importance channel', () {
      final config = notificationChannelForPriority(Priority.high);

      expect(config.id, NotificationChannelIds.high);
      expect(config.nameKey, 'notificationChannelHigh');
      expect(config.hintKey, 'notificationChannelHintHigh');
      expect(config.priority, Priority.high);
      expect(config.importance, Importance.max);
      expect(config.playSound, isTrue);
      expect(config.enableVibration, isTrue);
    });

    test('maps medium priority to default importance channel', () {
      final config = notificationChannelForPriority(Priority.medium);

      expect(config.id, NotificationChannelIds.medium);
      expect(config.importance, Importance.defaultImportance);
    });

    test('maps low priority to low importance channel', () {
      final config = notificationChannelForPriority(Priority.low);

      expect(config.id, NotificationChannelIds.low);
      expect(config.importance, Importance.low);
    });

    test('maps none priority to silent min importance channel', () {
      final config = notificationChannelForPriority(Priority.none);

      expect(config.id, NotificationChannelIds.none);
      expect(config.importance, Importance.min);
      expect(config.playSound, isFalse);
      expect(config.enableVibration, isFalse);
    });
  });

  test('allNotificationChannelConfigs matches Priority.values order', () {
    final configs = allNotificationChannelConfigs;
    expect(configs, hasLength(Priority.values.length));
    expect(configs.map((c) => c.priority).toList(), Priority.values);
    expect(configs.map((c) => c.id).toSet(), hasLength(Priority.values.length));
    for (final config in configs) {
      expect(config.id, NotificationChannelIds.idFor(config.priority));
    }
    expect(configs.map((c) => c.nameKey).toSet(), {
      'notificationChannelHigh',
      'notificationChannelMedium',
      'notificationChannelLow',
      'notificationChannelNone',
    });
    expect(configs.map((c) => c.hintKey).toSet(), {
      'notificationChannelHintHigh',
      'notificationChannelHintMedium',
      'notificationChannelHintLow',
      'notificationChannelHintNone',
    });
  });
}
