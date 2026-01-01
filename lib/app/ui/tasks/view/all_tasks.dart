import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/tasks/widgets/statistics.dart';
import 'package:zest/app/ui/tasks/widgets/task_list.dart';
import 'package:zest/app/ui/widgets/confirmation_dialog.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/progress_calculator.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/scroll_fab_handler.dart';

class AllTasks extends StatefulWidget {
  const AllTasks({super.key});

  @override
  State<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks>
    with SingleTickerProviderStateMixin {
  late final TodoController _todoController = Get.put(TodoController());
  late final FabController _fabController = Get.find<FabController>();
  late final TabController _tabController;
  late final TextEditingController _searchController;

  String _filter = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    _searchController = TextEditingController();
    _tabController = TabController(vsync: this, length: 2);
  }

  void _setupListeners() {
    _tabController.addListener(_onTabChanged);
    ever(_todoController.isMultiSelectionTask, _handleMultiSelectionChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleMultiSelectionChanged(bool isMultiSelection) {
    if (isMultiSelection) {
      _fabController.hide();
    } else {
      if (_tabController.index == 0) {
        _fabController.show();
      }
    }
  }

  void _onTabChanged() {
    if (!mounted) return;

    if (_tabController.index == 1) {
      _fabController.hide();
    } else {
      if (!_todoController.isMultiSelectionTask.value) {
        _fabController.show();
      }
    }
  }

  void _applyFilter(String value) => setState(() => _filter = value);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = ProgressCalculator(
        total: _todoController.createdAllTodos(),
        completed: _todoController.completedAllTodos(),
      );

      return PopScope(
        canPop: _todoController.isPop.value,
        onPopInvokedWithResult: _handlePopInvokedWithResult,
        child: Scaffold(body: SafeArea(child: _buildBody(context, progress))),
      );
    });
  }

  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) return;

    if (_todoController.isMultiSelectionTask.isTrue) {
      _todoController.doMultiSelectionTaskClear();
    }
  }

  Widget _buildBody(BuildContext context, ProgressCalculator progress) {
    return Stack(
      children: [
        _buildScrollableContent(context, progress),
        _buildMultiSelectionBar(context),
      ],
    );
  }

  Widget _buildScrollableContent(
    BuildContext context,
    ProgressCalculator progress,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_todoController.isMultiSelectionTask.value) {
          return true;
        }

        return ScrollFabHandler.handleScrollFabVisibility(
          notification: notification,
          tabController: _tabController,
          fabController: _fabController,
        );
      },
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSearchTextField(context),
            _buildStatistics(progress),
            _buildTabBar(context),
          ],
          body: _buildTabBarView(),
        ),
      ),
    );
  }

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

  void _clearSearch() {
    _searchController.clear();
    _applyFilter('');
  }

  Widget _buildStatistics(ProgressCalculator progress) {
    return SliverToBoxAdapter(
      child: Statistics(
        createdTodos: progress.total,
        completedTodos: progress.completed,
        percent: progress.percentageString,
      ),
    );
  }

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

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        TasksList(archived: false, searchTask: _filter),
        TasksList(archived: true, searchTask: _filter),
      ],
    );
  }

  Widget _buildMultiSelectionBar(BuildContext context) {
    return Obx(() {
      if (!_todoController.isMultiSelectionTask.isTrue) {
        return const SizedBox.shrink();
      }

      return _buildFloatingActionBar(context);
    });
  }

  Widget _buildFloatingActionBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

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
                Expanded(child: _buildSelectionCounter(context)),
                SizedBox(width: AppConstants.spacingS),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCounter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCount = _todoController.selectedTask.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall + 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSelectionBadge(context, selectedCount),
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
    );
  }

  Widget _buildSelectionBadge(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          IconsaxPlusBold.tick_square,
          size: AppConstants.iconSizeMedium,
          color: colorScheme.onPrimaryContainer,
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingXS),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primaryContainer,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: _areAllSelectedInCurrentTab()
              ? IconsaxPlusBold.tick_square
              : IconsaxPlusLinear.tick_square,
          onPressed: _toggleSelectAll,
          tooltip: 'selectAll'.tr,
        ),
        _ActionButton(
          icon: _isArchiveTab
              ? IconsaxPlusLinear.refresh_left_square
              : IconsaxPlusLinear.archive_add,
          color: colorScheme.primary,
          onPressed: () => _showArchiveConfirmationDialog(context),
          tooltip: _isArchiveTab ? 'restore'.tr : 'archive'.tr,
        ),
        _ActionButton(
          icon: IconsaxPlusLinear.trash,
          color: colorScheme.error,
          onPressed: () => _showDeleteConfirmationDialog(context),
          tooltip: 'delete'.tr,
        ),
        SizedBox(width: AppConstants.spacingXS),
        FilledButton.tonal(
          onPressed: _todoController.doMultiSelectionTaskClear,
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

  bool _areAllSelectedInCurrentTab() {
    return _todoController.areAllTasksSelected(
      archived: _isArchiveTab,
      searchQuery: _filter,
    );
  }

  void _toggleSelectAll() {
    final allSelected = _areAllSelectedInCurrentTab();
    _todoController.selectAllTasks(
      select: !allSelected,
      archived: _isArchiveTab,
      searchQuery: _filter,
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    await showDeleteConfirmation(
      context: context,
      title: 'deleteCategory',
      message: 'deleteCategoryQuery',
      onConfirm: () {
        _todoController.deleteTask(_todoController.selectedTask);
        _todoController.doMultiSelectionTaskClear();
      },
    );
  }

  Future<void> _showArchiveConfirmationDialog(BuildContext context) async {
    await showArchiveConfirmation(
      context: context,
      title: _isArchiveTab ? 'noArchiveCategory' : 'archiveCategory',
      message: _isArchiveTab
          ? 'noArchiveCategoryQuery'
          : 'archiveCategoryQuery',
      isUnarchive: _isArchiveTab,
      onConfirm: () {
        if (_isArchiveTab) {
          _todoController.noArchiveTask(_todoController.selectedTask);
        } else {
          _todoController.archiveTask(_todoController.selectedTask);
        }
        _todoController.doMultiSelectionTaskClear();
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  @override
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

class _AnimatedMultiSelectBar extends StatelessWidget {
  final Widget child;

  const _AnimatedMultiSelectBar({required this.child});

  @override
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
