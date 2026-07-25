import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:reorderables/reorderables.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/list_empty.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/features/todos/presentation/widgets/todo_card.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/i18n/tr.dart';

/// Scrollable list of filtered and sorted todo cards.
class TodosList extends ConsumerStatefulWidget {
  /// Creates a [TodosList].
  const TodosList({
    super.key,
    required this.statusFilter,
    this.task,
    this.todo,
    required this.allTodos,
    required this.calendar,
    this.selectedDay,
    required this.searchTodo,
    this.sortOption,
    this.excludeArchivedCategories = false,
  });

  /// The status filter.
  final TodoStatus? statusFilter;

  /// The task.
  final Tasks? task;

  /// The todo.
  final Todos? todo;

  /// The all todos.
  final bool allTodos;

  /// The calendar.
  final bool calendar;

  /// The selected day.
  final DateTime? selectedDay;

  /// The search todo.
  final String searchTodo;

  /// The sort option.
  final SortOption? sortOption;

  /// When true, todos from archived categories are hidden (All Todos).
  final bool excludeArchivedCategories;

  @override
  /// Creates the state for this widget.
  ConsumerState<TodosList> createState() => _TodosListState();
}

/// State for [TodosList] preserving scroll position across rebuilds.
class _TodosListState extends ConsumerState<TodosList>
    with AutomaticKeepAliveClientMixin {
  /// The random scores.
  late Map<int, double> _randomScores;

  @override
  bool get wantKeepAlive => true;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _randomScores = {};
  }

  @override
  /// Did update widget.
  void didUpdateWidget(covariant TodosList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.sortOption == SortOption.random &&
        oldWidget.sortOption != widget.sortOption) {
      _randomScores.clear();
    }
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    super.build(context);

    final isMobile = ResponsiveUtils.isMobile(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final todosState = ref.watch(todosNotifierProvider);
    final todosNotifier = ref.read(todosNotifierProvider.notifier);
    final isImage = ref.watch(appSettingsProvider).isImage;

    final todos = _getFilteredAndSortedTodos(todosNotifier);

    if (todos.isEmpty) {
      return _buildEmptyState(context, isMobile, topPadding, isImage);
    }

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        _buildReorderableList(todos, todosNotifier, todosState),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppConstants.listFabClearanceHeight),
        ),
      ],
    );
  }

  /// Builds the empty state widget.
  Widget _buildEmptyState(
    BuildContext context,
    bool isMobile,
    double topPadding,
    bool isImage,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding + (isMobile ? 60 : 70)),
      child: ListEmpty(
        img: widget.calendar
            ? 'assets/images/Calendar.png'
            : 'assets/images/Todo.png',
        text: widget.statusFilter == TodoStatus.done
            ? 'completedTodo'.tr
            : widget.statusFilter == TodoStatus.cancelled
            ? 'cancelledTodos'.tr
            : 'addTodo'.tr,
        subtitle: widget.statusFilter == TodoStatus.done
            ? 'completedTodoHint'.tr
            : widget.statusFilter == TodoStatus.cancelled
            ? 'cancelledTodosHint'.tr
            : (widget.calendar ? 'addCalendarTodoHint'.tr : 'addTodoHint'.tr),
        icon: !isImage
            ? (widget.statusFilter == TodoStatus.done
                  ? IconsaxPlusBold.tick_circle
                  : (widget.calendar
                        ? IconsaxPlusBold.calendar_tick
                        : IconsaxPlusBold.task_square))
            : null,
      ),
    );
  }

  /// Todos.
  List<Todos> _getFilteredAndSortedTodos(TodosNotifier todosNotifier) {
    final filteredList = _filterTodos(todosNotifier);
    _sortTodos(filteredList);
    return filteredList;
  }

  /// Todos.
  List<Todos> _filterTodos(TodosNotifier todosNotifier) {
    if (widget.task != null) {
      return todosNotifier.getFilteredTodos(
        statusFilter: widget.statusFilter,
        searchQuery: widget.searchTodo,
        task: widget.task,
      );
    }
    if (widget.todo != null) {
      return todosNotifier.getFilteredTodos(
        statusFilter: widget.statusFilter,
        searchQuery: widget.searchTodo,
        parent: widget.todo,
      );
    }
    if (widget.calendar) {
      return todosNotifier.getFilteredTodos(
        statusFilter: widget.statusFilter,
        searchQuery: widget.searchTodo,
        selectedDay: widget.selectedDay,
        excludeArchivedCategories: widget.excludeArchivedCategories,
      );
    }
    if (widget.allTodos) {
      return todosNotifier.getFilteredTodos(
        statusFilter: widget.statusFilter,
        searchQuery: widget.searchTodo,
        excludeArchivedCategories: widget.excludeArchivedCategories,
      );
    }
    return todosNotifier.getFilteredTodos(
      statusFilter: widget.statusFilter,
      searchQuery: widget.searchTodo,
    );
  }

  /// Sort todos.
  void _sortTodos(List<Todos> todos) {
    final opt = widget.sortOption ?? SortOption.none;

    if (opt == SortOption.random) {
      for (var todo in todos) {
        _randomScores.putIfAbsent(todo.id, () => Random().nextDouble());
      }
    }

    todos.sort((a, b) {
      if (a.fix != b.fix) {
        return a.fix ? -1 : 1;
      }

      switch (opt) {
        case SortOption.alphaAsc:
          return _compareName(a, b);
        case SortOption.alphaDesc:
          return _compareName(b, a);
        case SortOption.dateAsc:
          return _compareDate(a, b, ascending: true);
        case SortOption.dateDesc:
          return _compareDate(a, b, ascending: false);
        case SortOption.dateNotifAsc:
          return _compareDateNotif(a, b, ascending: true);
        case SortOption.dateNotifDesc:
          return _compareDateNotif(a, b, ascending: false);
        case SortOption.priorityAsc:
          return _comparePriority(b, a);
        case SortOption.priorityDesc:
          return _comparePriority(a, b);
        case SortOption.random:
          return _randomScores[a.id]!.compareTo(_randomScores[b.id]!);
        case SortOption.none:
          return 0;
      }
    });
  }

  /// Compare priority.
  int _comparePriority(Todos a, Todos b) =>
      a.priority.index.compareTo(b.priority.index);

  /// Compare name.
  int _compareName(Todos a, Todos b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  /// Compare date.
  int _compareDate(Todos a, Todos b, {bool ascending = true}) {
    final cmp = a.createdTime.compareTo(b.createdTime);
    return ascending ? cmp : -cmp;
  }

  /// Compare date notif.
  int _compareDateNotif(Todos a, Todos b, {bool ascending = true}) {
    final da = a.todoCompletedTime;
    final db = b.todoCompletedTime;

    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;

    final cmp = da.compareTo(db);
    return ascending ? cmp : -cmp;
  }

  /// Builds the reorderable list widget.
  Widget _buildReorderableList(
    List<Todos> todos,
    TodosNotifier todosNotifier,
    TodosState todosState,
  ) {
    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (context, index) =>
            _buildTodoCard(todos[index], todosNotifier, todosState),
        childCount: todos.length,
      ),
      onReorder: (oldIndex, newIndex) =>
          _handleReorder(todos, oldIndex, newIndex, todosNotifier),
    );
  }

  /// Builds the todo card widget.
  Widget _buildTodoCard(
    Todos todo,
    TodosNotifier todosNotifier,
    TodosState todosState,
  ) {
    return TodoCard(
      key: ValueKey(todo.id),
      todo: todo,
      allTodos: widget.allTodos,
      calendar: widget.calendar,
      createdTodos: todosNotifier.createdAllTodosTodo(todo),
      completedTodos: todosNotifier.completedAllTodosTodo(todo),
      isSelected:
          todosState.isMultiSelectionTodo &&
          todosState.selectedTodoIds.contains(todo.id),
      onTap: () => _handleTodoTap(todo, todosNotifier, todosState),
      onDoubleTap: () => _handleTodoDoubleTap(todo, todosNotifier, todosState),
    );
  }

  /// Void.
  Future<void> _handleReorder(
    List<Todos> todos,
    int oldIndex,
    int newIndex,
    TodosNotifier todosNotifier,
  ) async {
    if (oldIndex == newIndex) return;

    final element = todos.removeAt(oldIndex);
    todos.insert(newIndex, element);

    final allTodos = ref.read(todosNotifierProvider).todos.toList();
    final filteredIds = todos.map((t) => t.id).toSet();
    var position = 0;

    for (int i = 0; i < allTodos.length && position < todos.length; i++) {
      if (filteredIds.contains(allTodos[i].id)) {
        allTodos[i] = todos[position++];
      }
    }

    for (int i = 0; i < allTodos.length; i++) {
      allTodos[i].index = i;
    }

    await ref.read(todoRepositoryProvider).updateIndexes(allTodos);
    await todosNotifier.reloadTodos();
  }

  /// Handle todo tap.
  void _handleTodoTap(
    Todos todo,
    TodosNotifier todosNotifier,
    TodosState todosState,
  ) {
    if (todosState.isMultiSelectionTodo) {
      todosNotifier.doMultiSelectionTodo(todo);
    } else {
      _showTodoActionBottomSheet(todo);
    }
  }

  /// Handle todo double tap.
  void _handleTodoDoubleTap(
    Todos todo,
    TodosNotifier todosNotifier,
    TodosState todosState,
  ) {
    if (!todosState.isMultiSelectionTodo) {
      todosNotifier.toggleMultiSelectionTodo();
    }
    todosNotifier.doMultiSelectionTodo(todo);
  }

  /// Show todo action bottom sheet.
  void _showTodoActionBottomSheet(Todos todo) {
    NavigationHelper.showModalSheet(
      context: context,
      child: TodosAction(
        text: 'editing'.tr,
        edit: true,
        todo: todo,
        category: true,
      ),
      enableDrag: false,
    );
  }
}
