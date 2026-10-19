import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/reorder_filtered.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/ports/caldav_sync_port.dart';
import 'package:zest/domain/ports/device_calendar_sync_port.dart';
import 'package:zest/domain/ports/notification_scheduler_port.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/domain/repositories/todo_repository.dart';

/// Category (task list) CRUD, archive, and notification cleanup.
class CategoryService {
  /// Creates a service with category/item repositories and notifications.
  CategoryService({
    required this._categoryRepo,
    required this._todoRepo,
    required this._notificationService,
    this._calendarSync,
    this._caldavSync,
  });

  /// Persistence layer for category entities.
  final CategoryRepositoryPort _categoryRepo;

  /// Persistence layer for item entities.
  final TodoRepositoryPort _todoRepo;

  /// Schedules and cancels item reminder notifications.
  final NotificationSchedulerPort _notificationService;

  /// Optional device-calendar cleanup when items are deleted with a category.
  final DeviceCalendarSyncPort? _calendarSync;

  /// Optional two-way CalDAV VTODO sync (remote delete enqueue).
  final CalDavSyncPort? _caldavSync;

  // ==================== CREATE ====================

  /// Creates a category when [title] is unique; returns `null` if the title exists.
  Future<Category?> createCategory({
    required String title,
    required String description,
    required int colorArgb,
    required int currentTaskCount,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    if (await _categoryRepo.existsByTitle(title)) {
      return null;
    }

    return _categoryRepo.create(
      title: title,
      description: description,
      colorArgb: colorArgb,
      index: currentTaskCount,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
  }

  // ==================== UPDATE ====================

  /// Updates category fields and syncs category-habit dues on eligible children.
  Future<void> updateCategory({
    required Category category,
    required String title,
    required String description,
    required int colorArgb,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    await _categoryRepo.updateFields(
      category: category,
      title: title,
      description: description,
      colorArgb: colorArgb,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    final updated = category.copyWith(
      title: title,
      description: description,
      colorArgb: colorArgb,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
      clearRecurrenceMinuteOfDay: recurrenceMinuteOfDay == null,
    );

    await _syncCategoryHabitDues(updated);
  }

  /// Stamps due + notifications for active children without their own recurrence.
  Future<void> _syncCategoryHabitDues(Category category) async {
    if (!RecurrenceService.isRecurring(category.recurrence)) return;

    final todos = await _todoRepo.getByCategoryId(category.id);
    final now = DateTime.now();

    for (final todo in todos) {
      if (!RecurrenceService.isCategoryHabitChild(
        todo: todo,
        category: category,
      )) {
        continue;
      }

      final due = RecurrenceService.resolveDueForTodo(
        todo: todo,
        category: category,
        now: now,
      );

      final updated = todo.copyWith(dueAt: due, clearDueAt: due == null);
      await _todoRepo.update(updated);

      if (due != null) {
        await _notificationService.reschedule(updated, category: category);
      } else {
        await _notificationService.cancel(todo.id);
      }
      await _calendarSync?.ensureSynced(updated);
    }
  }

  /// Archives [categories], cancels their item reminders, and persists state.
  Future<void> archiveCategories(List<Category> categories) async {
    if (categories.isEmpty) return;

    final categoriesCopy = List<Category>.from(categories);
    final allTodos = await _collectTodosForCategories(categoriesCopy);

    await _notificationService.cancelForTask(allTodos);
    for (final todo in allTodos) {
      await _calendarSync?.removeSynced(todo);
    }
    await _categoryRepo.updateArchiveStatusBatch(categoriesCopy, true);
  }

  /// Unarchives [categories], reschedules item reminders, and persists state.
  Future<void> unarchiveCategories(List<Category> categories) async {
    if (categories.isEmpty) return;

    final categoriesCopy = List<Category>.from(categories);
    final allTodos = await _collectTodosForCategories(categoriesCopy);

    await _notificationService.scheduleForTask(allTodos);
    await _categoryRepo.updateArchiveStatusBatch(categoriesCopy, false);
    for (final todo in allTodos) {
      await _calendarSync?.ensureSynced(todo);
    }
  }

  Future<List<Todo>> _collectTodosForCategories(
    List<Category> categories,
  ) async {
    final allTodos = <Todo>[];
    for (final category in categories) {
      allTodos.addAll(await _todoRepo.getByCategoryId(category.id));
    }
    return allTodos;
  }

  // ==================== DELETE ====================

  /// Deletes [categories], their items, and associated notifications.
  Future<void> deleteCategories(List<Category> categories) async {
    if (categories.isEmpty) return;

    final categoriesCopy = List<Category>.from(categories);

    for (final category in categoriesCopy) {
      final todos = await _todoRepo.getByCategoryId(category.id);
      await _notificationService.cancelForTask(todos);
      await _deleteAllTodosForCategory(todos);
      await _categoryRepo.delete(category);
    }
  }

  Future<void> _deleteAllTodosForCategory(List<Todo> todos) async {
    if (todos.isEmpty) return;

    final todosCopy = List<Todo>.from(todos);
    final allIds = <int>{};

    for (final root in todosCopy) {
      final subtreeIds = await _collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isNotEmpty) {
      for (final id in allIds) {
        final todoItem = await _todoRepo.getById(id);
        if (todoItem != null) {
          await _calendarSync?.removeSynced(todoItem);
          await _caldavSync?.enqueueDelete(todoItem);
        }
      }
      await _todoRepo.deleteBatch(allIds);
    }
  }

  Future<Set<int>> _collectSubtreeIds(Todo root) async {
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

  // ==================== REORDER ====================

  /// Reorders [allTasks] to match the order of [filteredTasks].
  Future<void> reorderCategories({
    required List<Category> allCategories,
    required List<Category> filteredCategories,
  }) async {
    if (filteredCategories.isEmpty) return;

    reorderFilteredInPlace(
      all: allCategories,
      filtered: filteredCategories,
      idOf: (t) => t.id,
      assignIndex: (_, _) {},
    );
    await _categoryRepo.updateIndexes(allCategories);
  }

  // ==================== FILTERS ====================

  /// Filters [tasks] by archive state and optional [searchQuery].
  List<Category> filterCategories({
    required List<Category> categories,
    required bool archived,
    String searchQuery = '',
  }) {
    final query = searchQuery.trim().toLowerCase();

    return categories.where((task) {
      if (task.archive != archived) return false;
      if (query.isEmpty) return true;

      final titleMatch = task.title.toLowerCase().contains(query);
      final descMatch = task.description.toLowerCase().contains(query);

      return titleMatch || descMatch;
    }).toList();
  }
}
