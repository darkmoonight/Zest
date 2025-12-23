import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:zest/app/ui/tasks/widgets/task_list.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/tasks/widgets/statistics.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/app/utils/scroll_fab_handler.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class AllTasks extends StatefulWidget {
  const AllTasks({super.key});

  @override
  State<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  final fabController = Get.find<FabController>();
  late TabController tabController;
  final TextEditingController searchTasks = TextEditingController();
  String filter = '';

  @override
  void initState() {
    super.initState();
    applyFilter('');
    tabController = TabController(vsync: this, length: 2);
    tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    searchTasks.dispose();
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
    return Obx(() {
      final createdTodos = todoController.createdAllTodos();
      final completedTodos = todoController.completedAllTodos();
      final percent = createdTodos > 0
          ? (completedTodos / createdTodos * 100).toStringAsFixed(0)
          : '0';

      return PopScope(
        canPop: todoController.isPop.value,
        onPopInvokedWithResult: _handlePopInvokedWithResult,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context, createdTodos, completedTodos, percent),
        ),
      );
    });
  }

  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) return;
    if (todoController.isMultiSelectionTask.isTrue) {
      todoController.doMultiSelectionTaskClear();
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
    return todoController.isMultiSelectionTask.isTrue
        ? IconButton(
            onPressed: () => todoController.doMultiSelectionTaskClear(),
            icon: const Icon(IconsaxPlusLinear.close_square, size: 22),
            tooltip: 'cancel'.tr,
          )
        : null;
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'categories'.tr,
      key: ValueKey(todoController.isMultiSelectionTask.value),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ColorScheme colorScheme) {
    return [
      _buildDeleteIconButton(context, colorScheme),
      _buildArchiveIconButton(context, colorScheme),
    ];
  }

  Widget _buildDeleteIconButton(BuildContext context, ColorScheme colorScheme) {
    return AnimatedOpacity(
      opacity: todoController.selectedTask.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: todoController.selectedTask.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            IconsaxPlusLinear.trash_square,
            size: 22,
            color: todoController.selectedTask.isNotEmpty
                ? colorScheme.error
                : Colors.transparent,
          ),
          onPressed: todoController.selectedTask.isNotEmpty
              ? () => _showDeleteConfirmationDialog(context)
              : null,
          tooltip: 'delete'.tr,
        ),
      ),
    );
  }

  Widget _buildArchiveIconButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final isArchiveTab = tabController.index == 1;

    return AnimatedOpacity(
      opacity: todoController.selectedTask.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: todoController.selectedTask.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            isArchiveTab
                ? IconsaxPlusLinear.refresh_left_square
                : IconsaxPlusLinear.archive_add,
            size: 22,
            color: todoController.selectedTask.isNotEmpty
                ? colorScheme.primary
                : Colors.transparent,
          ),
          onPressed: todoController.selectedTask.isNotEmpty
              ? () => _showArchiveConfirmationDialog(context)
              : null,
          tooltip: isArchiveTab ? 'restore'.tr : 'archive'.tr,
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
                      'deleteCategory'.tr,
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
                      'deleteCategoryQuery'.tr,
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
                            todoController.deleteTask(
                              todoController.selectedTask,
                            );
                            todoController.doMultiSelectionTaskClear();
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

  Future<void> _showArchiveConfirmationDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final isArchiveTab = tabController.index == 1;

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
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isArchiveTab
                            ? IconsaxPlusBold.refresh_left_square
                            : IconsaxPlusBold.archive_minus,
                        size: 32,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArchiveTab
                          ? 'noArchiveCategory'.tr
                          : 'archiveCategory'.tr,
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
                      isArchiveTab
                          ? 'noArchiveCategoryQuery'.tr
                          : 'archiveCategoryQuery'.tr,
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
                        FilledButton(
                          onPressed: () {
                            if (isArchiveTab) {
                              todoController.noArchiveTask(
                                todoController.selectedTask,
                              );
                            } else {
                              todoController.archiveTask(
                                todoController.selectedTask,
                              );
                            }
                            todoController.doMultiSelectionTaskClear();
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            isArchiveTab ? 'noArchive'.tr : 'archive'.tr,
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

  Widget _buildBody(
    BuildContext context,
    int createdTodos,
    int completedTodos,
    String percent,
  ) {
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
            _buildStatistics(createdTodos, completedTodos, percent),
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
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        controller: searchTasks,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 16,
          vertical: isMobile ? 5 : 8,
        ),
        onChanged: applyFilter,
        iconButton: searchTasks.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchTasks.clear();
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

  Widget _buildStatistics(
    int createdTodos,
    int completedTodos,
    String percent,
  ) {
    return SliverToBoxAdapter(
      child: Statistics(
        createdTodos: createdTodos,
        completedTodos: completedTodos,
        percent: percent,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) => SliverOverlapAbsorber(
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
                    Tab(text: 'active'.tr),
                    Tab(text: 'archived'.tr),
                  ],
                ),
              ),
              if (todoController.isMultiSelectionTask.isTrue)
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
      ),
      floating: true,
      pinned: true,
    ),
  );

  Widget _buildTabBarView() => TabBarView(
    controller: tabController,
    children: [
      TasksList(archived: false, searchTask: filter),
      TasksList(archived: true, searchTask: filter),
    ],
  );

  bool _areAllSelectedInCurrentTab() {
    final isArchived = tabController.index == 1;
    return todoController.areAllTasksSelected(
      archived: isArchived,
      searchQuery: filter,
    );
  }

  void _selectAllInCurrentTab(bool select) {
    final isArchived = tabController.index == 1;
    todoController.selectAllTasks(
      select: select,
      archived: isArchived,
      searchQuery: filter,
    );
  }
}
