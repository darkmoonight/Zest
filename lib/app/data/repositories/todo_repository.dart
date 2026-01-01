import 'package:isar_community/isar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/main.dart';

class TodoRepository {
  final Isar _isar = isar;

  // ==================== CREATE ====================

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

  List<Todos> getAll() {
    return _isar.todos.where().sortByIndex().findAllSync();
  }

  Todos? getById(int id) {
    return _isar.todos.getSync(id);
  }

  List<Todos> getByTaskId(int taskId) {
    return _isar.todos
        .filter()
        .task((q) => q.idEqualTo(taskId))
        .sortByIndex()
        .findAllSync();
  }

  List<Todos> getChildren(int parentId) {
    return _isar.todos
        .filter()
        .parent((q) => q.idEqualTo(parentId))
        .sortByIndex()
        .findAllSync();
  }

  List<Todos> getRoots() {
    return _isar.todos.filter().parentIsNull().sortByIndex().findAllSync();
  }

  List<Todos> getRootsByTask(int taskId) {
    return _isar.todos
        .filter()
        .task((q) => q.idEqualTo(taskId))
        .and()
        .parentIsNull()
        .sortByIndex()
        .findAllSync();
  }

  // ==================== UPDATE ====================

  Future<void> update(Todos todo) async {
    await _isar.writeTxn(() => _isar.todos.put(todo));
  }

  Future<void> updateDone({required Todos todo, required bool done}) async {
    final now = DateTime.now();
    await _isar.writeTxn(() async {
      todo.done = done;
      todo.todoCompletionTime = done ? now : null;
      await _isar.todos.put(todo);
    });
  }

  Future<void> updateDoneById({required int id, required bool done}) async {
    final todo = getById(id);
    if (todo == null) return;

    final now = DateTime.now();
    await _isar.writeTxn(() async {
      todo.done = done;
      todo.todoCompletionTime = done ? now : null;
      await _isar.todos.put(todo);
    });
  }

  Future<void> updateDoneBatch({
    required Set<int> ids,
    required bool done,
  }) async {
    if (ids.isEmpty) return;

    final todos = ids
        .map((id) => _isar.todos.getSync(id))
        .whereType<Todos>()
        .toList();

    if (todos.isEmpty) return;

    final now = DateTime.now();
    await _isar.writeTxn(() async {
      for (final todo in todos) {
        todo.done = done;
        todo.todoCompletionTime = done ? now : null;
      }

      await _isar.todos.putAll(todos);
    });
  }

  Future<void> updateFields({
    required Todos todo,
    required String name,
    required String description,
    required DateTime? completedTime,
    required bool fix,
    required Priority priority,
    required List<String> tags,
    required Tasks task,
  }) async {
    await _isar.writeTxn(() async {
      todo.name = name;
      todo.description = description;
      todo.todoCompletedTime = completedTime;
      todo.fix = fix;
      todo.priority = priority;
      todo.tags = tags;
      todo.task.value = task;
      await _isar.todos.put(todo);
      await todo.task.save();
    });
  }

  Future moveToTask({required Set todoIds, required Tasks task}) async {
    if (todoIds.isEmpty) return;

    final List<Todos> todos = todoIds
        .map((id) => _isar.todos.getSync(id))
        .whereType<Todos>()
        .toList();

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

  Future<void> moveToParent({
    required Set<int> todoIds,
    required Todos? newParent,
    required Tasks? newTask,
  }) async {
    if (todoIds.isEmpty) return;

    final todos = todoIds
        .map((id) => _isar.todos.getSync(id))
        .whereType<Todos>()
        .toList();

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

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.todos.delete(id));
  }

  Future<void> deleteBatch(Set<int> ids) async {
    if (ids.isEmpty) return;

    await _isar.writeTxn(() async {
      await _isar.todos.deleteAll(ids.toList());
    });
  }

  // ==================== WATCH ====================

  Stream<void> watchLazy() {
    return _isar.todos.watchLazy();
  }

  // ==================== ADDITIONAL QUERIES ====================

  List<Todos> getByPriority(Priority priority) {
    return _isar.todos
        .filter()
        .priorityEqualTo(priority)
        .sortByIndex()
        .findAllSync();
  }

  List<Todos> getPinned() {
    return _isar.todos.filter().fixEqualTo(true).sortByIndex().findAllSync();
  }

  List<Todos> getByDoneStatus(bool done) {
    return _isar.todos.filter().doneEqualTo(done).sortByIndex().findAllSync();
  }

  List<Todos> getByDateRange(DateTime start, DateTime end) {
    return _isar.todos
        .filter()
        .todoCompletedTimeBetween(start, end)
        .sortByIndex()
        .findAllSync();
  }

  Future<int> countByTask(int taskId) {
    return _isar.todos.filter().task((q) => q.idEqualTo(taskId)).count();
  }

  Future<int> countCompletedByTask(int taskId) {
    return _isar.todos
        .filter()
        .task((q) => q.idEqualTo(taskId))
        .doneEqualTo(true)
        .count();
  }
}
