import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/usecases/todo_usecases.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/noop_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TodoService service;

  setUp(() {
    service = TodoService(
      todoRepo: NoopTodoRepository(),
      notificationService: NotificationService(
        notificationShow: FakeNotificationShow(),
      ),
    );
  });

  group('TodoService.filterTodos', () {
    late Category task;
    late Category archivedTask;
    late Todo parent;
    late List<Todo> allTodos;
    late Set<int> archivedCategoryIds;

    setUp(() {
      task = const Category(id: 1, title: 'Work', colorArgb: 0xFF0000FF);
      archivedTask = const Category(
        id: 2,
        title: 'Archive',
        colorArgb: 0xFFFF0000,
        archive: true,
      );
      archivedCategoryIds = {archivedTask.id};
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
          category: task,
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
        archivedCategoryIds: archivedCategoryIds,
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

    test('filters by category', () {
      final filtered = service.filterTodos(
        allTodos: allTodos,
        statusFilter: null,
        category: task,
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
        archivedCategoryIds: archivedCategoryIds,
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
        archivedCategoryIds: archivedCategoryIds,
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
    late Category task;
    late Category archivedTask;
    late Todo parent;
    late List<Todo> allTodos;
    late Set<int> archivedCategoryIds;

    setUp(() {
      task = const Category(id: 1, title: 'Work', colorArgb: 0xFF0000FF);
      archivedTask = const Category(
        id: 2,
        title: 'Archive',
        colorArgb: 0xFFFF0000,
        archive: true,
      );
      archivedCategoryIds = {archivedTask.id};
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

    test('countForCategory counts root todos in category', () {
      expect(service.countForCategory(task, allTodos), 3);
      expect(service.countCompletedForCategory(task, allTodos), 1);
    });

    test('countAll ignores archived tasks and subtasks', () {
      expect(
        service.countAll(allTodos, archivedCategoryIds: archivedCategoryIds),
        3,
      );
      expect(
        service.countAllCompleted(
          allTodos,
          archivedCategoryIds: archivedCategoryIds,
        ),
        1,
      );
    });

    test('countForCalendar counts active todos on date', () {
      final archivedActive = buildTodo(
        id: 99,
        task: archivedTask,
        name: 'Archived due',
        todoCompletedTime: DateTime(2026, 6, 23, 11),
      );
      final withArchived = [...allTodos, archivedActive];

      expect(
        service.countForCalendar(
          DateTime(2026, 6, 23),
          withArchived,
          archivedCategoryIds: archivedCategoryIds,
        ),
        1,
      );
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
