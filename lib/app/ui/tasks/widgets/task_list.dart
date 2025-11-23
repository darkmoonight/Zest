import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/tasks/widgets/task_card.dart';
import 'package:zest/app/ui/todos/view/task_todos.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';
import 'package:zest/main.dart';

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
    final query = widget.searchTask.trim().toLowerCase();

    bool matchesSearch(Tasks task) {
      if (query.isEmpty) return true;
      final titleMatch = task.title.toLowerCase().contains(query);
      final descMatch = (task.description).toLowerCase().contains(query);
      return titleMatch || descMatch;
    }

    return todoController.tasks
        .where((task) => task.archive == widget.archived && matchesSearch(task))
        .toList();
  }

  Widget _buildListEmpty() {
    return ListEmpty(
      img: 'assets/images/Category.png',
      text: widget.archived ? 'addArchiveCategory'.tr : 'addCategory'.tr,
    );
  }

  Widget _buildListView(List<Tasks> tasks) {
    return AnimatedReorderableListView(
      items: tasks,
      itemBuilder: (BuildContext context, int index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
      enterTransition: [SlideInDown()],
      exitTransition: [SlideInUp()],
      insertDuration: const Duration(milliseconds: 300),
      removeDuration: const Duration(milliseconds: 300),
      dragStartDelay: const Duration(milliseconds: 300),
      onReorder: (int oldIndex, int newIndex) async {
        final element = tasks.removeAt(oldIndex);
        tasks.insert(newIndex, element);

        final all = todoController.tasks.toList();

        int pos = 0;
        for (int i = 0; i < all.length && pos < tasks.length; i++) {
          if (all[i].archive == widget.archived) {
            all[i] = tasks[pos++];
          }
        }

        isar.writeTxnSync(() {
          for (int i = 0; i < all.length; i++) {
            all[i].index = i;
            isar.tasks.putSync(all[i]);
          }
        });

        todoController.tasks.assignAll(all);
        todoController.tasks.refresh();
      },
      isSameItem: (a, b) => a.id == b.id,
    );
  }

  Widget _buildTaskCard(Tasks task) {
    final createdTodos = todoController.createdAllTodosTask(task);
    final completedTodos = todoController.completedAllTodosTask(task);
    final percent = (createdTodos == 0)
        ? '0'
        : (completedTodos / createdTodos * 100).toStringAsFixed(0);

    return TaskCard(
      key: ValueKey(task.id),
      task: task,
      createdTodos: createdTodos,
      completedTodos: completedTodos,
      percent: percent,
      onTap: () => _handleTaskTap(task),
      onDoubleTap: () => _handleTaskDoubleTap(task),
    );
  }

  void _handleTaskTap(Tasks task) {
    if (todoController.isMultiSelectionTask.isTrue) {
      todoController.doMultiSelectionTask(task);
    } else {
      Get.to(() => TodosTask(task: task), transition: Transition.downToUp);
    }
  }

  void _handleTaskDoubleTap(Tasks task) {
    todoController.isMultiSelectionTask.value = true;
    todoController.doMultiSelectionTask(task);
  }
}
