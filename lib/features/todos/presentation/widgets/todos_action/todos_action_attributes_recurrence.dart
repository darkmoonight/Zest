part of '../todos_action.dart';

mixin _TodosActionAttributesRecurrence
    on
        ConsumerState<TodosAction>,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave {
  /// Builds the recurrence button widget.
  Widget _buildRecurrenceButton(BuildContext context) {
    final use24h = !DateTimeFormatHelper.is12HourFormat(
      ref.watch(appSettingsProvider.select((s) => s.timeformat)),
    );
    return RecurrenceChipButton(
      frequency: _todoRecurrence,
      minuteOfDay: _todoRecurrenceMinuteOfDay,
      use24h: use24h,
      onPressed: () async {
        final appSettings = ref.read(appSettingsProvider);
        final due = DateTimeFormatHelper.parseDateTime(
          _timeController.text,
          timeformat: appSettings.timeformat,
          languageCode: appSettings.locale.languageCode,
        );
        final selection = await showRecurrencePicker(
          context: context,
          current: _todoRecurrence,
          currentWeekdays: _todoRecurrenceWeekdays,
          currentMode: _todoRecurrenceMode,
          currentMinuteOfDay: _todoRecurrenceMinuteOfDay,
          use24h: use24h,
          anchorWeekday: due?.weekday,
        );
        if (selection == null || !mounted) return;
        setState(() {
          _todoRecurrence = selection.frequency;
          _todoRecurrenceWeekdays = selection.weekdays;
          _todoRecurrenceMode = selection.mode;
          _todoRecurrenceMinuteOfDay = selection.minuteOfDay;
          _editingController.recurrence.apply(selection);
          _syncDueFromReminderTime(
            frequency: selection.frequency,
            weekdays: selection.weekdays,
            minuteOfDay: selection.minuteOfDay,
          );
        });
      },
    );
  }

  /// Writes due field from reminder time so save + notification stay in sync.
  void _syncDueFromReminderTime({
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    required int? minuteOfDay,
  }) {
    final category = _selectedCategory ?? widget.category;
    final now = DateTime.now();
    final due = category != null
        ? RecurrenceService.resolveDueForTodoInCategory(
            now: now,
            category: category,
            todoRecurrence: frequency,
            todoWeekdays: weekdays,
            todoMinuteOfDay: minuteOfDay,
          )
        : RecurrenceService.resolveActiveReminderDue(
            now: now,
            frequency: frequency,
            weekdays: weekdays,
            minuteOfDay: minuteOfDay,
          );
    _setFormDue(due);
  }
}
