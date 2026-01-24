import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:reorderables/reorderables.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/todos/widgets/todo_card.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/main.dart';

class TodosList extends StatefulWidget {
  const TodosList({
    super.key,
    required this.done,
    this.task,
    this.todo,
    required this.allTodos,
    required this.calendar,
    this.selectedDay,
    required this.searchTodo,
    this.sortOption,
  });

  final bool done;
  final Tasks? task;
  final Todos? todo;
  final bool allTodos;
  final bool calendar;
  final DateTime? selectedDay;
  final String searchTodo;
  final SortOption? sortOption;

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList>
    with AutomaticKeepAliveClientMixin {
  late final TodoController _todoController = Get.find<TodoController>();
  late Map<int, double> _randomScores;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _randomScores = {};
  }

  @override
  void didUpdateWidget(covariant TodosList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.sortOption == SortOption.random &&
        oldWidget.sortOption != widget.sortOption) {
      _randomScores.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isMobile = ResponsiveUtils.isMobile(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Obx(() {
      final todos = _getFilteredAndSortedTodos();

      if (todos.isEmpty) {
        return _buildEmptyState(context, isMobile, topPadding);
      }

      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          _buildReorderableList(todos),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      );
    });
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isMobile,
    double topPadding,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding + (isMobile ? 60 : 70)),
      child: Obx(() {
        final showIcon = !isImage.value;

        return ListEmpty(
          img: widget.calendar
              ? 'assets/images/Calendar.png'
              : 'assets/images/Todo.png',
          text: widget.done ? 'completedTodo'.tr : 'addTodo'.tr,
          subtitle: widget.done
              ? 'completedTodoHint'.tr
              : (widget.calendar ? 'addCalendarTodoHint'.tr : 'addTodoHint'.tr),
          icon: showIcon
              ? (widget.done
                    ? IconsaxPlusBold.tick_circle
                    : (widget.calendar
                          ? IconsaxPlusBold.calendar_tick
                          : IconsaxPlusBold.task_square))
              : null,
        );
      }),
    );
  }

  List<Todos> _getFilteredAndSortedTodos() {
    List<Todos> filteredList = _filterTodos();
    _sortTodos(filteredList);
    return filteredList;
  }

  List<Todos> _filterTodos() {
    final query = widget.searchTodo.trim().toLowerCase();
    final baseTodos = _getBaseTodos();

    if (query.isEmpty) {
      return baseTodos;
    }

    return baseTodos.where((todo) {
      final nameMatch = todo.name.toLowerCase().contains(query);
      final descMatch = todo.description.toLowerCase().contains(query);
      final tagsMatch = todo.tags.any((t) => t.toLowerCase().contains(query));
      return nameMatch || descMatch || tagsMatch;
    }).toList();
  }

  List<Todos> _getBaseTodos() {
    if (widget.task != null) {
      return _getTaskTodos();
    } else if (widget.todo != null) {
      return _getSubTodos();
    } else if (widget.allTodos) {
      return _getAllTodos();
    } else if (widget.calendar) {
      return _getCalendarTodos();
    }
    return _todoController.todos.toList();
  }

  List<Todos> _getTaskTodos() {
    return _todoController.todos.where((todo) {
      final inSameTask = todo.task.value?.id == widget.task!.id;
      final isRoot = todo.parent.value == null;
      final matchesDone = todo.done == widget.done;
      return inSameTask && isRoot && matchesDone;
    }).toList();
  }

  List<Todos> _getSubTodos() {
    return _todoController.todos.where((todo) {
      final isChild = todo.parent.value?.id == widget.todo!.id;
      final matchesDone = todo.done == widget.done;
      return isChild && matchesDone;
    }).toList();
  }

  List<Todos> _getAllTodos() {
    return _todoController.todos.where((todo) {
      final notArchived = todo.task.value?.archive == false;
      final isRoot = todo.parent.value == null;
      final matchesDone = todo.done == widget.done;
      return notArchived && isRoot && matchesDone;
    }).toList();
  }

  List<Todos> _getCalendarTodos() {
    return _todoController.todos.where((todo) {
      final notArchived = todo.task.value?.archive == false;
      final hasTime = todo.todoCompletedTime != null;
      final inSelectedDay = hasTime && _isWithinSelectedDay(todo);
      final matchesDone = todo.done == widget.done;
      return notArchived && hasTime && inSelectedDay && matchesDone;
    }).toList();
  }

  bool _isWithinSelectedDay(Todos todo) {
    final selectedDate = widget.selectedDay!;
    final completedDate = todo.todoCompletedTime!;

    final startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
      0,
    );

    final endOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    return completedDate.isAfter(startOfDay) &&
        completedDate.isBefore(endOfDay);
  }

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

  int _comparePriority(Todos a, Todos b) =>
      a.priority.index.compareTo(b.priority.index);

  int _compareName(Todos a, Todos b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  int _compareDate(Todos a, Todos b, {bool ascending = true}) {
    final cmp = a.createdTime.compareTo(b.createdTime);
    return ascending ? cmp : -cmp;
  }

  int _compareDateNotif(Todos a, Todos b, {bool ascending = true}) {
    final da = a.todoCompletedTime;
    final db = b.todoCompletedTime;

    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;

    final cmp = da.compareTo(db);
    return ascending ? cmp : -cmp;
  }

  Widget _buildReorderableList(List<Todos> todos) {
    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (context, index) => _buildTodoCard(todos[index]),
        childCount: todos.length,
      ),
      onReorder: (oldIndex, newIndex) =>
          _handleReorder(todos, oldIndex, newIndex),
    );
  }

  Widget _buildTodoCard(Todos todo) {
    final createdTodos = _todoController.createdAllTodosTodo(todo);
    final completedTodos = _todoController.completedAllTodosTodo(todo);
    print('Rendering todo: ${todo.id} - ${todo.name}');
    return TodoCard(
      key: ValueKey(todo.id),
      todo: todo,
      allTodos: widget.allTodos,
      calendar: widget.calendar,
      createdTodos: createdTodos,
      completedTodos: completedTodos,
      onTap: () => _handleTodoTap(todo),
      onDoubleTap: () => _handleTodoDoubleTap(todo),
    );
  }

  Future<void> _handleReorder(
    List<Todos> todos,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex) return;

    final element = todos.removeAt(oldIndex);
    todos.insert(newIndex, element);

    final allTodos = _todoController.todos.toList();
    final filteredIds = todos.map((t) => t.id).toSet();
    int position = 0;

    for (int i = 0; i < allTodos.length && position < todos.length; i++) {
      if (filteredIds.contains(allTodos[i].id)) {
        allTodos[i] = todos[position++];
      }
    }

    await isar.writeTxn(() async {
      for (int i = 0; i < allTodos.length; i++) {
        allTodos[i].index = i;
        await isar.todos.put(allTodos[i]);
      }
    });

    _todoController.todos.assignAll(allTodos);
    _todoController.todos.refresh();
  }

  void _handleTodoTap(Todos todo) {
    if (_todoController.isMultiSelectionTodo.isTrue) {
      _todoController.doMultiSelectionTodo(todo);
    } else {
      _showTodoActionBottomSheet(todo);
    }
  }

  void _handleTodoDoubleTap(Todos todo) {
    if (!_todoController.isMultiSelectionTodo.isTrue) {
      _todoController.toggleMultiSelectionTodo();
    }
    _todoController.doMultiSelectionTodo(todo);
  }

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
