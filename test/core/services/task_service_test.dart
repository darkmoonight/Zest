import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/task_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late FakeNotificationShow fakeNotifications;
  late TaskRepository taskRepo;
  late TodoRepository todoRepo;
  late TaskService service;

  setUp(() async {
    isar = await openTestIsar();
    fakeNotifications = FakeNotificationShow();
    taskRepo = TaskRepository(isar);
    todoRepo = TodoRepository(isar);
    service = TaskService(
      taskRepo: taskRepo,
      todoRepo: todoRepo,
      notificationService: NotificationService(
        notificationShow: fakeNotifications,
      ),
    );
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('createTask returns null for duplicate title', () async {
    await service.createTask(
      title: 'Duplicate',
      description: '',
      color: Colors.blue,
      currentTaskCount: 0,
    );

    final duplicate = await service.createTask(
      title: 'Duplicate',
      description: '',
      color: Colors.red,
      currentTaskCount: 1,
    );

    expect(duplicate, isNull);
    expect((await taskRepo.getAll()).length, 1);
  });

  test('archiveTasks cancels notifications and archives tasks', () async {
    final task = await createTestTask(isar, title: 'Archive me');
    await createTestTodo(
      isar,
      task: task,
      name: 'Todo',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    fakeNotifications.clear();

    await service.archiveTasks([task]);

    final reloaded = await taskRepo.getById(task.id);
    expect(reloaded?.archive, isTrue);
    expect(fakeNotifications.cancelled, isNotEmpty);
  });

  test('deleteTasks removes todos and task', () async {
    final task = await createTestTask(isar, title: 'Delete me');
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Todo',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    fakeNotifications.clear();

    await service.deleteTasks([task]);

    expect(await taskRepo.getById(task.id), isNull);
    expect(await todoRepo.getById(todo.id), isNull);
    expect(fakeNotifications.cancelled, contains(todo.id));
  });

  test('updateTask persists new fields', () async {
    final task = await createTestTask(isar, title: 'Old title');

    await service.updateTask(
      task: task,
      title: 'New title',
      description: 'Updated',
      color: Colors.green,
    );

    final reloaded = await taskRepo.getById(task.id);
    expect(reloaded?.title, 'New title');
    expect(reloaded?.description, 'Updated');
  });

  test('unarchiveTasks schedules notifications and unarchives', () async {
    final task = await createTestTask(isar, title: 'Archived', archive: true);
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Todo',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    fakeNotifications.clear();

    await service.unarchiveTasks([task]);

    final reloaded = await taskRepo.getById(task.id);
    expect(reloaded?.archive, isFalse);
    expect(fakeNotifications.shown.any((n) => n.id == todo.id), isTrue);
  });

  test('unarchiveTasks skips done todos with due times', () async {
    final task = await createTestTask(
      isar,
      title: 'Archived done',
      archive: true,
    );
    final doneTodo = await createTestTodo(
      isar,
      task: task,
      name: 'Done todo',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
      status: TodoStatus.done,
    );
    fakeNotifications.clear();

    await service.unarchiveTasks([task]);

    expect(fakeNotifications.shown.any((n) => n.id == doneTodo.id), isFalse);
  });
}
