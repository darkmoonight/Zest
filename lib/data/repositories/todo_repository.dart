import 'package:isar_community/isar.dart';
import 'package:zest/data/mappers/todo_mapper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/repositories/todo_repository.dart';

/// Isar-backed CRUD and queries for ⟦Items⟧.
class TodoRepository implements TodoRepositoryPort {
  /// Creates a repository backed by [isar].
  TodoRepository(this._isar);

  /// Isar database handle.
  final Isar _isar;

  // ==================== CREATE ====================

  @override
  Future<Todo> create({
    required String name,
    required String description,
    required DateTime? completedTime,
    required bool fix,
    required Priority priority,
    required List<String> tags,
    required int index,
    required int categoryId,
    int? parentId,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final task = await _isar.tasks.get(categoryId);
    if (task == null) {
      throw StateError('Category $categoryId not found');
    }

    Todos? parent;
    if (parentId != null) {
      parent = await _isar.todos.get(parentId);
      if (parent == null) {
        throw StateError('Parent todo $parentId not found');
      }
    }

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

    return TodoMapper.toDomain(todo);
  }

  // ==================== READ ====================

  @override
  Future<List<Todo>> getAll() async {
    final rows = await _isar.todos.where().sortByIndex().findAll();
    await _prefetchLinks(rows);
    return TodoMapper.toDomainList(rows);
  }

  /// Loads [task] and [parent] links for [todos] concurrently.
  Future<void> _prefetchLinks(List<Todos> todos) async {
    if (todos.isEmpty) return;
    await Future.wait([
      for (final todo in todos) ...[todo.task.load(), todo.parent.load()],
    ]);
  }

  Future<Todo?> _toDomainOrNull(Todos? row) async {
    if (row == null) return null;
    await _prefetchLinks([row]);
    return TodoMapper.toDomain(row);
  }

  Future<List<Todo>> _toDomainList(List<Todos> rows) async {
    await _prefetchLinks(rows);
    return TodoMapper.toDomainList(rows);
  }

  @override
  Future<Todo?> getById(int id) async {
    return _toDomainOrNull(await _isar.todos.get(id));
  }

  @override
  Future<List<Todo>> getByCategoryId(int categoryId) async {
    final rows = await _isar.todos
        .filter()
        .task((q) => q.idEqualTo(categoryId))
        .sortByIndex()
        .findAll();
    return _toDomainList(rows);
  }

  @override
  Future<List<Todo>> getChildren(int parentId) async {
    final rows = await _isar.todos
        .filter()
        .parent((q) => q.idEqualTo(parentId))
        .sortByIndex()
        .findAll();
    return _toDomainList(rows);
  }

  // ==================== UPDATE ====================

  @override
  Future<void> update(Todo todo) async {
    final row = await _isar.todos.get(todo.id);
    if (row == null) return;
    TodoMapper.applyDomain(row, todo);
    await _isar.writeTxn(() => _isar.todos.put(row));
  }

  @override
  Future<void> updateStatusWithSubtasks({
    required int parentId,
    required TodoStatus status,
  }) async {
    final parentTodo = await _isar.todos.get(parentId);
    if (parentTodo == null) return;

    final allIds = <int>{};
    final stack = <Todos>[parentTodo];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (!allIds.add(current.id)) continue;

      final children = await _isar.todos
          .filter()
          .parent((q) => q.idEqualTo(current.id))
          .findAll();
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

  @override
  Future<void> updateFields({
    required Todo todo,
    required String name,
    required String description,
    required DateTime? completedTime,
    required bool fix,
    required Priority priority,
    required List<String> tags,
    required int categoryId,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final row = await _isar.todos.get(todo.id);
    if (row == null) return;

    final task = await _isar.tasks.get(categoryId);
    if (task == null) {
      throw StateError('Category $categoryId not found');
    }

    await _isar.writeTxn(() async {
      row.name = name;
      row.description = description;
      row.todoCompletedTime = completedTime;
      row.fix = fix;
      row.priority = priority;
      row.tags = tags;
      row.recurrence = recurrence;
      row.recurrenceWeekdays = recurrenceWeekdays;
      row.recurrenceMode = recurrenceMode;
      row.recurrenceMinuteOfDay = recurrenceMinuteOfDay;
      row.task.value = task;
      await _isar.todos.put(row);
      await row.task.save();
    });
  }

  @override
  Future<void> moveToCategory({
    required Set<int> todoIds,
    required int categoryId,
  }) async {
    if (todoIds.isEmpty) return;

    final task = await _isar.tasks.get(categoryId);
    if (task == null) {
      throw StateError('Category $categoryId not found');
    }

    final todos = <Todos>[];
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

  @override
  Future<void> moveToParent({
    required Set<int> rootIds,
    required Set<int> subtreeIds,
    int? newParentId,
    int? newCategoryId,
  }) async {
    if (rootIds.isEmpty || subtreeIds.isEmpty) return;

    Todos? newParent;
    if (newParentId != null) {
      newParent = await _isar.todos.get(newParentId);
    }

    Tasks? newTask;
    if (newCategoryId != null) {
      newTask = await _isar.tasks.get(newCategoryId);
    }

    final todos = <Todos>[];
    for (final id in subtreeIds) {
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
        if (rootIds.contains(todo.id)) {
          todo.parent.value = newParent;
        } else {
          final parent = todo.parent.value;
          if (parent != null && !subtreeIds.contains(parent.id)) {
            todo.parent.value = null;
          }
        }
        if (newTask != null) {
          todo.task.value = newTask;
        }
      }

      await _isar.todos.putAll(todos);

      for (final todo in todos) {
        await todo.task.save();
        await todo.parent.save();
      }
    });
  }

  @override
  Future<void> updateIndexes(List<Todo> todos) async {
    if (todos.isEmpty) return;

    await _isar.writeTxn(() async {
      final rows = <Todos>[];
      for (var i = 0; i < todos.length; i++) {
        final row = await _isar.todos.get(todos[i].id);
        if (row == null) continue;
        row.index = i;
        rows.add(row);
      }
      if (rows.isNotEmpty) {
        await _isar.todos.putAll(rows);
      }
    });
  }

  // ==================== DELETE ====================

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.todos.delete(id));
  }

