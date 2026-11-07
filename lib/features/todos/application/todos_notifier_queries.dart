part of 'todos_notifier.dart';

mixin _TodosNotifierQueries on _TodosNotifierBase {

  /// Count of root items across non-archived categories.
  Set<int> _archivedCategoryIds() {
    final tasks = ref.read(categoriesNotifierProvider).categories;
    return {
      for (final t in tasks)
        if (t.archive) t.id,
    };
  }

  /// Count of root items across non-archived categories.
  int createdAllTodos() => todoService.countAll(
    state.todos,
    archivedCategoryIds: _archivedCategoryIds(),
  );

  /// Count of completed root items across non-archived categories.
  int completedAllTodos() => todoService.countAllCompleted(
    state.todos,
    archivedCategoryIds: _archivedCategoryIds(),
  );

  /// One-pass root counts keyed by category id: `(created, completed)`.
  Map<int, (int, int)> rootCountsByCategoryId() {
    final counts = <int, (int, int)>{};
    for (final todo in state.todos) {
      if (todo.parentId != null) continue;
      final categoryId = todo.categoryId;
      if (categoryId == null) continue;
      final prev = counts[categoryId] ?? (0, 0);
      counts[categoryId] = (
        prev.$1 + 1,
        prev.$2 + (todo.status.isCompleted ? 1 : 0),
      );
    }
    return counts;
  }

  /// One-pass calendar marker counts keyed by local calendar day.
  Map<DateTime, int> calendarDayCounts({
    bool excludeArchivedCategories = true,
  }) {
    final counts = <DateTime, int>{};
    for (final todo in state.todos) {
      if (excludeArchivedCategories &&
          (todo.categoryId == null ||
              _archivedCategoryIds().contains(todo.categoryId))) {
        continue;
      }
      if (todo.parentId != null) continue;
      if (todo.status != TodoStatus.active) continue;
      final due = todo.dueAt;
      if (due == null) continue;
      final day = DateTime(due.year, due.month, due.day);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  // ==================== Filters ====================

  /// Returns items matching status, search, date, category, and parent filters.
  List<Todo> getFilteredTodos({
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Category? category,
    Todo? parent,
    bool excludeArchivedCategories = false,
  }) {
    return todoService.filterTodos(
      allTodos: state.todos,
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      category: category,
      parent: parent,
      excludeArchivedCategories: excludeArchivedCategories,
      archivedCategoryIds: _archivedCategoryIds(),
    );
  }

}
