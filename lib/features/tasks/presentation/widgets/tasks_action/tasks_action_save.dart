part of '../tasks_action.dart';

mixin _TasksActionSave
    on ConsumerState<TasksAction>, _TasksActionFields, _TasksActionFormState {
  /// On save pressed.
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    final saved = widget.edit ? await _updateTask() : await _addTask();
    if (!saved || !mounted) return;
    NavigationHelper.back(context);
  }

  /// Update task.
  Future<bool> _updateTask() async {
    await ref
        .read(tasksNotifierProvider.notifier)
        .updateTask(
          widget.task!,
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
          recurrence: _taskRecurrence,
          recurrenceWeekdays: _taskRecurrenceWeekdays,
          recurrenceMode: _taskRecurrenceMode,
          recurrenceMinuteOfDay: _taskRecurrenceMinuteOfDay,
        );
    showSnackBar('editCategory'.tr);
    await _applyDefaultPreference(widget.task!);
    widget.updateTaskName?.call();
    return true;
  }

  /// Add task.
  Future<bool> _addTask() async {
    final created = await ref
        .read(tasksNotifierProvider.notifier)
        .addTask(
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
          recurrence: _taskRecurrence,
          recurrenceWeekdays: _taskRecurrenceWeekdays,
          recurrenceMode: _taskRecurrenceMode,
          recurrenceMinuteOfDay: _taskRecurrenceMinuteOfDay,
        );
    if (created == null) {
      showSnackBar('duplicateCategory'.tr, isError: true);
      return false;
    }
    showSnackBar('createCategory'.tr);
    await _applyDefaultPreference(created);
    _titleController.clear();
    _descController.clear();
    return true;
  }

  /// Persists or clears the user default category for [task].
  Future<void> _applyDefaultPreference(Category task) async {
    final wantDefault = _isDefaultNotifier.value;
    final currentId = ref.read(settingsProvider).defaultCategoryId;
    final isCurrentlyDefault = currentId == task.id;

    if (wantDefault && !isCurrentlyDefault) {
      await setDefaultCategory(ref, category: task);
      if (mounted) showSnackBar('defaultCategorySet'.tr);
    } else if (!wantDefault && isCurrentlyDefault) {
      await setDefaultCategory(ref, category: null);
      if (mounted) showSnackBar('defaultCategoryCleared'.tr);
    }
  }
}
