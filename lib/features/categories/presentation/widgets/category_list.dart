import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:reorderables/reorderables.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/progress_calculator.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/list_empty.dart';
import 'package:zest/domain/entities/entities.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';
import 'package:zest/features/categories/presentation/widgets/category_card.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/features/todos/presentation/view/category_todos.dart';
import 'package:zest/i18n/tr.dart';

/// Scrollable list of task categories.
class CategoryList extends ConsumerStatefulWidget {
  /// Creates a [TasksList].
  const CategoryList({
    super.key,
    required this.archived,
    required this.searchTask,
  });

  /// The archived.
  final bool archived;

  /// The search task.
  final String searchTask;

  @override
  /// Creates the state for this widget.
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    super.build(context);

    final isMobile = ResponsiveUtils.isMobile(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final tasksNotifier = ref.read(categoriesNotifierProvider.notifier);
    final todosNotifier = ref.read(todosNotifierProvider.notifier);
    final tasksState = ref.watch(categoriesNotifierProvider);
    // Progress badges need todo changes even though CategoriesNotifier only watches
    // the tasks collection after the single-watch split.
    ref.watch(todosNotifierProvider.select((s) => s.todos));
    final isImage = ref.watch(appSettingsProvider.select((s) => s.isImage));
    final taskCounts = todosNotifier.rootCountsByTaskId();

    final tasks = tasksNotifier.getFilteredTasks(
      archived: widget.archived,
      searchQuery: widget.searchTask,
    );

    if (tasks.isEmpty) {
      return _buildEmptyState(context, isMobile, topPadding, isImage);
    }

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        _buildReorderableList(tasks, tasksNotifier, tasksState, taskCounts),
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
      padding: EdgeInsets.only(
        top: topPadding + ResponsiveUtils.getEmptyStateTopOffset(context),
      ),
      child: ListEmpty(
        img: AppConstants.emptyStateCategoryImage,
        text: widget.archived ? 'addArchiveCategory'.tr : 'addCategory'.tr,
        subtitle: widget.archived
            ? 'addArchiveCategoryHint'.tr
            : 'addCategoryHint'.tr,
        icon: !isImage
            ? (widget.archived
                  ? IconsaxPlusBold.archive
                  : IconsaxPlusBold.folder_2)
            : null,
      ),
    );
  }

  /// Builds the reorderable list widget.
  Widget _buildReorderableList(
    List<Category> tasks,
    CategoriesNotifier tasksNotifier,
    CategoriesState tasksState,
    Map<int, (int, int)> taskCounts,
  ) {
    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (context, index) =>
            _buildCategoryCard(tasks[index], tasksNotifier, tasksState, taskCounts),
        childCount: tasks.length,
      ),
      onReorder: (oldIndex, newIndex) =>
          _handleReorder(tasks, oldIndex, newIndex, tasksNotifier),
    );
  }

  /// Builds the task card widget.
  Widget _buildCategoryCard(
    Category task,
    CategoriesNotifier tasksNotifier,
    CategoriesState tasksState,
    Map<int, (int, int)> taskCounts,
  ) {
    final counts = taskCounts[task.id] ?? (0, 0);
    final progress = ProgressCalculator(total: counts.$1, completed: counts.$2);

    return CategoryCard(
      key: ValueKey(task.id),
      category: task,
      createdTodos: progress.total,
      completedTodos: progress.completed,
      percent: progress.percentageString,
      isSelected:
          tasksState.isMultiSelectionCategory &&
          tasksState.selectedCategoryIds.contains(task.id),
      onTap: () => _handleTaskTap(task, tasksNotifier, tasksState),
      onDoubleTap: () => _handleTaskDoubleTap(task, tasksNotifier, tasksState),
    );
  }

  /// Void.
  Future<void> _handleReorder(
    List<Category> tasks,
    int oldIndex,
    int newIndex,
    CategoriesNotifier tasksNotifier,
  ) async {
    if (oldIndex == newIndex) return;

    final element = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, element);

    await tasksNotifier.reorderCategories(
      filteredTasks: tasks,
      archived: widget.archived,
    );
  }

  /// Handle task tap.
  void _handleTaskTap(
    Category task,
    CategoriesNotifier tasksNotifier,
    CategoriesState tasksState,
  ) {
    if (tasksState.isMultiSelectionCategory) {
      tasksNotifier.doMultiSelectionCategory(task);
    } else {
      NavigationHelper.toDownToUp(context, () => CategoryTodos(task: task));
    }
  }

  /// Handle task double tap.
  void _handleTaskDoubleTap(
    Category task,
    CategoriesNotifier tasksNotifier,
    CategoriesState tasksState,
  ) {
    if (!tasksState.isMultiSelectionCategory) {
      tasksNotifier.toggleMultiSelectionCategory();
    }
    tasksNotifier.doMultiSelectionCategory(task);
  }
}
