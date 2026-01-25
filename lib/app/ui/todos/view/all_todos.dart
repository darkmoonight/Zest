import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/todos/widgets/selection_action_bar.dart';
import 'package:zest/app/ui/todos/widgets/sort_menu.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_screen_mixin.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/scroll_fab_handler.dart';
import 'package:zest/main.dart';

class AllTodos extends StatefulWidget {
  const AllTodos({super.key});

  @override
  State<AllTodos> createState() => _AllTodosState();
}

class _AllTodosState extends State<AllTodos>
    with SingleTickerProviderStateMixin, TodosScreenMixin {
  @override
  void initState() {
    super.initState();
    initializeTodosScreen(
      initialSortOption: settings.allTodosSortOption,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFabVisibility();
  }

  void _updateFabVisibility() {
    if (!mounted) return;

    if (todoController.isMultiSelectionTodo.value) {
      fabController.hide();
    } else if (tabController.index == 0) {
      fabController.show();
    } else {
      fabController.hide();
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
        child: Scaffold(body: SafeArea(child: _buildBody(context))),
      ),
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

  void _handleSortChanged(SortOption option) {
    updateSortOption(option);
    settings.allTodosSortOption = option;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        TodosList(
          calendar: false,
          allTodos: true,
          done: false,
          searchTodo: searchFilter,
          sortOption: sortOption,
        ),
        TodosList(
          calendar: false,
          allTodos: true,
          done: true,
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

      return SelectionActionBar(
        onTransfer: () => showTodosTransferSheet(context),
        onDelete: () => showDeleteDialog(context),
        onSelectAll: _toggleSelectAll,
        isAllSelected: _areAllSelectedInCurrentTab(),
      );
    });
  }

  bool _areAllSelectedInCurrentTab() {
    final isDone = tabController.index == 1;
    return todoController.areAllSelected(
      done: isDone,
      searchQuery: searchFilter,
    );
  }

  void _toggleSelectAll() {
    final allSelected = _areAllSelectedInCurrentTab();
    final isDone = tabController.index == 1;

    todoController.selectAll(
      select: !allSelected,
      done: isDone,
      searchQuery: searchFilter,
    );
  }
}
