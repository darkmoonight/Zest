import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/services/recurrence_background_scheduler.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';

void main() {
  group('RecurrenceService.nextOccurrence', () {
    test('returns null when frequency is none', () {
      expect(
        RecurrenceService.nextOccurrence(
          frequency: RecurrenceFrequency.none,
          weekdays: const [],
          from: DateTime(2026, 7, 15, 9),
        ),
        isNull,
      );
    });

    test('daily advances one day and keeps time-of-day', () {
      final from = DateTime(2026, 7, 15, 9, 30);
      expect(
        RecurrenceService.nextOccurrence(
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          from: from,
        ),
        DateTime(2026, 7, 16, 9, 30),
      );
    });

    test('weekly uses same weekday when weekdays list is empty', () {
      // Wednesday
      final from = DateTime(2026, 7, 15, 10);
      expect(from.weekday, DateTime.wednesday);
      expect(
        RecurrenceService.nextOccurrence(
          frequency: RecurrenceFrequency.weekly,
          weekdays: const [],
          from: from,
        ),
        DateTime(2026, 7, 22, 10),
      );
    });

    test('isOccurrenceDay weekly empty does not match other weekdays', () {
      expect(
        RecurrenceService.isOccurrenceDay(
          day: DateTime(2026, 7, 21), // Tuesday
          frequency: RecurrenceFrequency.weekly,
          weekdays: const [],
          fallbackWeekday: DateTime.wednesday,
        ),
        isFalse,
      );
      expect(
        RecurrenceService.isOccurrenceDay(
          day: DateTime(2026, 7, 22), // Wednesday
          frequency: RecurrenceFrequency.weekly,
          weekdays: const [],
          fallbackWeekday: DateTime.wednesday,
        ),
        isTrue,
      );
    });

    test('weekly picks the next matching weekday', () {
      // Wednesday → next Friday
      final from = DateTime(2026, 7, 15, 8);
      expect(
        RecurrenceService.nextOccurrence(
          frequency: RecurrenceFrequency.weekly,
          weekdays: const [DateTime.friday, DateTime.monday],
          from: from,
        ),
        DateTime(2026, 7, 17, 8),
      );
    });

    test('monthly clamps day for shorter months', () {
      final from = DateTime(2026, 1, 31, 12);
      expect(
        RecurrenceService.nextOccurrence(
          frequency: RecurrenceFrequency.monthly,
          weekdays: const [],
          from: from,
        ),
        DateTime(2026, 2, 28, 12),
      );
    });

    test('without from uses calendar day only (habit without hour)', () {
      final now = DateTime(2026, 7, 15, 18, 45);
      expect(
        RecurrenceService.nextOccurrence(
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          now: now,
        ),
        DateTime(2026, 7, 16),
      );
    });
    test('applies fixed minuteOfDay instead of previous due time', () {
      final from = DateTime(2026, 7, 15, 9, 30);
      expect(
        RecurrenceService.nextOccurrence(
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          from: from,
          minuteOfDay: 8 * 60, // 08:00
        ),
        DateTime(2026, 7, 16, 8),
      );
    });
  });

  group('RecurrenceService.applyRecurrenceTime', () {
    test('returns null when date is null', () {
      expect(RecurrenceService.applyRecurrenceTime(null, 480), isNull);
    });

    test('uses minuteOfDay when set', () {
      expect(
        RecurrenceService.applyRecurrenceTime(
          DateTime(2026, 7, 16, 9, 30),
          8 * 60 + 15,
        ),
        DateTime(2026, 7, 16, 8, 15),
      );
    });

    test('falls back to previous clock when minute is null', () {
      expect(
        RecurrenceService.applyRecurrenceTime(
          DateTime(2026, 7, 16),
          null,
          fallbackTime: DateTime(2026, 7, 15, 14, 5),
        ),
        DateTime(2026, 7, 16, 14, 5),
      );
    });

    test('uses midnight when neither minute nor fallback', () {
      expect(
        RecurrenceService.applyRecurrenceTime(DateTime(2026, 7, 16, 11), null),
        DateTime(2026, 7, 16),
      );
    });
  });

  group('RecurrenceService.resolveDueForTodoInCategory', () {
    Category habitTask({
      RecurrenceFrequency frequency = RecurrenceFrequency.daily,
      int? minuteOfDay = 18 * 60 + 37,
    }) => Category(
      id: 1,
      title: 'Habits',
      colorArgb: 0xFF00FF00,
      recurrence: frequency,
      recurrenceMode: RecurrenceMode.reopen,
      recurrenceMinuteOfDay: minuteOfDay,
    );

    test('uses category reminder when todo has no own recurrence', () {
      expect(
        RecurrenceService.resolveDueForTodoInCategory(
          now: DateTime(2026, 7, 15, 10),
          category: habitTask(),
          todoRecurrence: RecurrenceFrequency.none,
          todoWeekdays: const [],
          todoMinuteOfDay: null,
        ),
        DateTime(2026, 7, 15, 18, 37),
      );
    });

    test('keeps explicit fallback due over category minute', () {
      final fallback = DateTime(2026, 7, 20, 9);
      expect(
        RecurrenceService.resolveDueForTodoInCategory(
          now: DateTime(2026, 7, 15, 10),
          category: habitTask(),
          todoRecurrence: RecurrenceFrequency.none,
          todoWeekdays: const [],
          todoMinuteOfDay: null,
          fallbackTime: fallback,
        ),
        fallback,
      );
    });

    test('own todo recurrence wins over category', () {
      expect(
        RecurrenceService.resolveDueForTodoInCategory(
          now: DateTime(2026, 7, 15, 6),
          category: habitTask(),
          todoRecurrence: RecurrenceFrequency.daily,
          todoWeekdays: const [],
          todoMinuteOfDay: 7 * 60,
        ),
        DateTime(2026, 7, 15, 7),
      );
    });
  });

  group('RecurrenceService.shouldEnsureCategoryHabitDue', () {
    test('true when active habit child has null due', () {
      final task = Category(
        id: 1,
        title: 'Habits',
        colorArgb: 0xFF00FF00,
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.reopen,
        recurrenceMinuteOfDay: 18 * 60,
      );
      final todo = Todo(
        id: 101,
        name: 'Stretch',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.active,
      );
      expect(
        RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15),
        ),
        isTrue,
      );
    });

    test('false when todo has its own recurrence', () {
      final task = Category(
        id: 1,
        title: 'Habits',
        colorArgb: 0xFF00FF00,
        recurrence: RecurrenceFrequency.daily,
        recurrenceMinuteOfDay: 18 * 60,
      );
      final todo = Todo(
        id: 102,
        name: 'Stretch',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.active,
        recurrence: RecurrenceFrequency.daily,
      );
      expect(
        RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15),
        ),
        isFalse,
      );
    });

    test('weekly empty does not restamp stale due off the due weekday', () {
      final task = Category(
        id: 1,
        title: 'Habits',
        colorArgb: 0xFF00FF00,
        recurrence: RecurrenceFrequency.weekly,
        recurrenceWeekdays: const [],
        recurrenceMode: RecurrenceMode.reopen,
        recurrenceMinuteOfDay: 18 * 60,
      );
      final todo = Todo(
        id: 103,
        name: 'Stretch',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.active,
        dueAt: DateTime(2026, 7, 13, 18), // Monday
      );
      expect(
        RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15), // Wednesday
        ),
        isFalse,
      );
      expect(
        RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 20), // next Monday
        ),
        isTrue,
      );
    });

    test('monthly does not restamp stale due off the due day-of-month', () {
      final task = Category(
        id: 1,
        title: 'Habits',
        colorArgb: 0xFF00FF00,
        recurrence: RecurrenceFrequency.monthly,
        recurrenceMode: RecurrenceMode.reopen,
        recurrenceMinuteOfDay: 9 * 60,
      );
      final todo = Todo(
        id: 104,
        name: 'Rent',
        description: '',
        createdAt: DateTime(2026, 6, 1),
        status: TodoStatus.active,
        dueAt: DateTime(2026, 7, 1, 9),
      );
      expect(
        RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15),
        ),
        isFalse,
      );
      expect(
        RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          category: task,
          today: DateTime(2026, 8, 1),
        ),
        isTrue,
      );
    });
  });

  group('RecurrenceService.resolveActiveReminderDue', () {
    test('returns fallback when not recurring or no minute', () {
      final fallback = DateTime(2026, 7, 15, 12);
      expect(
        RecurrenceService.resolveActiveReminderDue(
          now: DateTime(2026, 7, 15, 10),
          frequency: RecurrenceFrequency.none,
          weekdays: const [],
          minuteOfDay: 18 * 60,
          fallbackTime: fallback,
        ),
        fallback,
      );
      expect(
        RecurrenceService.resolveActiveReminderDue(
          now: DateTime(2026, 7, 15, 10),
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          minuteOfDay: null,
          fallbackTime: fallback,
        ),
        fallback,
      );
    });

    test('uses today when reminder is ahead, else next day', () {
      expect(
        RecurrenceService.resolveActiveReminderDue(
          now: DateTime(2026, 7, 15, 10),
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          minuteOfDay: 18 * 60 + 37,
        ),
        DateTime(2026, 7, 15, 18, 37),
      );
      expect(
        RecurrenceService.resolveActiveReminderDue(
          now: DateTime(2026, 7, 15, 19),
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          minuteOfDay: 18 * 60 + 37,
        ),
        DateTime(2026, 7, 16, 18, 37),
      );
    });

    test('weekly skips today when it is not an occurrence day', () {
      // Tuesday 10:00, weekly Wednesday 18:00 → Wednesday not Tuesday.
      final tuesday = DateTime(2026, 7, 14, 10);
      expect(tuesday.weekday, DateTime.tuesday);
      expect(
        RecurrenceService.resolveActiveReminderDue(
          now: tuesday,
          frequency: RecurrenceFrequency.weekly,
          weekdays: const [DateTime.wednesday],
          minuteOfDay: 18 * 60,
        ),
        DateTime(2026, 7, 15, 18),
      );
    });
  });

  group('RecurrenceService.dueForOccurrenceDay', () {
    test('builds today due from minuteOfDay', () {
      expect(
        RecurrenceService.dueForOccurrenceDay(
          DateTime(2026, 7, 15, 9),
          18 * 60 + 37,
        ),
        DateTime(2026, 7, 15, 18, 37),
      );
    });

    test('returns null without minute or fallback', () {
      expect(
        RecurrenceService.dueForOccurrenceDay(DateTime(2026, 7, 15), null),
        isNull,
      );
    });
  });

  group('RecurrenceService.nextReminderAfter', () {
    test('keeps today when reminder is still ahead', () {
      expect(
        RecurrenceService.nextReminderAfter(
          now: DateTime(2026, 7, 15, 10),
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          minuteOfDay: 18 * 60 + 37,
        ),
        DateTime(2026, 7, 15, 18, 37),
      );
    });

    test('moves to tomorrow when today reminder already passed', () {
      expect(
        RecurrenceService.nextReminderAfter(
          now: DateTime(2026, 7, 15, 19),
          frequency: RecurrenceFrequency.daily,
          weekdays: const [],
          minuteOfDay: 18 * 60 + 37,
        ),
        DateTime(2026, 7, 16, 18, 37),
      );
    });
  });

  group('RecurrenceService.shouldSpawnCloneForToday', () {
    test('spawns daily clone when done yesterday and no active today', () {
      final todo = Todo(
        id: 105,
        name: 'Water',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.done,
        completedAt: DateTime(2026, 7, 14, 20),
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.clone,
        recurrenceMinuteOfDay: 18 * 60 + 37,
      );
      expect(
        RecurrenceService.shouldSpawnCloneForToday(
          todo: todo,
          today: DateTime(2026, 7, 15, 0, 1),
        ),
        isTrue,
      );
    });

    test('does not spawn when completed today', () {
      final todo = Todo(
        id: 106,
        name: 'Water',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.done,
        completedAt: DateTime(2026, 7, 15, 8),
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.clone,
      );
      expect(
        RecurrenceService.shouldSpawnCloneForToday(
          todo: todo,
          today: DateTime(2026, 7, 15, 12),
        ),
        isFalse,
      );
    });

    test('weekly with empty weekdays uses due weekday, not every day', () {
      final todo = Todo(
        id: 107,
        name: 'Weekly',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.done,
        dueAt: DateTime(2026, 7, 15, 10), // Wednesday
        completedAt: DateTime(2026, 7, 16, 9),
        recurrence: RecurrenceFrequency.weekly,
        recurrenceWeekdays: const [],
        recurrenceMode: RecurrenceMode.clone,
      );
      expect(
        RecurrenceService.shouldSpawnCloneForToday(
          todo: todo,
          today: DateTime(2026, 7, 21), // Tuesday
        ),
        isFalse,
      );
      expect(
        RecurrenceService.shouldSpawnCloneForToday(
          todo: todo,
          today: DateTime(2026, 7, 22), // Wednesday
        ),
        isTrue,
      );
    });

    test('monthly spawn uses due day-of-month, not completion day', () {
      final todo = Todo(
        id: 108,
        name: 'Rent',
        description: '',
        createdAt: DateTime(2026, 6, 1),
        status: TodoStatus.done,
        dueAt: DateTime(2026, 7, 1, 9),
        completedAt: DateTime(2026, 7, 15, 12),
        recurrence: RecurrenceFrequency.monthly,
        recurrenceMode: RecurrenceMode.clone,
      );
      expect(
        RecurrenceService.shouldSpawnCloneForToday(
          todo: todo,
          today: DateTime(2026, 8, 15),
        ),
        isFalse,
      );
      expect(
        RecurrenceService.shouldSpawnCloneForToday(
          todo: todo,
          today: DateTime(2026, 8, 1),
        ),
        isTrue,
      );
    });
  });

  group('RecurrenceService.shouldBumpActiveCloneDue', () {
    test('bumps active clone with yesterday due on occurrence day', () {
      final todo = Todo(
        id: 109,
        name: 'Water',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.active,
        dueAt: DateTime(2026, 7, 14, 18, 37),
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.clone,
        recurrenceMinuteOfDay: 18 * 60 + 37,
      );
      expect(
        RecurrenceService.shouldBumpActiveCloneDue(
          todo: todo,
          today: DateTime(2026, 7, 15, 0, 5),
        ),
        isTrue,
      );
    });

    test('does not bump when due is already today', () {
      final todo = Todo(
        id: 110,
        name: 'Water',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.active,
        dueAt: DateTime(2026, 7, 15, 18, 37),
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.clone,
        recurrenceMinuteOfDay: 18 * 60 + 37,
      );
      expect(
        RecurrenceService.shouldBumpActiveCloneDue(
          todo: todo,
          today: DateTime(2026, 7, 15, 9),
        ),
        isFalse,
      );
    });
  });

  group('RecurrenceService.buildNextClone', () {
    test('copies fields and advances due time', () {
      final source = Todo(
        id: 111,
        name: 'Water plants',
        description: 'Balcony',
        dueAt: DateTime(2026, 7, 15, 8),
        createdAt: DateTime(2026, 7, 1),
        fix: true,
        priority: Priority.high,
        tags: const ['home'],
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.clone,
        recurrenceMinuteOfDay: 7 * 60,
        status: TodoStatus.done,
        completedAt: DateTime(2026, 7, 15, 9),
      );

      final clone = RecurrenceService.buildNextClone(
        source,
        now: DateTime(2026, 7, 15, 9, 5),
        occurrenceDay: DateTime(2026, 7, 15),
      );

      expect(clone.name, 'Water plants');
      expect(clone.description, 'Balcony');
      expect(clone.fix, isTrue);
      expect(clone.priority, Priority.high);
      expect(clone.tags, ['home']);
      expect(clone.recurrence, RecurrenceFrequency.daily);
      expect(clone.recurrenceMode, RecurrenceMode.clone);
      expect(clone.recurrenceMinuteOfDay, 7 * 60);
      expect(clone.status, TodoStatus.active);
      expect(clone.dueAt, DateTime(2026, 7, 15, 7));
      expect(clone.completedAt, isNull);
      expect(clone.createdAt, DateTime(2026, 7, 15, 9, 5));
    });

    test('clones habit without due time as active without schedule', () {
      final source = Todo(
        id: 112,
        name: 'Skincare',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        recurrence: RecurrenceFrequency.daily,
        status: TodoStatus.done,
        completedAt: DateTime(2026, 7, 15),
      );

      final clone = RecurrenceService.buildNextClone(
        source,
        now: DateTime(2026, 7, 15, 21),
        occurrenceDay: DateTime(2026, 7, 15),
      );

      expect(clone.status, TodoStatus.active);
      expect(clone.dueAt, isNull);
    });
  });

  group('RecurrenceBackgroundScheduler delay', () {
    test('delayUntilNextLocalMidnight aims at next calendar midnight', () {
      expect(
        RecurrenceBackgroundScheduler.delayUntilNextLocalMidnight(
          DateTime(2026, 7, 15, 18, 37),
        ),
        const Duration(hours: 5, minutes: 23),
      );
    });

    test('delayUntilNextLocalMidnight uses calendar date not 24h duration', () {
      final now = DateTime(2026, 3, 8, 12);
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      expect(
        RecurrenceBackgroundScheduler.delayUntilNextLocalMidnight(now),
        nextMidnight.difference(now),
      );
    });
  });

  // Keep legacy nextOccurrence-based clone coverage
  group('RecurrenceService.buildNextClone (next day default)', () {
    test('without occurrenceDay advances via nextOccurrence', () {
      final source = Todo(
        id: 113,
        name: 'Water plants',
        description: 'Balcony',
        dueAt: DateTime(2026, 7, 15, 8),
        createdAt: DateTime(2026, 7, 1),
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.clone,
        recurrenceMinuteOfDay: 7 * 60,
        status: TodoStatus.done,
        completedAt: DateTime(2026, 7, 15, 9),
      );

      final clone = RecurrenceService.buildNextClone(
        source,
        now: DateTime(2026, 7, 15, 9, 5),
      );

      expect(clone.dueAt, DateTime(2026, 7, 16, 7));
    });
  });

  group('RecurrenceService.shouldResetCategoryHabit', () {
    Category habitTask({
      RecurrenceFrequency frequency = RecurrenceFrequency.daily,
      List<int> weekdays = const [],
      RecurrenceMode mode = RecurrenceMode.reopen,
    }) => Category(
      id: 1,
      title: 'Habits',
      colorArgb: 0xFF00FF00,
      recurrence: frequency,
      recurrenceWeekdays: weekdays,
      recurrenceMode: mode,
    );

    Todo doneTodo({
      required DateTime completed,
      RecurrenceFrequency recurrence = RecurrenceFrequency.none,
      RecurrenceMode mode = RecurrenceMode.clone,
    }) => Todo(
      id: 1,
      name: 'AM',
      description: '',
      createdAt: completed,
      status: TodoStatus.done,
      completedAt: completed,
      recurrence: recurrence,
      recurrenceMode: mode,
    );

    test('resets daily habit completed on a previous day', () {
      final task = habitTask();
      final todo = doneTodo(completed: DateTime(2026, 7, 14, 21));
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15, 8),
        ),
        isTrue,
      );
    });

    test('treats legacy category clone mode as reopen', () {
      final task = habitTask(mode: RecurrenceMode.clone);
      final todo = doneTodo(completed: DateTime(2026, 7, 14, 21));
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15, 8),
        ),
        isTrue,
      );
    });

    test('skips todos that have their own recurrence', () {
      final task = habitTask();
      final todo = doneTodo(
        completed: DateTime(2026, 7, 14, 21),
        recurrence: RecurrenceFrequency.daily,
        mode: RecurrenceMode.reopen,
      );
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15, 8),
        ),
        isFalse,
      );
    });

    test('does not reset when completed today', () {
      final task = habitTask();
      final todo = doneTodo(completed: DateTime(2026, 7, 15, 7));
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15, 20),
        ),
        isFalse,
      );
    });

    test('weekly only resets on matching weekdays', () {
      final task = habitTask(
        frequency: RecurrenceFrequency.weekly,
        weekdays: const [DateTime.monday, DateTime.wednesday],
      );
      final todo = doneTodo(completed: DateTime(2026, 7, 13)); // Monday

      // Tuesday — skip
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 14),
        ),
        isFalse,
      );
      // Wednesday — reset
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          category: task,
          today: DateTime(2026, 7, 15),
        ),
        isTrue,
      );
    });

    test('ignores non-recurring categories and active todos', () {
      final task = Category(id: 1, title: 'One-off', colorArgb: 0xFF0000FF);
      final done = doneTodo(completed: DateTime(2026, 7, 14));
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: done,
          category: task,
          today: DateTime(2026, 7, 15),
        ),
        isFalse,
      );

      final habit = habitTask();
      final active = Todo(
        id: 114,
        name: 'AM',
        description: '',
        createdAt: DateTime(2026, 7, 14),
        status: TodoStatus.active,
      );
      expect(
        RecurrenceService.shouldResetCategoryHabit(
          todo: active,
          category: habit,
          today: DateTime(2026, 7, 15),
        ),
        isFalse,
      );
    });
  });

  group('RecurrenceService.shouldResetTodoHabit', () {
    test('reopens stale done todos with reopen mode', () {
      final todo = Todo(
        id: 115,
        name: 'Stretch',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.done,
        completedAt: DateTime(2026, 7, 14),
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.reopen,
      );
      expect(
        RecurrenceService.shouldResetTodoHabit(
          todo: todo,
          today: DateTime(2026, 7, 15),
        ),
        isTrue,
      );
    });

    test('does not reopen clone-mode todos', () {
      final todo = Todo(
        id: 116,
        name: 'Stretch',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.done,
        completedAt: DateTime(2026, 7, 14),
        recurrence: RecurrenceFrequency.daily,
        recurrenceMode: RecurrenceMode.clone,
      );
      expect(
        RecurrenceService.shouldResetTodoHabit(
          todo: todo,
          today: DateTime(2026, 7, 15),
        ),
        isFalse,
      );
    });

    test('weekly with empty weekdays reopens on due weekday only', () {
      final todo = Todo(
        id: 117,
        name: 'Weekly',
        description: '',
        createdAt: DateTime(2026, 7, 1),
        status: TodoStatus.done,
        dueAt: DateTime(2026, 7, 15, 10), // Wednesday
        completedAt: DateTime(2026, 7, 16, 9),
        recurrence: RecurrenceFrequency.weekly,
        recurrenceWeekdays: const [],
        recurrenceMode: RecurrenceMode.reopen,
      );
      expect(
        RecurrenceService.shouldResetTodoHabit(
          todo: todo,
          today: DateTime(2026, 7, 21),
        ),
        isFalse,
      );
      expect(
        RecurrenceService.shouldResetTodoHabit(
          todo: todo,
          today: DateTime(2026, 7, 22),
        ),
        isTrue,
      );
    });

    test('monthly reopen uses due day-of-month, not completion day', () {
      final todo = Todo(
        id: 118,
        name: 'Rent',
        description: '',
        createdAt: DateTime(2026, 6, 1),
        status: TodoStatus.done,
        dueAt: DateTime(2026, 7, 1, 9),
        completedAt: DateTime(2026, 7, 15, 12),
        recurrence: RecurrenceFrequency.monthly,
        recurrenceMode: RecurrenceMode.reopen,
      );
      expect(
        RecurrenceService.shouldResetTodoHabit(
          todo: todo,
          today: DateTime(2026, 8, 15),
        ),
        isFalse,
      );
      expect(
        RecurrenceService.shouldResetTodoHabit(
          todo: todo,
          today: DateTime(2026, 8, 1),
        ),
        isTrue,
      );
    });
  });
}
