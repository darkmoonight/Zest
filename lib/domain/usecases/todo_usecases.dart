import 'package:flutter/foundation.dart' hide Category;
import 'package:zest/core/caldav/caldav_sync_service.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/reorder_filtered.dart';
import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/todo_repository.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/recurrence_service.dart';

/// Item CRUD, status changes, moves, and notification scheduling.
class TodoService {
  /// Creates a service with repository, notifications, and locale formatting.
  TodoService({
    required this._todoRepo,
    required this._notificationService,
    this._calendarSync,
    this._caldavSync,
    this._timeformat = AppConstants.defaultTimeformat,
    this._languageCode = AppConstants.defaultLanguageCode,
  });

  /// Persistence layer for item entities.
  final TodoRepositoryPort _todoRepo;

  /// Schedules and cancels item reminder notifications.
  final NotificationService _notificationService;

  /// Optional one-way export of deadlines to the device calendar.
  final DeviceCalendarSyncService? _calendarSync;

  /// Optional two-way CalDAV VTODO sync.
  final CalDavSyncService? _caldavSync;

  /// User time format for parsing due-date strings.
  final String _timeformat;

  /// Language code used when parsing due-date strings.
  final String _languageCode;

  // ==================== CREATE ====================

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

  // ==================== MOVE ====================

  /// Moves [todos] and their subtrees to [category].
  Future<void> moveTodos({
    required List<Todo> todos,
    required Category category,
  }) async {
    if (todos.isEmpty) return;

    final todosCopy = List<Todo>.from(todos);
    final allIds = <int>{};

    for (final root in todosCopy) {
      final subtreeIds = await collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _todoRepo.moveToCategory(todoIds: allIds, categoryId: category.id);
    await _syncCalDavAfterHierarchyChange(allIds);
  }

  /// Reparents [rootTodos] under [newParent], preserving nested subtrees.
  Future<void> moveTodosToParent({
    required List<Todo> rootTodos,
    required Todo? newParent,
  }) async {
    if (rootTodos.isEmpty) return;

    final rootTodosCopy = List<Todo>.from(rootTodos);
    final subtreeByRoot = <int, Set<int>>{};
    for (final root in rootTodosCopy) {
      subtreeByRoot[root.id] = await collectSubtreeIds(root);
    }

    final effectiveRoots = rootTodosCopy.where((root) {
      return !rootTodosCopy.any(
        (other) =>
            other.id != root.id &&
            (subtreeByRoot[other.id]?.contains(root.id) ?? false),
      );
    }).toList();

    final rootIds = <int>{};
    final allIds = <int>{};
    for (final root in effectiveRoots) {
      rootIds.add(root.id);
      allIds.addAll(subtreeByRoot[root.id] ?? {root.id});
    }

    if (allIds.isEmpty) return;

    if (newParent != null && allIds.contains(newParent.id)) {
      debugPrint(
        'moveTodosToParent rejected: newParent ${newParent.id} is in moved subtree',
      );
      return;
    }

    await _todoRepo.moveToParent(
      rootIds: rootIds,
      subtreeIds: allIds,
      newParentId: newParent?.id,
      newCategoryId: newParent?.categoryId,
    );
    await _syncCalDavAfterHierarchyChange(allIds);
  }

  Future<void> _syncCalDavAfterHierarchyChange(Set<int> todoIds) async {
    final caldav = _caldavSync;
    if (caldav == null) return;

    for (final id in todoIds) {
      final todo = await _todoRepo.getById(id);
      if (todo == null) continue;
      if (todo.parentId != null) {
        await caldav.enqueueDelete(todo);
        await _todoRepo.update(
          todo.copyWith(
            clearCaldavUid: true,
            clearCaldavHref: true,
            clearCaldavEtag: true,
            caldavDirty: false,
          ),
        );
      } else {
        await caldav.markDirty(todo);
      }
    }
  }

  // ==================== DELETE ====================

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

  /// Collects ids for [root] and every descendant item.
  Future<Set<int>> collectSubtreeIds(Todo root) async {
    final ids = <int>{};
    final stack = <Todo>[root];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (!ids.add(node.id)) continue;

      final children = await _todoRepo.getChildren(node.id);
      for (final child in children) {
        if (!ids.contains(child.id)) {
          stack.add(child);
        }
      }
    }

    return ids;
  }

