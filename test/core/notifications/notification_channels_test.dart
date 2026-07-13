import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show Importance;
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/data/models/db.dart';

void main() {
  group('notificationChannelForPriority', () {
    test('maps high priority to max importance channel', () {
      final config = notificationChannelForPriority(Priority.high);

      expect(config.id, 'zest_priority_high');
      expect(config.nameKey, 'notificationChannelHigh');
      expect(config.importance, Importance.max);
      expect(config.playSound, isTrue);
      expect(config.enableVibration, isTrue);
    });

    test('maps medium priority to default importance channel', () {
      final config = notificationChannelForPriority(Priority.medium);

      expect(config.id, 'zest_priority_medium');
      expect(config.importance, Importance.defaultImportance);
    });

    test('maps low priority to low importance channel', () {
      final config = notificationChannelForPriority(Priority.low);

      expect(config.id, 'zest_priority_low');
      expect(config.importance, Importance.low);
    });

    test('maps none priority to silent min importance channel', () {
      final config = notificationChannelForPriority(Priority.none);

      expect(config.id, 'zest_priority_none');
      expect(config.importance, Importance.min);
      expect(config.playSound, isFalse);
      expect(config.enableVibration, isFalse);
    });
  });

  test('allNotificationChannelConfigs contains four unique ids', () {
    final ids = allNotificationChannelConfigs.map((c) => c.id).toList();
    expect(ids, hasLength(4));
    expect(ids.toSet(), hasLength(4));
  });
}
