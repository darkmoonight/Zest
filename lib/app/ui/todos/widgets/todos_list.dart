import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/ui/todos/widgets/todo_card.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';
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
  });

  final bool done;
  final Tasks? task;
  final Todos? todo;
  final bool allTodos;
  final bool calendar;
  final DateTime? selectedDay;
  final String searchTodo;

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 50),
    child: Obx(() {
      final todos = _getFilteredTodos();
      return todos.isEmpty ? _buildListEmpty() : _buildListView(todos);
    }),
  );

  List<Todos> _getFilteredTodos() {
    List<Todos> filteredList = _filterTodos();
    _sortTodos(filteredList);
    return filteredList;
  }

  List<Todos> _filterTodos() {
    final query = widget.searchTodo.trim().toLowerCase();

    bool matchesSearch(Todos todo) {
      if (query.isEmpty) return true;
      final nameMatch = todo.name.toLowerCase().contains(query);
      final descMatch = (todo.description).toLowerCase().contains(query);
      final tagsMatch = todo.tags.any((t) => t.toLowerCase().contains(query));
      return nameMatch || descMatch || tagsMatch;
    }

    if (widget.task != null) {
      return todoController.todos.where((todo) {
        final inSameTask = todo.task.value?.id == widget.task!.id;
        final isRoot = todo.parent.value == null;
        final matchesDone = todo.done == widget.done;
        return inSameTask && isRoot && matchesDone && matchesSearch(todo);
      }).toList();
    } else if (widget.todo != null) {
      return todoController.todos.where((todo) {
        final isChild = todo.parent.value?.id == widget.todo!.id;
        final matchesDone = todo.done == widget.done;
        return isChild && matchesDone && matchesSearch(todo);
      }).toList();
    } else if (widget.allTodos) {
      return todoController.todos.where((todo) {
        final isRoot = todo.parent.value == null;
        final matchesDone = todo.done == widget.done;
        return isRoot && matchesDone && matchesSearch(todo);
      }).toList();
    } else if (widget.calendar) {
      return todoController.todos.where((todo) {
        final notArchived = todo.task.value?.archive == false;
        final hasTime = todo.todoCompletedTime != null;
        final inSelectedDay = hasTime && _isWithinSelectedDay(todo);
        final matchesDone = todo.done == widget.done;
        return notArchived &&
            hasTime &&
            inSelectedDay &&
            matchesDone &&
            matchesSearch(todo);
      }).toList();
    } else {
      return todoController.todos.where((todo) {
        return matchesSearch(todo);
      }).toList();
    }
  }

  bool _isWithinSelectedDay(Todos todo) =>
      todo.todoCompletedTime!.isAfter(
        DateTime(
          widget.selectedDay!.year,
          widget.selectedDay!.month,
          widget.selectedDay!.day,
          0,
          0,
        ),
      ) &&
      todo.todoCompletedTime!.isBefore(
        DateTime(
          widget.selectedDay!.year,
          widget.selectedDay!.month,
          widget.selectedDay!.day,
          23,
          59,
          59,
        ),
      );

  void _sortTodos(List<Todos> todos) {
    if (widget.calendar) {
      todos.sort(
        (a, b) => a.todoCompletedTime!.compareTo(b.todoCompletedTime!),
      );
    } else {
      todos.sort((a, b) {
        if (a.fix && !b.fix) {
          return -1;
        } else if (!a.fix && b.fix) {
          return 1;
        } else {
          return 0;
        }
      });
    }
  }

  Widget _buildListEmpty() => ListEmpty(
    img: widget.calendar
        ? 'assets/images/Calendar.png'
        : 'assets/images/Todo.png',
    text: widget.done ? 'completedTodo'.tr : 'addTodo'.tr,
  );

  Widget _buildListView(List<Todos> todos) => AnimatedReorderableListView(
    items: todos,
    itemBuilder: (BuildContext context, int index) {
      final todo = todos[index];
      return _buildTodoCard(todo);
    },
    enterTransition: [SlideInDown()],
    exitTransition: [SlideInUp()],
    insertDuration: const Duration(milliseconds: 300),
    removeDuration: const Duration(milliseconds: 300),
    dragStartDelay: const Duration(milliseconds: 300),
    onReorder: (int oldIndex, int newIndex) async {
      final element = todos.removeAt(oldIndex);
      todos.insert(newIndex, element);

      final all = todoController.todos.toList();

      int pos = 0;
      for (int i = 0; i < all.length && pos < todos.length; i++) {
        if (all[i].done == widget.done) {
          all[i] = todos[pos++];
        }
      }

      isar.writeTxnSync(() {
        for (int i = 0; i < all.length; i++) {
          all[i].index = i;
          isar.todos.putSync(all[i]);
        }
      });

      todoController.todos.assignAll(all);
      todoController.todos.refresh();
    },
    isSameItem: (a, b) => a.id == b.id,
  );

  Widget _buildTodoCard(Todos todo) {
    final createdTodos = todoController.createdAllTodosTodo(todo);
    final completedTodos = todoController.completedAllTodosTodo(todo);

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

  void _handleTodoTap(Todos todo) {
    if (todoController.isMultiSelectionTodo.isTrue) {
      todoController.doMultiSelectionTodo(todo);
    } else {
      _showTodoActionBottomSheet(todo);
    }
  }

  void _handleTodoDoubleTap(Todos todo) {
    todoController.isMultiSelectionTodo.value = true;
    todoController.doMultiSelectionTodo(todo);
  }

  void _showTodoActionBottomSheet(Todos todo) => showModalBottomSheet(
    enableDrag: false,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) =>
        TodosAction(text: 'editing'.tr, edit: true, todo: todo, category: true),
  );
}
