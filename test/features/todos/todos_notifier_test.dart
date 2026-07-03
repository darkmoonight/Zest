import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/provider_overrides.dart';

void main() {
  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await openTestIsar();
    container = createTestContainer(isar: isar);
  });

  tearDown(() async {
    container.dispose();
    await closeTestIsar(isar);
  });

  Future<TodosNotifier> notifier() => readTodosNotifier(container);

  test('toggleMultiSelectionTodo enters and exits multi-select mode', () async {
    final todosNotifier = await notifier();

    todosNotifier.toggleMultiSelectionTodo();
    expect(container.read(todosNotifierProvider).isMultiSelectionTodo, isTrue);

    todosNotifier.toggleMultiSelectionTodo();
    expect(container.read(todosNotifierProvider).isMultiSelectionTodo, isFalse);
  });

  test('selectAll selects every filtered todo', () async {
    final task = await createTestTask(isar);
    await createTestTodo(isar, task: task, name: 'One');
    await createTestTodo(isar, task: task, name: 'Two');
    final todosNotifier = await notifier();

    todosNotifier.selectAll(select: true, statusFilter: null);

    final state = container.read(todosNotifierProvider);
    expect(state.selectedTodoIds.length, 2);
    expect(todosNotifier.areAllSelected(statusFilter: null), isTrue);
  });

  test('areAllSelected is false for empty filtered list', () async {
    final todosNotifier = await notifier();
    expect(todosNotifier.areAllSelected(statusFilter: null), isFalse);
  });

  test('deleteTodo removes deleted ids from selection', () async {
    final task = await createTestTask(isar);
    final first = await createTestTodo(isar, task: task, name: 'One');
    final second = await createTestTodo(isar, task: task, name: 'Two');
    final todosNotifier = await notifier();

    todosNotifier.toggleMultiSelectionTodo();
    todosNotifier.doMultiSelectionTodo(first);
    todosNotifier.doMultiSelectionTodo(second);

    await todosNotifier.deleteTodo([first]);

    final state = container.read(todosNotifierProvider);
    expect(state.selectedTodoIds, {second.id});
    expect(state.todos.any((todo) => todo.id == first.id), isFalse);
  });

  test('selectAll with select false clears filtered selection', () async {
    final task = await createTestTask(isar);
    await createTestTodo(isar, task: task, name: 'One');
    final second = await createTestTodo(isar, task: task, name: 'Two');
    final todosNotifier = await notifier();

    todosNotifier.selectAll(select: true, statusFilter: null);
    todosNotifier.selectAll(
      select: false,
      statusFilter: null,
      searchQuery: 'One',
    );

    final state = container.read(todosNotifierProvider);
    expect(state.selectedTodoIds, {second.id});
  });

  test('reloadTodos drops stale selected ids', () async {
    final task = await createTestTask(isar);
    final todo = await createTestTodo(isar, task: task, name: 'Keep');
    final todosNotifier = await notifier();

    todosNotifier.toggleMultiSelectionTodo();
    todosNotifier.doMultiSelectionTodo(todo);
    todosNotifier.doMultiSelectionTodo(
      Todos(id: 99999, name: 'ghost', createdTime: DateTime.now()),
    );

    await todosNotifier.reloadTodos();

    final state = container.read(todosNotifierProvider);
    expect(state.selectedTodoIds, {todo.id});
  });

  test('moveTodos reassigns todo to another task', () async {
    final source = await createTestTask(isar, title: 'Source');
    final target = await createTestTask(isar, title: 'Target');
    final todo = await createTestTodo(isar, task: source, name: 'Move');
    final todosNotifier = await notifier();

    await todosNotifier.moveTodos([todo], target);
    await todosNotifier.reloadTodos();

    final moved = container
        .read(todosNotifierProvider)
        .todos
        .firstWhere((item) => item.id == todo.id);
    await moved.task.load();
    expect(moved.task.value?.id, target.id);
  });
}
