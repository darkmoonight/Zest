import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
  late FakeNotificationShow fakeNotifications;
  late TodoRepository todoRepo;
  late TodoService service;
  late Tasks task;

  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  setUp(() async {
    isar = await openTestIsar();
    fakeNotifications = FakeNotificationShow();
    todoRepo = TodoRepository(isar);
    service = TodoService(
      todoRepo: todoRepo,
      notificationService: NotificationService(
        notificationShow: fakeNotifications,
      ),
      timeformat: '24',
      languageCode: 'en',
    );
    task = await createTestTask(isar, title: 'Work');
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('createTodo schedules notification when due time is provided', () async {
    final due = DateTime.now().add(const Duration(days: 1));
    final formatted = DateFormat.yMMMEd('en').add_Hm().format(due);

    final todo = await service.createTodo(
      task: task,
      title: 'New todo',
      description: 'Details',
      timeString: formatted,
      pinned: false,
      priority: Priority.none,
      tags: const [],
      currentTodoCount: 0,
    );

    expect(todo.name, 'New todo');
    expect(fakeNotifications.shown, isNotEmpty);
    expect(fakeNotifications.shown.last.id, todo.id);
  });

  test('updateTodo cancels notification when due time is cleared', () async {
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Scheduled',
      completedTime: DateTime.now().add(const Duration(hours: 2)),
    );
    fakeNotifications.clear();

    await service.updateTodo(
      todo: todo,
      task: task,
      title: 'Scheduled',
      description: '',
      timeString: '',
      pinned: false,
      priority: Priority.none,
      tags: const [],
    );

    expect(fakeNotifications.cancelled, contains(todo.id));
    expect(fakeNotifications.shown, isEmpty);
  });

  test('markTodoAsDone cancels notification', () async {
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Finish me',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    fakeNotifications.clear();

    await service.markTodoAsDone(todo);

    expect(todo.status, TodoStatus.done);
    expect(fakeNotifications.cancelled, contains(todo.id));
  });

  test('snoozeTodo updates due time and snoozes notification', () async {
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Snooze',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    final settings = Settings()..snoozeDuration = 20;
    fakeNotifications.clear();

    await service.snoozeTodo(todo, settings);

    expect(todo.todoCompletedTime, isNotNull);
    expect(fakeNotifications.snoozed, hasLength(1));
    expect(fakeNotifications.snoozed.first.snoozeMinutes, 20);
  });

  test(
    'updateStatusWithSubtasks cancels notifications for completed subtree',
    () async {
      final parent = await createTestTodo(isar, task: task, name: 'Parent');
      final child = await createTestTodo(
        isar,
        task: task,
        parent: parent,
        name: 'Child',
        completedTime: DateTime.now().add(const Duration(hours: 3)),
      );
      fakeNotifications.clear();

      await service.updateStatusWithSubtasks(parent, TodoStatus.done);

      expect(fakeNotifications.cancelled, containsAll([parent.id, child.id]));
    },
  );

  test('deleteTodos cancels notifications and removes subtree', () async {
    final parent = await createTestTodo(
      isar,
      task: task,
      name: 'Parent',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    final child = await createTestTodo(
      isar,
      task: task,
      parent: parent,
      name: 'Child',
      completedTime: DateTime.now().add(const Duration(hours: 2)),
    );
    fakeNotifications.clear();

    await service.deleteTodos([parent]);

    expect(fakeNotifications.cancelled, containsAll([parent.id, child.id]));
    expect(await todoRepo.getById(parent.id), isNull);
    expect(await todoRepo.getById(child.id), isNull);
  });

  test('updateTodoStatus reschedules active todo with due time', () async {
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Active reminder',
      completedTime: DateTime.now().add(const Duration(hours: 2)),
    );
    fakeNotifications.clear();

    await service.updateTodoStatus(todo);

    expect(fakeNotifications.shown, hasLength(1));
    expect(fakeNotifications.shown.first.id, todo.id);
  });

  test(
    'updateTodoStatus cancels notification when todo has no due time',
    () async {
      final todo = await createTestTodo(isar, task: task, name: 'No reminder');
      fakeNotifications.clear();

      await service.updateTodoStatus(todo);

      expect(fakeNotifications.cancelled, contains(todo.id));
      expect(fakeNotifications.shown, isEmpty);
    },
  );

  test('moveTodos reassigns todo to another task', () async {
    final otherTask = await createTestTask(isar, title: 'Personal');
    final todo = await createTestTodo(isar, task: task, name: 'Move me');

    await service.moveTodos(todos: [todo], task: otherTask);

    final reloaded = (await todoRepo.getById(todo.id))!;
    await reloaded.task.load();
    expect(reloaded.task.value?.id, otherTask.id);
  });

  test('moveTodosToParent nests todo under new parent', () async {
    final parent = await createTestTodo(isar, task: task, name: 'Parent');
    final child = await createTestTodo(isar, task: task, name: 'Child');

    await service.moveTodosToParent(rootTodos: [child], newParent: parent);

    final reloaded = (await todoRepo.getById(child.id))!;
    await reloaded.parent.load();
    expect(reloaded.parent.value?.id, parent.id);
  });
}
