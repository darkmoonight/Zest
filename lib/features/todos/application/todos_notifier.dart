import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/todo_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/features/tasks/application/tasks_notifier.dart';

/// Riverpod state for the todos tab: list, filters, and multi-selection.
class TodosState {
  /// Creates a [TodosState].
  const TodosState({
    this.todos = const [],
    this.selectedTodo = const [],
    this.selectedTodoIds = const {},
    this.isMultiSelectionTodo = false,
    this.isPop = true,
  });

  /// Loaded todos shown in list screens.
  final List<Todos> todos;

  /// Selected todos kept in sync with [selectedTodoIds] for UI actions.
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

/// Loads and mutates todos; subscribes to Isar watch streams for live updates.
class TodosNotifier extends Notifier<TodosState> {
  /// The task repo.
  late final TaskRepository _taskRepo;

  /// The todo repo.
  late final TodoRepository _todoRepo;

  /// The todo service.
  TodoService? _todoService;

  /// Debounce timer for coalescing database reload requests.
  Timer? _loadDebounce;

  /// Cached locale prefs used to rebuild [TodoService].
  (String, String?)? _todoServicePrefs;

  @override
  /// Initializes repositories, watchers, and returns initial [TodosState].
  TodosState build() {
    _taskRepo = ref.read(taskRepositoryProvider);
    _todoRepo = ref.read(todoRepositoryProvider);
    final formatPrefs = ref.watch(
      settingsProvider.select((s) => (s.timeformat, s.language)),
    );
    _ensureTodoService(formatPrefs);

    StreamSubscription<void>? taskWatcherSubscription;
    StreamSubscription<void>? todoWatcherSubscription;

    taskWatcherSubscription = _taskRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    todoWatcherSubscription = _todoRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    ref.onDispose(() {
      _loadDebounce?.cancel();
      taskWatcherSubscription?.cancel();
      todoWatcherSubscription?.cancel();
    });

    Future.microtask(_loadTodos);

    return const TodosState();
  }

  /// Ensure todo service.
  void _ensureTodoService((String, String?) formatPrefs) {
    if (_todoService != null && _todoServicePrefs == formatPrefs) return;

    _todoServicePrefs = formatPrefs;
    _todoService = TodoService(
      todoRepo: _todoRepo,
      notificationService: ref.read(notificationServiceProvider),
      timeformat: formatPrefs.$1,
      languageCode: formatPrefs.$2 ?? AppConstants.defaultLanguageCode,
    );
  }

  TodoService get todoService {
    _ensureTodoService(
      ref.read(settingsProvider.select((s) => (s.timeformat, s.language))),
    );
    return _todoService!;
  }

  /// Debounce load.
  void _debounceLoad() {
    _loadDebounce?.cancel();
    _loadDebounce = Timer(AppConstants.debounceDelay, () async {
      await _loadTodos();
    });
  }

  /// Void.
  Future<void> _loadTodos() async {
    final preservedSelectedIds = state.selectedTodoIds.toSet();

    final newTodos = await _todoRepo.getAll();
    state = state.copyWith(todos: newTodos);

    _restoreSelectedTodos(preservedSelectedIds);
  }

  /// Restore selected todos.
  void _restoreSelectedTodos(Set<int> preservedIds) {
    if (preservedIds.isEmpty) {
      doMultiSelectionTodoClear();
      return;
    }

    final todosMap = {for (final todo in state.todos) todo.id: todo};
    final restored = preservedIds
        .map((id) => todosMap[id])
        .whereType<Todos>()
        .toList();

    if (restored.isEmpty) {
      doMultiSelectionTodoClear();
    } else {
      state = state.copyWith(
        selectedTodo: restored,
        selectedTodoIds: restored.map((e) => e.id).toSet(),
        isMultiSelectionTodo: true,
        isPop: false,
      );
    }
  }

  /// Void.
  Future<void> reloadTodos() => _loadTodos();

  /// Resync selected todo from ids.
  void resyncSelectedTodoFromIds() => _resyncSelectedTodoFromIds();

