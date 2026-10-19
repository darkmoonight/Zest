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
    if (isarCoreUnavailable) return;
    await closeTestIsar(isar);
  });

  test('create links category and parent', () async {
    final category = await createTestTask(isar);
    final parent = await repo.create(
      name: 'Parent',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 0,
      categoryId: category.id,
    );
    final child = await repo.create(
      name: 'Child',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 1,
      categoryId: category.id,
      parentId: parent.id,
    );

    expect(child.parentId, parent.id);
    expect(child.categoryId, category.id);
  });

  test('getAll returns todos sorted by index', () async {
    final category = await createTestTask(isar);
    await repo.create(
      name: 'Second',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 1,
      categoryId: category.id,
    );
    await repo.create(
      name: 'First',
      description: '',
      completedTime: null,
      fix: false,
      priority: Priority.none,
      tags: const [],
      index: 0,
      categoryId: category.id,
    );

    final todos = await repo.getAll();
    expect(todos.map((t) => t.name), ['First', 'Second']);
  });

  test('updateStatusWithSubtasks updates entire subtree', () async {
    final category = await createTestTask(isar);
    final parent = await createTestTodo(isar, task: category, name: 'Parent');
    final child = await createTestTodo(
      isar,
      task: category,
      parent: parent,
      name: 'Child',
    );

    await repo.updateStatusWithSubtasks(
      parentId: parent.id,
      status: TodoStatus.done,
    );

    final reloadedParent = await repo.getById(parent.id);
    final reloadedChild = await repo.getById(child.id);

    expect(reloadedParent?.status, TodoStatus.done);
    expect(reloadedParent?.completedAt, isNotNull);
    expect(reloadedChild?.status, TodoStatus.done);
  });

  test(
    'moveToCategory detaches parent when parent is outside moved set',
    () async {
      final categoryA = await createTestTask(isar, title: 'A');
      final categoryB = await createTestTask(isar, title: 'B');
      final parent = await createTestTodo(
        isar,
        task: categoryA,
        name: 'Parent',
      );
      final child = await createTestTodo(
        isar,
        task: categoryA,
        parent: parent,
        name: 'Child',
      );

      await repo.moveToCategory(todoIds: {child.id}, categoryId: categoryB.id);

      final reloaded = (await repo.getById(child.id))!;

      expect(reloaded.categoryId, categoryB.id);
      expect(reloaded.parentId, isNull);
    },
  );

  test('moveToParent updates parent and optional category', () async {
    final categoryA = await createTestTask(isar, title: 'A');
    final categoryB = await createTestTask(isar, title: 'B');
    final parent = await createTestTodo(isar, task: categoryA, name: 'Parent');
    final child = await createTestTodo(isar, task: categoryA, name: 'Child');

    await repo.moveToParent(
      rootIds: {child.id},
      subtreeIds: {child.id},
      newParentId: parent.id,
      newCategoryId: categoryB.id,
    );

    final reloaded = (await repo.getById(child.id))!;

    expect(reloaded.parentId, parent.id);
    expect(reloaded.categoryId, categoryB.id);
  });

  test('moveToParent preserves nested links inside subtree', () async {
    final category = await createTestTask(isar, title: 'A');
    final newParent = await createTestTodo(
      isar,
      task: category,
      name: 'New parent',
    );
    final root = await createTestTodo(isar, task: category, name: 'Root');
    final mid = await createTestTodo(
      isar,
      task: category,
      name: 'Mid',
      parent: root,
    );

    await repo.moveToParent(
      rootIds: {root.id},
      subtreeIds: {root.id, mid.id},
      newParentId: newParent.id,
      newCategoryId: null,
    );

    final reloadedRoot = (await repo.getById(root.id))!;
    final reloadedMid = (await repo.getById(mid.id))!;

    expect(reloadedRoot.parentId, newParent.id);
    expect(reloadedMid.parentId, root.id);
  });

  test('deleteBatch removes todos', () async {
    final category = await createTestTask(isar);
    final first = await createTestTodo(isar, task: category, name: 'One');
    final second = await createTestTodo(isar, task: category, name: 'Two');

    await repo.deleteBatch({first.id, second.id});

    expect(await repo.getById(first.id), isNull);
    expect(await repo.getById(second.id), isNull);
  });
}
