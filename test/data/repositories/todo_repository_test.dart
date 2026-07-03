import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late TodoRepository repo;

  setUp(() async {
    isar = await openTestIsar();
    repo = TodoRepository(isar);
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('create links task and parent', () async {
    final task = await createTestTask(isar);
    final parent = await repo.create(
      name: 'Parent',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 0,
      task: task,
    );
    final child = await repo.create(
      name: 'Child',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 1,
      task: task,
      parent: parent,
    );

    await child.parent.load();
    await child.task.load();

    expect(child.parent.value?.id, parent.id);
    expect(child.task.value?.id, task.id);
  });

  test('getAll returns todos sorted by index', () async {
    final task = await createTestTask(isar);
    await repo.create(
      name: 'Second',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 1,
      task: task,
    );
    await repo.create(
      name: 'First',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 0,
      task: task,
    );

    final todos = await repo.getAll();
    expect(todos.map((t) => t.name), ['First', 'Second']);
  });

  test('updateStatusWithSubtasks updates entire subtree', () async {
    final task = await createTestTask(isar);
    final parent = await createTestTodo(isar, task: task, name: 'Parent');
    final child = await createTestTodo(
      isar,
      task: task,
      parent: parent,
      name: 'Child',
    );

    await repo.updateStatusWithSubtasks(
      parentTodo: parent,
      status: TodoStatus.done,
    );

    final reloadedParent = await repo.getById(parent.id);
    final reloadedChild = await repo.getById(child.id);

    expect(reloadedParent?.status, TodoStatus.done);
    expect(reloadedParent?.todoCompletionTime, isNotNull);
    expect(reloadedChild?.status, TodoStatus.done);
  });

  test('moveToTask detaches parent when parent is outside moved set', () async {
    final taskA = await createTestTask(isar, title: 'A');
    final taskB = await createTestTask(isar, title: 'B');
    final parent = await createTestTodo(isar, task: taskA, name: 'Parent');
    final child = await createTestTodo(
      isar,
      task: taskA,
      parent: parent,
      name: 'Child',
    );

    await repo.moveToTask(todoIds: {child.id}, task: taskB);

    final reloaded = (await repo.getById(child.id))!;
    await reloaded.task.load();
    await reloaded.parent.load();

    expect(reloaded.task.value?.id, taskB.id);
    expect(reloaded.parent.value, isNull);
  });

  test('moveToParent updates parent and optional task', () async {
    final taskA = await createTestTask(isar, title: 'A');
    final taskB = await createTestTask(isar, title: 'B');
    final parent = await createTestTodo(isar, task: taskA, name: 'Parent');
    final child = await createTestTodo(isar, task: taskA, name: 'Child');

    await repo.moveToParent(
      todoIds: {child.id},
      newParent: parent,
      newTask: taskB,
    );

    final reloaded = (await repo.getById(child.id))!;
    await reloaded.parent.load();
    await reloaded.task.load();

    expect(reloaded.parent.value?.id, parent.id);
    expect(reloaded.task.value?.id, taskB.id);
  });

  test('deleteBatch removes todos', () async {
    final task = await createTestTask(isar);
    final first = await createTestTodo(isar, task: task, name: 'One');
    final second = await createTestTodo(isar, task: task, name: 'Two');

    await repo.deleteBatch({first.id, second.id});

    expect(await repo.getById(first.id), isNull);
    expect(await repo.getById(second.id), isNull);
  });
}
