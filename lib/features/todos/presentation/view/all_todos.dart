import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/features/todos/presentation/widgets/todos_screen_mixin.dart';
import 'package:zest/features/todos/presentation/widgets/todos_search_sliver.dart';
import 'package:zest/features/todos/presentation/widgets/todos_status_tab_bar.dart';
import 'package:zest/features/todos/presentation/widgets/todos_tab_views.dart';
import 'package:zest/core/widgets/scroll_fab_listener.dart';

/// Shared tab/search state and actions for todo list screens.
class AllTodos extends ConsumerStatefulWidget {
  /// Creates the global all-todos screen.
  const AllTodos({super.key});

  @override
  ConsumerState<AllTodos> createState() => _AllTodosState();
}

class _AllTodosState extends ConsumerState<AllTodos>
    with SingleTickerProviderStateMixin, TodosScreenMixin {
  @override
  void initState() {
    super.initState();
    initializeTodosScreen(
      initialSortOption: ref.read(settingsProvider).allTodosSortOption,
      vsync: this,
    );
    setupTodosScreenListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateFabVisibility();
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
      child: Scaffold(body: SafeArea(child: _buildBody(context, todosState))),
    );
  }

  Widget _buildBody(BuildContext context, TodosState todosState) {
    final showArchived = ref.watch(settingsProvider).showArchivedInAllTodos;
    final excludeArchived = !showArchived;

    return Stack(
      children: [
        ScrollFabListener(
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
                showArchived: showArchived,
                onShowArchivedChanged: _handleShowArchivedChanged,
              ),
            ],
            body: TodosTabViews(
              config: TodosTabViewsConfig(
                tabController: tabController,
                searchFilter: searchFilter,
                sortOption: sortOption,
                allTodos: true,
                excludeArchivedCategories: excludeArchived,
              ),
            ),
          ),
        ),
        buildSelectionActionBar(
          isMultiSelection: todosState.isMultiSelectionTodo,
          selectedCount: todosState.selectedTodo.length,
          onTransfer: () => showTodosTransferSheet(context),
          onDelete: () => showDeleteDialog(context),
          onSelectAll: _toggleSelectAll,
          isAllSelected: _areAllSelectedInCurrentTab(excludeArchived),
        ),
      ],
    );
  }

  Future<void> _handleShowArchivedChanged(bool value) async {
    final settings = ref.read(liveSettingsProvider);
    settings.showArchivedInAllTodos = value;
    await ref.read(settingsRepositoryProvider).save(settings);
    if (mounted) setState(() {});
  }

  Future<void> _handleSortChanged(SortOption option) async {
    updateSortOption(option);
    final settings = ref.read(liveSettingsProvider);
    settings.allTodosSortOption = option;
    await ref.read(settingsRepositoryProvider).save(settings);
  }

  bool _areAllSelectedInCurrentTab(bool excludeArchived) {
    return todosNotifier.areAllSelected(
      statusFilter: TodoStatus.fromTabIndex(tabController.index),
      searchQuery: searchFilter,
      excludeArchivedCategories: excludeArchived,
    );
  }

  void _toggleSelectAll() {
    final excludeArchived = !ref.read(settingsProvider).showArchivedInAllTodos;
    final allSelected = _areAllSelectedInCurrentTab(excludeArchived);
    todosNotifier.selectAll(
      select: !allSelected,
      statusFilter: TodoStatus.fromTabIndex(tabController.index),
      searchQuery: searchFilter,
      excludeArchivedCategories: excludeArchived,
    );
  }
}
