import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/todo_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late TodoService service;

  setUp(() async {
    isar = await openTestIsar();
    service = TodoService(
      todoRepo: TodoRepository(isar),
      notificationService: NotificationService(
        notificationShow: FakeNotificationShow(),
      ),
    );
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  group('TodoService.filterTodos', () {
    late Tasks task;
    late Tasks archivedTask;
    late Todos parent;
    late List<Todos> allTodos;

    setUp(() {
      task = Tasks(id: 1, title: 'Work', taskColor: 0xFF0000FF);
      archivedTask = Tasks(
        id: 2,
        title: 'Archive',
        taskColor: 0xFFFF0000,
        archive: true,
      );
      parent = buildTodo(id: 10, task: task, name: 'Parent');
      allTodos = [
        buildTodo(id: 1, task: task, name: 'Root active', tags: ['focus']),
        buildTodo(
          id: 2,
          task: task,
          name: 'Done root',
          status: TodoStatus.done,
        ),
        buildTodo(id: 3, task: task, name: 'Child', parent: parent),
        buildTodo(
          id: 4,
          task: archivedTask,
          name: 'Archived task todo',
          todoCompletedTime: DateTime(2026, 6, 23, 10),
        ),
        buildTodo(
          id: 5,
          task: task,
          name: 'Calendar todo',
          todoCompletedTime: DateTime(2026, 6, 23, 15),
        ),
      ];
    });

    test('throws when multiple contexts are provided', () {
      expect(
        () => service.filterTodos(
          allTodos: allTodos,
          statusFilter: null,
          task: task,
          selectedDay: DateTime(2026, 6, 23),
        ),
        throwsArgumentError,
      );
    });

    test('root mode returns todos without parent', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
      );
      expect(filtered.map((t) => t.id), [1, 2, 4, 5]);
    });

    test('root mode excludes archived categories when requested', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
        excludeArchivedCategories: true,
      );
      expect(filtered.map((t) => t.id), [1, 2, 5]);
    });

    test('root mode includes archived categories when not excluded', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
        excludeArchivedCategories: false,
      );
      expect(filtered.map((t) => t.id), [1, 2, 4, 5]);
    });

    test('filters by task', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
        task: task,
      );
      expect(filtered.map((t) => t.id), [1, 2, 5]);
    });

    test('filters by parent', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
        parent: parent,
      );
      expect(filtered.map((t) => t.id), [3]);
    });

    test('filters by selected day and skips archived tasks', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
        selectedDay: DateTime(2026, 6, 23),
        excludeArchivedCategories: true,
      );
      expect(filtered.map((t) => t.id), [5]);
    });

    test('filters by selected day and includes archived when enabled', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
        selectedDay: DateTime(2026, 6, 23),
        excludeArchivedCategories: false,
      );
      expect(filtered.map((t) => t.id), [4, 5]);
    });

    test('includes midnight dues and excludes subtasks for selected day', () {
      final midnight = buildTodo(
        id: 6,
        task: task,
        name: 'Midnight',
        todoCompletedTime: DateTime(2026, 6, 23),
      );
      final subtask = buildTodo(
        id: 7,
        task: task,
        name: 'Subtask due',
        parent: parent,
        todoCompletedTime: DateTime(2026, 6, 23, 12),
      );
      final filtered = service.filterTodos(
        allTodos: [...allTodos, midnight, subtask],
        statusFilter: null,
        selectedDay: DateTime(2026, 6, 23),
        excludeArchivedCategories: true,
      );
      expect(filtered.map((t) => t.id), [5, 6]);
    });

    test('filters by status and search query', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: TodoStatus.active,
        searchQuery: 'focus',
      );
      expect(filtered.map((t) => t.id), [1]);
    });
  });

  group('TodoService counters', () {
    late Tasks task;
    late Tasks archivedTask;
    late Todos parent;
    late List<Todos> allTodos;

    setUp(() {
      task = Tasks(id: 1, title: 'Work', taskColor: 0xFF0000FF);
      archivedTask = Tasks(
        id: 2,
        title: 'Archive',
        taskColor: 0xFFFF0000,
        archive: true,
      );
      parent = buildTodo(id: 10, task: task, name: 'Parent');
      allTodos = [
        buildTodo(id: 1, task: task, name: 'Root'),
        buildTodo(id: 2, task: task, name: 'Done', status: TodoStatus.done),
        buildTodo(id: 3, task: task, name: 'Child', parent: parent),
        buildTodo(
          id: 4,
          task: archivedTask,
          name: 'Archived root',
          status: TodoStatus.done,
        ),
        buildTodo(
          id: 5,
          task: task,
          name: 'Today',
          todoCompletedTime: DateTime(2026, 6, 23, 9),
        ),
        buildTodo(
          id: 6,
          task: task,
          name: 'Child done',
          parent: parent,
          status: TodoStatus.done,
        ),
      ];
    });

    test('countForTask counts root todos in task', () {
      expect(service.countForTask(task, allTodos), 3);
      expect(service.countCompletedForTask(task, allTodos), 1);
    });

    test('countAll ignores archived tasks and subtasks', () {
      expect(service.countAll(allTodos), 3);
      expect(service.countAllCompleted(allTodos), 1);
    });

    test('countForCalendar counts active todos on date', () {
      final archivedActive = buildTodo(
        id: 99,
        task: archivedTask,
        name: 'Archived due',
        todoCompletedTime: DateTime(2026, 6, 23, 11),
      );
      final withArchived = [...allTodos, archivedActive];

      expect(service.countForCalendar(DateTime(2026, 6, 23), withArchived), 1);
      expect(
        service.countForCalendar(
          DateTime(2026, 6, 23),
          withArchived,
          excludeArchivedCategories: false,
        ),
        2,
      );
    });

    test('countForParent includes direct children only', () {
      expect(service.countForParent(parent, allTodos), 2);
      expect(service.countCompletedForParent(parent, allTodos), 1);
    });
  });
}
