import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/features/todos/presentation/widgets/todos_screen_mixin.dart';
import 'package:zest/features/todos/presentation/widgets/todos_search_sliver.dart';
import 'package:zest/features/todos/presentation/widgets/todos_status_tab_bar.dart';
import 'package:zest/features/todos/presentation/widgets/todos_tab_views.dart';
import 'package:zest/core/widgets/scroll_fab_listener.dart';

/// Configuration for [TodosListScreen] scoped to a task or parent item.
class TodosListScreenConfig {
  /// Creates a [TodosListScreenConfig].
  const TodosListScreenConfig({
    required this.initialSortOption,
    required this.onSortPersist,
    required this.buildAppBar,
    required this.buildTabViewsConfig,
    required this.areAllSelected,
    required this.toggleSelectAll,
    required this.buildFab,
  });

  /// Initial sort option loaded from persistence.
  final SortOption initialSortOption;

  /// Persists sort option changes to Isar.
  final Future<void> Function(SortOption option) onSortPersist;

  /// Builds the screen app bar for the current selection state.
  final PreferredSizeWidget Function(BuildContext context, TodosState state)
  buildAppBar;

  /// Builds tab view configuration for the nested scroll body.
  final TodosTabViewsConfig Function(
    TabController tabController,
    String searchFilter,
    SortOption sortOption,
  )
  buildTabViewsConfig;

  /// Whether all visible items in the current tab are selected.
  final bool Function(
    TodoStatus statusFilter,
    String searchFilter,
    TodosNotifier todosNotifier,
  )
  areAllSelected;

  /// Toggles select-all for the current tab.
  final void Function(
    TodoStatus statusFilter,
    String searchFilter,
    bool select,
    TodosNotifier todosNotifier,
  )
  toggleSelectAll;

  /// Builds the FAB when visible; return null to hide.
  final Widget? Function(BuildContext context) buildFab;
}

/// Shared items list screen shell for task and sub-item navigation.
class TodosListScreen extends ConsumerStatefulWidget {
  /// Creates a [TodosListScreen].
  const TodosListScreen({super.key, required this.config});

  /// Screen-specific configuration.
  final TodosListScreenConfig config;

  @override
  ConsumerState<TodosListScreen> createState() => _TodosListScreenState();
}

class _TodosListScreenState extends ConsumerState<TodosListScreen>
    with SingleTickerProviderStateMixin, TodosScreenMixin {
  @override
  void initState() {
    super.initState();
    initializeTodosScreen(
      initialSortOption: widget.config.initialSortOption,
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
  void dispose() {
    disposeTodosScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosNotifierProvider);

    return PopScope(
      canPop: todosState.isPop,
      onPopInvokedWithResult: handlePopInvoked,
      child: Scaffold(
        appBar: widget.config.buildAppBar(context, todosState),
        body: SafeArea(child: _buildBody(context, todosState)),
        floatingActionButton: widget.config.buildFab(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TodosState todosState) {
    return Stack(
      children: [
        _buildScrollableContent(context, todosState),
        _buildSelectionActionBar(context, todosState),
      ],
    );
  }

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
          config: widget.config.buildTabViewsConfig(
            tabController,
            searchFilter,
            sortOption,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSortChanged(SortOption option) async {
    updateSortOption(option);
    await widget.config.onSortPersist(option);
  }

  Widget _buildSelectionActionBar(BuildContext context, TodosState todosState) {
    final statusFilter = TodoStatus.fromTabIndex(tabController.index);

    return buildSelectionActionBar(
      isMultiSelection: todosState.isMultiSelectionTodo,
      selectedCount: todosState.selectedTodo.length,
      onTransfer: () => showTodosTransferSheet(context),
      onDelete: () => showDeleteDialog(context),
      onSelectAll: () {
        final allSelected = widget.config.areAllSelected(
          statusFilter,
          searchFilter,
          todosNotifier,
        );
        widget.config.toggleSelectAll(
          statusFilter,
          searchFilter,
          !allSelected,
          todosNotifier,
        );
      },
      isAllSelected: widget.config.areAllSelected(
        statusFilter,
        searchFilter,
        todosNotifier,
      ),
    );
  }
}
