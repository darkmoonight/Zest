import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/todo_service.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/i18n/tr.dart';

/// Riverpod state for the items tab: list, filters, and multi-selection.
class TodosState {
  /// Creates a [TodosState].
  const TodosState({
    this.todos = const [],
    this.selectedTodo = const [],
    this.selectedTodoIds = const {},
    this.isMultiSelectionTodo = false,
    this.isPop = true,
  });

  /// Loaded items shown in list screens.
  final List<Todos> todos;

  /// Selected items kept in sync with [selectedTodoIds] for UI actions.
  final List<Todos> selectedTodo;

  /// Stable id set for multi-select; survives list reloads.
  final Set<int> selectedTodoIds;

  /// Whether the screen is in multi-select mode.
  final bool isMultiSelectionTodo;

  /// Whether [PopScope] should allow popping (false during multi-select).
  final bool isPop;

  /// Returns a copy with the given fields replaced.
  TodosState copyWith({
    List<Todos>? todos,
    List<Todos>? selectedTodo,
    Set<int>? selectedTodoIds,
    bool? isMultiSelectionTodo,
    bool? isPop,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      selectedTodo: selectedTodo ?? this.selectedTodo,
      selectedTodoIds: selectedTodoIds ?? this.selectedTodoIds,
      isMultiSelectionTodo: isMultiSelectionTodo ?? this.isMultiSelectionTodo,
      isPop: isPop ?? this.isPop,
    );
  }
}

/// Loads and mutates items; subscribes to Isar watch streams for live updates.
class TodosNotifier extends Notifier<TodosState> {
  TaskRepository? _taskRepo;

  TodoRepository? _todoRepo;

  /// Debounce timer for coalescing database reload requests.
  Timer? _loadDebounce;

  /// Monotonic token so stale [getAll] results cannot overwrite newer loads.
  int _loadGeneration = 0;

  TaskRepository get taskRepo {
    final cached = _taskRepo;
    if (cached != null) return cached;
    final created = ref.read(taskRepositoryProvider);
    _taskRepo = created;
    return created;
  }

  TodoRepository get todoRepo {
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
    final newTodos = await todoRepo.getAllWithLinks();
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
  Future<Todos> addTodo({
    required Tasks task,
    required String title,
    required String description,
    required String time,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    Todos? parent,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final todo = await todoService.createTodo(
      task: task,
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
    showSnackBar('todoCreate'.tr);
    return todo;
  }

  /// Persists edits to an existing item.
  Future<void> updateTodo({
    required Todos todo,
    required Tasks task,
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
      task: task,
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
    showSnackBar('updateTodo'.tr);
  }

  /// Updates item status and resyncs the current multi-selection.
  Future<void> updateTodoStatus(Todos todo) async {
    await todoService.updateTodoStatus(todo);
    await _loadTodos();
    _resyncSelectedTodoFromIds();
  }

  /// Sets status on [item] and its subtasks, then resyncs selection.
  Future<void> updateTodoStatusWithSubtasks(
    Todos todo,
    TodoStatus status,
  ) async {
    await todoService.updateStatusWithSubtasks(todo, status);
    await _loadTodos();
    _resyncSelectedTodoFromIds();
  }

  /// Moves [todoList] to [task] and reloads items.
  Future<void> moveTodos(List<Todos> todoList, Tasks task) async {
    if (todoList.isEmpty) return;

    await todoService.moveTodos(todos: todoList, task: task);
    await _loadTodos();
    showSnackBar('updateTodo'.tr);
  }

  /// Reparents [rootList] under [newParent] and reloads items.
  Future<void> moveTodosToParent(List<Todos> rootList, Todos? newParent) async {
    if (rootList.isEmpty) return;

    await todoService.moveTodosToParent(
      rootTodos: rootList,
      newParent: newParent,
    );
    await _loadTodos();
    showSnackBar('updateTodo'.tr);
  }

  /// Deletes [todoList], updates selection, and reindexes remaining items.
  Future<void> deleteTodo(List<Todos> todoList) async {
    if (todoList.isEmpty) return;

    _loadDebounce?.cancel();

    final todoListCopy = List<Todos>.from(todoList);

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
    showSnackBar('todoDelete'.tr);
  }

  Future<void> _reindexTodos() async {
    final all = state.todos.toList();

    for (int i = 0; i < all.length; i++) {
      all[i].index = i;
    }

    await todoRepo.updateIndexes(all);
    state = state.copyWith(todos: all);
  }

  /// Persists a new order for [filteredTodos] within the full item list.
  Future<void> reorderTodos({required List<Todos> filteredTodos}) async {
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
  int createdAllTodos() => todoService.countAll(state.todos);

  /// Count of completed root items across non-archived categories.
  int completedAllTodos() => todoService.countAllCompleted(state.todos);

  /// Count of root items in [task].
  int createdAllTodosTask(Tasks task) =>
      todoService.countForTask(task, state.todos);

  /// Count of completed root items in [task].
  int completedAllTodosTask(Tasks task) =>
      todoService.countCompletedForTask(task, state.todos);

  /// Count of active root items due on [date] for calendar markers.
  int countTotalTodosCalendar(
    DateTime date, {
    bool excludeArchivedCategories = true,
  }) => todoService.countForCalendar(
    date,
    state.todos,
    excludeArchivedCategories: excludeArchivedCategories,
  );

  /// Count of direct children under [parent].
  int createdAllTodosTodo(Todos parent) =>
      todoService.countForParent(parent, state.todos);

  /// Count of completed direct children under [parent].
  int completedAllTodosTodo(Todos parent) =>
      todoService.countCompletedForParent(parent, state.todos);

  /// One-pass child counts keyed by parent id: `(created, completed)`.
  Map<int, (int, int)> childCountsByParentId() {
    final counts = <int, (int, int)>{};
    for (final todo in state.todos) {
      final parentId = todo.parent.value?.id;
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
      if (todo.parent.value != null) continue;
      final taskId = todo.task.value?.id;
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
      if (excludeArchivedCategories && todo.task.value?.archive != false) {
        continue;
      }
      if (todo.parent.value != null) continue;
      if (todo.status != TodoStatus.active) continue;
      final due = todo.todoCompletedTime;
      if (due == null) continue;
      final day = DateTime(due.year, due.month, due.day);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  // ==================== Filters ====================

  /// Returns items matching status, search, date, task, and parent filters.
  List<Todos> getFilteredTodos({
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Tasks? task,
    Todos? parent,
    bool excludeArchivedCategories = false,
  }) {
    return todoService.filterTodos(
      allTodos: state.todos,
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      task: task,
      parent: parent,
      excludeArchivedCategories: excludeArchivedCategories,
    );
  }

  // ==================== Multi-Selection Items ====================

  /// Toggles the given entry in the multi-select id set.
  void doMultiSelectionTodo(Todos todo) {
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
        .whereType<Todos>()
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
    Tasks? task,
    Todos? parent,
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
    Tasks? task,
    Todos? parent,
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
}

/// Items notifier provider.
final todosNotifierProvider = NotifierProvider<TodosNotifier, TodosState>(
  TodosNotifier.new,
);
