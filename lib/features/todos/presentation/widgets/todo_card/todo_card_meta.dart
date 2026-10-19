part of '../todo_card.dart';

mixin _TodoCardMeta on ConsumerState<TodoCard>, _TodoCardStatus {
  Category? get _todoCategory {
    final categoryId = widget.todo.categoryId;
    if (categoryId == null) return null;
    final tasks = ref.watch(
      categoriesNotifierProvider.select((s) => s.categories),
    );
    for (final category in tasks) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  /// Whether this item belongs to an archived category in list views.
  bool get _isFromArchivedCategory =>
      (widget.allTodos || widget.calendar) && _todoCategory?.archive == true;

  Widget? _buildCategoryRow() {
    final chips = _buildCategoryInfo();
    if (chips == null) return null;
    return Padding(
      padding: const EdgeInsets.only(top: _metadataGap),
      child: chips,
    );
  }

  Widget? _buildPriorityRow() {
    if (widget.todo.priority == Priority.none) return null;
    return Padding(
      padding: const EdgeInsets.only(top: _metadataSectionGap),
      child: _buildPriorityChip(),
    );
  }

  /// Category and priority on one line when both are enabled.
  Widget? _buildCategoryPriorityRow() {
    final category = _buildCategoryInfo();
    if (widget.todo.priority == Priority.none && category == null) return null;

    return Padding(
      padding: const EdgeInsets.only(top: _metadataGap),
      child: Wrap(
        spacing: AppConstants.spacingXS,
        runSpacing: AppConstants.spacingXS,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ?category,
          if (widget.todo.priority != Priority.none) _buildPriorityChip(),
        ],
      ),
    );
  }

  /// Builds the category info widget.
  Widget? _buildCategoryInfo() {
    final category = _todoCategory;
    if (!((widget.allTodos || widget.calendar) && category != null)) {
      return null;
    }

    final isArchivedCategory =
        (widget.allTodos || widget.calendar) && category.archive;
    final categoryColor = Color(category.colorArgb);
    final luminance = categoryColor.computeLuminance();
    final isDarkColor = luminance < 0.5;
    final textColor = isDarkColor
        ? categoryColor.withValues(alpha: isArchivedCategory ? 0.65 : 1.0)
        : _darkenColor(categoryColor, isArchivedCategory ? 0.55 : 0.4);

    return Wrap(
      spacing: AppConstants.spacingXS,
      runSpacing: AppConstants.spacingXS,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        MetadataChip(
          accentColor: categoryColor,
          backgroundAlpha: isArchivedCategory ? 0.08 : 0.12,
          borderAlpha: isArchivedCategory ? 0.2 : 0.35,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(
                    alpha: isArchivedCategory ? 0.6 : 1.0,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  category.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      11,
                    ),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (isArchivedCategory)
          MetadataChip(
            accentColor: Theme.of(context).colorScheme.outline,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            showBorder: false,
            child: Text(
              'archived'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  /// Darken color.
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness * (1 - amount)).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  /// Builds the created time widget.
  Widget? _buildCreatedTime(ColorScheme colorScheme) {
    if (widget.todo.createdAt.year < 2000) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: _metadataGapTight),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.clock_1,
            size: 11,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: _metadataGapTight),
          Text(
            'createdAtLabel'.trFormat({
              'date': _formatCompletionTime(widget.todo.createdAt),
            }),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the deadline row.
  Widget? _buildDeadlineRow(ColorScheme colorScheme) {
    if (widget.todo.dueAt == null || widget.calendar) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: _metadataGapTight),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.calendar_1,
            size: 11,
            color: colorScheme.primary,
          ),
          const SizedBox(width: _metadataGapTight),
          Text(
            _formatCompletionTime(widget.todo.dueAt!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the completion timestamp for done or cancelled items.
  Widget? _buildCompletedDateRow(ColorScheme colorScheme) {
    final completed = _completionTime;
    if (completed == null ||
        (_status != TodoStatus.done && _status != TodoStatus.cancelled)) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: _metadataGapTight),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.tick_circle,
            size: 11,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: _metadataGapTight),
          Text(
            'completedAtLabel'.trFormat({
              'date': _formatCompletionTime(completed),
            }),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompletionTime(DateTime time) {
    final (timeformat, languageCode) = ref.watch(
      appSettingsProvider.select((s) => (s.timeformat, s.locale.languageCode)),
    );
    return DateTimeFormatHelper.formatDateTime(
      time,
      timeformat: timeformat,
      languageCode: languageCode,
    );
  }

  Widget? _buildTagsRow() {
    if (widget.todo.tags.isEmpty) return null;

    return Padding(
      padding: const EdgeInsets.only(top: _metadataSectionGap),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildTagsChips(),
      ),
    );
  }

  /// Builds the priority chip widget.
  Widget _buildPriorityChip() {
    if (widget.todo.priority == Priority.none) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = widget.todo.priority.color ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: MetadataChip(
        accentColor: chipColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusBold.flag,
              size: AppConstants.iconSizeInline,
              color: chipColor,
            ),
            const SizedBox(width: 3),
            Text(
              widget.todo.priority.name.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                fontWeight: FontWeight.w600,
                color: chipColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the tags chips widget.
  Widget _buildTagsChips() {
    if (widget.todo.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: widget.todo.tags
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(right: 5),
              child: MetadataChip(
                accentColor: colorScheme.outline,
                backgroundColor: colorScheme.secondaryContainer,
                backgroundAlpha: 1.0,
                borderAlpha: 0.2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusBold.tag_2,
                      size: AppConstants.iconSizeInline,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      e,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          11,
                        ),
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
