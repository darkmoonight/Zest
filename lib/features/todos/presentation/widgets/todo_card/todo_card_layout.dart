part of '../todo_card.dart';

mixin _TodoCardLayout
    on ConsumerState<TodoCard>, _TodoCardStatus, _TodoCardMeta {
  Widget _buildCardContent(
    BuildContext context,
    ColorScheme colorScheme,
    bool isMobile,
    bool isSelected,
  ) {
    final layout = TodoCardLayoutConfig.decode(
      ref.watch(settingsProvider.select((s) => s.todoCardLayout)),
    );

    return SelectableCardShell(
      isSelected: isSelected,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 2 : AppConstants.spacingXS + 2,
          isMobile ? AppConstants.spacingS + 2 : AppConstants.spacingM,
          isMobile ? AppConstants.spacingS + 2 : AppConstants.spacingM + 2,
          isMobile ? AppConstants.spacingS + 2 : AppConstants.spacingM,
        ),
        child: Row(
          children: [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCheckbox(context),
                  SizedBox(width: AppConstants.spacingXS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTodoName(colorScheme),
                        ..._buildMetadataRows(layout, colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppConstants.spacingXS + 2),
            _buildAdditionalInfo(colorScheme),
          ],
        ),
      ),
    );
  }

  /// Builds configurable metadata rows below the title.
  List<Widget> _buildMetadataRows(
    List<TodoCardLayoutEntry> layout,
    ColorScheme colorScheme,
  ) {
    final mergeCategoryPriority = TodoCardLayoutConfig.mergeCategoryPriority(
      layout,
    );
    var mergedCategoryPriority = false;
    final rows = <Widget>[];

    for (final id in TodoCardLayoutConfig.visibleIds(layout)) {
      if (mergeCategoryPriority &&
          (id == TodoCardFieldId.category || id == TodoCardFieldId.priority)) {
        if (!mergedCategoryPriority) {
          final row = _buildCategoryPriorityRow();
          if (row != null) rows.add(row);
          mergedCategoryPriority = true;
        }
        continue;
      }

      final row = switch (id) {
        TodoCardFieldId.description => _buildTodoDescription(colorScheme),
        TodoCardFieldId.category => _buildCategoryRow(),
        TodoCardFieldId.created => _buildCreatedTime(colorScheme),
        TodoCardFieldId.deadline => _buildDeadlineRow(colorScheme),
        TodoCardFieldId.priority => _buildPriorityRow(),
        TodoCardFieldId.tags => _buildTagsRow(),
        TodoCardFieldId.completed => _buildCompletedDateRow(colorScheme),
      };

      if (row != null) rows.add(row);
    }

    return rows;
  }

  /// Builds the item name widget.
  Widget _buildTodoName(ColorScheme colorScheme) {
    final isCancelled = _status == TodoStatus.cancelled;
    final isDone = _status == TodoStatus.done;
    final isArchivedCategory = _isFromArchivedCategory;
    final isRecurring = RecurrenceService.isRecurring(widget.todo.recurrence);

    return Row(
      children: [
        if (isRecurring) ...[
          Icon(
            IconsaxPlusLinear.repeat,
            size: 14,
            color: colorScheme.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            widget.todo.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
              fontWeight: FontWeight.w600,
              color: isCancelled
                  ? colorScheme.error.withValues(alpha: 0.6)
                  : (isDone || isArchivedCategory
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface),
              decoration: (isDone || isCancelled)
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: isCancelled
                  ? colorScheme.error.withValues(alpha: 0.6)
                  : colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  /// Builds the item description widget.
  Widget? _buildTodoDescription(ColorScheme colorScheme) {
    if (widget.todo.description.isEmpty) {
      return null;
    }

    final lines = widget.todo.description.split('\n');
    final isTruncated =
        lines.length > 2 || lines.any((line) => line.length > 80);

    return Padding(
      padding: const EdgeInsets.only(top: _metadataGapTight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.todo.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              color: _isFromArchivedCategory
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : colorScheme.onSurfaceVariant,
              decoration: _status == TodoStatus.done
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          if (isTruncated)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  decoration: _status == TodoStatus.done
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the additional info widget.
  Widget _buildAdditionalInfo(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacingXS + 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.todo.fix) _buildFixedIcon(colorScheme),
          if (widget.calendar) _buildCalendarTime(colorScheme),
          _buildTrailingText(colorScheme),
        ],
      ),
    );
  }

  /// Builds the calendar time widget.
  Widget _buildCalendarTime(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: MetadataChip(
        accentColor: colorScheme.tertiary,
        backgroundColor: colorScheme.tertiaryContainer,
        showBorder: false,
        child: Text(
          _formatCalendarTime(widget.todo.dueAt!),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onTertiaryContainer,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Format calendar time.
  String _formatCalendarTime(DateTime time) {
    final (timeformat, languageCode) = ref.watch(
      appSettingsProvider.select((s) => (s.timeformat, s.locale.languageCode)),
    );
    return DateTimeFormatHelper.formatTime(
      time,
      timeformat: timeformat,
      languageCode: languageCode,
    );
  }

  /// Builds the fixed icon widget.
  Widget _buildFixedIcon(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: MetadataChip(
        accentColor: colorScheme.secondary,
        backgroundColor: colorScheme.secondaryContainer,
        showBorder: false,
        padding: const EdgeInsets.all(5),
        child: Icon(
          IconsaxPlusBold.attach_square,
          size: 14,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  /// Builds the trailing text widget.
  Widget _buildTrailingText(ColorScheme colorScheme) {
    final hasNoSubtasks = widget.createdTodos == 0;
    final allComplete =
        widget.createdTodos > 0 && widget.completedTodos == widget.createdTodos;
    final shouldDim = hasNoSubtasks || allComplete;

    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      child: MetadataChip(
        accentColor: colorScheme.outline,
        backgroundColor: shouldDim
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest,
        showBorder: false,
        child: Text(
          '${widget.completedTodos}/${widget.createdTodos}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: shouldDim
                ? colorScheme.onSurface.withValues(alpha: 0.4)
                : colorScheme.onSurface,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
