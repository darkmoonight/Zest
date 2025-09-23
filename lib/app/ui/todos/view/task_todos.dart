import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/tasks/widgets/tasks_action.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_transfer.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodosTask extends StatefulWidget {
  const TodosTask({super.key, required this.task});
  final Tasks task;

  @override
  State<TodosTask> createState() => _TodosTaskState();
}

class _TodosTaskState extends State<TodosTask>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  late TabController tabController;
  final TextEditingController searchTodos = TextEditingController();
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
    return Obx(
      () => PopScope(
        canPop: todoController.isPop.value,
        onPopInvokedWithResult: _handlePopInvokedWithResult,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
          floatingActionButton: _buildFloatingActionButton(context),
        ),
      ),
    );
  }

  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) {
      return;
    }

    if (todoController.isMultiSelectionTodo.isTrue) {
      todoController.doMultiSelectionTodoClear();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: _buildLeadingIconButton(),
      title: _buildTitle(),
      actions: _buildActions(context),
    );
  }

  IconButton? _buildLeadingIconButton() {
    return todoController.isMultiSelectionTodo.isTrue
        ? IconButton(
            onPressed: () => todoController.doMultiSelectionTodoClear(),
            icon: const Icon(IconsaxPlusLinear.close_square, size: 20),
          )
        : IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(IconsaxPlusLinear.arrow_left_3, size: 20),
          );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: context.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.task.description.isNotEmpty)
          Text(
            widget.task.description,
            style: context.theme.textTheme.labelLarge?.copyWith(
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      _buildTransferIconButton(context),
      _buildEditIconButton(context),
      _buildDeleteIconButton(context),
    ];
  }

  Widget _buildTransferIconButton(BuildContext context) {
    return Visibility(
      visible: todoController.selectedTodo.isNotEmpty,
      replacement: const Offstage(),
      child: IconButton(
        icon: const Icon(IconsaxPlusLinear.arrange_square, size: 20),
        onPressed: () {
          _showTodosTransferBottomSheet(context);
        },
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
      builder: (BuildContext context) {
        return TodosTransfer(
          text: 'editing'.tr,
          todos: todoController.selectedTodo,
        );
      },
    );
  }

  Widget _buildEditIconButton(BuildContext context) {
    return Visibility(
      visible: todoController.selectedTodo.isNotEmpty,
      replacement: IconButton(
        onPressed: () {
          _showTasksActionBottomSheet(context, edit: true);
        },
        icon: const Icon(IconsaxPlusLinear.edit, size: 20),
      ),
      child: const Offstage(),
    );
  }

  void _showTasksActionBottomSheet(BuildContext context, {required bool edit}) {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TasksAction(
          text: 'editing'.tr,
          edit: edit,
          task: widget.task,
          updateTaskName: () => setState(() {}),
        );
      },
    );
  }

  Widget _buildDeleteIconButton(BuildContext context) {
    return Visibility(
      visible: todoController.selectedTodo.isNotEmpty,
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
        return AlertDialog.adaptive(
          title: Text(
            'deletedTodo'.tr,
            style: context.theme.textTheme.titleLarge,
          ),
          content: Text(
            'deletedTodoQuery'.tr,
            style: context.theme.textTheme.titleMedium,
          ),
          actions: [_buildCancelButton(context), _buildDeleteButton(context)],
        );
      },
    );
  }

  TextButton _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Get.back(),
      child: Text(
        'cancel'.tr,
        style: context.theme.textTheme.titleMedium?.copyWith(
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  TextButton _buildDeleteButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        todoController.deleteTodo(todoController.selectedTodo);
        todoController.doMultiSelectionTodoClear();
        Get.back();
      },
      child: Text(
        'delete'.tr,
        style: context.theme.textTheme.titleMedium?.copyWith(color: Colors.red),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [_buildSearchTextField(), _buildTabBar(context)];
          },
          body: _buildTabBarView(),
        ),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return SliverToBoxAdapter(
      child: MyTextForm(
        labelText: 'searchTodo'.tr,
        type: TextInputType.text,
        icon: const Icon(IconsaxPlusLinear.search_normal_1, size: 20),
        controller: searchTodos,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        onChanged: applyFilter,
        iconButton: searchTodos.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchTodos.clear();
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
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              return Colors.transparent;
            }),
            tabs: [
              Tab(text: 'doing'.tr),
              Tab(text: 'done'.tr),
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
      controller: tabController,
      children: [
        TodosList(
          allTodos: false,
          calendar: false,
          done: false,
          task: widget.task,
          searchTodo: filter,
        ),
        TodosList(
          allTodos: false,
          calendar: false,
          done: true,
          task: widget.task,
          searchTodo: filter,
        ),
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showTodosActionBottomSheet(context, edit: false);
      },
      child: const Icon(IconsaxPlusLinear.add),
    );
  }

  void _showTodosActionBottomSheet(BuildContext context, {required bool edit}) {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TodosAction(
          text: 'create'.tr,
          edit: edit,
          task: widget.task,
          category: false,
        );
      },
    );
  }
}
