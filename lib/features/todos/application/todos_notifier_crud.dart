part of 'todos_notifier.dart';

mixin _TodosNotifierCrud on _TodosNotifierBase {
  /// Creates a list item and returns the persisted record.
  Future<Todo> addTodo({
    required Category category,
    required String title,
    required String description,
    required String time,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    Todo? parent,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final todo = await todoService.createTodo(
      category: category,
      title: title,
      description: description,
      timeString: time,
      pinned: pinned,
      priority: priority,
      tags: tags,
      currentTodoCount: await todoRepo.nextIndex(),
      parent: parent,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
    return todo;
  }

  /// Persists edits to an existing item.
  Future<void> updateTodo({
    required Todo todo,
    required Category category,
    required String title,
    required String description,
    required String time,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    await todoService.updateTodo(
      todo: todo,
      category: category,
      title: title,
      description: description,
      timeString: time,
      pinned: pinned,
      priority: priority,
      tags: tags,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
  }

  /// Updates item status and resyncs the current multi-selection.
  Future<void> updateTodoStatus(Todo todo) async {
    await todoService.updateTodoStatus(todo);
    await loadTodos();
    resyncSelectedTodoFromIds();
  }

  /// Sets status on [item] and its subtasks, then resyncs selection.
  Future<void> updateTodoStatusWithSubtasks(
    Todo todo,
    TodoStatus status,
  ) async {
    await todoService.updateStatusWithSubtasks(todo, status);
    await loadTodos();
    resyncSelectedTodoFromIds();
  }

  /// Moves [todoList] to [category] and reloads items.
  Future<void> moveTodos(List<Todo> todoList, Category category) async {
    if (todoList.isEmpty) return;

    await todoService.moveTodos(todos: todoList, category: category);
    await loadTodos();
  }

  /// Reparents [rootList] under [newParent] and reloads items.
  Future<void> moveTodosToParent(List<Todo> rootList, Todo? newParent) async {
    if (rootList.isEmpty) return;

    await todoService.moveTodosToParent(
      rootTodos: rootList,
      newParent: newParent,
    );
    await loadTodos();
  }

  /// Deletes [todoList], updates selection, and reindexes remaining items.
  Future<void> deleteTodo(List<Todo> todoList) async {
    if (todoList.isEmpty) return;

    loadDebounce?.cancel();

    final todoListCopy = List<Todo>.from(todoList);

    await todoService.deleteTodos(todoListCopy);

    final idsToRemove = todoListCopy.map((t) => t.id).toSet();
    final updatedIds = Set<int>.from(state.selectedTodoIds)
      ..removeWhere((id) => idsToRemove.contains(id));

    state = state.copyWith(
      todos: await todoRepo.getAll(),
      selectedTodoIds: updatedIds,
    );
    resyncSelectedTodoFromIds();
    await _reindexTodos();
  }

  Future<void> _reindexTodos() async {
    final all = state.todos.toList();
    await todoRepo.updateIndexes(all);
    state = state.copyWith(todos: await todoRepo.getAll());
  }

  /// Persists a new order for [filteredTodos] within the full item list.
  Future<void> reorderTodos({required List<Todo> filteredTodos}) async {
    if (filteredTodos.isEmpty) return;

    final allTodos = state.todos.toList();
    await todoService.reorderTodos(
      allTodos: allTodos,
      filteredTodos: filteredTodos,
    );
    state = state.copyWith(todos: await todoRepo.getAll());
  }

  Future<void> persistChildrenSort(Todo todo, SortOption option) async {
    await todoRepo.update(todo.copyWith(childrenSortOption: option));
  }

  /// Unique tags from the repository (for form autocomplete).
  Future<List<String>> collectUniqueTags() => todoRepo.collectUniqueTags();
}
