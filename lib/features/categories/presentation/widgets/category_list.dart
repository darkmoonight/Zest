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

/// Scrollable list of categories.
class CategoryList extends ConsumerStatefulWidget {
  /// Creates a [CategoryList].
  const CategoryList({
    super.key,
    required this.archived,
    required this.searchQuery,
  });

  /// The archived.
  final bool archived;

  /// Search query for filtering categories.
  final String searchQuery;

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
    final categoriesNotifier = ref.read(categoriesNotifierProvider.notifier);
    final todosNotifier = ref.read(todosNotifierProvider.notifier);
    final categoriesState = ref.watch(categoriesNotifierProvider);
    // Progress badges need todo changes even though CategoriesNotifier only watches
    // the tasks collection after the single-watch split.
    ref.watch(todosNotifierProvider.select((s) => s.todos));
    final isImage = ref.watch(appSettingsProvider.select((s) => s.isImage));
    final taskCounts = todosNotifier.rootCountsByCategoryId();

    final categories = categoriesNotifier.getFilteredCategories(
      archived: widget.archived,
      searchQuery: widget.searchQuery,
    );

    if (categories.isEmpty) {
      return _buildEmptyState(context, isMobile, topPadding, isImage);
    }

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        _buildReorderableList(
          categories,
          categoriesNotifier,
          categoriesState,
          taskCounts,
        ),
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
    List<Category> categories,
    CategoriesNotifier categoriesNotifier,
    CategoriesState categoriesState,
    Map<int, (int, int)> taskCounts,
  ) {
    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (context, index) => _buildCategoryCard(
          categories[index],
          categoriesNotifier,
          categoriesState,
          taskCounts,
        ),
        childCount: categories.length,
      ),
      onReorder: (oldIndex, newIndex) =>
          _handleReorder(categories, oldIndex, newIndex, categoriesNotifier),
    );
  }

  /// Builds the category card widget.
  Widget _buildCategoryCard(
    Category category,
    CategoriesNotifier categoriesNotifier,
    CategoriesState categoriesState,
    Map<int, (int, int)> taskCounts,
  ) {
    final counts = taskCounts[category.id] ?? (0, 0);
    final progress = ProgressCalculator(total: counts.$1, completed: counts.$2);

    return CategoryCard(
      key: ValueKey(category.id),
      category: category,
      createdTodos: progress.total,
      completedTodos: progress.completed,
      percent: progress.percentageString,
      isSelected:
          categoriesState.isMultiSelectionCategory &&
          categoriesState.selectedCategoryIds.contains(category.id),
      onTap: () =>
          _handleCategoryTap(category, categoriesNotifier, categoriesState),
      onDoubleTap: () => _handleCategoryDoubleTap(
        category,
        categoriesNotifier,
        categoriesState,
      ),
    );
  }

  /// Void.
  Future<void> _handleReorder(
    List<Category> categories,
    int oldIndex,
    int newIndex,
    CategoriesNotifier categoriesNotifier,
  ) async {
    if (oldIndex == newIndex) return;

    final element = categories.removeAt(oldIndex);
    categories.insert(newIndex, element);

    await categoriesNotifier.reorderCategories(
      filteredCategories: categories,
      archived: widget.archived,
    );
  }

  /// Handle category tap.
  void _handleCategoryTap(
    Category category,
    CategoriesNotifier categoriesNotifier,
    CategoriesState categoriesState,
  ) {
    if (categoriesState.isMultiSelectionCategory) {
      categoriesNotifier.doMultiSelectionCategory(category);
    } else {
      NavigationHelper.toDownToUp(
        context,
        () => CategoryTodos(category: category),
      );
    }
  }

  /// Handle category double tap.
  void _handleCategoryDoubleTap(
    Category category,
    CategoriesNotifier categoriesNotifier,
    CategoriesState categoriesState,
  ) {
    if (!categoriesState.isMultiSelectionCategory) {
      categoriesNotifier.toggleMultiSelectionCategory();
    }
    categoriesNotifier.doMultiSelectionCategory(category);
  }
}
