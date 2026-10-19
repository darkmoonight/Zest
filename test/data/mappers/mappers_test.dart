import 'package:flutter_test/flutter_test.dart';
import 'package:zest/data/mappers/category_mapper.dart';
import 'package:zest/data/mappers/settings_mapper.dart';
import 'package:zest/data/mappers/todo_mapper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/entities/todo.dart';

void main() {
  group('TodoMapper', () {
    test('toDomain maps scalar fields and null link ids', () {
      final row =
          Todos(
              id: 7,
              name: 'Buy milk',
              description: '2%',
              createdTime: DateTime.utc(2024, 1, 2, 3, 4),
              todoCompletedTime: DateTime.utc(2024, 1, 3),
              todoCompletionTime: DateTime.utc(2024, 1, 4),
              fix: true,
              priority: Priority.high,
              status: TodoStatus.done,
              tags: const ['a', 'b'],
              index: 3,
              recurrence: RecurrenceFrequency.weekly,
              recurrenceWeekdays: const [1, 3],
              recurrenceMode: RecurrenceMode.reopen,
              recurrenceMinuteOfDay: 90,
            )
            ..childrenSortOption = SortOption.alphaAsc
            ..deviceCalendarEventId = 'evt'
            ..caldavUid = 'uid'
            ..caldavHref = '/href'
            ..caldavEtag = 'etag'
            ..caldavDirty = true;

      final todo = TodoMapper.toDomain(row);

      expect(todo.id, 7);
      expect(todo.name, 'Buy milk');
      expect(todo.description, '2%');
      expect(todo.dueAt, DateTime.utc(2024, 1, 3));
      expect(todo.createdAt, DateTime.utc(2024, 1, 2, 3, 4));
      expect(todo.completedAt, DateTime.utc(2024, 1, 4));
      expect(todo.fix, isTrue);
      expect(todo.priority, Priority.high);
      expect(todo.status, TodoStatus.done);
      expect(todo.tags, ['a', 'b']);
      expect(todo.index, 3);
      expect(todo.childrenSortOption, SortOption.alphaAsc);
      expect(todo.categoryId, isNull);
      expect(todo.parentId, isNull);
      expect(todo.deviceCalendarEventId, 'evt');
      expect(todo.caldavUid, 'uid');
      expect(todo.caldavHref, '/href');
      expect(todo.caldavEtag, 'etag');
      expect(todo.caldavDirty, isTrue);
      expect(todo.recurrence, RecurrenceFrequency.weekly);
      expect(todo.recurrenceWeekdays, [1, 3]);
      expect(todo.recurrenceMode, RecurrenceMode.reopen);
      expect(todo.recurrenceMinuteOfDay, 90);
    });

    test('applyDomain writes scalars back onto the Isar row', () {
      final row = Todos(name: 'old', createdTime: DateTime.utc(2020));
      final domain = Todo(
        id: 1,
        name: 'new',
        description: 'desc',
        createdAt: DateTime.utc(2021),
        dueAt: DateTime.utc(2022),
        completedAt: DateTime.utc(2023),
        fix: true,
        priority: Priority.low,
        status: TodoStatus.cancelled,
        tags: const ['t'],
        index: 9,
        caldavDirty: true,
      );

      TodoMapper.applyDomain(row, domain);

      expect(row.name, 'new');
      expect(row.description, 'desc');
      expect(row.todoCompletedTime, DateTime.utc(2022));
      expect(row.createdTime, DateTime.utc(2021));
      expect(row.todoCompletionTime, DateTime.utc(2023));
      expect(row.fix, isTrue);
      expect(row.priority, Priority.low);
      expect(row.status, TodoStatus.cancelled);
      expect(row.tags, ['t']);
      expect(row.index, 9);
      expect(row.caldavDirty, isTrue);
    });
  });

  group('CategoryMapper', () {
    test('round-trips colorArgb via taskColor', () {
      final row = Tasks(
        id: 5,
        title: 'Work',
        description: 'desk',
        taskColor: 0xFF112233,
        archive: true,
        index: 2,
        isSystem: true,
        sortOption: SortOption.dateAsc,
        recurrence: RecurrenceFrequency.daily,
        recurrenceWeekdays: const [2],
        recurrenceMode: RecurrenceMode.clone,
        recurrenceMinuteOfDay: 600,
      );

      final category = CategoryMapper.toDomain(row);
      expect(category.id, 5);
      expect(category.title, 'Work');
      expect(category.colorArgb, 0xFF112233);
      expect(category.archive, isTrue);
      expect(category.isSystem, isTrue);
      expect(category.recurrenceMinuteOfDay, 600);

      final blank = Tasks(title: 'x', taskColor: 0);
      CategoryMapper.applyDomain(blank, category);
      expect(blank.title, 'Work');
      expect(blank.taskColor, 0xFF112233);
      expect(blank.archive, isTrue);
      expect(blank.isSystem, isTrue);
      expect(blank.recurrence, RecurrenceFrequency.daily);
    });
  });

  group('SettingsMapper', () {
    test('round-trips CalDAV and sort preferences', () {
      final row = Settings()
        ..id = 1
        ..caldavEnabled = true
        ..caldavUrl = 'https://example.test'
        ..caldavUsername = 'alice'
        ..allTodosSortOption = SortOption.priorityDesc
        ..autoBackupFrequency = AutoBackupFrequency.weekly
        ..autoEraseCompletedFrequency = AutoEraseCompletedFrequency.monthly
        ..todoCardLayout = '[]'
        ..settingsSchemaVersion = 3;

      final domain = SettingsMapper.toDomain(row);
      expect(domain.id, 1);
      expect(domain.caldavEnabled, isTrue);
      expect(domain.caldavUrl, 'https://example.test');
      expect(domain.caldavUsername, 'alice');
      expect(domain.allTodosSortOption, SortOption.priorityDesc);
      expect(domain.autoBackupFrequency, AutoBackupFrequency.weekly);
      expect(
        domain.autoEraseCompletedFrequency,
        AutoEraseCompletedFrequency.monthly,
      );
      expect(domain.settingsSchemaVersion, 3);

      final other = Settings();
      SettingsMapper.applyDomain(other, domain);
      expect(other.caldavEnabled, isTrue);
      expect(other.caldavUrl, 'https://example.test');
      expect(other.allTodosSortOption, SortOption.priorityDesc);
      expect(other.settingsSchemaVersion, 3);

      final fromDomain = SettingsMapper.toIsar(
        const AppSettings(caldavEnabled: false, timeformat: '12'),
      );
      expect(fromDomain.caldavEnabled, isFalse);
      expect(fromDomain.timeformat, '12');
    });
  });
}
