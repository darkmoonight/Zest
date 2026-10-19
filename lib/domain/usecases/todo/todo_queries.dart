part of 'todo_usecases.dart';

mixin _TodoQueries on _TodoServiceBase {
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // ==================== COUNTERS ====================

  /// Counts root-level items belonging to [category].
  int countForCategory(Category category, List<Todo> allTodos) {
    return allTodos
        .where((t) => t.categoryId == category.id && t.parentId == null)
        .length;
  }

  /// Counts completed root-level items belonging to [category].
  int countCompletedForCategory(Category category, List<Todo> allTodos) {
    return allTodos
        .where(
          (t) =>
              t.categoryId == category.id &&
              t.status.isCompleted &&
              t.parentId == null,
        )
        .length;
  }

  /// Counts root-level items in non-archived categories.
  int countAll(List<Todo> allTodos, {Set<int> archivedCategoryIds = const {}}) {
    return allTodos
        .where(
          (t) =>
              t.parentId == null &&
              t.categoryId != null &&
              !archivedCategoryIds.contains(t.categoryId),
        )
        .length;
  }

  /// Counts completed root-level items in non-archived categories.
  int countAllCompleted(
    List<Todo> allTodos, {
    Set<int> archivedCategoryIds = const {},
  }) {
    return allTodos
        .where(
          (t) =>
              t.parentId == null &&
              t.categoryId != null &&
              !archivedCategoryIds.contains(t.categoryId) &&
              t.status.isCompleted,
        )
        .length;
  }

  /// Counts active root items due on [date].
  int countForCalendar(
    DateTime date,
    List<Todo> allTodos, {
    bool excludeArchivedCategories = true,
    Set<int> archivedCategoryIds = const {},
  }) {
    return allTodos.where((todo) {
      final completedTime = todo.dueAt;
      if (excludeArchivedCategories &&
          (todo.categoryId == null ||
              archivedCategoryIds.contains(todo.categoryId))) {
        return false;
      }
      return todo.status == TodoStatus.active &&
          completedTime != null &&
          todo.parentId == null &&
          _isSameDay(date, completedTime);
    }).length;
  }

  /// Counts direct child items of [parent].
  int countForParent(Todo parent, List<Todo> allTodos) {
    return allTodos.where((t) => t.parentId == parent.id).length;
  }

  /// Counts completed direct child items of [parent].
  int countCompletedForParent(Todo parent, List<Todo> allTodos) {
    return allTodos
        .where((t) => t.parentId == parent.id && t.status.isCompleted)
        .length;
  }

  // ==================== FILTERS ====================

  /// Filters [allTodos] by status, search, and a single context scope.
  List<Todo> filterTodos({
    required List<Todo> allTodos,
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Category? category,
    Todo? parent,
    bool excludeArchivedCategories = false,
    Set<int> archivedCategoryIds = const {},
  }) {
    final contextCount = [
      selectedDay,
      category,
      parent,
    ].where((c) => c != null).length;

    if (contextCount > 1) {
      throw ArgumentError(
        'Specify only one context: selectedDay, category, or parent.',
      );
    }

    final isRootMode = contextCount == 0;
    final lowerQuery = searchQuery.trim().toLowerCase();

    return allTodos.where((todo) {
      if (statusFilter != null && todo.status != statusFilter) {
        return false;
      }

      if (lowerQuery.isNotEmpty) {
        final nameMatch = todo.name.toLowerCase().contains(lowerQuery);
        final descMatch = todo.description.toLowerCase().contains(lowerQuery);
        final tagsMatch = todo.tags.any(
          (tag) => tag.toLowerCase().contains(lowerQuery),
        );

        if (!nameMatch && !descMatch && !tagsMatch) return false;
      }

      if (isRootMode) {
        if (excludeArchivedCategories &&
            (todo.categoryId == null ||
                archivedCategoryIds.contains(todo.categoryId))) {
          return false;
        }
        return todo.parentId == null;
      } else if (selectedDay != null) {
        final time = todo.dueAt;
        if (excludeArchivedCategories &&
            (todo.categoryId == null ||
                archivedCategoryIds.contains(todo.categoryId))) {
          return false;
        }
        if (todo.parentId != null) return false;
        if (time == null) return false;
        return _isSameDay(selectedDay, time);
      } else if (category != null) {
        return todo.categoryId == category.id && todo.parentId == null;
      } else if (parent != null) {
        return todo.parentId == parent.id;
      }

      return false;
    }).toList();
  }
}
