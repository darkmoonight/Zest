import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/data/repositories/task_repository.dart';
import 'package:zest/app/data/repositories/todo_repository.dart';
import 'package:zest/app/services/task_service.dart';
import 'package:zest/app/services/todo_service.dart';
import 'package:zest/app/services/notification_service.dart';
import 'package:zest/app/constants/app_constants.dart';

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}

class TodoController extends GetxController {
  // ==================== Stream Subscriptions ====================
  StreamSubscription<void>? _taskWatcherSubscription;
  StreamSubscription<void>? _todoWatcherSubscription;

  // ==================== Repositories ====================
  late final TaskRepository _taskRepo;
  late final TodoRepository _todoRepo;

  // ==================== Services ====================
  late final TaskService _taskService;
  late final TodoService _todoService;

  // ==================== Observable State ====================
  final tasks = <Tasks>[].obs;
  final todos = <Todos>[].obs;

  // Multi-selection Tasks
  final selectedTask = <Tasks>[].obs;
  final isMultiSelectionTask = false.obs;

  // Multi-selection Todos
  final selectedTodo = <Todos>[].obs;
  final selectedTodoIds = <int>{}.obs;
  final isMultiSelectionTodo = false.obs;

  // PopScope control
  final isPop = true.obs;

  // ==================== Private ====================
  Timer? _loadDebounce;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    _initializeRepositories();
    _initializeServices();
    _loadTasksAndTodos();
    _setupWatchers();
  }

  @override
  void onClose() {
    _loadDebounce?.cancel();
    _taskWatcherSubscription?.cancel();
    _todoWatcherSubscription?.cancel();
    super.onClose();
  }

  void _initializeRepositories() {
    _taskRepo = TaskRepository();
    _todoRepo = TodoRepository();
  }

  void _initializeServices() {
    final notificationService = NotificationService();

    _taskService = TaskService(
      taskRepo: _taskRepo,
      todoRepo: _todoRepo,
      notificationService: notificationService,
    );

    _todoService = TodoService(
      todoRepo: _todoRepo,
      notificationService: notificationService,
    );
  }

  void _setupWatchers() {
    _taskWatcherSubscription = _taskRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    _todoWatcherSubscription = _todoRepo.watchLazy().listen((_) {
      _debounceLoad();
    });
  }

  void _debounceLoad() {
    _loadDebounce?.cancel();
    _loadDebounce = Timer(AppConstants.debounceDelay, _loadTasksAndTodos);
  }

  // ==================== Load Data ====================

  void _loadTasksAndTodos() {
    final preservedSelectedIds = selectedTodoIds.toSet();

    final newTasks = _taskRepo.getAll();
    final newTodos = _todoRepo.getAll();

    tasks.assignAll(newTasks);
    todos.assignAll(newTodos);

    _restoreSelectedTodos(preservedSelectedIds);
  }

  void _restoreSelectedTodos(Set<int> preservedIds) {
    if (preservedIds.isEmpty) {
      doMultiSelectionTodoClear();
      return;
    }

    final todosMap = {for (var todo in todos) todo.id: todo};
    final restored = preservedIds
        .map((id) => todosMap[id])
        .whereType<Todos>()
        .toList();

    selectedTodo.assignAll(restored);
    selectedTodoIds.assignAll(restored.map((e) => e.id));

    if (restored.isEmpty) {
      doMultiSelectionTodoClear();
    } else {
      isMultiSelectionTodo.value = true;
      isPop.value = false;
    }
  }

  // ==================== Tasks CRUD ====================

  Future<void> addTask(String title, String description, Color color) async {
    final task = await _taskService.createTask(
      title: title,
      description: description,
      color: color,
      currentTaskCount: tasks.length,
    );

    if (task != null) {
      tasks.add(task);
    }
  }

  Future<void> updateTask(
    Tasks task,
    String title,
    String description,
    Color color,
  ) async {
    await _taskService.updateTask(
      task: task,
      title: title,
      description: description,
      color: color,
    );

    _refreshTask(task);
  }

  void _refreshTask(Tasks task) {
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      tasks[idx] = task;
      tasks.refresh();
    } else {
      _loadTasksAndTodos();
    }
    todos.refresh();
  }

  Future<void> deleteTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();

    await _taskService.deleteTasks(taskList);

    tasks.assignAll(_taskRepo.getAll());
    _reindexTasks();
  }

  Future<void> archiveTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await _taskService.archiveTasks(taskList);
    tasks.assignAll(_taskRepo.getAll());
    todos.assignAll(_todoRepo.getAll());
    doMultiSelectionTaskClear();
    _resyncSelectedTodoFromIds();
  }

  Future<void> noArchiveTask(List<Tasks> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await _taskService.unarchiveTasks(taskList);
    tasks.assignAll(_taskRepo.getAll());
    todos.assignAll(_todoRepo.getAll());
    doMultiSelectionTaskClear();
    _resyncSelectedTodoFromIds();
  }

  Future<void> reorderTasks({
    required List<Tasks> filteredTasks,
    required bool archived,
  }) async {
    if (filteredTasks.isEmpty) return;

    await _taskService.reorderTasks(
      allTasks: tasks.toList(),
      filteredTasks: filteredTasks,
    );

    tasks.assignAll(_taskRepo.getAll());
  }

  void _reindexTasks() {
    final all = tasks.toList();

    for (int i = 0; i < all.length; i++) {
      all[i].index = i;
    }

    _taskRepo.updateIndexes(all);
    tasks.assignAll(all);
  }

  // ==================== Todos CRUD ====================

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
    final todo = await _todoService.createTodo(
      task: task,
      title: title,
      description: description,
      timeString: time,
      pinned: pinned,
      priority: priority,
      tags: tags,
      currentTodoCount: todos.length,
      parent: parent,
    );

    todos.add(todo);
    return todo;
  }

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
    await _todoService.updateTodo(
      todo: todo,
      task: task,
      title: title,
      description: description,
      timeString: time,
      pinned: pinned,
      priority: priority,
      tags: tags,
    );

    _refreshTodo(todo);
  }

  void _refreshTodo(Todos todo) {
    final idx = todos.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      todos[idx] = todo;
      todos.refresh();
    } else {
      _loadTasksAndTodos();
    }
  }

  Future<void> updateTodoCheck(Todos todo) async {
    await _todoService.toggleDone(todo, todos);

    todos.assignAll(_todoRepo.getAll());
    _resyncSelectedTodoFromIds();
  }

  Future<void> moveTodos(List<Todos> todoList, Tasks task) async {
    if (todoList.isEmpty) return;

    await _todoService.moveTodos(todos: todoList, task: task);
    _loadTasksAndTodos();
  }

  Future<void> moveTodosToParent(List<Todos> rootList, Todos? newParent) async {
    if (rootList.isEmpty) return;

    await _todoService.moveTodosToParent(
      rootTodos: rootList,
      newParent: newParent,
    );
    _loadTasksAndTodos();
  }

  Future<void> deleteTodo(List<Todos> todoList) async {
    if (todoList.isEmpty) return;

    _loadDebounce?.cancel();

    await _todoService.deleteTodos(todoList);

    for (final t in todoList) {
      selectedTodoIds.remove(t.id);
    }

    todos.assignAll(_todoRepo.getAll());
    _resyncSelectedTodoFromIds();
    _reindexTodos();
  }

  void _reindexTodos() {
    final all = todos.toList();

    for (int i = 0; i < all.length; i++) {
      all[i].index = i;
    }

    _todoRepo.updateIndexes(all);
    todos.assignAll(all);
  }

  // ==================== Counters ====================

  int createdAllTodos() => _todoService.countAll(todos);

  int completedAllTodos() => _todoService.countAllCompleted(todos);

  int createdAllTodosTask(Tasks task) => _todoService.countForTask(task, todos);

  int completedAllTodosTask(Tasks task) =>
      _todoService.countCompletedForTask(task, todos);

  int countTotalTodosCalendar(DateTime date) =>
      _todoService.countForCalendar(date, todos);

  int createdAllTodosTodo(Todos parent) =>
      _todoService.countForParent(parent, todos);

  int completedAllTodosTodo(Todos parent) =>
      _todoService.countCompletedForParent(parent, todos);

  // ==================== Filters ====================

  List<Tasks> getFilteredTasks({
    required bool archived,
    String searchQuery = '',
  }) {
    return _taskService.filterTasks(
      tasks: tasks,
      archived: archived,
      searchQuery: searchQuery,
    );
  }

  List<Todos> getFilteredTodos({
    required bool done,
    String searchQuery = '',
    DateTime? selectedDay,
    Tasks? task,
    Todos? parent,
  }) {
    return _todoService.filterTodos(
      allTodos: todos,
      done: done,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      task: task,
      parent: parent,
    );
  }

  // ==================== Multi-Selection Tasks ====================

  void doMultiSelectionTask(Tasks task) {
    if (!isMultiSelectionTask.isTrue) return;

    isPop.value = false;

    if (selectedTask.contains(task)) {
      selectedTask.remove(task);
    } else {
      selectedTask.add(task);
    }

    if (selectedTask.isEmpty) {
      isMultiSelectionTask.value = false;
      isPop.value = true;
    }
  }

  void doMultiSelectionTaskClear() {
    selectedTask.clear();
    isMultiSelectionTask.value = false;
    isPop.value = true;
  }

  void toggleMultiSelectionTask() {
    isMultiSelectionTask.value = !isMultiSelectionTask.value;

    if (!isMultiSelectionTask.value) {
      doMultiSelectionTaskClear();
    } else {
      isPop.value = false;
    }
  }

  bool areAllTasksSelected({required bool archived, String searchQuery = ''}) {
    final filtered = getFilteredTasks(
      archived: archived,
      searchQuery: searchQuery,
    );

    return filtered.isNotEmpty &&
        filtered.every((task) => selectedTask.contains(task));
  }

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
      if (!isMultiSelectionTask.isTrue) {
        isMultiSelectionTask.value = true;
        isPop.value = false;
      }

      for (final t in filtered) {
        if (!selectedTask.contains(t)) {
          selectedTask.add(t);
        }
      }
    } else {
      for (final t in filtered) {
        selectedTask.remove(t);
      }

      if (selectedTask.isEmpty) {
        isMultiSelectionTask.value = false;
        isPop.value = true;
      }
    }
  }

  // ==================== Multi-Selection Todos ====================

  void doMultiSelectionTodo(Todos todo) {
    if (!isMultiSelectionTodo.isTrue) return;

    isPop.value = false;

    if (selectedTodoIds.contains(todo.id)) {
      selectedTodoIds.remove(todo.id);
    } else {
      selectedTodoIds.add(todo.id);
    }

    _resyncSelectedTodoFromIds();
  }

  void doMultiSelectionTodoClear() {
    selectedTodoIds.clear();
    selectedTodo.clear();
    isMultiSelectionTodo.value = false;
    isPop.value = true;
  }

  void toggleMultiSelectionTodo() {
    isMultiSelectionTodo.value = !isMultiSelectionTodo.value;

    if (!isMultiSelectionTodo.value) {
      doMultiSelectionTodoClear();
    } else {
      isPop.value = false;
    }
  }

  void _resyncSelectedTodoFromIds() {
    if (selectedTodoIds.isEmpty) {
      doMultiSelectionTodoClear();
      return;
    }

    final todosMap = {for (var todo in todos) todo.id: todo};
    final updated = selectedTodoIds
        .map((id) => todosMap[id])
        .whereType<Todos>()
        .toList();

    selectedTodo.assignAll(updated);

    if (updated.isEmpty) {
      doMultiSelectionTodoClear();
    } else {
      isMultiSelectionTodo.value = true;
      isPop.value = false;
      selectedTodoIds.assignAll(updated.map((e) => e.id));
    }
  }

  bool areAllSelected({
    required bool done,
    String searchQuery = '',
    DateTime? selectedDay,
    Tasks? task,
    Todos? parent,
  }) {
    final filtered = getFilteredTodos(
      done: done,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      task: task,
      parent: parent,
    );

    return filtered.isNotEmpty &&
        filtered.every((todo) => selectedTodoIds.contains(todo.id));
  }

  void selectAll({
    required bool select,
    required bool done,
    String searchQuery = '',
    DateTime? selectedDay,
    Tasks? task,
    Todos? parent,
  }) {
    final filtered = getFilteredTodos(
      done: done,
      searchQuery: searchQuery,
      selectedDay: selectedDay,
      task: task,
      parent: parent,
    );

    if (select) {
      if (!isMultiSelectionTodo.isTrue) {
        isMultiSelectionTodo.value = true;
        isPop.value = false;
      }

      for (final todo in filtered) {
        selectedTodoIds.add(todo.id);
      }
    } else {
      for (final todo in filtered) {
        selectedTodoIds.remove(todo.id);
      }

      if (selectedTodoIds.isEmpty) {
        isMultiSelectionTodo.value = false;
        isPop.value = true;
      }
    }

    _resyncSelectedTodoFromIds();
  }
}
