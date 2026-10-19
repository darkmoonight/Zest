import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/domain/usecases/category_usecases.dart';
import 'package:zest/core/utils/app_log.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

/// Riverpod state and notifier for task categories.
class TasksState {
  /// Creates a [TasksState].
  const TasksState({
    this.tasks = const [],
    this.selectedTask = const [],
    this.selectedTaskIds = const {},
    this.isMultiSelectionTask = false,
    this.isPop = true,
  });

  /// Loaded task categories for the home list.
  final List<Category> tasks;

  /// Selected categories during multi-select mode (resolved from ids).
  final List<Category> selectedTask;

  /// Selected category ids; survives list reloads.
  final Set<int> selectedTaskIds;

  /// Whether the categories screen is in multi-select mode.
  final bool isMultiSelectionTask;

  /// Whether [PopScope] should allow popping (false during multi-select).
  final bool isPop;

  /// Returns a copy with the given fields replaced.
  TasksState copyWith({
    List<Category>? tasks,
    List<Category>? selectedTask,
    Set<int>? selectedTaskIds,
    bool? isMultiSelectionTask,
    bool? isPop,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
      isMultiSelectionTask: isMultiSelectionTask ?? this.isMultiSelectionTask,
      isPop: isPop ?? this.isPop,
    );
  }
}

/// Loads and mutates task categories; watches Isar for live list updates.
class TasksNotifier extends Notifier<TasksState> {
  CategoryRepositoryPort? _taskRepo;

  Timer? _loadDebounce;

  /// Monotonic token so stale [getAll] results cannot overwrite newer loads.
  int _loadGeneration = 0;

  CategoryRepositoryPort get taskRepo {
    final cached = _taskRepo;
    if (cached != null) return cached;
    final created = ref.read(categoryRepositoryProvider);
    _taskRepo = created;
    return created;
  }

  /// [TaskService] from [taskServiceProvider].
  TaskService get taskService => ref.read(taskServiceProvider);

  @override
  /// Initializes repositories, watchers, and returns initial [TasksState].
  TasksState build() {
    StreamSubscription<void>? taskWatcherSubscription;

    taskWatcherSubscription = taskRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    ref.onDispose(() {
      _loadDebounce?.cancel();
      taskWatcherSubscription?.cancel();
    });

    Future.microtask(reloadTasks);

    return const TasksState();
  }

  /// Debounce load.
  void _debounceLoad() {
    _loadDebounce?.cancel();
    _loadDebounce = Timer(AppConstants.debounceDelay, () async {
      await reloadTasks();
    });
  }

  /// Reloads task categories from the database into state.
  Future<void> reloadTasks() async {
    final generation = ++_loadGeneration;
    final preservedSelectedIds = state.selectedTaskIds.toSet();
    final newTasks = await taskRepo.getAll();
    if (generation != _loadGeneration || !ref.mounted) return;
    state = state.copyWith(tasks: newTasks);
    _restoreSelectedTasks(preservedSelectedIds);
  }

  void _restoreSelectedTasks(Set<int> preservedIds) {
    if (preservedIds.isEmpty) {
      if (state.selectedTask.isNotEmpty || state.isMultiSelectionTask) {
        doMultiSelectionTaskClear();
      }
      return;
    }

    final tasksMap = {for (final task in state.tasks) task.id: task};
    final restored = preservedIds
        .map((id) => tasksMap[id])
        .whereType<Category>()
        .toList();

    if (restored.isEmpty) {
      doMultiSelectionTaskClear();
    } else {
      state = state.copyWith(
        selectedTask: restored,
        selectedTaskIds: restored.map((e) => e.id).toSet(),
        isMultiSelectionTask: true,
        isPop: false,
      );
    }
  }

  void _resyncSelectedTaskFromIds() {
    if (state.selectedTaskIds.isEmpty) {
      if (state.selectedTask.isNotEmpty) {
        state = state.copyWith(selectedTask: const []);
      }
      return;
    }

    final tasksMap = {for (final task in state.tasks) task.id: task};
    final updated = state.selectedTaskIds
        .map((id) => tasksMap[id])
        .whereType<Category>()
        .toList();

    state = state.copyWith(
      selectedTask: updated,
      selectedTaskIds: updated.map((e) => e.id).toSet(),
    );
  }

  // ==================== Category CRUD ====================

