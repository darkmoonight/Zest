import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/utils/progress_calculator.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/multi_select_action_bar.dart';
import 'package:zest/core/widgets/scroll_fab_listener.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/core/widgets/my_delegate.dart';
import 'package:zest/core/widgets/text_form.dart';
import 'package:zest/features/tasks/presentation/widgets/statistics.dart';
import 'package:zest/features/tasks/presentation/widgets/task_list.dart';
import 'package:zest/i18n/tr.dart';

/// Main tasks screen with search, stats, and active/archived tabs.
class AllTasks extends ConsumerStatefulWidget {
  /// Creates a [AllTasks].
  const AllTasks({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends ConsumerState<AllTasks>
    with SingleTickerProviderStateMixin {
  /// The tab controller.
  late final TabController _tabController;

  /// The search controller.
  late final TextEditingController _searchController;

  /// Scroll controller for the nested scroll view.
  late final ScrollController _scrollController;

  /// Filter.
  String _filter = '';

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_onTabChanged);
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle multi selection changed.
  void _handleMultiSelectionChanged(bool? prev, bool next) {
    if (next) {
      ref.read(fabNotifierProvider.notifier).setVisibility(false);
    } else if (_tabController.index == 0) {
      ref.read(fabNotifierProvider.notifier).setVisibility(true);
    }
  }

  /// On tab changed.
  void _onTabChanged() {
    if (!mounted) return;

    if (_tabController.index == 1) {
      ref.read(fabNotifierProvider.notifier).setVisibility(false);
    } else if (!ref.read(tasksNotifierProvider).isMultiSelectionTask) {
      ref.read(fabNotifierProvider.notifier).setVisibility(true);
    }
  }

  /// Apply filter.
  void _applyFilter(String value) => setState(() => _filter = value);

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    ref.listen(
      tasksNotifierProvider.select((s) => s.isMultiSelectionTask),
      _handleMultiSelectionChanged,
    );

    final tasksState = ref.watch(tasksNotifierProvider);
    final progress = ProgressCalculator(
      total: ref.read(todosNotifierProvider.notifier).createdAllTodos(),
      completed: ref.read(todosNotifierProvider.notifier).completedAllTodos(),
    );

    return PopScope(
      canPop: tasksState.isPop,
      onPopInvokedWithResult: _handlePopInvokedWithResult,
      child: Scaffold(
        body: SafeArea(child: _buildBody(context, progress, tasksState)),
      ),
    );
  }

  /// Handle pop invoked with result.
  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) return;

