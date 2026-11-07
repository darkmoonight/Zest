part of '../categories_action.dart';

mixin _CategoriesActionFormState
    on
        ConsumerState<CategoriesAction>,
        SingleTickerProviderStateMixin<CategoriesAction>,
        ModalSheetAnimationMixin<CategoriesAction>,
        _CategoriesActionFields {
  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeEditMode();
    initModalSheetAnimations();
  }

  /// Initialize controllers.
  void _initializeControllers() {
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _colorNotifier = ValueNotifier(
      widget.edit
          ? Color(widget.category!.colorArgb)
          : AppConstants.defaultCategoryColor,
    );
    final settings = ref.read(settingsProvider);
    _isDefaultNotifier = ValueNotifier(
      widget.edit && isSelectedDefaultCategory(settings, widget.category!),
    );
  }

  /// Initialize edit mode.
  void _initializeEditMode() {
    if (widget.edit) {
      _titleController.text = widget.category!.title;
      _descController.text = widget.category!.description;
      _categoryRecurrence = widget.category!.recurrence;
      _categoryRecurrenceWeekdays = List<int>.from(
        widget.category!.recurrenceWeekdays,
      );
      _categoryRecurrenceMode =
          widget.category!.recurrenceMode == RecurrenceMode.clone
          ? RecurrenceMode.reopen
          : widget.category!.recurrenceMode;
      _categoryRecurrenceMinuteOfDay = widget.category!.recurrenceMinuteOfDay;
    }

    _editingController = _EditingController(
      _titleController.text,
      _descController.text,
      _colorNotifier.value,
      _isDefaultNotifier.value,
      _categoryRecurrence,
      List<int>.from(_categoryRecurrenceWeekdays),
      _categoryRecurrenceMode,
      _categoryRecurrenceMinuteOfDay,
    );
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _colorNotifier.dispose();
    _isDefaultNotifier.dispose();
    _editingController.dispose();
    disposeModalSheetAnimations();
    super.dispose();
  }

  /// Void.
  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) return;

    if (!_editingController.canCompose.value) {
      NavigationHelper.back(context);
      return;
    }

    final shouldPop = await showClearTextConfirmation(
      context: context,
      onConfirm: () {
        _titleController.clear();
        _descController.clear();
        NavigationHelper.back(context, result: true);
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back(context);
    }
  }
}

/// Tracks dirty state for the category create/edit form.
class _EditingController {
  _EditingController(
    this.initialTitle,
    this.initialDescription,
    this.initialColor,
    this.initialIsDefault,
    RecurrenceFrequency initialRecurrence,
    List<int> initialRecurrenceWeekdays,
    RecurrenceMode initialRecurrenceMode,
    int? initialRecurrenceMinuteOfDay,
  ) : recurrence = RecurrenceFormFields(
        frequency: initialRecurrence,
        weekdays: initialRecurrenceWeekdays,
        mode: initialRecurrenceMode,
        minuteOfDay: initialRecurrenceMinuteOfDay,
      ) {
    title.value = initialTitle;
    description.value = initialDescription;
    color.value = initialColor;
    isDefault.value = initialIsDefault;

    _dirtyTracker.watchAll([
      title,
      description,
      color,
      isDefault,
      ...recurrence.listenables,
    ], _hasChanges);
  }

  final String? initialTitle;
  final String? initialDescription;
  final Color? initialColor;
  final bool initialIsDefault;

  final title = ValueNotifier<String?>(null);
  final description = ValueNotifier<String?>(null);
  final color = ValueNotifier<Color?>(null);
  final isDefault = ValueNotifier<bool>(false);

  /// Recurrence dirty fields shared with the category habit picker.
  final RecurrenceFormFields recurrence;

  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  /// Whether the category form has unsaved changes.
  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  bool _hasChanges() =>
      title.value != initialTitle ||
      description.value != initialDescription ||
      color.value != initialColor ||
      isDefault.value != initialIsDefault ||
      recurrence.hasChanges;

  void dispose() {
    _dirtyTracker.dispose();
    title.dispose();
    description.dispose();
    color.dispose();
    isDefault.dispose();
    recurrence.dispose();
  }
}
