import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';

class RecordedNotification {
  const RecordedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.priority,
  });

  final int id;
  final String title;
  final String body;
  final DateTime? date;
  final Priority priority;
}

class RecordedSnooze {
  const RecordedSnooze({
    required this.id,
    required this.snoozeMinutes,
    required this.priority,
  });

  final int id;
  final int? snoozeMinutes;
  final Priority priority;
}

/// Test double for [NotificationShow] that records calls.
class FakeNotificationShow extends NotificationShow {
  final List<RecordedNotification> shown = [];
  final List<Settings> shownSettings = [];
  final List<int> cancelled = [];
  final List<RecordedSnooze> snoozed = [];
  bool cancelAllCalled = false;

  @override
  Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime? date, {
    bool requestPermission = true,
    String? markDoneActionText,
    String? snoozeActionText,
    Settings? settings,
    Priority priority = Priority.none,
  }) async {
    shown.add(
      RecordedNotification(
        id: id,
        title: title,
        body: body,
        date: date,
        priority: priority,
      ),
    );
    if (settings != null) {
      shownSettings.add(settings);
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCalled = true;
  }

  @override
  Future<void> snoozeNotification(
    int id,
    String title,
    String body, {
    String? markDoneActionText,
    String? snoozeActionText,
    int? snoozeMinutes,
    Settings? settings,
    Priority priority = Priority.none,
  }) async {
    snoozed.add(
      RecordedSnooze(id: id, snoozeMinutes: snoozeMinutes, priority: priority),
    );
  }

  void clear() {
    shown.clear();
    shownSettings.clear();
    cancelled.clear();
    snoozed.clear();
    cancelAllCalled = false;
  }
}
