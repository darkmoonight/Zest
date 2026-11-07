part of '../todos_action.dart';

mixin _TodosActionAttributesSubtasks
    on
        ConsumerState<TodosAction>,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave {
  /// Builds the sub task button widget.
  Widget _buildSubTaskButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: () => _handleSubTasksNavigation(context),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        minimumSize: const Size(0, 36),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.task_square,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: AppConstants.spacingS),
          Text(
            'subTask'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Saves the form if dirty, then opens the item detail screen.
  Future<void> _handleSubTasksNavigation(BuildContext context) async {
    if (widget.edit && widget.todo != null) {
      if (_editingController.canCompose.value) {
        final bool shouldSave = await showConfirmationDialog(
          context: context,
          title: 'unsavedChanges'.tr,
          message: 'saveBeforeSubtasks'.tr,
          icon: IconsaxPlusBold.document_filter,
          confirmText: 'save'.tr,
        );

        if (!context.mounted) return;
        if (!shouldSave) return;

        if (!_formKey.currentState!.validate()) return;

        TextUtils.trimController(_titleController);
        TextUtils.trimController(_descController);
        final saved = await _saveTodo();
        if (!saved) return;
      }

      if (!context.mounted) return;
      NavigationHelper.back(context);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TodosTodo(key: ValueKey(widget.todo!.id), todo: widget.todo!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: AppConstants.cardTapAnimation,
        ),
      );
    } else {
      await _createTodoAndNavigateToSubtasks(context);
    }
  }

  /// Creates the item then opens its detail screen.
  Future<void> _createTodoAndNavigateToSubtasks(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    late final Todo newTodo;
    try {
      Category? categoryToUse;

      if (widget.showCategory) {
        categoryToUse = _selectedCategory;
      } else if (widget.todo != null) {
        categoryToUse = _findCategoryById(widget.todo!.categoryId);
      } else if (widget.category != null) {
        categoryToUse = widget.category;
      }

      categoryToUse ??= await _requireCategory(null);
      if (categoryToUse == null) return;

      newTodo = await ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            category: categoryToUse,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
            parent: widget.showCategory ? null : widget.todo,
            recurrence: _todoRecurrence,
            recurrenceWeekdays: _todoRecurrenceWeekdays,
            recurrenceMode: _todoRecurrenceMode,
            recurrenceMinuteOfDay: _todoRecurrenceMinuteOfDay,
          );
      showSnackBar('todoCreate'.tr);
    } catch (e, stackTrace) {
      AppLog.d('Create todo before subtasks failed: $e\n$stackTrace');
      showSnackBar('error'.tr, isError: true);
      return;
    }

    if (!context.mounted) return;
    try {
      NavigationHelper.back(context);

      if (!context.mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TodosTodo(key: ValueKey(newTodo.id), todo: newTodo),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: AppConstants.cardTapAnimation,
        ),
      );
    } catch (e, stackTrace) {
      AppLog.d('Navigate to subtasks after create failed: $e\n$stackTrace');
    }
  }
}
