import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/todo_card_layout_config.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/features/todos/presentation/view/todo_todos.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/card_tap_scale_mixin.dart';
import 'package:zest/core/widgets/metadata_chip.dart';
import 'package:zest/core/widgets/selectable_card_shell.dart';
import 'package:zest/features/todos/presentation/widgets/todo_status_change_dialog.dart';

/// Card widget displaying a single item with status, tags, and actions.
class TodoCard extends ConsumerStatefulWidget {
  /// Creates a [TodoCard].
  const TodoCard({
    super.key,
    required this.todo,
    required this.allTodos,
    required this.calendar,
    required this.createdTodos,
    required this.completedTodos,
    required this.isSelected,
    required this.onDoubleTap,
    required this.onTap,
  });

  /// Item shown by this card.
  final Todos todo;

  /// Whether the card is rendered in the all-items list.
  final bool allTodos;

  /// Whether the card is rendered in the calendar list.
  final bool calendar;

  /// Number of subtasks under this item.
  final int createdTodos;

  /// Number of completed subtasks under this item.
  final int completedTodos;

  /// Whether the card is currently selected in multi-select mode.
  final bool isSelected;

  /// Called when the card is double tapped.
  final VoidCallback onDoubleTap;

  /// Called when the card is tapped outside the detail preview zone.
  final VoidCallback onTap;

  @override
  ConsumerState<TodoCard> createState() => _TodoCardState();
}

/// State for [TodoCard] managing tap animations and status changes.
class _TodoCardState extends ConsumerState<TodoCard>
    with SingleTickerProviderStateMixin, CardTapScaleMixin {
  static const double _detailPreviewZoneFraction = 0.15;

  static const double _metadataGapTight = 3;
  static const double _metadataGap = 5;
  static const double _metadataSectionGap = 6;

  /// Whether the last tap started in the detail-preview zone.
  bool _tappedRightSide = false;

  /// Rejects stale delayed status writes after a newer interaction.
  int _statusWriteGen = 0;

  @override
  void initState() {
    super.initState();
    initCardTapScaleAnimation();
  }

  @override
  void dispose() {
    disposeCardTapScaleAnimation();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    handleCardTapDown(details);

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = details.localPosition;
    final width = box.size.width;
    final rightZoneStart = width * (1 - _detailPreviewZoneFraction);

    _tappedRightSide = local.dx >= rightZoneStart;

    if (_tappedRightSide) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TodosTodo(key: ValueKey(widget.todo.id), todo: widget.todo),
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
    }
  }

  void _handleTapUp(TapUpDetails details) {
    handleCardTapUp(details);
    if (!_tappedRightSide) {
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    handleCardTapCancel();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppConstants.spacingS + 2
            : AppConstants.spacingM,
        vertical: AppConstants.spacingXS,
      ),
      child: ScaleTransition(
        scale: cardTapScaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onDoubleTap: widget.onDoubleTap,
          child: _buildCardContent(
            context,
            colorScheme,
            isMobile,
            widget.isSelected,
          ),
        ),
      ),
    );
  }

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

  Widget _buildCheckbox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Transform.scale(
      scale: ResponsiveUtils.isMobile(context) ? 1.0 : 1.1,
      child: GestureDetector(
        onLongPress: () => _showStatusMenu(context),
        child: widget.todo.status == TodoStatus.cancelled
            ? IconButton(
                icon: Icon(
                  IconsaxPlusBold.close_circle,
                  color: colorScheme.error.withValues(alpha: 0.7),
                ),
                onPressed: () => _showStatusMenu(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : Checkbox(
                value: widget.todo.status == TodoStatus.done,
                shape: const CircleBorder(),
                onChanged: (val) {
                  if (val == null) return;

                  _applyLocalStatus(val ? TodoStatus.done : TodoStatus.active);
                  _persistStatus(
                    () => ref
                        .read(todosNotifierProvider.notifier)
                        .updateTodoStatus(widget.todo),
                  );
                },
              ),
      ),
    );
  }

  void _persistStatus(VoidCallback write) {
    final gen = ++_statusWriteGen;
    Future.delayed(AppConstants.shortAnimation, () {
      if (!mounted || gen != _statusWriteGen) return;
      write();
    });
  }

  void _showStatusMenu(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    showDialog(
      context: context,
      builder: (context) => TodoStatusChangeDialog(
        todo: widget.todo,
        isMobile: isMobile,
        onStatusChanged: _changeStatus,
        onBulkCompletion: _handleBulkCompletion,
        onBulkCancellation: _handleBulkCancellation,
      ),
    );
  }

  void _changeStatus(TodoStatus newStatus) {
    _applyLocalStatus(newStatus);
    _persistStatus(
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatus(widget.todo),
    );
  }

  void _handleBulkCompletion() {
    _applyLocalStatus(TodoStatus.done);
    _persistStatus(
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatusWithSubtasks(widget.todo, TodoStatus.done),
    );
  }

  void _handleBulkCancellation() {
    _applyLocalStatus(TodoStatus.cancelled);
    _persistStatus(
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatusWithSubtasks(widget.todo, TodoStatus.cancelled),
    );
  }

  void _applyLocalStatus(TodoStatus status) {
    setState(() {
      widget.todo.status = status;
      widget.todo.todoCompletionTime =
          (status == TodoStatus.done || status == TodoStatus.cancelled)
          ? DateTime.now()
          : null;
    });
  }

  /// Whether this item belongs to an archived category in list views.
  bool get _isFromArchivedCategory =>
      (widget.allTodos || widget.calendar) &&
      widget.todo.task.value?.archive == true;

  /// Builds the item name widget.
  Widget _buildTodoName(ColorScheme colorScheme) {
    final isCancelled = widget.todo.status == TodoStatus.cancelled;
    final isDone = widget.todo.status == TodoStatus.done;
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
              decoration: widget.todo.status == TodoStatus.done
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
                  decoration: widget.todo.status == TodoStatus.done
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

  /// Builds the category info widget.
  Widget? _buildCategoryInfo() {
    if (!((widget.allTodos || widget.calendar) &&
        widget.todo.task.value != null)) {
      return null;
    }

    final task = widget.todo.task.value!;
    final isArchivedCategory =
        (widget.allTodos || widget.calendar) && task.archive;
    final categoryColor = Color(task.taskColor);
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
                  task.title,
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
    if (widget.todo.createdTime.year < 2000) {
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
              'date': _formatCompletionTime(widget.todo.createdTime),
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
    if (widget.todo.todoCompletedTime == null || widget.calendar) {
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
            _formatCompletionTime(widget.todo.todoCompletedTime!),
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
    final completed = widget.todo.todoCompletionTime;
    if (completed == null ||
        (widget.todo.status != TodoStatus.done &&
            widget.todo.status != TodoStatus.cancelled)) {
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
    final appSettings = ref.watch(appSettingsProvider);
    return DateTimeFormatHelper.formatDateTime(
      time,
      timeformat: appSettings.timeformat,
      languageCode: appSettings.locale.languageCode,
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
          _formatCalendarTime(widget.todo.todoCompletedTime!),
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
    final appSettings = ref.watch(appSettingsProvider);
    return DateTimeFormatHelper.formatTime(
      time,
      timeformat: appSettings.timeformat,
      languageCode: appSettings.locale.languageCode,
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
