import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/services/task_service.dart';
import 'package:zest/core/settings/settings_writer.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/i18n/tr.dart';

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
  final List<Tasks> tasks;

  /// Selected categories during multi-select mode (resolved from ids).
  final List<Tasks> selectedTask;

  /// Selected category ids; survives list reloads.
  final Set<int> selectedTaskIds;

  /// Whether the categories screen is in multi-select mode.
  final bool isMultiSelectionTask;

  /// Whether [PopScope] should allow popping (false during multi-select).
  final bool isPop;

  /// Returns a copy with the given fields replaced.
  TasksState copyWith({
    List<Tasks>? tasks,
    List<Tasks>? selectedTask,
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
  TaskRepository? _taskRepo;

  TodoRepository? _todoRepo;

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

  /// [TaskService] from [taskServiceProvider].
  TaskService get taskService => ref.read(taskServiceProvider);

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
    final preservedSelectedIds = state.selectedTaskIds.toSet();
    final newTasks = await taskRepo.getAll();
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
        .whereType<Tasks>()
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
        .whereType<Tasks>()
        .toList();

    state = state.copyWith(
      selectedTask: updated,
      selectedTaskIds: updated.map((e) => e.id).toSet(),
    );
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
    final task = await taskService.createTask(
      title: title,
      description: description,
      color: color,
      currentTaskCount: state.tasks.length,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
    if (task == null) {
      showSnackBar('duplicateCategory'.tr, isError: true);
      return null;
    }
    showSnackBar('createCategory'.tr);
    return task;
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
    showSnackBar('editCategory'.tr);
  }

  /// Deletes [taskList] and reindexes remaining categories.
  Future<void> deleteTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();

    await taskService.deleteTasks(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);

    state = state.copyWith(tasks: await taskRepo.getAll());
    await _reindexTasks();
    showSnackBar('categoryDelete'.tr);
  }

  /// Archives [taskList] and clears selection.
  Future<void> archiveTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await taskService.archiveTasks(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);
    state = state.copyWith(tasks: await taskRepo.getAll());
    doMultiSelectionTaskClear();
    showSnackBar('categoryArchive'.tr);
  }

  /// Restores [taskList] from archive and clears selection.
  Future<void> noArchiveTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await taskService.unarchiveTasks(taskList);
    state = state.copyWith(tasks: await taskRepo.getAll());
    doMultiSelectionTaskClear();
    showSnackBar('noCategoryArchive'.tr);
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

    await SettingsWriter.write(
      settings: settings,
      revision: ref.read(settingsRevisionProvider.notifier),
      repository: ref.read(settingsRepositoryProvider),
      mutate: (s) => s.defaultCategoryId = null,
    );
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

  /// Toggles [task] in the multi-select id set.
  void doMultiSelectionTask(Tasks task) {
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

/// Tasks notifier provider.
final tasksNotifierProvider = NotifierProvider<TasksNotifier, TasksState>(
  TasksNotifier.new,
);
