import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/tasks/widgets/task_list.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/tasks/widgets/statistics.dart';
import 'package:zest/app/ui/widgets/text_form.dart';

class AllTasks extends StatefulWidget {
  const AllTasks({super.key});

  @override
  State<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  late TabController tabController;
  final TextEditingController searchTasks = TextEditingController();
  String filter = '';

  @override
  void initState() {
    super.initState();
    applyFilter('');
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void applyFilter(String value) {
    setState(() {
      filter = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final createdTodos = todoController.createdAllTodos();
      final completedTodos = todoController.completedAllTodos();
      final percent = (completedTodos / createdTodos * 100).toStringAsFixed(0);

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
    if (didPop) {
      return;
    }

    if (todoController.isMultiSelectionTask.isTrue) {
      todoController.doMultiSelectionTaskClear();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: _buildLeadingIconButton(),
      title: _buildTitle(),
      actions: _buildActions(context),
    );
  }

  IconButton? _buildLeadingIconButton() {
    return todoController.isMultiSelectionTask.isTrue
        ? IconButton(
          onPressed: () => todoController.doMultiSelectionTaskClear(),
          icon: const Icon(IconsaxPlusLinear.close_square, size: 20),
        )
        : null;
  }

  Widget _buildTitle() {
    return Text(
      'categories'.tr,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [_buildDeleteIconButton(context), _buildArchiveIconButton(context)];
  }

  Widget _buildDeleteIconButton(BuildContext context) {
    return Visibility(
      visible: todoController.selectedTask.isNotEmpty,
      child: IconButton(
        icon: const Icon(IconsaxPlusLinear.trash_square, size: 20),
        onPressed: () async {
          await _showDeleteConfirmationDialog(context);
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('deleteCategory'.tr, style: context.textTheme.titleLarge),
          content: Text(
            'deleteCategoryQuery'.tr,
            style: context.textTheme.titleMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'cancel'.tr,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.blueAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                todoController.deleteTask(todoController.selectedTask);
                todoController.doMultiSelectionTaskClear();
                Get.back();
              },
              child: Text(
                'delete'.tr,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArchiveIconButton(BuildContext context) {
    return Visibility(
      visible: todoController.selectedTask.isNotEmpty,
      child: IconButton(
        icon: Icon(
          tabController.index == 0
              ? IconsaxPlusLinear.archive_1
              : IconsaxPlusLinear.refresh_left_square,
          size: 20,
        ),
        onPressed: () async {
          await _showArchiveConfirmationDialog(context);
        },
      ),
    );
  }

  Future<void> _showArchiveConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tabController.index == 0
                ? 'archiveCategory'.tr
                : 'noArchiveCategory'.tr,
            style: context.textTheme.titleLarge,
          ),
          content: Text(
            tabController.index == 0
                ? 'archiveCategoryQuery'.tr
                : 'noArchiveCategoryQuery'.tr,
            style: context.textTheme.titleMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'cancel'.tr,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.blueAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (tabController.index == 0) {
                  todoController.archiveTask(todoController.selectedTask);
                } else {
                  todoController.noArchiveTask(todoController.selectedTask);
                }
                todoController.doMultiSelectionTaskClear();
                Get.back();
              },
              child: Text(
                tabController.index == 0 ? 'archive'.tr : 'noArchive'.tr,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
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
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        controller: ScrollController(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSearchTextField(),
            _buildStatistics(createdTodos, completedTodos, percent),
            _buildTabBar(context),
          ];
        },
        body: _buildTabBarView(),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return SliverToBoxAdapter(
      child: MyTextForm(
        labelText: 'searchCategory'.tr,
        type: TextInputType.text,
        icon: const Icon(IconsaxPlusLinear.search_normal_1, size: 20),
        controller: searchTasks,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        onChanged: applyFilter,
        iconButton:
            searchTasks.text.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    searchTasks.clear();
                    applyFilter('');
                  },
                  icon: const Icon(
                    IconsaxPlusLinear.close_square,
                    color: Colors.grey,
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

  Widget _buildTabBar(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverPersistentHeader(
        delegate: MyDelegate(
          TabBar(
            tabAlignment: TabAlignment.start,
            controller: tabController,
            isScrollable: true,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return Colors.transparent;
            }),
            tabs: [Tab(text: 'active'.tr), Tab(text: 'archived'.tr)],
          ),
        ),
        floating: true,
        pinned: true,
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        TasksList(archived: false, searchTask: filter),
        TasksList(archived: true, searchTask: filter),
      ],
    );
  }
}
