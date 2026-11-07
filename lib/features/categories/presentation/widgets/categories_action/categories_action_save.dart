part of '../categories_action.dart';

mixin _CategoriesActionSave
    on
        ConsumerState<CategoriesAction>,
        _CategoriesActionFields,
        _CategoriesActionFormState {
  /// On save pressed.
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    final saved = widget.edit ? await _updateCategory() : await _addCategory();
    if (!saved || !mounted) return;
    NavigationHelper.back(context);
  }

  /// Update category.
  Future<bool> _updateCategory() async {
    await ref
        .read(categoriesNotifierProvider.notifier)
        .updateCategory(
          widget.category!,
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
          recurrence: _categoryRecurrence,
          recurrenceWeekdays: _categoryRecurrenceWeekdays,
          recurrenceMode: _categoryRecurrenceMode,
          recurrenceMinuteOfDay: _categoryRecurrenceMinuteOfDay,
        );
    showSnackBar('editCategory'.tr);
    await _applyDefaultPreference(widget.category!);
    widget.updateCategoryName?.call();
    return true;
  }

  /// Add category.
  Future<bool> _addCategory() async {
    final created = await ref
        .read(categoriesNotifierProvider.notifier)
        .addCategory(
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
          recurrence: _categoryRecurrence,
          recurrenceWeekdays: _categoryRecurrenceWeekdays,
          recurrenceMode: _categoryRecurrenceMode,
          recurrenceMinuteOfDay: _categoryRecurrenceMinuteOfDay,
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

  /// Persists or clears the user default category for [category].
  Future<void> _applyDefaultPreference(Category category) async {
    final wantDefault = _isDefaultNotifier.value;
    final currentId = ref.read(settingsProvider).defaultCategoryId;
    final isCurrentlyDefault = currentId == category.id;

    if (wantDefault && !isCurrentlyDefault) {
      await setDefaultCategory(ref, category: category);
      if (mounted) showSnackBar('defaultCategorySet'.tr);
    } else if (!wantDefault && isCurrentlyDefault) {
      await setDefaultCategory(ref, category: null);
      if (mounted) showSnackBar('defaultCategoryCleared'.tr);
    }
  }
}
