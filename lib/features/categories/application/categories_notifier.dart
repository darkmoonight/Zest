import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/domain/usecases/category_usecases.dart';
import 'package:zest/core/utils/app_log.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

/// Riverpod state and notifier for task categories.
class CategoriesState {
  /// Creates a [CategoriesState].
  const CategoriesState({
    this.categories = const [],
    this.selectedCategories = const [],
    this.selectedCategoryIds = const {},
    this.isMultiSelectionCategory = false,
    this.isPop = true,
    this.categoriesRevision = 0,
  });

  /// Loaded task categories for the home list.
  final List<Category> categories;

  /// Selected categories during multi-select mode (resolved from ids).
  final List<Category> selectedCategories;

  /// Selected category ids; survives list reloads.
  final Set<int> selectedCategoryIds;

  /// Whether the categories screen is in multi-select mode.
  final bool isMultiSelectionCategory;

  /// Whether [PopScope] should allow popping (false during multi-select).
  final bool isPop;

  /// Increments whenever [categories] is replaced — stats/list widgets use for invalidation.
  final int categoriesRevision;

  /// Returns a copy with the given fields replaced.
  ///
  /// When [categories] is provided, [categoriesRevision] bumps unless overridden.
  CategoriesState copyWith({
    List<Category>? categories,
    List<Category>? selectedCategories,
    Set<int>? selectedCategoryIds,
    bool? isMultiSelectionCategory,
    bool? isPop,
    int? categoriesRevision,
  }) {
    final categoriesChanged = categories != null;
    return CategoriesState(
      categories: categories ?? this.categories,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      isMultiSelectionCategory:
          isMultiSelectionCategory ?? this.isMultiSelectionCategory,
      isPop: isPop ?? this.isPop,
      categoriesRevision:
          categoriesRevision ??
          (categoriesChanged
              ? this.categoriesRevision + 1
              : this.categoriesRevision),
    );
  }
}

/// Loads and mutates task categories; watches Isar for live list updates.
class CategoriesNotifier extends Notifier<CategoriesState> {
  CategoryRepositoryPort? _categoryRepo;

  Timer? _loadDebounce;

  /// Monotonic token so stale [getAll] results cannot overwrite newer loads.
  int _loadGeneration = 0;

  CategoryRepositoryPort get categoryRepo {
    final cached = _categoryRepo;
    if (cached != null) return cached;
    final created = ref.read(categoryRepositoryProvider);
    _categoryRepo = created;
    return created;
  }

  /// [CategoryService] from [categoryServiceProvider].
  CategoryService get categoryService => ref.read(categoryServiceProvider);

  @override
  /// Initializes repositories, watchers, and returns initial [CategoriesState].
  CategoriesState build() {
    StreamSubscription<void>? taskWatcherSubscription;

    taskWatcherSubscription = categoryRepo.watchLazy().listen((_) {
      _debounceLoad();
    });

    ref.onDispose(() {
      _loadDebounce?.cancel();
      taskWatcherSubscription?.cancel();
    });

    Future.microtask(reloadCategories);

    return const CategoriesState();
  }

  /// Debounce load.
  void _debounceLoad() {
    _loadDebounce?.cancel();
    _loadDebounce = Timer(AppConstants.debounceDelay, () async {
      await reloadCategories();
    });
  }

  /// Reloads task categories from the database into state.
  Future<void> reloadCategories() async {
    final generation = ++_loadGeneration;
    final preservedSelectedIds = state.selectedCategoryIds.toSet();
    final newTasks = await categoryRepo.getAll();
    if (generation != _loadGeneration || !ref.mounted) return;
    state = state.copyWith(categories: newTasks);
    _restoreSelectedTasks(preservedSelectedIds);
  }

