import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/domain/usecases/todo_usecases.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/domain/repositories/todo_repository.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';

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

/// Loads and mutates items; subscribes to Isar watch streams for live updates.
class TodosNotifier extends Notifier<TodosState> {
  CategoryRepositoryPort? _categoryRepo;

  TodoRepositoryPort? _todoRepo;

  /// Debounce timer for coalescing database reload requests.
  Timer? _loadDebounce;

  /// Monotonic token so stale [getAll] results cannot overwrite newer loads.
  int _loadGeneration = 0;

  CategoryRepositoryPort get categoryRepo {
    final cached = _categoryRepo;
    if (cached != null) return cached;
    final created = ref.read(categoryRepositoryProvider);
    _categoryRepo = created;
    return created;
  }

  TodoRepositoryPort get todoRepo {
    final cached = _todoRepo;
    if (cached != null) return cached;
    final created = ref.read(todoRepositoryProvider);
    _todoRepo = created;
    return created;
  }

  /// [TodoService] from [todoServiceProvider] (clock/locale aware).
  TodoService get todoService => ref.read(todoServiceProvider);

  @override
  /// Initializes repositories, watchers, and returns initial [TodosState].
  TodosState build() {
    StreamSubscription<void>? todoWatcherSubscription;

    todoWatcherSubscription = todoRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    ref.onDispose(() {
      _loadDebounce?.cancel();
      todoWatcherSubscription?.cancel();
    });

    Future.microtask(_loadTodos);

    return const TodosState();
  }

  /// Debounces Isar watch events before reloading.
  void _debounceLoad() {
    _loadDebounce?.cancel();
    _loadDebounce = Timer(AppConstants.debounceDelay, () async {
      await _loadTodos();
    });
  }

  Future<void> _loadTodos() async {
    final generation = ++_loadGeneration;
    final preservedSelectedIds = state.selectedTodoIds.toSet();
    final newTodos = await todoRepo.getAll();
    if (generation != _loadGeneration) return;
    state = state.copyWith(
      todos: newTodos,
      selectedTodoIds: preservedSelectedIds,
    );
    _resyncSelectedTodoFromIds();
  }

  /// Reloads list items from the database while preserving multi-select ids.
  Future<void> reloadTodos() => _loadTodos();

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
    await _loadTodos();
    _resyncSelectedTodoFromIds();
  }

  /// Sets status on [item] and its subtasks, then resyncs selection.
  Future<void> updateTodoStatusWithSubtasks(
    Todo todo,
    TodoStatus status,
  ) async {
    await todoService.updateStatusWithSubtasks(todo, status);
    await _loadTodos();
    _resyncSelectedTodoFromIds();
  }

  /// Moves [todoList] to [task] and reloads items.
  Future<void> moveTodos(List<Todo> todoList, Category category) async {
    if (todoList.isEmpty) return;

    await todoService.moveTodos(todos: todoList, category: category);
    await _loadTodos();
  }

  /// Reparents [rootList] under [newParent] and reloads items.
  Future<void> moveTodosToParent(List<Todo> rootList, Todo? newParent) async {
    if (rootList.isEmpty) return;

    await todoService.moveTodosToParent(
      rootTodos: rootList,
      newParent: newParent,
    );
    await _loadTodos();
  }

  /// Deletes [todoList], updates selection, and reindexes remaining items.
  Future<void> deleteTodo(List<Todo> todoList) async {
    if (todoList.isEmpty) return;

    _loadDebounce?.cancel();

    final todoListCopy = List<Todo>.from(todoList);

    await todoService.deleteTodos(todoListCopy);

    final idsToRemove = todoListCopy.map((t) => t.id).toSet();
    final updatedIds = Set<int>.from(state.selectedTodoIds)
      ..removeWhere((id) => idsToRemove.contains(id));

    state = state.copyWith(
      todos: await todoRepo.getAll(),
      selectedTodoIds: updatedIds,
    );
    _resyncSelectedTodoFromIds();
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

  // ==================== Counters ====================

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

  /// Count of root items in [task].
  int createdAllTodosTask(Category category) =>
      todoService.countForCategory(category, state.todos);

  /// Count of completed root items in [task].
  int completedAllTodosTask(Category category) =>
      todoService.countCompletedForCategory(category, state.todos);

  /// Count of active root items due on [date] for calendar markers.
  int countTotalTodosCalendar(
    DateTime date, {
    bool excludeArchivedCategories = true,
  }) => todoService.countForCalendar(
    date,
    state.todos,
    excludeArchivedCategories: excludeArchivedCategories,
    archivedCategoryIds: _archivedCategoryIds(),
  );

  /// Count of direct children under [parent].
  int createdAllTodosTodo(Todo parent) =>
      todoService.countForParent(parent, state.todos);

  /// Count of completed direct children under [parent].
  int completedAllTodosTodo(Todo parent) =>
      todoService.countCompletedForParent(parent, state.todos);

  /// One-pass child counts keyed by parent id: `(created, completed)`.
  ///
  /// Prefer [TodosState.childCountsByParentId] in UI hot paths (already cached).
  Map<int, (int, int)> childCountsByParentId() => state.childCountsByParentId;

  /// Computes child counts for [todos] (used when building [TodosState]).
  static Map<int, (int, int)> computeChildCountsByParentId(List<Todo> todos) {
    final counts = <int, (int, int)>{};
    for (final todo in todos) {
      final parentId = todo.parentId;
      if (parentId == null) continue;
      final prev = counts[parentId] ?? (0, 0);
      counts[parentId] = (
        prev.$1 + 1,
        prev.$2 + (todo.status.isCompleted ? 1 : 0),
      );
    }
    return counts;
  }

  /// One-pass root counts keyed by task id: `(created, completed)`.
  Map<int, (int, int)> rootCountsByTaskId() {
    final counts = <int, (int, int)>{};
    for (final todo in state.todos) {
      if (todo.parentId != null) continue;
      final taskId = todo.categoryId;
      if (taskId == null) continue;
      final prev = counts[taskId] ?? (0, 0);
      counts[taskId] = (
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
      if (excludeArchivedCategories && todo.categoryId == null ||
          _archivedCategoryIds().contains(todo.categoryId)) {
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

  /// Returns items matching status, search, date, task, and parent filters.
  List<Todo> getFilteredTodos({
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Category? task,
    Todo? parent,
    bool excludeArchivedCategories = false,
  }) {
    return todoService.filterTodos(
      allTodos: state.todos,
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      category: task,
      parent: parent,
      excludeArchivedCategories: excludeArchivedCategories,
      archivedCategoryIds: _archivedCategoryIds(),
    );
  }

  // ==================== Multi-Selection Items ====================

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
    _resyncSelectedTodoFromIds();
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
  void _resyncSelectedTodoFromIds() {
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
    Category? task,
    Todo? parent,
    bool excludeArchivedCategories = false,
  }) {
    final filtered = getFilteredTodos(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      task: task,
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
    Category? task,
    Todo? parent,
    bool excludeArchivedCategories = false,
  }) {
    final filtered = getFilteredTodos(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      task: task,
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

    _resyncSelectedTodoFromIds();
  }

  /// Persists [todo.childrenSortOption] after the user changes list sort.
  Future<void> persistChildrenSort(Todo todo, SortOption option) async {
    await todoRepo.update(todo.copyWith(childrenSortOption: option));
  }

  /// Unique tags from the repository (for form autocomplete).
  Future<List<String>> collectUniqueTags() => todoRepo.collectUniqueTags();
}

/// Items notifier provider.
final todosNotifierProvider = NotifierProvider<TodosNotifier, TodosState>(
  TodosNotifier.new,
);
