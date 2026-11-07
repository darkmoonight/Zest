import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/domain/entities/entities.dart';
import 'package:zest/features/categories/presentation/widgets/categories_action.dart';
import 'package:zest/features/todos/presentation/view/todos_list_screen.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/features/todos/presentation/widgets/todos_tab_views.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/app_back_button.dart';

/// Items list for a task category.
class CategoryTodos extends ConsumerStatefulWidget {
  /// Creates a [CategoryTodos].
  const CategoryTodos({super.key, required this.category});

  /// Task category whose items are listed.
  final Category category;

  @override
  ConsumerState<CategoryTodos> createState() => _CategoryTodosState();
}

class _CategoryTodosState extends ConsumerState<CategoryTodos> {
  /// Mutable snapshot so AppBar/list refresh after category edit.
  late Category _category;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
  }

  @override
  void didUpdateWidget(covariant CategoryTodos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _category = widget.category;
    }
  }

  /// Pulls the latest category from the notifier after an edit save.
  void _refreshCategoryFromNotifier() {
    final id = _category.id;
    for (final category in ref.read(categoriesNotifierProvider).categories) {
      if (category.id == id) {
        setState(() => _category = category);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TodosListScreen(
      config: TodosListScreenConfig(
        initialSortOption: _category.sortOption,
        onSortPersist: (option) async {
          await ref
              .read(categoriesNotifierProvider.notifier)
              .persistCategorySort(_category, option);
        },
        buildAppBar: (context, todosState) => _buildAppBar(context, todosState),
        buildTabViewsConfig: (tabController, searchFilter, sortOption) =>
            TodosTabViewsConfig(
              tabController: tabController,
              searchFilter: searchFilter,
              sortOption: sortOption,
              category: _category,
            ),
        areAllSelected: (statusFilter, searchFilter, notifier) =>
            notifier.areAllSelected(
              statusFilter: statusFilter,
              searchQuery: searchFilter,
              category: _category,
            ),
        toggleSelectAll: (statusFilter, searchFilter, select, notifier) =>
            notifier.selectAll(
              select: select,
              statusFilter: statusFilter,
              searchQuery: searchFilter,
              category: _category,
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
            _category.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (_category.description.isNotEmpty)
            Text(
              _category.description,
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
            onPressed: () => _showCategoriesActionBottomSheet(context),
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

  void _showCategoriesActionBottomSheet(BuildContext context) {
    NavigationHelper.showFormModal(
      context: context,
      enableDrag: false,
      child: CategoriesAction(
        text: 'editing'.tr,
        edit: true,
        category: _category,
        updateCategoryName: _refreshCategoryFromNotifier,
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
        category: _category,
        showCategory: false,
      ),
    );
  }
}
