import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/tasks/presentation/widgets/tasks_action.dart';
import 'package:zest/features/todos/presentation/view/todos_list_screen.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/features/todos/presentation/widgets/todos_tab_views.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/app_back_button.dart';

/// Todos list for a task category.
class TaskTodos extends ConsumerStatefulWidget {
  /// Creates a [TaskTodos].
  const TaskTodos({super.key, required this.task});

  /// Task category whose todos are listed.
  final Tasks task;

  @override
  ConsumerState<TaskTodos> createState() => _TaskTodosState();
}

class _TaskTodosState extends ConsumerState<TaskTodos> {
  @override
  Widget build(BuildContext context) {
    return TodosListScreen(
      config: TodosListScreenConfig(
        initialSortOption: widget.task.sortOption,
        onSortPersist: (option) async {
          widget.task.sortOption = option;
          await ref
              .read(isarProvider)
              .writeTxn(() => ref.read(isarProvider).tasks.put(widget.task));
        },
        buildAppBar: (context, todosState) => _buildAppBar(context, todosState),
        buildTabViewsConfig: (tabController, searchFilter, sortOption) =>
            TodosTabViewsConfig(
              tabController: tabController,
              searchFilter: searchFilter,
              sortOption: sortOption,
              task: widget.task,
            ),
        areAllSelected: (statusFilter, searchFilter, notifier) =>
            notifier.areAllSelected(
              statusFilter: statusFilter,
              searchQuery: searchFilter,
              task: widget.task,
            ),
        toggleSelectAll: (statusFilter, searchFilter, select, notifier) =>
            notifier.selectAll(
              select: select,
              statusFilter: statusFilter,
              searchQuery: searchFilter,
              task: widget.task,
            ),
        buildFab: (context) {
          if (!ref.watch(fabNotifierProvider).isVisible) return null;
          return FloatingActionButton(
            onPressed: () => _showTodosActionBottomSheet(context),
            child: const Icon(IconsaxPlusLinear.add),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    TodosState todosState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: const AppBackButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.task.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.task.description.isNotEmpty)
            Text(
              widget.task.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        if (todosState.selectedTodo.isEmpty)
          IconButton(
            onPressed: () => _showTasksActionBottomSheet(context),
            icon: Icon(
              IconsaxPlusLinear.edit,
              size: AppConstants.iconSizeAppBarAction,
              color: colorScheme.primary,
            ),
            tooltip: 'edit'.tr,
          ),
      ],
    );
  }

  void _showTasksActionBottomSheet(BuildContext context) {
    NavigationHelper.showModalSheet(
      context: context,
      enableDrag: false,
      child: TasksAction(
        text: 'editing'.tr,
        edit: true,
        task: widget.task,
        updateTaskName: () => setState(() {}),
      ),
    );
  }

  void _showTodosActionBottomSheet(BuildContext context) {
    NavigationHelper.showModalSheet(
      context: context,
      enableDrag: false,
      child: TodosAction(
        text: 'create'.tr,
        edit: false,
        task: widget.task,
        category: false,
      ),
    );
  }
}
