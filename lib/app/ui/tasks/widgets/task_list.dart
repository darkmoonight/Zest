import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:reorderables/reorderables.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/tasks/widgets/task_card.dart';
import 'package:zest/app/ui/todos/view/task_todos.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/progress_calculator.dart';
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

class _TasksListState extends State<TasksList>
    with AutomaticKeepAliveClientMixin {
  late final TodoController _todoController = Get.find<TodoController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isMobile = ResponsiveUtils.isMobile(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Obx(() {
      final tasks = _todoController.getFilteredTasks(
        archived: widget.archived,
        searchQuery: widget.searchTask,
      );

      if (tasks.isEmpty) {
        return _buildEmptyState(context, isMobile, topPadding);
      }

      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          _buildReorderableList(tasks),
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
      }),
    );
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
    final progress = ProgressCalculator(
      total: _todoController.createdAllTodosTask(task),
      completed: _todoController.completedAllTodosTask(task),
    );

    return TaskCard(
      key: ValueKey(task.id),
      task: task,
      createdTodos: progress.total,
      completedTodos: progress.completed,
      percent: progress.percentageString,
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

    await _todoController.reorderTasks(
      filteredTasks: tasks,
      archived: widget.archived,
    );
  }

  void _handleTaskTap(Tasks task) {
    if (_todoController.isMultiSelectionTask.isTrue) {
      _todoController.doMultiSelectionTask(task);
    } else {
      NavigationHelper.slideUp(TaskTodos(task: task));
    }
  }

  void _handleTaskDoubleTap(Tasks task) {
    if (!_todoController.isMultiSelectionTask.isTrue) {
      _todoController.toggleMultiSelectionTask();
    }
    _todoController.doMultiSelectionTask(task);
  }
}
