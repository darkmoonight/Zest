import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_transfer.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllTodos extends StatefulWidget {
  const AllTodos({super.key});

  @override
  State<AllTodos> createState() => _AllTodosState();
}

class _AllTodosState extends State<AllTodos>
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
      centerTitle: true,
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
        : null;
  }

  Text _buildTitle() {
    return Text(
      'allTodos'.tr,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [_buildTransferIconButton(context), _buildDeleteIconButton(context)];
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
    await showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text('deletedTodo'.tr, style: context.textTheme.titleLarge),
          content: Text(
            'deletedTodoQuery'.tr,
            style: context.textTheme.titleMedium,
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
        style: context.textTheme.titleMedium?.copyWith(
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
        style: context.textTheme.titleMedium?.copyWith(color: Colors.red),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        controller: ScrollController(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSearchTextField(), _buildTabBar(context)];
        },
        body: _buildTabBarView(),
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
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
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
          calendare: false,
          allTodos: true,
          done: false,
          searchTodo: filter,
        ),
        TodosList(
          calendare: false,
          allTodos: true,
          done: true,
          searchTodo: filter,
        ),
      ],
    );
  }
}
