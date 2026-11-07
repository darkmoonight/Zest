part of 'todos_notifier.dart';

/// Riverpod state for the items tab: list, filters, and multi-selection.
class TodosState {
  /// Creates a [TodosState].
  const TodosState({
    this.todos = const [],
    this.selectedTodo = const [],
    this.selectedTodoIds = const {},
    this.isMultiSelectionTodo = false,
    this.isPop = true,
    this.todosRevision = 0,
    this.childCountsByParentId = const {},
  });

  /// Loaded items shown in list screens.
  final List<Todo> todos;

  /// Selected items kept in sync with [selectedTodoIds] for UI actions.
  final List<Todo> selectedTodo;

  /// Stable id set for multi-select; survives list reloads.
  final Set<int> selectedTodoIds;

  /// Whether the screen is in multi-select mode.
  final bool isMultiSelectionTodo;

  /// Whether [PopScope] should allow popping (false during multi-select).
  final bool isPop;

  /// Increments whenever [todos] is replaced — list widgets use this for memo keys.
  final int todosRevision;

  /// Precomputed `(created, completed)` child counts keyed by parent id.
  final Map<int, (int, int)> childCountsByParentId;

  /// Returns a copy with the given fields replaced.
  ///
  /// When [todos] is provided, [childCountsByParentId] and [todosRevision] are
  /// refreshed unless overridden explicitly.
  TodosState copyWith({
    List<Todo>? todos,
    List<Todo>? selectedTodo,
    Set<int>? selectedTodoIds,
    bool? isMultiSelectionTodo,
    bool? isPop,
    int? todosRevision,
    Map<int, (int, int)>? childCountsByParentId,
  }) {
    final nextTodos = todos ?? this.todos;
    final todosChanged = todos != null;
    return TodosState(
      todos: nextTodos,
      selectedTodo: selectedTodo ?? this.selectedTodo,
      selectedTodoIds: selectedTodoIds ?? this.selectedTodoIds,
      isMultiSelectionTodo: isMultiSelectionTodo ?? this.isMultiSelectionTodo,
      isPop: isPop ?? this.isPop,
      todosRevision:
          todosRevision ??
          (todosChanged ? this.todosRevision + 1 : this.todosRevision),
      childCountsByParentId:
          childCountsByParentId ??
          (todosChanged
              ? TodosNotifier.computeChildCountsByParentId(nextTodos)
              : this.childCountsByParentId),
    );
  }
}