  void _restoreSelectedTasks(Set<int> preservedIds) {
    if (preservedIds.isEmpty) {
      if (state.selectedCategories.isNotEmpty || state.isMultiSelectionCategory) {
        doMultiSelectionCategoryClear();
      }
      return;
    }

    final tasksMap = {for (final task in state.categories) task.id: task};
    final restored = preservedIds
        .map((id) => tasksMap[id])
        .whereType<Category>()
        .toList();

    if (restored.isEmpty) {
      doMultiSelectionCategoryClear();
    } else {
      state = state.copyWith(
        selectedCategories: restored,
        selectedCategoryIds: restored.map((e) => e.id).toSet(),
        isMultiSelectionCategory: true,
        isPop: false,
      );
    }
  }

  void _resyncSelectedTaskFromIds() {
    if (state.selectedCategoryIds.isEmpty) {
      if (state.selectedCategories.isNotEmpty) {
        state = state.copyWith(selectedCategories: const []);
      }
      return;
    }

    final tasksMap = {for (final task in state.categories) task.id: task};
    final updated = state.selectedCategoryIds
        .map((id) => tasksMap[id])
        .whereType<Category>()
        .toList();

    state = state.copyWith(
      selectedCategories: updated,
      selectedCategoryIds: updated.map((e) => e.id).toSet(),
    );
  }

  // ==================== Category CRUD ====================

