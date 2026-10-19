part of '../todos_action.dart';

mixin _TodosActionSave
    on ConsumerState<TodosAction>, _TodosActionFields, _TodosActionFormState {
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    final saved = await _saveTodo();
    if (!saved) return;
    showSnackBar(widget.edit ? 'updateTodo'.tr : 'todoCreate'.tr);
    _clearControllers();
    if (!mounted) return;
    NavigationHelper.back(context);
  }

  /// Save item and return whether it succeeded.
  Future<bool> _saveTodo() async {
    if (widget.edit) {
      return _updateTodo();
    }
    return _createTodo();
  }

  /// Resolves [selected] or the fallback category; shows a snackbar when none exist.
  Future<Category?> _requireCategory(Category? selected) async {
    final category =
        selected ??
        await getFallbackCategoryViaRepo(
          ref.read(categoryRepositoryProvider),
          ref.read(settingsProvider),
        );
    if (category == null && mounted) {
      showSnackBar('createCategoryFirstHint'.tr, isError: true);
    }
    return category;
  }

  /// Update item.
  Future<bool> _updateTodo() async {
    final category = await _requireCategory(_selectedCategory);
    if (category == null) return false;
    await ref
        .read(todosNotifierProvider.notifier)
        .updateTodo(
          todo: widget.todo!,
          category: category,
          title: _titleController.text,
          description: _descController.text,
          time: _timeController.text,
          pinned: _todoPinned,
          priority: _todoPriority,
          tags: _todoTags,
          recurrence: _todoRecurrence,
          recurrenceWeekdays: _todoRecurrenceWeekdays,
          recurrenceMode: _todoRecurrenceMode,
          recurrenceMinuteOfDay: _todoRecurrenceMinuteOfDay,
        );
    return true;
  }

  /// Create item.
  Future<bool> _createTodo() async {
    if (widget.showCategory) {
      final category = await _requireCategory(_selectedCategory);
      if (category == null) return false;
      await ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            category: category,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
            recurrence: _todoRecurrence,
            recurrenceWeekdays: _todoRecurrenceWeekdays,
            recurrenceMode: _todoRecurrenceMode,
            recurrenceMinuteOfDay: _todoRecurrenceMinuteOfDay,
          );
      return true;
    } else if (widget.todo != null) {
      final parentCategory = _findCategoryById(widget.todo!.categoryId);
      if (parentCategory == null) return false;

      await ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            category: parentCategory,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
            parent: widget.todo,
            recurrence: _todoRecurrence,
            recurrenceWeekdays: _todoRecurrenceWeekdays,
            recurrenceMode: _todoRecurrenceMode,
            recurrenceMinuteOfDay: _todoRecurrenceMinuteOfDay,
          );
      return true;
    } else if (widget.category != null) {
      await ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            category: widget.category!,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
            recurrence: _todoRecurrence,
            recurrenceWeekdays: _todoRecurrenceWeekdays,
            recurrenceMode: _todoRecurrenceMode,
            recurrenceMinuteOfDay: _todoRecurrenceMinuteOfDay,
          );
      return true;
    }
    return false;
  }
}
