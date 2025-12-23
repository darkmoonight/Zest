import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_transfer.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/scroll_fab_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/main.dart';

class AllTodos extends StatefulWidget {
  const AllTodos({super.key});

  @override
  State<AllTodos> createState() => _AllTodosState();
}

class _AllTodosState extends State<AllTodos>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  final fabController = Get.find<FabController>();
  late TabController tabController;
  final TextEditingController searchTodos = TextEditingController();
  String filter = '';
  SortOption _sortOption = SortOption.none;

  @override
  void initState() {
    super.initState();
    _sortOption = settings.sortOption;
    applyFilter('');
    tabController = TabController(vsync: this, length: 2);
    tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    searchTodos.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (tabController.index == 1) {
      fabController.hide();
    } else {
      fabController.show();
    }
  }

  void applyFilter(String value) => setState(() => filter = value);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: todoController.isPop.value,
        onPopInvokedWithResult: _handlePopInvokedWithResult,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        ),
      ),
    );
  }

  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) return;
    if (todoController.isMultiSelectionTodo.isTrue) {
      todoController.doMultiSelectionTodoClear();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      centerTitle: true,
      leading: _buildLeadingIconButton(),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildTitle(context),
      ),
      actions: _buildActions(context, colorScheme),
    );
  }

  IconButton? _buildLeadingIconButton() {
    return todoController.isMultiSelectionTodo.isTrue
        ? IconButton(
            onPressed: () => todoController.doMultiSelectionTodoClear(),
            icon: const Icon(IconsaxPlusLinear.close_square, size: 22),
            tooltip: 'cancel'.tr,
          )
        : null;
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'allTodos'.tr,
      key: ValueKey(todoController.isMultiSelectionTodo.value),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ColorScheme colorScheme) {
    return [
      _buildTransferIconButton(context, colorScheme),
      _buildDeleteIconButton(context, colorScheme),
    ];
  }

  Widget _buildTransferIconButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return AnimatedOpacity(
      opacity: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            IconsaxPlusLinear.arrange_square_2,
            size: 22,
            color: todoController.selectedTodo.isNotEmpty
                ? colorScheme.primary
                : Colors.transparent,
          ),
          onPressed: todoController.selectedTodo.isNotEmpty
              ? () => _showTodosTransferBottomSheet(context)
              : null,
          tooltip: 'transfer'.tr,
        ),
      ),
    );
  }

  void _showTodosTransferBottomSheet(BuildContext context) {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) =>
          TodosTransfer(text: 'editing'.tr, todos: todoController.selectedTodo),
    );
  }

  Widget _buildDeleteIconButton(BuildContext context, ColorScheme colorScheme) {
    return AnimatedOpacity(
      opacity: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            IconsaxPlusLinear.trash_square,
            size: 22,
            color: todoController.selectedTodo.isNotEmpty
                ? colorScheme.error
                : Colors.transparent,
          ),
          onPressed: todoController.selectedTodo.isNotEmpty
              ? () => _showDeleteConfirmationDialog(context)
              : null,
          tooltip: 'delete'.tr,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconsaxPlusBold.trash,
                        size: 32,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'deletedTodo'.tr,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              20,
                            ),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'deletedTodoQuery'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          14,
                        ),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () {
                            todoController.deleteTodo(
                              todoController.selectedTodo,
                            );
                            todoController.doMultiSelectionTodoClear();
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            backgroundColor: colorScheme.errorContainer,
                            foregroundColor: colorScheme.onErrorContainer,
                          ),
                          child: Text(
                            'delete'.tr,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => handleScrollFabVisibility(
        notification: notification,
        tabController: tabController,
        fabController: fabController,
        context: context,
      ),
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
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        controller: searchTodos,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 16,
          vertical: isMobile ? 5 : 8,
        ),
        onChanged: applyFilter,
        iconButton: searchTodos.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchTodos.clear();
                  applyFilter('');
                },
                icon: Icon(
                  IconsaxPlusLinear.close_circle,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverPersistentHeader(
        delegate: MyDelegate(
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    controller: tabController,
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) => Colors.transparent,
                    ),
                    tabs: [
                      Tab(text: 'doing'.tr),
                      Tab(text: 'done'.tr),
                    ],
                  ),
                ),
                _buildSortButton(context, colorScheme),
                if (todoController.isMultiSelectionTodo.isTrue)
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Checkbox(
                      value: _areAllSelectedInCurrentTab(),
                      onChanged: (val) => _selectAllInCurrentTab(val ?? false),
                      shape: const CircleBorder(),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          height: kTextTabBarHeight,
        ),
        floating: true,
        pinned: true,
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, ColorScheme colorScheme) {
    return PopupMenuButton<SortOption>(
      tooltip: 'sort'.tr,
      icon: Icon(
        IconsaxPlusLinear.sort,
        size: 22,
        color: colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (SortOption option) {
        setState(() => _sortOption = option);
        settings.sortOption = option;
        isar.writeTxnSync(() => isar.settings.putSync(settings));
      },
      itemBuilder: (context) => <PopupMenuEntry<SortOption>>[
        _buildSortMenuItem(
          SortOption.none,
          'sortByIndex'.tr,
          IconsaxPlusLinear.menu,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.alphaAsc,
          'sortByNameAsc'.tr,
          IconsaxPlusLinear.text,
        ),
        _buildSortMenuItem(
          SortOption.alphaDesc,
          'sortByNameDesc'.tr,
          IconsaxPlusLinear.text,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.dateAsc,
          'sortByDateAsc'.tr,
          IconsaxPlusLinear.calendar_1,
        ),
        _buildSortMenuItem(
          SortOption.dateDesc,
          'sortByDateDesc'.tr,
          IconsaxPlusLinear.calendar_1,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.dateNotifAsc,
          'sortByDateNotifAsc'.tr,
          IconsaxPlusLinear.notification,
        ),
        _buildSortMenuItem(
          SortOption.dateNotifDesc,
          'sortByDateNotifDesc'.tr,
          IconsaxPlusLinear.notification,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.priorityAsc,
          'sortByPriorityAsc'.tr,
          IconsaxPlusLinear.flag,
        ),
        _buildSortMenuItem(
          SortOption.priorityDesc,
          'sortByPriorityDesc'.tr,
          IconsaxPlusLinear.flag,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.random,
          'sortByRandom'.tr,
          IconsaxPlusLinear.shuffle,
        ),
      ],
    );
  }

  PopupMenuItem<SortOption> _buildSortMenuItem(
    SortOption value,
    String text,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: _sortOption == value
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Flexible(
            // ← ДОБАВЛЕНО
            child: Text(
              text,
              style: TextStyle(
                fontWeight: _sortOption == value
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: _sortOption == value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis, // ← ДОБАВЛЕНО
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        TodosList(
          calendar: false,
          allTodos: true,
          done: false,
          searchTodo: filter,
          sortOption: _sortOption,
        ),
        TodosList(
          calendar: false,
          allTodos: true,
          done: true,
          searchTodo: filter,
          sortOption: _sortOption,
        ),
      ],
    );
  }

  bool _areAllSelectedInCurrentTab() {
    final isDone = tabController.index == 1;
    return todoController.areAllSelected(done: isDone, searchQuery: filter);
  }

  void _selectAllInCurrentTab(bool select) {
    final isDone = tabController.index == 1;
    todoController.selectAll(select: select, done: isDone, searchQuery: filter);
  }
}
