import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/tasks/widgets/tasks_action.dart';
import 'package:zest/app/ui/todos/widgets/selection_action_bar.dart';
import 'package:zest/app/ui/todos/widgets/sort_menu.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_screen_mixin.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/scroll_fab_handler.dart';
import 'package:zest/main.dart';

class TaskTodos extends StatefulWidget {
  const TaskTodos({super.key, required this.task});

  final Tasks task;

  @override
  State<TaskTodos> createState() => _TaskTodosState();
}

class _TaskTodosState extends State<TaskTodos>
    with SingleTickerProviderStateMixin, TodosScreenMixin {
  @override
  void initState() {
    super.initState();
    initializeTodosScreen(
      initialSortOption: widget.task.sortOption,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateFabVisibility();
      }
    });
  }

  void _updateFabVisibility() {
    if (!mounted) return;

    if (todoController.isMultiSelectionTodo.value) {
      fabController.setVisibility(false);
    } else if (tabController.index == 0) {
      fabController.setVisibility(true);
    } else {
      fabController.setVisibility(false);
    }
  }

  @override
  void dispose() {
    disposeTodosScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: todoController.isPop.value,
        onPopInvokedWithResult: handlePopInvoked,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(child: _buildBody(context)),
          floatingActionButton: _buildFloatingActionButton(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        icon: Icon(
          IconsaxPlusLinear.arrow_left_1,
          color: colorScheme.onSurface,
        ),
        onPressed: () => NavigationHelper.back(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.task.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.task.description.isNotEmpty)
            Text(
              widget.task.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        if (todoController.selectedTodo.isEmpty)
          IconButton(
            onPressed: () => _showTasksActionBottomSheet(context, edit: true),
            icon: Icon(
              IconsaxPlusLinear.edit,
              size: 22,
              color: colorScheme.primary,
            ),
            tooltip: 'edit'.tr,
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        _buildScrollableContent(context),
        _buildSelectionActionBar(context),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (todoController.isMultiSelectionTodo.value) {
          return true;
        }

        return ScrollFabHandler.handleScrollFabVisibility(
          notification: notification,
          tabController: tabController,
          fabController: fabController,
        );
      },
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSearchTextField(context),
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
        labelText: 'searchTodo'.tr,
        variant: TextFieldVariant.card,
        type: TextInputType.text,
        icon: Icon(
          IconsaxPlusLinear.search_normal_1,
          size: AppConstants.iconSizeMedium,
          color: colorScheme.onSurfaceVariant,
        ),
        controller: searchController,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile
              ? AppConstants.spacingS + 2
              : AppConstants.spacingL,
          vertical: isMobile
              ? AppConstants.spacingXS + 1
              : AppConstants.spacingS,
        ),
        onChanged: applySearchFilter,
        iconButton: searchController.text.isNotEmpty
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
    searchController.clear();
    applySearchFilter('');
  }

  Widget _buildTabBar(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverPersistentHeader(
        delegate: MyDelegate(
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  tabAlignment: TabAlignment.start,
                  controller: tabController,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: [
                    Tab(text: 'doing'.tr),
                    Tab(text: 'done'.tr),
                  ],
                ),
              ),
              SortMenu(
                currentSortOption: sortOption,
                onSortChanged: _handleSortChanged,
              ),
              SizedBox(width: AppConstants.spacingS),
            ],
          ),
        ),
        floating: true,
        pinned: true,
      ),
    );
  }

  Future<void> _handleSortChanged(SortOption option) async {
    updateSortOption(option);
    widget.task.sortOption = option;
    await isar.writeTxn(() => isar.tasks.put(widget.task));
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        TodosList(
          calendar: false,
          allTodos: false,
          done: false,
          task: widget.task,
          searchTodo: searchFilter,
          sortOption: sortOption,
        ),
        TodosList(
          calendar: false,
          allTodos: false,
          done: true,
          task: widget.task,
          searchTodo: searchFilter,
          sortOption: sortOption,
        ),
      ],
    );
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    return Obx(() {
      if (!todoController.isMultiSelectionTodo.isTrue) {
        return const SizedBox.shrink();
      }

      final selectedCount = todoController.selectedTodo.length;

      return SelectionActionBar(
        onTransfer: () => showTodosTransferSheet(context),
        onDelete: () => showDeleteDialog(context),
        onSelectAll: _toggleSelectAll,
        isAllSelected: _areAllSelectedInCurrentTab(),
        selectedCount: selectedCount,
      );
    });
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (!fabController.isVisible.value) return null;

    return FloatingActionButton(
      onPressed: () => _showTodosActionBottomSheet(context, edit: false),
      child: const Icon(IconsaxPlusLinear.add),
    );
  }

  void _showTasksActionBottomSheet(BuildContext context, {required bool edit}) {
    NavigationHelper.showModalSheet(
      context: context,
      enableDrag: false,
      child: TasksAction(
        text: 'editing'.tr,
        edit: edit,
        task: widget.task,
        updateTaskName: () => setState(() {}),
      ),
    );
  }

  void _showTodosActionBottomSheet(BuildContext context, {required bool edit}) {
    NavigationHelper.showModalSheet(
      context: context,
      enableDrag: false,
      child: TodosAction(
        text: 'create'.tr,
        edit: edit,
        task: widget.task,
        category: false,
      ),
    );
  }

  bool _areAllSelectedInCurrentTab() {
    final isDone = tabController.index == 1;
    return todoController.areAllSelected(
      done: isDone,
      searchQuery: searchFilter,
      task: widget.task,
    );
  }

  void _toggleSelectAll() {
    final allSelected = _areAllSelectedInCurrentTab();
    final isDone = tabController.index == 1;

    todoController.selectAll(
      select: !allSelected,
      done: isDone,
      searchQuery: searchFilter,
      task: widget.task,
    );
  }
}
