part of '../todos_action.dart';

mixin _TodosActionAttributesDateTime
    on
        ConsumerState<TodosAction>,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave {
  /// Builds the date time button widget.
  Widget _buildDateTimeButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTime = _timeController.text.isNotEmpty;

    return FilledButton.tonal(
      onPressed: _showDateTimePicker,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        minimumSize: const Size(0, 36),
        backgroundColor: hasTime
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.calendar,
            size: AppConstants.iconSizeSmall,
            color: hasTime
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: AppConstants.spacingS),
          Text(
            hasTime ? _timeController.text : 'timeComplete'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: hasTime
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          if (hasTime) ...[
            SizedBox(width: AppConstants.spacingS),
            InkWell(
              onTap: () {
                _timeController.clear();
                setState(() {
                  if (widget.edit) {
                    _editingController.time.value = _timeController.text;
                  }
                });
              },
              child: Icon(
                IconsaxPlusLinear.close_circle,
                size: AppConstants.iconSizeSmall - 2,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Opens the classical due date/time picker (Material date + time).
  Future<void> _showDateTimePicker() async {
    final appSettings = ref.read(appSettingsProvider);
    final use24h = !DateTimeFormatHelper.is12HourFormat(appSettings.timeformat);
    final current = DateTimeFormatHelper.parseDateTime(
      _timeController.text,
      timeformat: appSettings.timeformat,
      languageCode: appSettings.locale.languageCode,
    );

    final result = await showDueDateTimePicker(
      context: context,
      current: current,
      use24h: use24h,
    );
    if (result == null || !mounted) return;

    setState(() {
      switch (result) {
        case DueDateTimePicked(:final dateTime):
          _timeController.text = _formatDateTime(dateTime);
        case DueDateTimeCleared():
          _timeController.clear();
      }
      if (widget.edit) {
        _editingController.time.value = _timeController.text;
      }
    });
  }
}