  /// Todos.
  Future<Todos> addTodo({
    required Tasks task,
    required String title,
    required String description,
    required String time,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    Todos? parent,
  }) async {
    final todo = await todoService.createTodo(
      task: task,
      title: title,
      description: description,
      timeString: time,
      pinned: pinned,
      priority: priority,
      tags: tags,
      currentTodoCount: state.todos.length,
      parent: parent,
    );
    return todo;
  }

  /// Void.
  Future<void> updateTodo({
    required Todos todo,
    required Tasks task,
    required String title,
    required String description,
    required String time,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
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
    );
  }

  /// Void.
  Future<void> updateTodoStatus(Todos todo) async {
    await todoService.updateTodoStatus(todo);
    _resyncSelectedTodoFromIds();
  }

  /// Void.
  Future<void> updateTodoStatusWithSubtasks(
    Todos todo,
    TodoStatus status,
  ) async {
    await todoService.updateStatusWithSubtasks(todo, status);
    _resyncSelectedTodoFromIds();
  }

  /// Void.
  Future<void> moveTodos(List<Todos> todoList, Tasks task) async {
    if (todoList.isEmpty) return;

    await todoService.moveTodos(todos: todoList, task: task);
    await _loadTodos();
    await ref.read(tasksNotifierProvider.notifier).reloadTasks();
  }

  /// Void.
  Future<void> moveTodosToParent(List<Todos> rootList, Todos? newParent) async {
    if (rootList.isEmpty) return;

    await todoService.moveTodosToParent(
      rootTodos: rootList,
      newParent: newParent,
    );
    await _loadTodos();
    await ref.read(tasksNotifierProvider.notifier).reloadTasks();
  }

  /// Void.
  Future<void> deleteTodo(List<Todos> todoList) async {
    if (todoList.isEmpty) return;

    _loadDebounce?.cancel();

    final todoListCopy = List<Todos>.from(todoList);

    await todoService.deleteTodos(todoListCopy);

    final idsToRemove = todoListCopy.map((t) => t.id).toSet();
    final updatedIds = Set<int>.from(state.selectedTodoIds)
      ..removeWhere((id) => idsToRemove.contains(id));

    state = state.copyWith(
      todos: await _todoRepo.getAll(),
      selectedTodoIds: updatedIds,
    );
    _resyncSelectedTodoFromIds();
    await _reindexTodos();
  }

  /// Void.
  Future<void> _reindexTodos() async {
    final all = state.todos.toList();

    for (int i = 0; i < all.length; i++) {
      all[i].index = i;
    }

    await _todoRepo.updateIndexes(all);
    state = state.copyWith(todos: all);
  }

  // ==================== Counters ====================

  /// Created all todos.
  int createdAllTodos() => todoService.countAll(state.todos);

  /// Completed all todos.
  int completedAllTodos() => todoService.countAllCompleted(state.todos);

  /// Created all todos task.
  int createdAllTodosTask(Tasks task) =>
      todoService.countForTask(task, state.todos);

  /// Completed all todos task.
  int completedAllTodosTask(Tasks task) =>
      todoService.countCompletedForTask(task, state.todos);

  /// Count total todos calendar.
  int countTotalTodosCalendar(
    DateTime date, {
    bool excludeArchivedCategories = true,
  }) => todoService.countForCalendar(
    date,
    state.todos,
    excludeArchivedCategories: excludeArchivedCategories,
  );

  /// Created all todos todo.
  int createdAllTodosTodo(Todos parent) =>
      todoService.countForParent(parent, state.todos);

  /// Completed all todos todo.
  int completedAllTodosTodo(Todos parent) =>
      todoService.countCompletedForParent(parent, state.todos);

  // ==================== Filters ====================

  /// Todos.
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

  // ==================== Multi-Selection Todos ====================

  /// Do multi selection todo.
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

  /// Do multi selection todo clear.
  void doMultiSelectionTodoClear() {
    state = state.copyWith(
      selectedTodoIds: const {},
      selectedTodo: const [],
      isMultiSelectionTodo: false,
      isPop: true,
    );
  }

  /// Toggle multi selection todo.
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

  /// Resync selected todo from ids.
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

/// Todos notifier provider.
final todosNotifierProvider = NotifierProvider<TodosNotifier, TodosState>(
  TodosNotifier.new,
);
