part of '../todos_transfer.dart';

mixin _TodosTransferSubmit
    on
        ConsumerState<TodosTransfer>,
        _TodosTransferFields,
        _TodosTransferFormState {
  /// On save pressed.
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mode == TransferMode.category) {
      final task = _selectedTask;
      if (task == null) return;
      await ref
          .read(todosNotifierProvider.notifier)
          .moveTodos(widget.todos, task);
      ref.read(todosNotifierProvider.notifier).doMultiSelectionTodoClear();
      showSnackBar('updateTodo'.tr);
      if (mounted) NavigationHelper.back(context);
      return;
    }

    final parent = _selectedTodo;
    if (parent == null) return;
    await ref
        .read(todosNotifierProvider.notifier)
        .moveTodosToParent(widget.todos, parent);
    ref.read(todosNotifierProvider.notifier).doMultiSelectionTodoClear();
    showSnackBar('updateTodo'.tr);
    if (mounted) NavigationHelper.back(context);
  }
}
