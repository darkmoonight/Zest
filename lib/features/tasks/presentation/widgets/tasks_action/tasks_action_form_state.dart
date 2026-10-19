part of '../tasks_action.dart';

mixin _TasksActionFormState
    on
        ConsumerState<TasksAction>,
        SingleTickerProviderStateMixin<TasksAction>,
        ModalSheetAnimationMixin<TasksAction>,
        _TasksActionFields {
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
          ? Color(widget.task!.colorArgb)
          : AppConstants.defaultTaskColor,
    );
    final settings = ref.read(settingsProvider);
    _isDefaultNotifier = ValueNotifier(
      widget.edit && isSelectedDefaultCategory(settings, widget.task!),
    );
  }

  /// Initialize edit mode.
  void _initializeEditMode() {
    if (widget.edit) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _taskRecurrence = widget.task!.recurrence;
      _taskRecurrenceWeekdays = List<int>.from(widget.task!.recurrenceWeekdays);
      _taskRecurrenceMode = widget.task!.recurrenceMode == RecurrenceMode.clone
          ? RecurrenceMode.reopen
          : widget.task!.recurrenceMode;
      _taskRecurrenceMinuteOfDay = widget.task!.recurrenceMinuteOfDay;
    }

    _editingController = _EditingController(
      _titleController.text,
      _descController.text,
      _colorNotifier.value,
      _isDefaultNotifier.value,
      _taskRecurrence,
      List<int>.from(_taskRecurrenceWeekdays),
      _taskRecurrenceMode,
      _taskRecurrenceMinuteOfDay,
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

/// Tracks dirty state for the task create/edit form.
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

  /// Whether the task form has unsaved changes.
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
