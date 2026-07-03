import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/features/todos/presentation/widgets/todos_screen_mixin.dart';
import 'package:zest/features/todos/presentation/widgets/todos_search_sliver.dart';
import 'package:zest/features/todos/presentation/widgets/todos_status_tab_bar.dart';
import 'package:zest/features/todos/presentation/widgets/todos_tab_views.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/scroll_fab_listener.dart';

/// Widget that todos todo.
class TodosTodo extends ConsumerStatefulWidget {
  /// Creates a [TodosTodo].
  const TodosTodo({super.key, required this.todo});

  /// The todo.
  final Todos todo;

  @override
  /// Creates the state for this widget.
  ConsumerState<TodosTodo> createState() => _TodosTodoState();
}

/// Widget that todos todo state.
class _TodosTodoState extends ConsumerState<TodosTodo>
    with SingleTickerProviderStateMixin, TodosScreenMixin {
  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    initializeTodosScreen(
      initialSortOption: widget.todo.childrenSortOption,
      vsync: this,
    );
    setupTodosScreenListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) updateFabVisibility();
    });
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    disposeTodosScreen();
    super.dispose();
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosNotifierProvider);

    return PopScope(
      canPop: todosState.isPop,
      onPopInvokedWithResult: handlePopInvoked,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(child: _buildBody(context, todosState)),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  /// Builds the app bar widget.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        icon: Icon(
          IconsaxPlusLinear.arrow_left_1,
          color: colorScheme.onSurface,
        ),
        onPressed: () => NavigationHelper.back(context),
      ),
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
            size: 22,
            color: colorScheme.primary,
          ),
          onPressed: () => _showEditTodoSheet(context),
        ),
        SizedBox(width: AppConstants.spacingXS),
      ],
    );
  }

  /// Show edit todo sheet.
  void _showEditTodoSheet(BuildContext context) {
    NavigationHelper.showModalSheet(
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

  /// Builds the body widget.
  Widget _buildBody(BuildContext context, TodosState todosState) {
    return Stack(
      children: [
        _buildScrollableContent(context, todosState),
        _buildSelectionActionBar(context, todosState),
      ],
    );
  }

  /// Builds the scrollable content widget.
  Widget _buildScrollableContent(BuildContext context, TodosState todosState) {
    return ScrollFabListener(
      tabController: tabController,
      setFabVisibility: setFabVisible,
      disabled: todosState.isMultiSelectionTodo,
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          TodosSearchSliver(
            controller: searchController,
            onChanged: applySearchFilter,
            onClear: clearSearch,
          ),
          TodosStatusTabBar(
            tabController: tabController,
            sortOption: sortOption,
            onSortChanged: _handleSortChanged,
          ),
        ],
        body: TodosTabViews(
          config: TodosTabViewsConfig(
            tabController: tabController,
            searchFilter: searchFilter,
            sortOption: sortOption,
            todo: widget.todo,
          ),
        ),
      ),
    );
  }

  /// Void.
  Future<void> _handleSortChanged(SortOption option) async {
    updateSortOption(option);
    widget.todo.childrenSortOption = option;
    await ref
        .read(isarProvider)
        .writeTxn(() => ref.read(isarProvider).todos.put(widget.todo));
  }

  /// Builds the selection action bar widget.
  Widget _buildSelectionActionBar(BuildContext context, TodosState todosState) {
    return buildSelectionActionBar(
      isMultiSelection: todosState.isMultiSelectionTodo,
      selectedCount: todosState.selectedTodo.length,
      onTransfer: () => showTodosTransferSheet(context),
      onDelete: () => showDeleteDialog(context),
      onSelectAll: _toggleSelectAll,
      isAllSelected: _areAllSelectedInCurrentTab(),
    );
  }

  /// Builds the floating action button widget.
  Widget? _buildFloatingActionButton(BuildContext context) {
    if (!ref.watch(fabNotifierProvider).isVisible) return null;

    return FloatingActionButton(
      onPressed: () => _showTodosActionBottomSheet(context, edit: false),
      child: const Icon(IconsaxPlusLinear.add),
    );
  }

  /// Show todos action bottom sheet.
  void _showTodosActionBottomSheet(BuildContext context, {required bool edit}) {
    NavigationHelper.showModalSheet(
      context: context,
      enableDrag: false,
      child: TodosAction(
        text: 'create'.tr,
        edit: edit,
        todo: widget.todo,
        category: false,
      ),
    );
  }

  /// Are all selected in current tab.
  bool _areAllSelectedInCurrentTab() {
    return todosNotifier.areAllSelected(
      statusFilter: TodoStatus.fromTabIndex(tabController.index),
      searchQuery: searchFilter,
      parent: widget.todo,
    );
  }

  void _toggleSelectAll() {
    final allSelected = _areAllSelectedInCurrentTab();
    todosNotifier.selectAll(
      select: !allSelected,
      statusFilter: TodoStatus.fromTabIndex(tabController.index),
      searchQuery: searchFilter,
      parent: widget.todo,
    );
  }
}
