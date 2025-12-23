import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:reorderables/reorderables.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/tasks/widgets/task_card.dart';
import 'package:zest/app/ui/todos/view/task_todos.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';
import 'package:zest/app/utils/responsive_utils.dart';
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
    final isMobile = ResponsiveUtils.isMobile(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Obx(() {
        final tasks = _filterTasks();

        if (tasks.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: topPadding + (isMobile ? 60 : 70)),
            child: _buildListEmpty(),
          );
        }

        return CustomScrollView(slivers: [_buildReorderableList(tasks)]);
      }),
    );
  }

  List<Tasks> _filterTasks() {
    final query = widget.searchTask.trim().toLowerCase();

    if (query.isEmpty) {
      return todoController.tasks
          .where((task) => task.archive == widget.archived)
          .toList();
    }

    return todoController.tasks.where((task) {
      if (task.archive != widget.archived) return false;
      final titleMatch = task.title.toLowerCase().contains(query);
      final descMatch = task.description.toLowerCase().contains(query);
      return titleMatch || descMatch;
    }).toList();
  }

  Widget _buildListEmpty() {
    return Obx(() {
      final showIcon = !isImage.value;

      return ListEmpty(
        img: 'assets/images/Category.png',
        text: widget.archived ? 'addArchiveCategory'.tr : 'addCategory'.tr,
        subtitle: widget.archived
            ? 'addArchiveCategoryHint'.tr
            : 'addCategoryHint'.tr,
        icon: showIcon
            ? (widget.archived
                  ? IconsaxPlusBold.archive
                  : IconsaxPlusBold.folder_2)
            : null,
      );
    });
  }

  Widget _buildReorderableList(List<Tasks> tasks) {
    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (context, index) => _buildTaskCard(tasks[index]),
        childCount: tasks.length,
      ),
      onReorder: (oldIndex, newIndex) =>
          _handleReorder(tasks, oldIndex, newIndex),
    );
  }

  Widget _buildTaskCard(Tasks task) {
    final createdTodos = todoController.createdAllTodosTask(task);
    final completedTodos = todoController.completedAllTodosTask(task);
    final percent = createdTodos == 0
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

  Future<void> _handleReorder(
    List<Tasks> tasks,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex) return;

    final element = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, element);

    final allTasks = todoController.tasks.toList();
    final filteredIds = tasks.map((t) => t.id).toSet();

    int position = 0;
    for (int i = 0; i < allTasks.length && position < tasks.length; i++) {
      if (filteredIds.contains(allTasks[i].id)) {
        allTasks[i] = tasks[position++];
      }
    }

    await isar.writeTxn(() async {
      for (int i = 0; i < allTasks.length; i++) {
        allTasks[i].index = i;
        await isar.tasks.put(allTasks[i]);
      }
    });

    todoController.tasks.assignAll(allTasks);
    todoController.tasks.refresh();
  }

  void _handleTaskTap(Tasks task) {
    if (todoController.isMultiSelectionTask.isTrue) {
      _toggleMultiSelection(task);
    } else {
      _openTaskDetails(task);
    }
  }

  void _handleTaskDoubleTap(Tasks task) {
    if (!todoController.isMultiSelectionTask.isTrue) {
      todoController.isMultiSelectionTask.value = true;
    }
    _toggleMultiSelection(task);
  }

  void _toggleMultiSelection(Tasks task) {
    todoController.doMultiSelectionTask(task);
  }

  void _openTaskDetails(Tasks task) {
    Get.to(
      () => TodosTask(task: task),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );
  }
}
