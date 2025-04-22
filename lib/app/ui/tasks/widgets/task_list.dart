import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/tasks/widgets/task_card.dart';
import 'package:zest/app/ui/todos/view/task_todos.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';

class TasksList extends StatefulWidget {
  const TasksList({
    super.key,
    required this.archived,
    required this.searchTask,
  });
  final bool archived;
  final String searchTask;

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Obx(() {
        final tasks = _filterTasks();
        return tasks.isEmpty ? _buildListEmpty() : _buildListView(tasks);
      }),
    );
  }

  List<Tasks> _filterTasks() {
    return todoController.tasks
        .where(
          (task) =>
              task.archive == widget.archived &&
              (widget.searchTask.isEmpty ||
                  task.title.toLowerCase().contains(widget.searchTask)),
        )
        .toList()
        .obs;
  }

  Widget _buildListEmpty() {
    return ListEmpty(
      img: 'assets/images/Category.png',
      text: widget.archived ? 'addArchiveCategory'.tr : 'addCategory'.tr,
    );
  }

  Widget _buildListView(List<Tasks> tasks) {
    return ListView(
      children:
          tasks.map((task) {
            final createdTodos = todoController.createdAllTodosTask(task);
            final completedTodos = todoController.completedAllTodosTask(task);
            final percent = (completedTodos / createdTodos * 100)
                .toStringAsFixed(0);

            return TaskCard(
              key: ValueKey(task),
              task: task,
              createdTodos: createdTodos,
              completedTodos: completedTodos,
              percent: percent,
              onTap: () {
                _handleTaskTap(task);
              },
              onLongPress: () {
                _handleTaskLongPress(task);
              },
            );
          }).toList(),
    );
  }

  void _handleTaskTap(Tasks task) {
    if (todoController.isMultiSelectionTask.isTrue) {
      todoController.doMultiSelectionTask(task);
    } else {
      Get.to(() => TodosTask(task: task), transition: Transition.downToUp);
    }
  }

  void _handleTaskLongPress(Tasks task) {
    todoController.isMultiSelectionTask.value = true;
    todoController.doMultiSelectionTask(task);
  }
}
