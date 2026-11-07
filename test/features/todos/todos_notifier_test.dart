import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/provider_overrides.dart';

void main() {
  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await openTestIsar();
    container = createTestContainer(isar: isar);
    await readTodosNotifier(container);
    await readCategoriesNotifier(container);
  });

  tearDown(() async {
    if (isarCoreUnavailable) return;
    // Let pending CategoriesNotifier microtask reloads finish before dispose.
    await Future<void>.delayed(Duration.zero);
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
    final category = await createTestTask(isar);
    await createTestTodo(isar, category: category, name: 'One');
    await createTestTodo(isar, category: category, name: 'Two');
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
    final category = await createTestTask(isar);
    final first = await createTestTodo(isar, category: category, name: 'One');
    final second = await createTestTodo(isar, category: category, name: 'Two');
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
    final category = await createTestTask(isar);
    await createTestTodo(isar, category: category, name: 'One');
    final second = await createTestTodo(isar, category: category, name: 'Two');
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
    final category = await createTestTask(isar);
    final todo = await createTestTodo(isar, category: category, name: 'Keep');
    final todosNotifier = await notifier();

    todosNotifier.toggleMultiSelectionTodo();
    todosNotifier.doMultiSelectionTodo(todo);
    todosNotifier.doMultiSelectionTodo(
      Todo(id: 99999, name: 'ghost', createdAt: DateTime.now()),
    );

    await todosNotifier.reloadTodos();

    final state = container.read(todosNotifierProvider);
    expect(state.selectedTodoIds, {todo.id});
  });

  test('moveTodos reassigns todo to another task', () async {
    final source = await createTestTask(isar, title: 'Source');
    final target = await createTestTask(isar, title: 'Target');
    final todo = await createTestTodo(isar, category: source, name: 'Move');
    final todosNotifier = await notifier();

    await todosNotifier.moveTodos([todo], target);
    await todosNotifier.reloadTodos();

    final moved = container
        .read(todosNotifierProvider)
        .todos
        .firstWhere((item) => item.id == todo.id);
    expect(moved.categoryId, target.id);
  });

  test(
    'calendarDayCounts includes archived categories when not excluding',
    () async {
      final active = await createTestTask(isar, title: 'Active');
      final archived = await createTestTask(
        isar,
        title: 'Archived',
        archive: true,
      );
      final due = DateTime(2026, 3, 15, 10);
      await createTestTodo(
        isar,
        category: active,
        name: 'A',
        completedTime: due,
      );
      await createTestTodo(
        isar,
        category: archived,
        name: 'B',
        completedTime: due,
      );
      await readCategoriesNotifier(container);
      final todosNotifier = await notifier();
      await todosNotifier.reloadTodos();

      final day = DateTime(due.year, due.month, due.day);
      final excluding = todosNotifier.calendarDayCounts(
        excludeArchivedCategories: true,
      );
      final including = todosNotifier.calendarDayCounts(
        excludeArchivedCategories: false,
      );

      expect(excluding[day], 1);
      expect(including[day], 2);
    },
  );
}
