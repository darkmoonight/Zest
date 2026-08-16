import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/view/todos_list_screen.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/features/todos/presentation/widgets/todos_tab_views.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/app_back_button.dart';

/// Items list for a parent item subtree.
class TodosTodo extends ConsumerStatefulWidget {
  /// Creates a [TodosTodo].
  const TodosTodo({super.key, required this.todo});

  /// Parent item whose children are listed.
  final Todos todo;

  @override
  ConsumerState<TodosTodo> createState() => _TodosTodoState();
}

class _TodosTodoState extends ConsumerState<TodosTodo> {
  @override
  Widget build(BuildContext context) {
    return TodosListScreen(
      config: TodosListScreenConfig(
        initialSortOption: widget.todo.childrenSortOption,
        onSortPersist: (option) async {
          widget.todo.childrenSortOption = option;
          await ref
              .read(isarProvider)
              .writeTxn(() => ref.read(isarProvider).todos.put(widget.todo));
        },
        buildAppBar: (context, todosState) => _buildAppBar(context),
        buildTabViewsConfig: (tabController, searchFilter, sortOption) =>
            TodosTabViewsConfig(
              tabController: tabController,
              searchFilter: searchFilter,
              sortOption: sortOption,
              todo: widget.todo,
            ),
        areAllSelected: (statusFilter, searchFilter, notifier) =>
            notifier.areAllSelected(
              statusFilter: statusFilter,
              searchQuery: searchFilter,
              parent: widget.todo,
            ),
        toggleSelectAll: (statusFilter, searchFilter, select, notifier) =>
            notifier.selectAll(
              select: select,
              statusFilter: statusFilter,
              searchQuery: searchFilter,
              parent: widget.todo,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: const AppBackButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.todo.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.todo.description.isNotEmpty)
            Text(
              widget.todo.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            IconsaxPlusLinear.edit,
            size: AppConstants.iconSizeAppBarAction,
            color: colorScheme.primary,
          ),
          onPressed: () => _showEditTodoSheet(context),
        ),
        SizedBox(width: AppConstants.spacingXS),
      ],
    );
  }

  void _showEditTodoSheet(BuildContext context) {
    NavigationHelper.showFormModal(
      context: context,
      enableDrag: false,
      child: TodosAction(
        text: 'editing'.tr,
        edit: true,
        todo: widget.todo,
        category: true,
      ),
    );
  }

  void _showTodosActionBottomSheet(BuildContext context) {
    NavigationHelper.showFormModal(
      context: context,
      enableDrag: false,
      child: TodosAction(
        text: 'create'.tr,
        edit: false,
        todo: widget.todo,
        category: false,
      ),
    );
  }
}
