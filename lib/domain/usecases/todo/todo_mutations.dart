part of 'todo_usecases.dart';

mixin _TodoMutations on _TodoServiceBase {
  /// Creates a list item under [category] and schedules a reminder when due.
  Future<Todo> createTodo({
    required Category category,
    required String title,
    required String description,
    required String timeString,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    required int currentTodoCount,
    Todo? parent,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final date = _resolveDueDate(
      timeString: timeString,
      category: category,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    final todo = await _todoRepo.create(
      name: title,
      description: description,
      completedTime: date,
      fix: pinned,
      priority: priority,
      tags: tags,
      index: currentTodoCount,
      categoryId: category.id,
      parentId: parent?.id,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    if (date != null) {
      await _notificationService.scheduleForTodo(todo, category: category);
    }
    await _calendarSync?.ensureSynced(todo);
    await _caldavSync?.markDirty(todo);

    return todo;
  }

  // ==================== UPDATE ====================

  /// Updates item fields and reschedules or cancels its reminder.
  Future<void> updateTodo({
    required Todo todo,
    required Category category,
    required String title,
    required String description,
    required String timeString,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final date = _resolveDueDatePreservingOnParseFailure(
      todo: todo,
      timeString: timeString,
      category: category,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    await _todoRepo.updateFields(
      todo: todo,
      name: title,
      description: description,
      completedTime: date,
      fix: pinned,
      priority: priority,
      tags: tags,
      categoryId: category.id,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    final updated = todo.copyWith(
      name: title,
      description: description,
      dueAt: date,
      clearDueAt: date == null,
      fix: pinned,
      priority: priority,
      tags: tags,
      categoryId: category.id,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
      clearRecurrenceMinuteOfDay: recurrenceMinuteOfDay == null,
    );

    if (date != null) {
      await _notificationService.reschedule(updated, category: category);
    } else {
      await _notificationService.cancel(todo.id);
    }
    await _calendarSync?.ensureSynced(updated);
    await _caldavSync?.markDirty(updated);
  }

  /// Persists [todo] status and syncs its notification schedule.
  Future<void> updateTodoStatus(Todo todo) async {
    await _todoRepo.update(todo);

    final completedTime = todo.dueAt;

    if (todo.status == TodoStatus.done || todo.status == TodoStatus.cancelled) {
      await _notificationService.cancel(todo.id);
    } else if (completedTime != null) {
      await _notificationService.scheduleForTodo(todo);
    } else {
      await _notificationService.cancel(todo.id);
    }
    await _calendarSync?.ensureSynced(todo);
    await _caldavSync?.markDirty(todo);
  }

  /// Marks [todo] done and cancels its reminder.
  Future<void> markTodoAsDone(Todo todo) async {
    if (todo.status == TodoStatus.done) return;

    await updateTodoStatus(
      todo.copyWith(status: TodoStatus.done, completedAt: DateTime.now()),
    );
  }

  /// Snoozes [todo] by [settings.snoozeDuration] and reschedules its reminder.
  Future<void> snoozeTodo(Todo todo, AppSettings settings) async {
    final newTime = DateTime.now().add(
      Duration(minutes: settings.snoozeDuration),
    );
    final updated = todo.copyWith(dueAt: newTime);
    await _todoRepo.update(updated);
    await _notificationService.snooze(updated, settings);
    await _calendarSync?.ensureSynced(updated);
    await _caldavSync?.markDirty(updated);
  }

  /// Sets [todo] and all subtasks to [status] and updates notifications.
  Future<void> updateStatusWithSubtasks(Todo todo, TodoStatus status) async {
    await _todoRepo.updateStatusWithSubtasks(parentId: todo.id, status: status);

    final allIds = await collectSubtreeIds(todo);

    if (status.isCompleted) {
      await _notificationService.cancelBatch(allIds.toList());
      for (final id in allIds) {
        final todoItem = await _todoRepo.getById(id);
        if (todoItem != null) {
          await _calendarSync?.ensureSynced(todoItem);
          await _caldavSync?.markDirty(todoItem);
        }
      }
    } else {
      for (final id in allIds) {
        final todoItem = await _todoRepo.getById(id);
        if (todoItem != null && todoItem.dueAt != null) {
          await _notificationService.scheduleForTodo(todoItem);
        }
        if (todoItem != null) {
          await _calendarSync?.ensureSynced(todoItem);
          await _caldavSync?.markDirty(todoItem);
        }
      }
    }
  }

  /// Deletes [todos], their subtrees, and associated notifications.
  Future<void> deleteTodos(List<Todo> todos) async {
    if (todos.isEmpty) return;

    final todosCopy = List<Todo>.from(todos);
    final allIds = <int>{};

    for (final root in todosCopy) {
      final subtreeIds = await collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _notificationService.cancelBatch(allIds.toList());
    for (final id in allIds) {
      final todoItem = await _todoRepo.getById(id);
      if (todoItem != null) {
        await _calendarSync?.removeSynced(todoItem);
        await _caldavSync?.enqueueDelete(todoItem);
      }
    }
    await _todoRepo.deleteBatch(allIds);
  }

  // ==================== REORDER ====================

  /// Reorders [allTodos] so filtered positions match [filteredTodos] order.
  Future<void> reorderTodos({
    required List<Todo> allTodos,
    required List<Todo> filteredTodos,
  }) async {
    if (filteredTodos.isEmpty) return;

    reorderFilteredInPlace(
      all: allTodos,
      filtered: filteredTodos,
      idOf: (t) => t.id,
      assignIndex: (_, _) {},
    );
    await _todoRepo.updateIndexes(allTodos);
  }

  // ==================== HELPERS ====================

  DateTime? _resolveDueDate({
    required String timeString,
    required Category category,
    required RecurrenceFrequency recurrence,
    required List<int> recurrenceWeekdays,
    required int? recurrenceMinuteOfDay,
  }) {
    final parsed = _parseDate(timeString);
    return RecurrenceService.resolveDueForTodoInCategory(
      now: DateTime.now(),
      category: category,
      todoRecurrence: recurrence,
      todoWeekdays: recurrenceWeekdays,
      todoMinuteOfDay: recurrenceMinuteOfDay,
      baseDay: parsed,
      fallbackTime: parsed,
    );
  }

  DateTime? _resolveDueDatePreservingOnParseFailure({
    required Todo todo,
    required String timeString,
    required Category category,
    required RecurrenceFrequency recurrence,
    required List<int> recurrenceWeekdays,
    required int? recurrenceMinuteOfDay,
  }) {
    if (timeString.isNotEmpty && _parseDate(timeString) == null) {
      return todo.dueAt;
    }
    return _resolveDueDate(
      timeString: timeString,
      category: category,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
  }

  DateTime? _parseDate(String timeString) => DateTimeFormatHelper.parseDateTime(
    timeString,
    timeformat: _timeformat,
    languageCode: _languageCode,
  );
}
