import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';

class RecordedNotification {
  const RecordedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  final int id;
  final String title;
  final String body;
  final DateTime? date;
}

class RecordedSnooze {
  const RecordedSnooze({required this.id, required this.snoozeMinutes});

  final int id;
  final int? snoozeMinutes;
}

/// Test double for [NotificationShow] that records calls.
class FakeNotificationShow extends NotificationShow {
  final List<RecordedNotification> shown = [];
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
  }) async {
    shown.add(
      RecordedNotification(id: id, title: title, body: body, date: date),
    );
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
  }) async {
    snoozed.add(RecordedSnooze(id: id, snoozeMinutes: snoozeMinutes));
  }

  void clear() {
    shown.clear();
    cancelled.clear();
    snoozed.clear();
    cancelAllCalled = false;
  }
}
