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

  Future<List<Todos>> getAll() async {
    return await _isar.todos.where().sortByIndex().findAll();
  }

  Future<Todos?> getById(int id) async {
    return await _isar.todos.get(id);
  }

  Future<List<Todos>> getByTaskId(int taskId) async {
    return await _isar.todos
        .filter()
        .task((q) => q.idEqualTo(taskId))
        .sortByIndex()
        .findAll();
  }

  Future<List<Todos>> getChildren(int parentId) async {
    return await _isar.todos
        .filter()
        .parent((q) => q.idEqualTo(parentId))
        .sortByIndex()
        .findAll();
  }

  Future<List<Todos>> getRoots() async {
    return await _isar.todos.filter().parentIsNull().sortByIndex().findAll();
  }

  Future<List<Todos>> getRootsByTask(int taskId) async {
    return await _isar.todos
        .filter()
        .task((q) => q.idEqualTo(taskId))
        .and()
        .parentIsNull()
        .sortByIndex()
        .findAll();
  }

  // ==================== UPDATE ====================

  Future<void> update(Todos todo) async {
    await _isar.writeTxn(() => _isar.todos.put(todo));
  }

  Future<void> updateDone({required Todos todo, required bool done}) async {
    final now = DateTime.now();
    await _isar.writeTxn(() async {
      todo.status = done ? TodoStatus.done : TodoStatus.active;
      todo.todoCompletionTime = done ? now : null;
      await _isar.todos.put(todo);
    });
  }

  Future<void> updateDoneById({required int id, required bool done}) async {
    final todo = await getById(id);
    if (todo == null) return;

    final now = DateTime.now();
    await _isar.writeTxn(() async {
      todo.status = done ? TodoStatus.done : TodoStatus.active;
      todo.todoCompletionTime = done ? now : null;
      await _isar.todos.put(todo);
    });
  }

  Future<void> updateDoneBatch({
    required Set<int> ids,
    required bool done,
  }) async {
    if (ids.isEmpty) return;

    final todos = <Todos>[];
    for (final id in ids) {
      final todo = await _isar.todos.get(id);
      if (todo != null) {
        todos.add(todo);
      }
    }

    if (todos.isEmpty) return;

    final now = DateTime.now();
    await _isar.writeTxn(() async {
      for (final todo in todos) {
        todo.status = done ? TodoStatus.done : TodoStatus.active;
        todo.todoCompletionTime = done ? now : null;
      }

      await _isar.todos.putAll(todos);
    });
  }

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

  Future<List<Todos>> getByPriority(Priority priority) async {
    return await _isar.todos
        .filter()
        .priorityEqualTo(priority)
        .sortByIndex()
        .findAll();
  }

  Future<List<Todos>> getPinned() async {
    return await _isar.todos.filter().fixEqualTo(true).sortByIndex().findAll();
  }

  Future<List<Todos>> getByDoneStatus(bool done) async {
    final status = done ? TodoStatus.done : TodoStatus.active;
    return await _isar.todos
        .filter()
        .statusEqualTo(status)
        .sortByIndex()
        .findAll();
  }

  Future<List<Todos>> getByDateRange(DateTime start, DateTime end) async {
    return await _isar.todos
        .filter()
        .todoCompletedTimeBetween(start, end)
        .sortByIndex()
        .findAll();
  }

  Future<int> countByTask(int taskId) async {
    return await _isar.todos.filter().task((q) => q.idEqualTo(taskId)).count();
  }

  Future<int> countCompletedByTask(int taskId) async {
    return await _isar.todos
        .filter()
        .task((q) => q.idEqualTo(taskId))
        .group((q) => q
            .statusEqualTo(TodoStatus.done)
            .or()
            .statusEqualTo(TodoStatus.cancelled))
        .count();
  }
}
