part of 'todos_notifier.dart';

mixin _TodosNotifierSelection on _TodosNotifierBase, _TodosNotifierQueries {
  /// Toggles the given entry in the multi-select id set.
  void doMultiSelectionTodo(Todo todo) {
    if (!state.isMultiSelectionTodo) return;

    final updatedIds = Set<int>.from(state.selectedTodoIds);
    if (updatedIds.contains(todo.id)) {
      updatedIds.remove(todo.id);
    } else {
      updatedIds.add(todo.id);
    }

    state = state.copyWith(selectedTodoIds: updatedIds);
    resyncSelectedTodoFromIds();
  }

  /// Clears multi-select and restores back navigation.
  void doMultiSelectionTodoClear() {
    state = state.copyWith(
      selectedTodoIds: const {},
      selectedTodo: const [],
      isMultiSelectionTodo: false,
      isPop: true,
    );
  }

  /// Enters or exits multi-select mode.
  void toggleMultiSelectionTodo() {
    if (state.isMultiSelectionTodo) {
      doMultiSelectionTodoClear();
    } else {
      state = state.copyWith(isMultiSelectionTodo: true, isPop: false);
    }
  }

  /// Sets is pop.
  void setIsPop(bool value) {
    if (state.isPop != value) {
      state = state.copyWith(isPop: value);
    }
  }

  /// Resolves [selectedTodo] entities from [selectedTodoIds] after list changes.
  @override
  void resyncSelectedTodoFromIds() {
    if (state.selectedTodoIds.isEmpty) {
      doMultiSelectionTodoClear();
      return;
    }

    final todosMap = {for (final todo in state.todos) todo.id: todo};
    final updated = state.selectedTodoIds
        .map((id) => todosMap[id])
        .whereType<Todo>()
        .toList();

    if (updated.isEmpty) {
      doMultiSelectionTodoClear();
    } else {
      state = state.copyWith(
        selectedTodo: updated,
        selectedTodoIds: updated.map((e) => e.id).toSet(),
        isMultiSelectionTodo: true,
        isPop: false,
      );
    }
  }

  /// Whether are all selected.
  bool areAllSelected({
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Category? category,
    Todo? parent,
    bool excludeArchivedCategories = false,
  }) {
    final filtered = getFilteredTodos(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      category: category,
      parent: parent,
      excludeArchivedCategories: excludeArchivedCategories,
    );

    return filtered.isNotEmpty &&
        filtered.every((todo) => state.selectedTodoIds.contains(todo.id));
  }

  /// Select all.
  void selectAll({
    required bool select,
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Category? category,
    Todo? parent,
    bool excludeArchivedCategories = false,
  }) {
    final filtered = getFilteredTodos(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      category: category,
      parent: parent,
      excludeArchivedCategories: excludeArchivedCategories,
    );

    if (select) {
      final updatedIds = Set<int>.from(state.selectedTodoIds);
      updatedIds.addAll(filtered.map((todo) => todo.id));

      state = state.copyWith(
        selectedTodoIds: updatedIds,
        isMultiSelectionTodo: true,
        isPop: false,
      );
    } else {
      final idsToRemove = filtered.map((todo) => todo.id).toSet();
      final updatedIds = Set<int>.from(state.selectedTodoIds)
        ..removeWhere((id) => idsToRemove.contains(id));

      if (updatedIds.isEmpty) {
        state = state.copyWith(
          selectedTodoIds: updatedIds,
          isMultiSelectionTodo: false,
          isPop: true,
        );
      } else {
        state = state.copyWith(selectedTodoIds: updatedIds);
      }
    }

    resyncSelectedTodoFromIds();
  }
}
