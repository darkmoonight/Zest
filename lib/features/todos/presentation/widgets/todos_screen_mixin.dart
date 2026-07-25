import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/widgets/selection_action_bar.dart';
import 'package:zest/features/todos/presentation/widgets/todos_transfer.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/i18n/tr.dart';

/// Shared tab/search state and actions for todo list screens.
mixin TodosScreenMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Tab controller for doing / done / cancelled tabs.
  late final TabController tabController;

  /// Search field controller.
  late final TextEditingController searchController;

  /// Scroll controller for the nested scroll view.
  late final ScrollController scrollController;

  /// Current search query applied to todo lists.
  String searchFilter = '';

  /// Current sort option applied to todo lists.
  SortOption sortOption = SortOption.none;

  /// Notifier for todo list mutations used by this screen.
  TodosNotifier get todosNotifier => ref.read(todosNotifierProvider.notifier);

  /// Initializes tab, search, and scroll controllers.
  void initializeTodosScreen({
    required SortOption initialSortOption,
    required TickerProvider vsync,
  }) {
    searchController = TextEditingController();
    scrollController = ScrollController();
    sortOption = initialSortOption;
    tabController = TabController(length: 3, vsync: vsync);
    tabController.addListener(_onTabChanged);
  }

  /// Registers listeners for multi-selection changes.
  void setupTodosScreenListeners() {
    ref.listenManual(
      todosNotifierProvider.select((s) => s.isMultiSelectionTodo),
      (prev, next) => _handleMultiSelectionChanged(next),
    );
  }

  /// Syncs FAB visibility with multi-select and active tab state.
  void updateFabVisibility() {
    if (!mounted) return;

    if (ref.read(todosNotifierProvider).isMultiSelectionTodo) {
      setFabVisible(false);
    } else {
      setFabVisible(tabController.index == 0);
    }
  }

  /// Clears the search field and filter.
  void clearSearch() {
    searchController.clear();
    applySearchFilter('');
  }

  void _handleMultiSelectionChanged(bool isMultiSelection) {
    if (isMultiSelection) {
      ref.read(fabNotifierProvider.notifier).setVisibility(false);
    } else if (tabController.index == 0) {
      ref.read(fabNotifierProvider.notifier).setVisibility(true);
    }
  }

  void _onTabChanged() {
    if (!mounted) return;

    if (tabController.index == 0) {
      ref.read(fabNotifierProvider.notifier).setVisibility(true);
    } else {
      ref.read(fabNotifierProvider.notifier).setVisibility(false);
    }

    if (ref.read(todosNotifierProvider).isMultiSelectionTodo) {
      todosNotifier.doMultiSelectionTodoClear();
    }
  }

  /// Disposes controllers created by [initializeTodosScreen].
  void disposeTodosScreen() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    searchController.dispose();
    scrollController.dispose();
  }

  /// Updates [searchFilter] from the search field.
  void applySearchFilter(String query) {
    setState(() {
      searchFilter = query;
    });
  }

  /// Updates [sortOption] locally.
  void updateSortOption(SortOption option) {
    setState(() {
      sortOption = option;
    });
  }

  /// Handles back navigation during multi-select mode.
  Future<void> handlePopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;

    if (ref.read(todosNotifierProvider).isMultiSelectionTodo) {
      todosNotifier.doMultiSelectionTodoClear();
      todosNotifier.setIsPop(false);
      return;
    }

    todosNotifier.setIsPop(true);
    if (mounted) {
      NavigationHelper.back(context);
    }
  }

  /// Opens the transfer sheet for the current selection.
  void showTodosTransferSheet(BuildContext context) {
    final selected = ref.read(todosNotifierProvider).selectedTodo;
    NavigationHelper.showModalSheet(
      context: context,
      child: TodosTransfer(text: 'editing'.tr, todos: selected),
      enableDrag: false,
    );
  }

  /// Confirms and deletes the current todo selection.
  Future<void> showDeleteDialog(BuildContext context) async {
    final selected = ref.read(todosNotifierProvider).selectedTodo;
    await showDeleteConfirmation(
      context: context,
      title: 'deletedTodo'.tr,
      message: 'deletedTodoQuery'.tr,
      onConfirm: () {
        todosNotifier.deleteTodo(selected);
        todosNotifier.doMultiSelectionTodoClear();
      },
    );
  }

  /// Shows or hides the screen FAB through [fabNotifierProvider].
  void setFabVisible(bool visible) {
    ref.read(fabNotifierProvider.notifier).setVisibility(visible);
  }

  /// Builds the multi-select action bar when selection mode is active.
  Widget buildSelectionActionBar({
    required bool isMultiSelection,
    required int selectedCount,
    required VoidCallback onTransfer,
    required VoidCallback onDelete,
    required VoidCallback onSelectAll,
    required bool isAllSelected,
  }) {
    if (!isMultiSelection) return const SizedBox.shrink();

    return SelectionActionBar(
      onTransfer: onTransfer,
      onDelete: onDelete,
      onSelectAll: onSelectAll,
      isAllSelected: isAllSelected,
      selectedCount: selectedCount,
    );
  }
}
