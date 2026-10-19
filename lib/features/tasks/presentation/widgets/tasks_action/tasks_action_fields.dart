part of '../tasks_action.dart';

mixin _TasksActionFields on ConsumerState<TasksAction> {
  /// Form key.
  final _formKey = GlobalKey<FormState>();

  /// The color notifier.
  late final ValueNotifier<Color> _colorNotifier;

  /// Whether this category should be the user default.
  late final ValueNotifier<bool> _isDefaultNotifier;

  /// The title controller.
  late final TextEditingController _titleController;

  /// The desc controller.
  late final TextEditingController _descController;

  /// The editing controller.
  late final _EditingController _editingController;

  /// Habit recurrence for this category.
  RecurrenceFrequency _taskRecurrence = RecurrenceFrequency.none;

  /// Weekdays for weekly habit recurrence.
  List<int> _taskRecurrenceWeekdays = [];

  /// Clone vs reopen default for this category.
  RecurrenceMode _taskRecurrenceMode = RecurrenceMode.reopen;

  /// Fixed reminder minutes from midnight for category recurrence.
  int? _taskRecurrenceMinuteOfDay;

  /// Builds the title input widget.
  Widget _buildTitleInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: _titleController,
      labelText: 'enterCategoryName'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.edit, color: colorScheme.primary),
      onChanged: (value) => _editingController.title.value = value,
      autofocus: !widget.edit,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'validateName'.tr;
        }
        return null;
      },
    );
  }

  /// Builds the description input widget.
  Widget _buildDescriptionInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: _descController,
      labelText: 'enterDescription'.tr,
      type: TextInputType.multiline,
      icon: Icon(IconsaxPlusLinear.note_text, color: colorScheme.primary),
      maxLine: null,
      onChanged: (value) => _editingController.description.value = value,
    );
  }

  /// Habit-reset control styled like the default-category / color cards.
  Widget _buildRecurrenceRow(BuildContext context) {
    final active = RecurrenceService.isRecurring(_taskRecurrence);
    final use24h = !DateTimeFormatHelper.is12HourFormat(
      ref.watch(appSettingsProvider.select((s) => s.timeformat)),
    );

    return TaskSheetOptionCard(
      leading: TaskSheetOptionIconPreview(
        active: active,
        icon: IconsaxPlusLinear.repeat,
        activeIcon: IconsaxPlusBold.repeat,
      ),
      titleKey: 'categoryRecurrence',
      subtitle: [
        recurrenceSummaryLabel(
          frequency: _taskRecurrence,
          mode: _taskRecurrenceMode,
          minuteOfDay: _taskRecurrenceMinuteOfDay,
          use24h: use24h,
        ),
        if (active) 'categoryRecurrenceHint'.tr,
      ].join('\n'),
      action: TaskSheetOptionChangeButton(
        active: active,
        icon: IconsaxPlusLinear.repeat,
        onPressed: () async {
          final selection = await showRecurrencePicker(
            context: context,
            current: _taskRecurrence,
            currentWeekdays: _taskRecurrenceWeekdays,
            currentMode: _taskRecurrenceMode == RecurrenceMode.clone
                ? RecurrenceMode.reopen
                : _taskRecurrenceMode,
            currentMinuteOfDay: _taskRecurrenceMinuteOfDay,
            use24h: use24h,
            allowCloneMode: false,
          );
          if (selection == null || !mounted) return;
          setState(() {
            _taskRecurrence = selection.frequency;
            _taskRecurrenceWeekdays = selection.weekdays;
            _taskRecurrenceMode = selection.mode;
            _taskRecurrenceMinuteOfDay = selection.minuteOfDay;
            _editingController.recurrence.apply(selection);
          });
        },
      ),
    );
  }

  /// Toggle to mark this category as the user default for new items.
  Widget _buildDefaultToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDefaultNotifier,
      builder: (context, isDefault, _) {
        return TaskSheetOptionCard(
          leading: TaskSheetOptionIconPreview(
            active: isDefault,
            icon: IconsaxPlusLinear.star,
            activeIcon: IconsaxPlusBold.star,
          ),
          titleKey: 'setDefaultCategory',
          subtitle: isDefault
              ? 'defaultCategoryStatusOn'.tr
              : 'defaultCategoryStatusOff'.tr,
          action: TaskSheetOptionChangeButton(
            active: isDefault,
            icon: isDefault ? IconsaxPlusBold.star : IconsaxPlusLinear.star,
            onPressed: () {
              final next = !isDefault;
              _isDefaultNotifier.value = next;
              _editingController.isDefault.value = next;
            },
          ),
        );
      },
    );
  }

  /// Builds the color picker widget.
  Widget _buildColorPicker() {
    return ValueListenableBuilder<Color>(
      valueListenable: _colorNotifier,
      builder: (context, color, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return TaskSheetOptionCard(
          leading: _buildColorPreview(color, colorScheme),
          titleKey: 'selectedColor',
          subtitle: color.toHexString(),
          action: TaskSheetOptionChangeButton(
            icon: IconsaxPlusLinear.colorfilter,
            onPressed: _showColorPickerDialog,
          ),
        );
      },
    );
  }

  /// Builds the color preview swatch.
  Widget _buildColorPreview(Color color, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: AppConstants.iconBoxSize,
      height: AppConstants.iconBoxSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCompact),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }

  /// Void.
  Future<void> _showColorPickerDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    final Color? newColor = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: _colorNotifier.value,
        colorScheme: colorScheme,
        isMobile: isMobile,
      ),
    );

    if (newColor != null) {
      _colorNotifier.value = newColor;
      if (widget.edit) {
        _editingController.color.value = newColor;
      }
    }
  }
}