  /// Creates a task category with the given title, description, and color.
  Future<Category?> addTask(
    String title,
    String description,
    Color color, {
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    final task = await categoryService.createCategory(
      title: title,
      description: description,
      colorArgb: color.toARGB32(),
      currentTaskCount: state.categories.length,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
    return task;
  }

  /// Persists edits to an existing task category.
  Future<void> updateCategory(
    Category category,
    String title,
    String description,
    Color color, {
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    await categoryService.updateCategory(
      category: category,
      title: title,
      description: description,
      colorArgb: color.toARGB32(),
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );
  }

  /// Deletes [taskList] and reindexes remaining categories.
  Future<void> deleteCategories(List<Category> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();

    await categoryService.deleteCategories(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);

    state = state.copyWith(categories: await categoryRepo.getAll());
    await _reindexCategories();
    // Archive flags live on linked tasks; refresh todos for filters/counts.
    unawaited(_reloadTodosSafely());
  }

  /// Archives [taskList] and clears selection.
  Future<void> archiveCategories(List<Category> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await categoryService.archiveCategories(taskList);
    await _clearDefaultCategoryIfNeeded(taskList);
    state = state.copyWith(categories: await categoryRepo.getAll());
    doMultiSelectionCategoryClear();
    unawaited(_reloadTodosSafely());
  }

  /// Restores [taskList] from archive and clears selection.
  Future<void> unarchiveCategories(List<Category> taskList) async {
    if (taskList.isEmpty) return;

    _loadDebounce?.cancel();
    await categoryService.unarchiveCategories(taskList);
    state = state.copyWith(categories: await categoryRepo.getAll());
    doMultiSelectionCategoryClear();
    unawaited(_reloadTodosSafely());
  }

  Future<void> _reloadTodosSafely() async {
    try {
      await ref.read(todosNotifierProvider.notifier).reloadTodos();
    } catch (e, stack) {
      AppLog.d('reloadTodos after category change failed: $e\n$stack');
    }
  }

  /// Persists a new order for [filteredTasks] within the full task list.
  Future<void> reorderCategories({
    required List<Category> filteredTasks,
    required bool archived,
  }) async {
    if (filteredTasks.isEmpty) return;

    await categoryService.reorderCategories(
      allCategories: state.categories.toList(),
      filteredCategories: filteredTasks,
    );

    state = state.copyWith(categories: await categoryRepo.getAll());
  }

  /// Clears the user default category when it was archived or deleted.
  Future<void> _clearDefaultCategoryIfNeeded(List<Category> categories) async {
    final settings = ref.read(liveSettingsProvider);
    final defaultId = settings.defaultCategoryId;
    if (defaultId == null) return;
    if (!categories.any((task) => task.id == defaultId)) return;

    await ref.writeLiveSettings(mutate: (s) => s.defaultCategoryId = null);
  }

  Future<void> _reindexCategories() async {
    final all = state.categories.toList();
    await categoryRepo.updateIndexes(all);
    state = state.copyWith(categories: await categoryRepo.getAll());
  }

  /// Persists [task.sortOption] after the user changes list sort.
  Future<void> persistCategorySort(Category task, SortOption option) async {
    await categoryRepo.update(task.copyWith(sortOption: option));
  }

  /// Active categories sorted by index (for pickers / transfer).
  Future<List<Category>> getActiveSorted() => categoryRepo.getActiveSorted();

  // ==================== Filters ====================

  /// Returns task categories filtered by archive state and search query.
  List<Category> getFilteredTasks({
    required bool archived,
    String searchQuery = '',
  }) {
    return categoryService.filterCategories(
      categories: state.categories,
      archived: archived,
      searchQuery: searchQuery,
    );
  }

  // ==================== Multi-Selection Category ====================

  /// Toggles [task] in the multi-select id set.
  void doMultiSelectionCategory(Category task) {
    if (!state.isMultiSelectionCategory) return;

    final updatedIds = Set<int>.from(state.selectedCategoryIds);
    if (updatedIds.contains(task.id)) {
      updatedIds.remove(task.id);
    } else {
      updatedIds.add(task.id);
    }

    if (updatedIds.isEmpty) {
      state = state.copyWith(
        selectedCategories: const [],
        selectedCategoryIds: const {},
        isMultiSelectionCategory: false,
        isPop: true,
      );
    } else {
      state = state.copyWith(
        selectedCategoryIds: updatedIds,
        isMultiSelectionCategory: true,
        isPop: false,
      );
      _resyncSelectedTaskFromIds();
    }
  }

  /// Clears category multi-select and restores back navigation.
  void doMultiSelectionCategoryClear() {
    state = state.copyWith(
      selectedCategories: const [],
      selectedCategoryIds: const {},
      isMultiSelectionCategory: false,
      isPop: true,
    );
  }

  /// Enters or exits category multi-select mode.
  void toggleMultiSelectionCategory() {
    if (state.isMultiSelectionCategory) {
      doMultiSelectionCategoryClear();
    } else {
      state = state.copyWith(isMultiSelectionCategory: true, isPop: false);
    }
  }

  /// Sets is pop.
  void setIsPop(bool value) {
    if (state.isPop != value) {
      state = state.copyWith(isPop: value);
    }
  }

  /// Whether are all tasks selected.
  bool areAllCategoriesSelected({required bool archived, String searchQuery = ''}) {
    final filtered = getFilteredTasks(
      archived: archived,
      searchQuery: searchQuery,
    );

    return filtered.isNotEmpty &&
        filtered.every((task) => state.selectedCategoryIds.contains(task.id));
  }

  /// Select all tasks.
  void selectAllCategories({
    required bool select,
    required bool archived,
    String searchQuery = '',
  }) {
    final filtered = getFilteredTasks(
      archived: archived,
      searchQuery: searchQuery,
    );

    if (select) {
      final updatedIds = Set<int>.from(state.selectedCategoryIds)
        ..addAll(filtered.map((t) => t.id));

      state = state.copyWith(
        selectedCategoryIds: updatedIds,
        isMultiSelectionCategory: true,
        isPop: false,
      );
      _resyncSelectedTaskFromIds();
    } else {
      final filteredIds = filtered.map((t) => t.id).toSet();
      final updatedIds = Set<int>.from(state.selectedCategoryIds)
        ..removeWhere(filteredIds.contains);

      if (updatedIds.isEmpty) {
        doMultiSelectionCategoryClear();
      } else {
        state = state.copyWith(selectedCategoryIds: updatedIds);
        _resyncSelectedTaskFromIds();
      }
    }
  }
}

/// Category notifier provider.
final categoriesNotifierProvider = NotifierProvider<CategoriesNotifier, CategoriesState>(
  CategoriesNotifier.new,
);