  /// Creates a task category with the given title, description, and color.
  Future<Category?> addTask(
    String title,
    String description,
    Color color, {
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    final task = await taskService.createTask(
      title: title,
      description: description,
      colorArgb: color.toARGB32(),
      currentTaskCount: state.tasks.length,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
    return task;
  }

  /// Persists edits to an existing task category.
  Future<void> updateTask(
    Category category,
    String title,
    String description,
    Color color, {
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    await taskService.updateTask(
      category: category,
      title: title,
      description: description,
      colorArgb: color.toARGB32(),
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
  }

  /// Deletes [taskList] and reindexes remaining categories.
  Future<void> deleteTask(List<Category> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();

    await taskService.deleteTasks(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);

    state = state.copyWith(tasks: await taskRepo.getAll());
    await _reindexTasks();
    // Archive flags live on linked tasks; refresh todos for filters/counts.
    unawaited(_reloadTodosSafely());
  }

  /// Archives [taskList] and clears selection.
  Future<void> archiveTask(List<Category> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await taskService.archiveTasks(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);
    state = state.copyWith(tasks: await taskRepo.getAll());
    doMultiSelectionTaskClear();
    unawaited(_reloadTodosSafely());
  }

  /// Restores [taskList] from archive and clears selection.
  Future<void> noArchiveTask(List<Category> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await taskService.unarchiveTasks(taskList);
    state = state.copyWith(tasks: await taskRepo.getAll());
    doMultiSelectionTaskClear();
    unawaited(_reloadTodosSafely());
  }

  Future<void> _reloadTodosSafely() async {
    try {
      await ref.read(todosNotifierProvider.notifier).reloadTodos();
    } catch (e, stack) {
      AppLog.d('reloadTodos after category change failed: $e\n$stack');
    }
  }

  /// Persists a new order for [filteredTasks] within the full task list.
  Future<void> reorderTasks({
    required List<Category> filteredTasks,
    required bool archived,
  }) async {
    if (filteredTasks.isEmpty) return;

    await taskService.reorderTasks(
      allTasks: state.tasks.toList(),
      filteredTasks: filteredTasks,
    );

    state = state.copyWith(tasks: await taskRepo.getAll());
  }

  /// Clears the user default category when it was archived or deleted.
  Future<void> _clearDefaultCategoryIfNeeded(List<Category> tasks) async {
    final settings = ref.read(liveSettingsProvider);
    final defaultId = settings.defaultCategoryId;
    if (defaultId == null) return;
    if (!tasks.any((task) => task.id == defaultId)) return;

    await ref.writeLiveSettings(mutate: (s) => s.defaultCategoryId = null);
  }

  Future<void> _reindexTasks() async {
    final all = state.tasks.toList();
    await taskRepo.updateIndexes(all);
    state = state.copyWith(tasks: await taskRepo.getAll());
  }

  /// Persists [task.sortOption] after the user changes list sort.
  Future<void> persistTaskSort(Category task, SortOption option) async {
    await taskRepo.update(task.copyWith(sortOption: option));
  }

  /// Active categories sorted by index (for pickers / transfer).
  Future<List<Category>> getActiveSorted() => taskRepo.getActiveSorted();

  // ==================== Filters ====================

  /// Returns task categories filtered by archive state and search query.
  List<Category> getFilteredTasks({
    required bool archived,
    String searchQuery = '',
  }) {
    return taskService.filterTasks(
      tasks: state.tasks,
      archived: archived,
      searchQuery: searchQuery,
    );
  }

  // ==================== Multi-Selection Category ====================

  /// Toggles [task] in the multi-select id set.
  void doMultiSelectionTask(Category task) {
    if (!state.isMultiSelectionTask) return;

    final updatedIds = Set<int>.from(state.selectedTaskIds);
    if (updatedIds.contains(task.id)) {
      updatedIds.remove(task.id);
    } else {
      updatedIds.add(task.id);
    }

    if (updatedIds.isEmpty) {
      state = state.copyWith(
        selectedTask: const [],
        selectedTaskIds: const {},
        isMultiSelectionTask: false,
        isPop: true,
      );
    } else {
      state = state.copyWith(
        selectedTaskIds: updatedIds,
        isMultiSelectionTask: true,
        isPop: false,
      );
      _resyncSelectedTaskFromIds();
    }
  }

  /// Clears category multi-select and restores back navigation.
  void doMultiSelectionTaskClear() {
    state = state.copyWith(
      selectedTask: const [],
      selectedTaskIds: const {},
      isMultiSelectionTask: false,
      isPop: true,
    );
  }

  /// Enters or exits category multi-select mode.
  void toggleMultiSelectionTask() {
    if (state.isMultiSelectionTask) {
      doMultiSelectionTaskClear();
    } else {
      state = state.copyWith(isMultiSelectionTask: true, isPop: false);
    }
  }

  /// Sets is pop.
  void setIsPop(bool value) {
    if (state.isPop != value) {
      state = state.copyWith(isPop: value);
    }
  }

  /// Whether are all tasks selected.
  bool areAllTasksSelected({required bool archived, String searchQuery = ''}) {
    final filtered = getFilteredTasks(
      archived: archived,
      searchQuery: searchQuery,
    );

    return filtered.isNotEmpty &&
        filtered.every((task) => state.selectedTaskIds.contains(task.id));
  }

  /// Select all tasks.
  void selectAllTasks({
    required bool select,
    required bool archived,
    String searchQuery = '',
  }) {
    final filtered = getFilteredTasks(
      archived: archived,
      searchQuery: searchQuery,
    );

    if (select) {
      final updatedIds = Set<int>.from(state.selectedTaskIds)
        ..addAll(filtered.map((t) => t.id));

      state = state.copyWith(
        selectedTaskIds: updatedIds,
        isMultiSelectionTask: true,
        isPop: false,
      );
      _resyncSelectedTaskFromIds();
    } else {
      final filteredIds = filtered.map((t) => t.id).toSet();
      final updatedIds = Set<int>.from(state.selectedTaskIds)
        ..removeWhere(filteredIds.contains);

      if (updatedIds.isEmpty) {
        doMultiSelectionTaskClear();
      } else {
        state = state.copyWith(selectedTaskIds: updatedIds);
        _resyncSelectedTaskFromIds();
      }
    }
  }
}

/// Category notifier provider.
final tasksNotifierProvider = NotifierProvider<TasksNotifier, TasksState>(
  TasksNotifier.new,
);