    if (ref.read(tasksNotifierProvider).isMultiSelectionTask) {
      ref.read(tasksNotifierProvider.notifier).doMultiSelectionTaskClear();
    }
  }

  /// Builds the body widget.
  Widget _buildBody(
    BuildContext context,
    ProgressCalculator progress,
    TasksState tasksState,
  ) {
    return Stack(
      children: [
        _buildScrollableContent(context, progress, tasksState),
        _buildMultiSelectionBar(context, tasksState),
      ],
    );
  }

  /// Builds the scrollable content widget.
  Widget _buildScrollableContent(
    BuildContext context,
    ProgressCalculator progress,
    TasksState tasksState,
  ) {
    return ScrollFabListener(
      tabController: _tabController,
      setFabVisibility: ref.read(fabNotifierProvider.notifier).setVisibility,
      disabled: tasksState.isMultiSelectionTask,
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSearchTextField(context),
          _buildStatistics(progress),
          _buildTabBar(context),
        ],
        body: _buildTabBarView(),
      ),
    );
  }

  /// Builds the search text field widget.
  Widget _buildSearchTextField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return SliverToBoxAdapter(
      child: MyTextForm(
        labelText: 'searchCategory'.tr,
        variant: TextFieldVariant.card,
        type: TextInputType.text,
        icon: Icon(
          IconsaxPlusLinear.search_normal_1,
          size: AppConstants.iconSizeMedium,
          color: colorScheme.onSurfaceVariant,
        ),
        controller: _searchController,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile
              ? AppConstants.spacingS + 2
              : AppConstants.spacingL,
          vertical: isMobile
              ? AppConstants.spacingXS + 1
              : AppConstants.spacingS,
        ),
        onChanged: _applyFilter,
        iconButton: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: _clearSearch,
                icon: Icon(
                  IconsaxPlusLinear.close_circle,
                  color: colorScheme.onSurfaceVariant,
                  size: AppConstants.iconSizeMedium,
                ),
              )
            : null,
      ),
    );
  }

  /// Clear search.
  void _clearSearch() {
    _searchController.clear();
    _applyFilter('');
  }

  /// Builds the statistics widget.
  Widget _buildStatistics(ProgressCalculator progress) {
    return SliverToBoxAdapter(
      child: Statistics(
        createdTodos: progress.total,
        completedTodos: progress.completed,
        percent: progress.percentageString,
      ),
    );
  }

  /// Builds the tab bar widget.
  Widget _buildTabBar(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverPersistentHeader(
        delegate: MyDelegate(
          child: TabBar(
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            isScrollable: true,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: 'active'.tr),
              Tab(text: 'archived'.tr),
            ],
          ),
        ),
        floating: true,
        pinned: true,
      ),
    );
  }

  /// Builds the tab bar view widget.
  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        TasksList(archived: false, searchTask: _filter),
        TasksList(archived: true, searchTask: _filter),
      ],
    );
  }

  /// Builds the multi selection bar widget.
  Widget _buildMultiSelectionBar(BuildContext context, TasksState tasksState) {
    if (!tasksState.isMultiSelectionTask) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final selectedCount = tasksState.selectedTask.length;

    return MultiSelectActionBar(
      selectedCount: selectedCount,
      isAllSelected: _areAllSelectedInCurrentTab(),
      onSelectAll: _toggleSelectAll,
      onClose: tasksNotifier.doMultiSelectionTaskClear,
      actions: [
        MultiSelectAction(
          icon: _isArchiveTab
              ? IconsaxPlusLinear.refresh_left_square
              : IconsaxPlusLinear.archive_add,
          color: colorScheme.primary,
          onPressed: () =>
              _showArchiveConfirmationDialog(context, tasksNotifier),
          tooltip: _isArchiveTab ? 'restore'.tr : 'archive'.tr,
        ),
        MultiSelectAction(
          icon: IconsaxPlusLinear.trash,
          color: colorScheme.error,
          onPressed: () =>
              _showDeleteConfirmationDialog(context, tasksNotifier),
          tooltip: 'delete'.tr,
        ),
      ],
    );
  }

  bool get _isArchiveTab => _tabController.index == 1;

  /// Are all selected in current tab.
  bool _areAllSelectedInCurrentTab() {
    return ref
        .read(tasksNotifierProvider.notifier)
        .areAllTasksSelected(archived: _isArchiveTab, searchQuery: _filter);
  }

  /// Toggle select all.
  void _toggleSelectAll() {
    final allSelected = _areAllSelectedInCurrentTab();
    ref
        .read(tasksNotifierProvider.notifier)
        .selectAllTasks(
          select: !allSelected,
          archived: _isArchiveTab,
          searchQuery: _filter,
        );
  }

  /// Void.
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    TasksNotifier tasksNotifier,
  ) async {
    final selected = ref.read(tasksNotifierProvider).selectedTask;
    await showDeleteConfirmation(
      context: context,
      title: 'deleteCategory',
      message: 'deleteCategoryQuery',
      onConfirm: () {
        tasksNotifier.deleteTask(selected);
        tasksNotifier.doMultiSelectionTaskClear();
      },
    );
  }

  /// Void.
  Future<void> _showArchiveConfirmationDialog(
    BuildContext context,
    TasksNotifier tasksNotifier,
  ) async {
    final selected = ref.read(tasksNotifierProvider).selectedTask;
    await showArchiveConfirmation(
      context: context,
      title: _isArchiveTab ? 'noArchiveCategory' : 'archiveCategory',
      message: _isArchiveTab
          ? 'noArchiveCategoryQuery'
          : 'archiveCategoryQuery',
      isUnarchive: _isArchiveTab,
      onConfirm: () {
        if (_isArchiveTab) {
          tasksNotifier.noArchiveTask(selected);
        } else {
          tasksNotifier.archiveTask(selected);
        }
        tasksNotifier.doMultiSelectionTaskClear();
      },
    );
  }
}
