import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/task_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

/// Riverpod state and notifier for task categories.
class TasksState {
  /// Creates a [TasksState].
  const TasksState({
    this.tasks = const [],
    this.selectedTask = const [],
    this.isMultiSelectionTask = false,
    this.isPop = true,
  });

  /// Loaded task categories for the home list.
  final List<Tasks> tasks;

  /// Selected categories during multi-select mode.
  final List<Tasks> selectedTask;

  /// Whether the categories screen is in multi-select mode.
  final bool isMultiSelectionTask;

  /// Whether [PopScope] should allow popping (false during multi-select).
  final bool isPop;

  /// Returns a copy with the given fields replaced.
  TasksState copyWith({
    List<Tasks>? tasks,
    List<Tasks>? selectedTask,
    bool? isMultiSelectionTask,
    bool? isPop,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      isMultiSelectionTask: isMultiSelectionTask ?? this.isMultiSelectionTask,
      isPop: isPop ?? this.isPop,
    );
  }
}

/// Loads and mutates task categories; watches Isar for live list updates.
class TasksNotifier extends Notifier<TasksState> {
  TaskRepository? _taskRepo;

  TodoRepository? _todoRepo;

  TaskService? _taskService;

  Timer? _loadDebounce;

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

  TaskService get taskService {
    final cached = _taskService;
    if (cached != null) return cached;
    final created = TaskService(
      taskRepo: taskRepo,
      todoRepo: todoRepo,
      notificationService: ref.read(notificationServiceProvider),
      calendarSync: ref.read(deviceCalendarSyncServiceProvider),
    );
    _taskService = created;
    return created;
  }

  @override
  /// Initializes repositories, watchers, and returns initial [TasksState].
  TasksState build() {
    StreamSubscription<void>? taskWatcherSubscription;
    StreamSubscription<void>? todoWatcherSubscription;

    taskWatcherSubscription = taskRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    todoWatcherSubscription = todoRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    ref.onDispose(() {
      _loadDebounce?.cancel();
      taskWatcherSubscription?.cancel();
      todoWatcherSubscription?.cancel();
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
    final newTasks = await taskRepo.getAll();
    state = state.copyWith(tasks: newTasks);
  }

  // ==================== Tasks CRUD ====================

  /// Creates a task category with the given title, description, and color.
  Future<Tasks?> addTask(
    String title,
    String description,
    Color color, {
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    return taskService.createTask(
      title: title,
      description: description,
      color: color,
      currentTaskCount: state.tasks.length,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
  }

  /// Persists edits to an existing task category.
  Future<void> updateTask(
    Tasks task,
    String title,
    String description,
    Color color, {
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    await taskService.updateTask(
      task: task,
      title: title,
      description: description,
      color: color,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
  }

  /// Deletes [taskList] and reindexes remaining categories.
  Future<void> deleteTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();

    await taskService.deleteTasks(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);

    state = state.copyWith(tasks: await taskRepo.getAll());
    await _reindexTasks();
  }

  /// Archives [taskList], clears selection, and reloads todos.
  Future<void> archiveTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await taskService.archiveTasks(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);
    state = state.copyWith(tasks: await taskRepo.getAll());
    doMultiSelectionTaskClear();
    await ref.read(todosNotifierProvider.notifier).reloadTodos();
    ref.read(todosNotifierProvider.notifier).resyncSelectedTodoFromIds();
  }

  /// Restores [taskList] from archive and reloads todos.
  Future<void> noArchiveTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await taskService.unarchiveTasks(taskList);
    state = state.copyWith(tasks: await taskRepo.getAll());
    doMultiSelectionTaskClear();
    await ref.read(todosNotifierProvider.notifier).reloadTodos();
    ref.read(todosNotifierProvider.notifier).resyncSelectedTodoFromIds();
  }

  /// Persists a new order for [filteredTasks] within the full task list.
  Future<void> reorderTasks({
    required List<Tasks> filteredTasks,
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
  Future<void> _clearDefaultCategoryIfNeeded(List<Tasks> tasks) async {
    final settings = ref.read(liveSettingsProvider);
    final defaultId = settings.defaultCategoryId;
    if (defaultId == null) return;
    if (!tasks.any((task) => task.id == defaultId)) return;

    settings.defaultCategoryId = null;
    await ref.read(settingsRepositoryProvider).save(settings);
  }

  Future<void> _reindexTasks() async {
    final all = state.tasks.toList();

    for (int i = 0; i < all.length; i++) {
      all[i].index = i;
    }

    await taskRepo.updateIndexes(all);
    state = state.copyWith(tasks: all);
  }

  // ==================== Filters ====================

  /// Returns task categories filtered by archive state and search query.
  List<Tasks> getFilteredTasks({
    required bool archived,
    String searchQuery = '',
  }) {
    return taskService.filterTasks(
      tasks: state.tasks,
      archived: archived,
      searchQuery: searchQuery,
    );
  }

  // ==================== Multi-Selection Tasks ====================

  /// Do multi selection task.
  void doMultiSelectionTask(Tasks task) {
    if (!state.isMultiSelectionTask) return;

    final selected = List<Tasks>.from(state.selectedTask);

    if (selected.contains(task)) {
      selected.remove(task);
    } else {
      selected.add(task);
    }

    if (selected.isEmpty) {
      state = state.copyWith(
        selectedTask: selected,
        isMultiSelectionTask: false,
        isPop: true,
      );
    } else {
      state = state.copyWith(selectedTask: selected, isPop: false);
    }
  }

  /// Do multi selection task clear.
  void doMultiSelectionTaskClear() {
    state = state.copyWith(
      selectedTask: const [],
      isMultiSelectionTask: false,
      isPop: true,
    );
  }

  /// Toggle multi selection task.
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
        filtered.every((task) => state.selectedTask.contains(task));
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
      final selected = List<Tasks>.from(state.selectedTask);
      final tasksToAdd = filtered.where((t) => !selected.contains(t)).toList();
      selected.addAll(tasksToAdd);

      state = state.copyWith(
        selectedTask: selected,
        isMultiSelectionTask: true,
        isPop: false,
      );
    } else {
      final selected = List<Tasks>.from(state.selectedTask)
        ..removeWhere((t) => filtered.contains(t));

      if (selected.isEmpty) {
        state = state.copyWith(
          selectedTask: selected,
          isMultiSelectionTask: false,
          isPop: true,
        );
      } else {
        state = state.copyWith(selectedTask: selected);
      }
    }
  }
}

/// Tasks notifier provider.
final tasksNotifierProvider = NotifierProvider<TasksNotifier, TasksState>(
  TasksNotifier.new,
);
