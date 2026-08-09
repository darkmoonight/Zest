import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';

/// Isar-backed CRUD and queries for [Todos].
class TodoRepository {
  /// Creates a repository backed by [isar].
  TodoRepository(this._isar);

  /// Isar database handle.
  final Isar _isar;

  // ==================== CREATE ====================

  /// Creates a todo linked to [task] and optional [parent].
  Future<Todos> create({
    required String name,
    required String description,
    required DateTime? completedTime,
    required bool fix,
    required Priority priority,
    required List<String> tags,
    required int index,
    required Tasks task,
    Todos? parent,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final todo = Todos(
      name: name,
      description: description,
      todoCompletedTime: completedTime,
      fix: fix,
      createdTime: DateTime.now(),
      priority: priority,
      tags: tags,
      index: index,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    )..task.value = task;

    if (parent != null) {
      todo.parent.value = parent;
    }

    await _isar.writeTxn(() async {
      await _isar.todos.put(todo);
      await todo.task.save();
      if (parent != null) {
        await todo.parent.save();
      }
    });

    return todo;
  }

  // ==================== READ ====================

  /// Returns all todos sorted by [Todos.index].
  Future<List<Todos>> getAll() async {
    return await _isar.todos.where().sortByIndex().findAll();
  }

  /// Returns the todo with [id], or null when missing.
  Future<Todos?> getById(int id) async {
    return await _isar.todos.get(id);
  }

  /// Returns todos belonging to the task with [taskId].
  Future<List<Todos>> getByTaskId(int taskId) async {
    return await _isar.todos
        .filter()
        .task((q) => q.idEqualTo(taskId))
        .sortByIndex()
        .findAll();
  }

  /// Returns direct child todos of the parent with [parentId].
  Future<List<Todos>> getChildren(int parentId) async {
    return await _isar.todos
        .filter()
        .parent((q) => q.idEqualTo(parentId))
        .sortByIndex()
        .findAll();
  }

  // ==================== UPDATE ====================

  /// Persists changes on an existing [todo].
  Future<void> update(Todos todo) async {
    await _isar.writeTxn(() => _isar.todos.put(todo));
  }

  /// Sets [status] on [parentTodo] and all descendant subtasks.
  Future<void> updateStatusWithSubtasks({
    required Todos parentTodo,
    required TodoStatus status,
  }) async {
    final allIds = <int>{};
    final stack = <Todos>[parentTodo];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (!allIds.add(current.id)) continue;

      final children = await getChildren(current.id);
      for (final child in children) {
        if (!allIds.contains(child.id)) {
          stack.add(child);
        }
      }
    }

    if (allIds.isEmpty) return;

    final todos = <Todos>[];
    for (final id in allIds) {
      final todo = await _isar.todos.get(id);
      if (todo != null) {
        todos.add(todo);
      }
    }

    if (todos.isEmpty) return;

    final now = DateTime.now();
    await _isar.writeTxn(() async {
      for (final todo in todos) {
        todo.status = status;
        todo.todoCompletionTime = status.isCompleted ? now : null;
      }
      await _isar.todos.putAll(todos);
    });
  }

  /// Updates editable fields on [todo] and re-links [task].
  Future<void> updateFields({
    required Todos todo,
    required String name,
    required String description,
    required DateTime? completedTime,
    required bool fix,
    required Priority priority,
    required List<String> tags,
    required Tasks task,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    await _isar.writeTxn(() async {
      todo.name = name;
      todo.description = description;
      todo.todoCompletedTime = completedTime;
      todo.fix = fix;
      todo.priority = priority;
      todo.tags = tags;
      todo.recurrence = recurrence;
      todo.recurrenceWeekdays = recurrenceWeekdays;
      todo.recurrenceMode = recurrenceMode;
      todo.recurrenceMinuteOfDay = recurrenceMinuteOfDay;
      todo.task.value = task;
      await _isar.todos.put(todo);
      await todo.task.save();
    });
  }

  /// Moves todos in [todoIds] to [task], detaching from external parents.
  Future moveToTask({required Set todoIds, required Tasks task}) async {
    if (todoIds.isEmpty) return;

    final List<Todos> todos = [];
    for (final id in todoIds) {
      final todo = await _isar.todos.get(id);
      if (todo != null) {
        todos.add(todo);
      }
    }

    if (todos.isEmpty) return;

    for (final todo in todos) {
      await todo.parent.load();
    }

    await _isar.writeTxn(() async {
      for (final todo in todos) {
        todo.task.value = task;

        final parent = todo.parent.value;

        if (parent != null && !todoIds.contains(parent.id)) {
          todo.parent.value = null;
        }
      }

      await _isar.todos.putAll(todos);

      for (final todo in todos) {
        await todo.task.save();
        await todo.parent.save();
      }
    });
  }

  /// Reparents todos in [todoIds] under [newParent] and optionally [newTask].
  Future<void> moveToParent({
    required Set<int> todoIds,
    required Todos? newParent,
    required Tasks? newTask,
  }) async {
    if (todoIds.isEmpty) return;

    final todos = <Todos>[];
    for (final id in todoIds) {
      final todo = await _isar.todos.get(id);
      if (todo != null) {
        todos.add(todo);
      }
    }

    if (todos.isEmpty) return;

    await _isar.writeTxn(() async {
      for (final todo in todos) {
        todo.parent.value = newParent;
        if (newTask != null) {
          todo.task.value = newTask;
        }
      }

      await _isar.todos.putAll(todos);

      for (final todo in todos) {
        await todo.task.save();
        if (todo.parent.value != null) {
          await todo.parent.save();
        }
      }
    });
  }

  /// Persists sequential [Todos.index] values for [todos].
  Future<void> updateIndexes(List<Todos> todos) async {
    if (todos.isEmpty) return;

    await _isar.writeTxn(() async {
      for (int i = 0; i < todos.length; i++) {
        todos[i].index = i;
      }
      await _isar.todos.putAll(todos);
    });
  }

  // ==================== DELETE ====================

  /// Deletes the todo with [id].
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.todos.delete(id));
  }

  /// Deletes all todos whose ids are in [ids].
  Future<void> deleteBatch(Set<int> ids) async {
    if (ids.isEmpty) return;

    await _isar.writeTxn(() async {
      await _isar.todos.deleteAll(ids.toList());
    });
  }

  // ==================== WATCH ====================

  /// Emits when any todo collection change may have occurred.
  Stream<void> watchLazy() {
    return _isar.todos.watchLazy();
  }
}
