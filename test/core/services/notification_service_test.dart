import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';

void main() {
  late FakeNotificationShow fake;
  late NotificationService service;

  setUp(() {
    fake = FakeNotificationShow();
    service = NotificationService(notificationShow: fake);
  });

  group('NotificationService.scheduleForTodo', () {
    test('skips when due time is null', () async {
      final task = buildTodo(task: Tasks(id: 1, title: 'T', taskColor: 1));
      await service.scheduleForTodo(task);
      expect(fake.shown, isEmpty);
    });

    test('schedules future due time as-is', () async {
      final due = DateTime.now().add(const Duration(hours: 2));
      final todo = buildTodo(
        id: 42,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        name: 'Reminder',
        description: 'Body',
        todoCompletedTime: due,
      );

      await service.scheduleForTodo(todo);

      expect(fake.shown, hasLength(1));
      expect(fake.shown.first.id, 42);
      expect(fake.shown.first.date, due);
    });

    test('bumps past due time to about one second from now', () async {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final todo = buildTodo(
        id: 7,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        todoCompletedTime: past,
      );

      final before = DateTime.now();
      await service.scheduleForTodo(todo);
      final after = DateTime.now().add(const Duration(seconds: 2));

      expect(fake.shown, hasLength(1));
      final scheduled = fake.shown.first.date!;
      expect(scheduled.isAfter(before), isTrue);
      expect(scheduled.isBefore(after), isTrue);
    });
  });

  group('NotificationService.cancel and reschedule', () {
    test('reschedule cancels then shows notification', () async {
      final due = DateTime.now().add(const Duration(hours: 1));
      final todo = buildTodo(
        id: 5,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        todoCompletedTime: due,
      );

      await service.reschedule(todo);

      expect(fake.cancelled, [5]);
      expect(fake.shown, hasLength(1));
      expect(fake.shown.first.id, 5);
    });

    test('cancelForTask only cancels todos with due times', () async {
      final todos = [
        buildTodo(
          id: 1,
          task: Tasks(id: 1, title: 'T', taskColor: 1),
          todoCompletedTime: DateTime.now().add(const Duration(hours: 1)),
        ),
        buildTodo(id: 2, task: Tasks(id: 1, title: 'T', taskColor: 1)),
      ];

      await service.cancelForTask(todos);

      expect(fake.cancelled, [1]);
    });

    test('cancelBatch cancels each id', () async {
      await service.cancelBatch([10, 20, 30]);
      expect(fake.cancelled, [10, 20, 30]);
    });

    test('cancelAll delegates to notification show', () async {
      await service.cancelAll();
      expect(fake.cancelAllCalled, isTrue);
    });
  });

  group('NotificationService.scheduleForTask', () {
    test('schedules only todos with due times', () async {
      final due = DateTime.now().add(const Duration(hours: 1));
      final todos = [
        buildTodo(
          id: 1,
          task: Tasks(id: 1, title: 'T', taskColor: 1),
          todoCompletedTime: due,
        ),
        buildTodo(id: 2, task: Tasks(id: 1, title: 'T', taskColor: 1)),
        buildTodo(
          id: 3,
          task: Tasks(id: 1, title: 'T', taskColor: 1),
          todoCompletedTime: due,
        ),
      ];

      await service.scheduleForTask(todos);

      expect(fake.shown.map((n) => n.id), [1, 3]);
    });

    test('is a no-op for empty list', () async {
      await service.scheduleForTask([]);
      expect(fake.shown, isEmpty);
    });
  });

  group('NotificationService.snooze', () {
    test('passes snooze duration from settings', () async {
      final settings = Settings()..snoozeDuration = 15;
      final todo = buildTodo(
        id: 9,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        name: 'Snooze me',
      );

      await service.snooze(todo, settings);

      expect(fake.snoozed, hasLength(1));
      expect(fake.snoozed.first.id, 9);
      expect(fake.snoozed.first.snoozeMinutes, 15);
    });
  });
}
