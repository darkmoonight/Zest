import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/ui/todos/widgets/todo_card.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';

class TodosList extends StatefulWidget {
  const TodosList({
    super.key,
    required this.done,
    this.task,
    required this.allTodos,
    required this.calendar,
    this.selectedDay,
    required this.searchTodo,
  });

  final bool done;
  final Tasks? task;
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Obx(() {
        final todos = _getFilteredTodos();
        return todos.isEmpty ? _buildListEmpty() : _buildListView(todos);
      }),
    );
  }

  List<Todos> _getFilteredTodos() {
    List<Todos> filteredList = _filterTodos();
    _sortTodos(filteredList);
    return filteredList;
  }

  List<Todos> _filterTodos() {
    if (widget.task != null) {
      return todoController.todos
          .where(
            (todo) =>
                todo.task.value?.id == widget.task?.id &&
                todo.done == widget.done &&
                (widget.searchTodo.isEmpty ||
                    todo.name.toLowerCase().contains(widget.searchTodo)),
          )
          .toList();
    } else if (widget.allTodos) {
      return todoController.todos
          .where(
            (todo) =>
                todo.task.value?.archive == false &&
                todo.done == widget.done &&
                (widget.searchTodo.isEmpty ||
                    todo.name.toLowerCase().contains(widget.searchTodo)),
          )
          .toList();
    } else if (widget.calendar) {
      return todoController.todos
          .where(
            (todo) =>
                todo.task.value?.archive == false &&
                todo.todoCompletedTime != null &&
                _isWithinSelectedDay(todo) &&
                todo.done == widget.done,
          )
          .toList();
    } else {
      return todoController.todos;
    }
  }

  bool _isWithinSelectedDay(Todos todo) {
    return todo.todoCompletedTime!.isAfter(
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
  }

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

  Widget _buildListEmpty() {
    return ListEmpty(
      img: widget.calendar
          ? 'assets/images/Calendar.png'
          : 'assets/images/Todo.png',
      text: widget.done ? 'completedTodo'.tr : 'addTodo'.tr,
    );
  }

  Widget _buildListView(List<Todos> todos) {
    return ListView(
      children: todos.map((todo) => _buildTodoCard(todo)).toList(),
    );
  }

  Widget _buildTodoCard(Todos todo) {
    return TodoCard(
      key: ValueKey(todo),
      todo: todo,
      allTodos: widget.allTodos,
      calendar: widget.calendar,
      onTap: () => _onTodoCardTap(todo),
      onLongPress: () => _onTodoCardLongPress(todo),
    );
  }

  void _onTodoCardTap(Todos todo) {
    if (todoController.isMultiSelectionTodo.isTrue) {
      todoController.doMultiSelectionTodo(todo);
    } else {
      _showTodoActionBottomSheet(todo);
    }
  }

  void _onTodoCardLongPress(Todos todo) {
    todoController.isMultiSelectionTodo.value = true;
    todoController.doMultiSelectionTodo(todo);
  }

  void _showTodoActionBottomSheet(Todos todo) {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TodosAction(
          text: 'editing'.tr,
          edit: true,
          todo: todo,
          category: true,
        );
      },
    );
  }
}