  @override
  Future<void> deleteBatch(Set<int> ids) async {
    if (ids.isEmpty) return;

    await _isar.writeTxn(() async {
      await _isar.todos.deleteAll(ids.toList());
    });
  }

  // ==================== WATCH ====================

  @override
  Stream<void> watchLazy() {
    return _isar.todos.watchLazy();
  }

  @override
  Future<Todo?> getByCalDavUid(String uid) async {
    return _toDomainOrNull(
      await _isar.todos.filter().caldavUidEqualTo(uid).findFirst(),
    );
  }

  @override
  Future<List<Todo>> getDirtyCalDav() async {
    final rows = await _isar.todos.filter().caldavDirtyEqualTo(true).findAll();
    return _toDomainList(rows);
  }

  @override
  Future<List<Todo>> getWithCalDavUid() async {
    final rows = await _isar.todos.filter().caldavUidIsNotNull().findAll();
    return _toDomainList(rows);
  }

  @override
  Future<int> nextIndex() async {
    final todos = await getAll();
    if (todos.isEmpty) return 0;
    var maxIndex = -1;
    for (final todo in todos) {
      final index = todo.index ?? 0;
      if (index > maxIndex) maxIndex = index;
    }
    return maxIndex + 1;
  }

  @override
  Future<List<String>> collectUniqueTags() async {
    final todos = await getAll();
    final tags = <String>{};
    for (final todo in todos) {
      for (final tag in todo.tags) {
        final trimmed = tag.trim();
        if (trimmed.isNotEmpty) tags.add(trimmed);
      }
    }
    return tags.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  @override
  Future<void> clearAll() async {
    await _isar.writeTxn(() => _isar.todos.clear());
  }
}
