import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/utils/progress_calculator.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/scroll_fab_listener.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/core/widgets/my_delegate.dart';
import 'package:zest/core/widgets/text_form.dart';
import 'package:zest/features/tasks/presentation/widgets/statistics.dart';
import 'package:zest/features/tasks/presentation/widgets/task_list.dart';
import 'package:zest/i18n/tr.dart';

/// Widget that all tasks.
class AllTasks extends ConsumerStatefulWidget {
  /// Creates a [AllTasks].
  const AllTasks({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<AllTasks> createState() => _AllTasksState();
}

/// Widget that all tasks state.
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

    return _buildFloatingActionBar(context, tasksState);
  }

  /// Builds the floating action bar widget.
  Widget _buildFloatingActionBar(BuildContext context, TasksState tasksState) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);

    return Positioned(
      bottom: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
      left: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
      right: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
      child: _AnimatedMultiSelectBar(
        child: Material(
          elevation: AppConstants.elevationMedium,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? AppConstants.spacingM
                  : AppConstants.spacingL,
              vertical: AppConstants.spacingM,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: AppConstants.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildSelectionCounter(context, tasksState)),
                SizedBox(width: AppConstants.spacingS),
                _buildActionButtons(context, tasksNotifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the selection counter widget.
  Widget _buildSelectionCounter(BuildContext context, TasksState tasksState) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCount = tasksState.selectedTask.length;

    return InkWell(
      onTap: _toggleSelectAll,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall + 2),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusSmall + 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSelectionBadge(context),
            SizedBox(width: AppConstants.spacingS + 2),
            Flexible(
              child: Text(
                selectedCount == 1
                    ? '1 ${'item'.tr}'
                    : '$selectedCount ${'items'.tr}',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the selection badge widget.
  Widget _buildSelectionBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Icon(
      _areAllSelectedInCurrentTab()
          ? IconsaxPlusBold.tick_square
          : IconsaxPlusLinear.tick_square,
      size: AppConstants.iconSizeMedium,
      color: colorScheme.onPrimaryContainer,
    );
  }

  /// Builds the action buttons widget.
  Widget _buildActionButtons(
    BuildContext context,
    TasksNotifier tasksNotifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: _isArchiveTab
              ? IconsaxPlusLinear.refresh_left_square
              : IconsaxPlusLinear.archive_add,
          color: colorScheme.primary,
          onPressed: () =>
              _showArchiveConfirmationDialog(context, tasksNotifier),
          tooltip: _isArchiveTab ? 'restore'.tr : 'archive'.tr,
        ),
        _ActionButton(
          icon: IconsaxPlusLinear.trash,
          color: colorScheme.error,
          onPressed: () =>
              _showDeleteConfirmationDialog(context, tasksNotifier),
          tooltip: 'delete'.tr,
        ),
        SizedBox(width: AppConstants.spacingXS),
        FilledButton.tonal(
          onPressed: tasksNotifier.doMultiSelectionTaskClear,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacingL,
              vertical: AppConstants.spacingS + 2,
            ),
            minimumSize: const Size(0, 40),
          ),
          child: Icon(
            IconsaxPlusLinear.close_circle,
            size: AppConstants.iconSizeSmall,
          ),
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

/// Widget that action button.
class _ActionButton extends StatelessWidget {
  /// Creates a [_ActionButton].
  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  /// The icon.
  final IconData icon;

  /// The on pressed.
  final VoidCallback onPressed;

  /// The color.
  final Color? color;

  /// The tooltip.
  final String? tooltip;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: AppConstants.iconSizeMedium + 2, color: color),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
      ),
      tooltip: tooltip,
    );
  }
}

/// Widget that animated multi select bar.
class _AnimatedMultiSelectBar extends StatelessWidget {
  /// Creates a [_AnimatedMultiSelectBar].
  const _AnimatedMultiSelectBar({required this.child});

  /// The child.
  final Widget child;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppConstants.animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
