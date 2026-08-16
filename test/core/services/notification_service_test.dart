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

    test('skips when todo is done', () async {
      final todo = buildTodo(
        id: 11,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        todoCompletedTime: DateTime.now().add(const Duration(hours: 1)),
        status: TodoStatus.done,
      );

      await service.scheduleForTodo(todo);

      expect(fake.shown, isEmpty);
    });

    test('skips when todo is cancelled', () async {
      final todo = buildTodo(
        id: 12,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        todoCompletedTime: DateTime.now().add(const Duration(hours: 1)),
        status: TodoStatus.cancelled,
      );

      await service.scheduleForTodo(todo);

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
        priority: Priority.high,
      );

      await service.scheduleForTodo(todo);

      expect(fake.shown, hasLength(1));
      expect(fake.shown.first.id, 42);
      expect(fake.shown.first.date, due);
      expect(fake.shown.first.priority, Priority.high);
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

    test(
      'skips non-recurring past due when firePastDueImmediately is false',
      () async {
        final past = DateTime.now().subtract(const Duration(hours: 1));
        final todo = buildTodo(
          id: 8,
          task: Tasks(id: 1, title: 'T', taskColor: 1),
          todoCompletedTime: past,
        );

        final ok = await service.scheduleForTodo(
          todo,
          firePastDueImmediately: false,
        );

        expect(ok, isTrue);
        expect(fake.shown, isEmpty);
      },
    );

    test('advances past-due daily clone instead of now+1s', () async {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final todo = buildTodo(
        id: 9,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        todoCompletedTime: past,
      );
      todo.recurrence = RecurrenceFrequency.daily;
      todo.recurrenceMinuteOfDay = 9 * 60;

      await service.scheduleForTodo(todo, firePastDueImmediately: false);

      expect(fake.shown, hasLength(1));
      expect(fake.shown.first.date!.isAfter(DateTime.now()), isTrue);
    });

    test('passes injected settings to showNotification', () async {
      final settings = Settings()..snoozeDuration = 30;
      service = NotificationService(notificationShow: fake, settings: settings);
      final due = DateTime.now().add(const Duration(hours: 2));
      final todo = buildTodo(
        id: 99,
        task: Tasks(id: 1, title: 'T', taskColor: 1),
        todoCompletedTime: due,
      );

      await service.scheduleForTodo(todo);

      expect(fake.shownSettings, hasLength(1));
      expect(fake.shownSettings.first.snoozeDuration, 30);
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

    test(
      'rescheduleActiveReminders only touches active todos with due times',
      () async {
        final due = DateTime.now().add(const Duration(hours: 1));
        final settings = Settings()..snoozeDuration = 5;
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
            status: TodoStatus.done,
          ),
        ];

        await service.rescheduleActiveReminders(todos, settings: settings);

        expect(fake.cancelled, [1]);
        expect(fake.shown, hasLength(1));
        expect(fake.shown.first.id, 1);
        expect(fake.shownSettings.single.snoozeDuration, 5);
      },
    );
  });

  group('NotificationService.scheduleForTask', () {
    test('schedules only active todos with due times', () async {
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
          status: TodoStatus.done,
        ),
        buildTodo(
          id: 4,
          task: Tasks(id: 1, title: 'T', taskColor: 1),
          todoCompletedTime: due,
        ),
      ];

      await service.scheduleForTask(todos);

      expect(fake.shown.map((n) => n.id), [1, 4]);
    });

    test('is a no-op for empty list', () async {
      await service.scheduleForTask([]);
      expect(fake.shown, isEmpty);
    });
  });

  group('NotificationService.snooze', () {
    test(
      'passes snooze duration and priority from settings and todo',
      () async {
        final settings = Settings()..snoozeDuration = 15;
        final todo = buildTodo(
          id: 9,
          task: Tasks(id: 1, title: 'T', taskColor: 1),
          name: 'Snooze me',
          priority: Priority.low,
        );

        await service.snooze(todo, settings);

        expect(fake.snoozed, hasLength(1));
        expect(fake.snoozed.first.id, 9);
        expect(fake.snoozed.first.snoozeMinutes, 15);
        expect(fake.snoozed.first.priority, Priority.low);
      },
    );
  });
}
