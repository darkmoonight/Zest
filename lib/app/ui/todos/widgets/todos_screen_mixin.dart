import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/todos/widgets/todos_transfer.dart';
import 'package:zest/app/ui/widgets/confirmation_dialog.dart';
import 'package:zest/app/utils/navigation_helper.dart';

mixin TodosScreenMixin<T extends StatefulWidget> on State<T> {
  late final TodoController todoController;
  late final FabController fabController;
  late final TabController tabController;
  late final TextEditingController searchController;

  String searchFilter = '';
  SortOption sortOption = SortOption.none;

  void initializeTodosScreen({
    required SortOption initialSortOption,
    required TickerProvider vsync,
  }) {
    todoController = Get.find<TodoController>();
    fabController = Get.find<FabController>();
    searchController = TextEditingController();
    sortOption = initialSortOption;
    tabController = TabController(length: 2, vsync: vsync);
    tabController.addListener(_onTabChanged);
    _setupListeners();
  }

  void _setupListeners() {
    tabController.addListener(_onTabChanged);
    ever(todoController.isMultiSelectionTodo, _handleMultiSelectionChanged);
  }

  void _handleMultiSelectionChanged(bool isMultiSelection) {
    if (isMultiSelection) {
      fabController.hide();
    } else {
      if (tabController.index == 0) {
        fabController.show();
      }
    }
  }

  void _onTabChanged() {
    if (!mounted) return;

    if (tabController.index == 0) {
      fabController.show();
    } else {
      fabController.hide();
    }

    if (todoController.isMultiSelectionTodo.value) {
      todoController.doMultiSelectionTodoClear();
    }
  }

  void disposeTodosScreen() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    searchController.dispose();
  }

  void applySearchFilter(String query) {
    setState(() {
      searchFilter = query;
    });
  }

  void updateSortOption(SortOption option) {
    setState(() {
      sortOption = option;
    });
  }

  Future<void> handlePopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;

    if (todoController.isMultiSelectionTodo.value) {
      todoController.doMultiSelectionTodoClear();
      todoController.isPop.value = false;
      return;
    }

    todoController.isPop.value = true;
    if (mounted) {
      NavigationHelper.back();
    }
  }

  void showTodosTransferSheet(BuildContext context) {
    NavigationHelper.showModalSheet(
      context: context,
      child: TodosTransfer(
        text: 'editing'.tr,
        todos: todoController.selectedTodo,
      ),
      enableDrag: false,
    );
  }

  Future<void> showDeleteDialog(BuildContext context) async {
    await showDeleteConfirmation(
      context: context,
      title: 'deletedTodo'.tr,
      message: 'deletedTodoQuery'.tr,
      onConfirm: () {
        todoController.deleteTodo(todoController.selectedTodo);
        todoController.doMultiSelectionTodoClear();
      },
    );
  }
}
