import 'package:flutter/rendering.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_transfer.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/main.dart';

class TodosTodo extends StatefulWidget {
  const TodosTodo({super.key, required this.todo});
  final Todos todo;
  @override
  State<TodosTodo> createState() => _TodosTodoState();
}

class _TodosTodoState extends State<TodosTodo> with TickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  late TabController tabController;
  final TextEditingController searchTodos = TextEditingController();
  String filter = '';

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final ScrollController _scrollController = ScrollController();

  SortOption _sortOption = SortOption.none;

  @override
  void initState() {
    super.initState();
    _sortOption = widget.todo.childrenSortOption;
    applyFilter('');
    tabController = TabController(vsync: this, length: 2);
    _initializeFabController();
  }

  @override
  void dispose() {
    tabController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _initializeFabController() {
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  void applyFilter(String value) =>
      setState(() => filter = value.toLowerCase());

  void _showFab() {
    _fabAnimationController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _hideFab() {
    _fabAnimationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final ScrollDirection direction = notification.direction;
      if (direction == ScrollDirection.reverse) {
        _hideFab();
      } else if (direction == ScrollDirection.forward) {
        _showFab();
      }
    }
    return false;
  }

  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) {
      return;
    }
    if (todoController.isMultiSelectionTodo.isTrue) {
      todoController.doMultiSelectionTodoClear();
    }
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    leading: _buildLeadingIconButton(),
    title: _buildTitle(),
    actions: _buildActions(context),
  );

  IconButton? _buildLeadingIconButton() =>
      todoController.isMultiSelectionTodo.isTrue
      ? IconButton(
          onPressed: () => todoController.doMultiSelectionTodoClear(),
          icon: const Icon(IconsaxPlusLinear.close_square, size: 20),
        )
      : IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconsaxPlusLinear.arrow_left_3, size: 20),
        );

  Widget _buildTitle() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.todo.name,
        style: context.theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      if (widget.todo.description.isNotEmpty)
        Text(
          widget.todo.description,
          style: context.theme.textTheme.labelLarge?.copyWith(
            color: Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
    ],
  );

  List<Widget> _buildActions(BuildContext context) => [
    _buildTransferIconButton(context),
    _buildDeleteIconButton(context),
  ];

  Widget _buildTransferIconButton(BuildContext context) => Visibility(
    visible: todoController.selectedTodo.isNotEmpty,
    replacement: const Offstage(),
    child: IconButton(
      icon: const Icon(IconsaxPlusLinear.arrange_square, size: 20),
      onPressed: () => _showTodosTransferBottomSheet(context),
    ),
  );

  void _showTodosTransferBottomSheet(BuildContext context) =>
      showModalBottomSheet(
        enableDrag: false,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) => TodosTransfer(
          text: 'editing'.tr,
          todos: todoController.selectedTodo,
        ),
      );

  Widget _buildDeleteIconButton(BuildContext context) => Visibility(
    visible: todoController.selectedTodo.isNotEmpty,
    child: IconButton(
      icon: const Icon(IconsaxPlusLinear.trash_square, size: 20),
      onPressed: () async => await _showDeleteConfirmationDialog(context),
    ),
  );

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async =>
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog.adaptive(
          title: Text(
            'deletedTodo'.tr,
            style: context.theme.textTheme.titleLarge,
          ),
          content: Text(
            'deletedTodoQuery'.tr,
            style: context.theme.textTheme.titleMedium,
          ),
          actions: [_buildCancelButton(context), _buildDeleteButton(context)],
        ),
      );

  TextButton _buildCancelButton(BuildContext context) => TextButton(
    onPressed: () => Get.back(),
    child: Text(
      'cancel'.tr,
      style: context.theme.textTheme.titleMedium?.copyWith(
        color: Colors.blueAccent,
      ),
    ),
  );

  TextButton _buildDeleteButton(BuildContext context) => TextButton(
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

  Widget _buildBody(BuildContext context) => SafeArea(
    child: DefaultTabController(
      length: 2,
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSearchTextField(),
          _buildTabBar(context),
        ],
        body: _buildTabBarView(),
      ),
    ),
  );

  Widget _buildSearchTextField() => SliverToBoxAdapter(
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
                    Tab(text: 'doing'.tr),
                    Tab(text: 'done'.tr),
                  ],
                ),
              ),
              PopupMenuButton<SortOption>(
                tooltip: 'sort'.tr,
                icon: const Icon(IconsaxPlusLinear.sort, size: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onSelected: (SortOption option) {
                  setState(() => _sortOption = option);
                  widget.todo.childrenSortOption = option;
                  isar.writeTxnSync(() => isar.todos.putSync(widget.todo));
                },
                itemBuilder: (context) => <PopupMenuEntry<SortOption>>[
                  PopupMenuItem(
                    value: SortOption.none,
                    child: Text('sortByIndex'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.alphaAsc,
                    child: Text('sortByNameAsc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.alphaDesc,
                    child: Text('sortByNameDesc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.dateAsc,
                    child: Text('sortByDateAsc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.dateDesc,
                    child: Text('sortByDateDesc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.dateNotifAsc,
                    child: Text('sortByDateNotifAsc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.dateNotifDesc,
                    child: Text('sortByDateNotifDesc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.priorityAsc,
                    child: Text('sortByPriorityAsc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.priorityDesc,
                    child: Text('sortByPriorityDesc'.tr),
                  ),
                  PopupMenuItem(
                    value: SortOption.random,
                    child: Text('sortByRandom'.tr),
                  ),
                ],
              ),
              if (todoController.isMultiSelectionTodo.isTrue)
                Checkbox(
                  value: _areAllSelectedInCurrentTab(),
                  onChanged: (val) => _selectAllInCurrentTab(val!),
                  shape: const CircleBorder(),
                ),
            ],
          ),
        ),
        height: kTextTabBarHeight,
      ),
      floating: true,
      pinned: true,
    ),
  );

  Widget _buildTabBarView() => TabBarView(
    controller: tabController,
    children: [
      TodosList(
        allTodos: false,
        calendar: false,
        done: false,
        todo: widget.todo,
        searchTodo: filter,
        sortOption: _sortOption,
      ),
      TodosList(
        allTodos: false,
        calendar: false,
        done: true,
        todo: widget.todo,
        searchTodo: filter,
        sortOption: _sortOption,
      ),
    ],
  );

  Widget? _buildFloatingActionButton(BuildContext context) => AnimatedBuilder(
    animation: _fabAnimation,
    builder: (context, child) => Transform.scale(
      scale: _fabAnimation.value,
      child: Opacity(
        opacity: _fabAnimation.value,
        child: FloatingActionButton(
          onPressed: _fabAnimation.value > 0.5
              ? () => _showTodosActionBottomSheet(context, edit: false)
              : null,
          child: const Icon(IconsaxPlusLinear.add),
        ),
      ),
    ),
  );

  void _showTodosActionBottomSheet(
    BuildContext context, {
    required bool edit,
  }) => showModalBottomSheet(
    enableDrag: false,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) => TodosAction(
      text: 'create'.tr,
      edit: edit,
      todo: widget.todo,
      category: false,
    ),
  );

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: todoController.isPop.value,
      onPopInvokedWithResult: _handlePopInvokedWithResult,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: _buildBody(context),
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    ),
  );

  bool _areAllSelectedInCurrentTab() {
    final isDone = tabController.index == 1;
    return todoController.areAllSelected(
      done: isDone,
      searchQuery: filter,
      parent: widget.todo,
    );
  }

  void _selectAllInCurrentTab(bool select) {
    final isDone = tabController.index == 1;
    todoController.selectAll(
      select: select,
      done: isDone,
      searchQuery: filter,
      parent: widget.todo,
    );
  }
}
