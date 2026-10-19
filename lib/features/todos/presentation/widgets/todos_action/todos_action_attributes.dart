part of '../todos_action.dart';

mixin _TodosActionAttributes
    on
        ConsumerState<TodosAction>,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave {
  Widget _buildAttributesSection(BuildContext context, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'todoAttributes'.tr,
          IconsaxPlusBold.setting_2,
        ),
        SizedBox(height: padding),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppConstants.spacingS,
            children: [
              _buildSubTaskButton(context),
              _buildDateTimeButton(context),
              _buildPriorityButton(context),
              _buildRecurrenceButton(context),
              _buildPinButton(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the section header widget.
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: AppConstants.iconSizeSmall + 2,
          color: colorScheme.primary,
        ),
        SizedBox(width: AppConstants.spacingS),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          ),
        ),
      ],
    );
  }

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
      debugPrint('Create todo before subtasks failed: $e\n$stackTrace');
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
      debugPrint('Navigate to subtasks after create failed: $e\n$stackTrace');
    }
  }

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

  /// Builds the priority button widget.
  Widget _buildPriorityButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Material 3 menu defaults: each MenuItemButton has a 48px min height and
    // the menu adds 8px top + 8px bottom vertical padding (16 total).
    const double priorityMenuItemHeight = 48.0;
    const double priorityMenuVerticalPadding = 16.0;
    const double priorityMenuGap = 8.0;
    final double priorityMenuHeight =
        Priority.values.length * priorityMenuItemHeight +
        priorityMenuVerticalPadding;

    // Always open upward: the attributes row sits near the sheet bottom, so a
    // downward menu clips off-screen even when the keyboard is closed.
    final double maxUpwardOffset =
        -(MediaQuery.of(context).size.height - keyboardHeight);
    final double rawDy = -(priorityMenuHeight + priorityMenuGap);
    final double clampedDy = rawDy.clamp(maxUpwardOffset, 0.0);

    return MenuAnchor(
      alignmentOffset: Offset(0, clampedDy),

      style: MenuStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevation: WidgetStateProperty.all(8),
      ),
      menuChildren: [
        for (final priority in Priority.values)
          MenuItemButton(
            leadingIcon: Icon(
              IconsaxPlusLinear.flag,
              color: priority.color ?? colorScheme.onSurface,
            ),
            child: Text(
              priority.name.tr,
              style: TextStyle(
                fontWeight: _todoPriority == priority
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            onPressed: () {
              setState(() {
                _todoPriority = priority;
                if (widget.edit) {
                  _editingController.priority.value = priority;
                }
              });
            },
          ),
      ],
      builder: (context, menuController, _) => FilledButton.tonal(
        onPressed: () {
          if (menuController.isOpen) {
            menuController.close();
          } else {
            menuController.open();
          }
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
          backgroundColor: _todoPriority != Priority.none
              ? _todoPriority.color?.withValues(alpha: 0.15)
              : colorScheme.secondaryContainer,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusLinear.flag,
              size: 18,
              color: _todoPriority != Priority.none
                  ? _todoPriority.color
                  : colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              _todoPriority.name.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: _todoPriority != Priority.none
                    ? _todoPriority.color
                    : colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  /// Builds the pin button widget.
  Widget _buildPinButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: () {
        setState(() {
          _todoPinned = !_todoPinned;
          if (widget.edit) {
            _editingController.pinned.value = _todoPinned;
          }
        });
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 36),
        backgroundColor: _todoPinned
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _todoPinned
                ? IconsaxPlusBold.attach_square
                : IconsaxPlusLinear.attach_square,
            size: 18,
            color: _todoPinned
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'todoPined'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: _todoPinned
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