  /// Collects ids for every root in [roots] and their descendants.
  Future<Set<int>> collectSubtreeIdsForRoots(Iterable<Todo> roots) async {
    final ids = <int>{};
    for (final root in roots) {
      ids.addAll(await collectSubtreeIds(root));
    }
    return ids;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // ==================== COUNTERS ====================

  /// Counts root-level items belonging to [category].
  int countForCategory(Category category, List<Todo> allTodos) {
    return allTodos
        .where((t) => t.categoryId == category.id && t.parentId == null)
        .length;
  }

  /// Counts completed root-level items belonging to [category].
  int countCompletedForCategory(Category category, List<Todo> allTodos) {
    return allTodos
        .where(
          (t) =>
              t.categoryId == category.id &&
              t.status.isCompleted &&
              t.parentId == null,
        )
        .length;
  }

  /// Counts root-level items in non-archived categories.
  int countAll(List<Todo> allTodos, {Set<int> archivedCategoryIds = const {}}) {
    return allTodos
        .where(
          (t) =>
              t.parentId == null &&
              t.categoryId != null &&
              !archivedCategoryIds.contains(t.categoryId),
        )
        .length;
  }

  /// Counts completed root-level items in non-archived categories.
  int countAllCompleted(
    List<Todo> allTodos, {
    Set<int> archivedCategoryIds = const {},
  }) {
    return allTodos
        .where(
          (t) =>
              t.parentId == null &&
              t.categoryId != null &&
              !archivedCategoryIds.contains(t.categoryId) &&
              t.status.isCompleted,
        )
        .length;
  }

  /// Counts active root items due on [date].
  int countForCalendar(
    DateTime date,
    List<Todo> allTodos, {
    bool excludeArchivedCategories = true,
    Set<int> archivedCategoryIds = const {},
  }) {
    return allTodos.where((todo) {
      final completedTime = todo.dueAt;
      if (excludeArchivedCategories &&
          (todo.categoryId == null ||
              archivedCategoryIds.contains(todo.categoryId))) {
        return false;
      }
      return todo.status == TodoStatus.active &&
          completedTime != null &&
          todo.parentId == null &&
          _isSameDay(date, completedTime);
    }).length;
  }

  /// Counts direct child items of [parent].
  int countForParent(Todo parent, List<Todo> allTodos) {
    return allTodos.where((t) => t.parentId == parent.id).length;
  }

  /// Counts completed direct child items of [parent].
  int countCompletedForParent(Todo parent, List<Todo> allTodos) {
    return allTodos
        .where((t) => t.parentId == parent.id && t.status.isCompleted)
        .length;
  }

  // ==================== FILTERS ====================

  /// Filters [allTodos] by status, search, and a single context scope.
  List<Todo> filterTodos({
    required List<Todo> allTodos,
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Category? category,
    Todo? parent,
    bool excludeArchivedCategories = false,
    Set<int> archivedCategoryIds = const {},
  }) {
    final contextCount = [
      selectedDay,
      category,
      parent,
    ].where((c) => c != null).length;

    if (contextCount > 1) {
      throw ArgumentError(
        'Specify only one context: selectedDay, category, or parent.',
      );
    }

    final isRootMode = contextCount == 0;
    final lowerQuery = searchQuery.trim().toLowerCase();

    return allTodos.where((todo) {
      if (statusFilter != null && todo.status != statusFilter) {
        return false;
      }

      if (lowerQuery.isNotEmpty) {
        final nameMatch = todo.name.toLowerCase().contains(lowerQuery);
        final descMatch = todo.description.toLowerCase().contains(lowerQuery);
        final tagsMatch = todo.tags.any(
          (tag) => tag.toLowerCase().contains(lowerQuery),
        );

        if (!nameMatch && !descMatch && !tagsMatch) return false;
      }

      if (isRootMode) {
        if (excludeArchivedCategories &&
            (todo.categoryId == null ||
                archivedCategoryIds.contains(todo.categoryId))) {
          return false;
        }
        return todo.parentId == null;
      } else if (selectedDay != null) {
        final time = todo.dueAt;
        if (excludeArchivedCategories &&
            (todo.categoryId == null ||
                archivedCategoryIds.contains(todo.categoryId))) {
          return false;
        }
        if (todo.parentId != null) return false;
        if (time == null) return false;
        return _isSameDay(selectedDay, time);
      } else if (category != null) {
        return todo.categoryId == category.id && todo.parentId == null;
      } else if (parent != null) {
        return todo.parentId == parent.id;
      }

      return false;
    }).toList();
  }
}
