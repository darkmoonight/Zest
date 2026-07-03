import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/features/todos/presentation/view/todo_todos.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/metadata_chip.dart';

/// Card widget displaying a single todo with status, tags, and actions.
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

  /// The todo.
  final Todos todo;

  /// The all todos.
  final bool allTodos;

  /// The calendar.
  final bool calendar;

  /// The created todos.
  final int createdTodos;

  /// The completed todos.
  final int completedTodos;

  /// The is selected.
  final bool isSelected;

  /// The on double tap.
  final VoidCallback onDoubleTap;

  /// The on tap.
  final VoidCallback onTap;

  @override
  /// Creates the state for this widget.
  ConsumerState<TodoCard> createState() => _TodoCardState();
}

/// State for [TodoCard] managing tap animations and status changes.
class _TodoCardState extends ConsumerState<TodoCard>
    with SingleTickerProviderStateMixin {
  /// The animation controller.
  late final AnimationController _animationController;

  /// The scale animation.
  late final Animation<double> _scaleAnimation;

  /// Tapped right side.
  bool _tappedRightSide = false;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  /// Initialize animation.
  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handle tap down.
  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = details.localPosition;
    final width = box.size.width;
    const rightZoneFraction = 0.15;
    final rightZoneStart = width * (1 - rightZoneFraction);

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

  /// Handle tap up.
  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    if (!_tappedRightSide) {
      widget.onTap();
    }
  }

  /// Handle tap cancel.
  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  /// Builds the widget subtree.
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
        scale: _scaleAnimation,
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

  /// Builds the card content widget.
  Widget _buildCardContent(
    BuildContext context,
    ColorScheme colorScheme,
    bool isMobile,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(
                color: colorScheme.primary,
                width: AppConstants.borderWidthThick,
              )
            : null,
        borderRadius: BorderRadius.circular(
          isSelected
              ? AppConstants.borderRadiusXLarge
              : AppConstants.borderRadiusLarge,
        ),
      ),
      child: Card(
        elevation: isSelected
            ? AppConstants.elevationMedium
            : AppConstants.elevationLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            isSelected
                ? AppConstants.borderRadiusXLarge
                : AppConstants.borderRadiusLarge,
          ),
        ),
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
                          _buildTodoDescription(colorScheme),
                          _buildCategoryInfo(),
                          _buildCreatedTime(colorScheme),
                          _buildCompletionTime(colorScheme),
                          _buildTagsAndPriority(),
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
      ),
    );
  }

  /// Builds the checkbox widget.
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

                  setState(() {
                    widget.todo.status = val
                        ? TodoStatus.done
                        : TodoStatus.active;
                    widget.todo.todoCompletionTime = val
                        ? DateTime.now()
                        : null;
                  });
                  _handleCheckboxChange(val);
                },
              ),
      ),
    );
  }

  /// Handle checkbox change.
  void _handleCheckboxChange(bool val) {
    final date = widget.todo.todoCompletedTime;

    if (val) {
      ref.read(notificationServiceProvider).cancel(widget.todo.id);
    } else if (date != null && DateTime.now().isBefore(date)) {
      ref.read(notificationServiceProvider).scheduleForTodo(widget.todo);
    }

    Future.delayed(
      AppConstants.shortAnimation,
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatus(widget.todo),
    );
  }

  /// Show status menu.
  void _showStatusMenu(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    showDialog(
      context: context,
      builder: (context) => _StatusChangeDialog(
        todo: widget.todo,
        isMobile: isMobile,
        onStatusChanged: _changeStatus,
        onBulkCompletion: _handleBulkCompletion,
        onBulkCancellation: _handleBulkCancellation,
      ),
    );
  }

  /// Change status.
  void _changeStatus(TodoStatus newStatus) {
    setState(() {
      widget.todo.status = newStatus;
      widget.todo.todoCompletionTime =
          (newStatus == TodoStatus.done || newStatus == TodoStatus.cancelled)
          ? DateTime.now()
          : null;
    });

    final date = widget.todo.todoCompletedTime;

    if (newStatus == TodoStatus.done || newStatus == TodoStatus.cancelled) {
      ref.read(notificationServiceProvider).cancel(widget.todo.id);
    } else if (date != null && DateTime.now().isBefore(date)) {
      ref.read(notificationServiceProvider).scheduleForTodo(widget.todo);
    }

    Future.delayed(
      AppConstants.shortAnimation,
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatus(widget.todo),
    );
  }

  /// Handle bulk completion.
  void _handleBulkCompletion() {
    setState(() {
      widget.todo.status = TodoStatus.done;
      widget.todo.todoCompletionTime = DateTime.now();
    });

    Future.delayed(
      AppConstants.shortAnimation,
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatusWithSubtasks(widget.todo, TodoStatus.done),
    );
  }

  /// Handle bulk cancellation.
  void _handleBulkCancellation() {
    setState(() {
      widget.todo.status = TodoStatus.cancelled;
      widget.todo.todoCompletionTime = DateTime.now();
    });

    Future.delayed(
      AppConstants.shortAnimation,
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatusWithSubtasks(widget.todo, TodoStatus.cancelled),
    );
  }

  /// Whether this todo belongs to an archived category in list views.
  bool get _isFromArchivedCategory =>
      (widget.allTodos || widget.calendar) &&
      widget.todo.task.value?.archive == true;

  /// Builds the todo name widget.
  Widget _buildTodoName(ColorScheme colorScheme) {
    final isCancelled = widget.todo.status == TodoStatus.cancelled;
    final isDone = widget.todo.status == TodoStatus.done;
    final isArchivedCategory = _isFromArchivedCategory;

    return Text(
      widget.todo.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
        fontWeight: FontWeight.w600,
        color: isCancelled
            ? colorScheme.error.withValues(alpha: 0.6)
            : (isDone || isArchivedCategory
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface),
        decoration: (isDone || isCancelled) ? TextDecoration.lineThrough : null,
        decorationColor: isCancelled
            ? colorScheme.error.withValues(alpha: 0.6)
            : colorScheme.onSurfaceVariant,
      ),
      overflow: TextOverflow.visible,
    );
  }

  /// Builds the todo description widget.
  Widget _buildTodoDescription(ColorScheme colorScheme) {
    if (widget.todo.description.isEmpty) {
      return const SizedBox.shrink();
    }

    final lines = widget.todo.description.split('\n');
    final isTruncated =
        lines.length > 2 || lines.any((line) => line.length > 80);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
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
  Widget _buildCategoryInfo() {
    if (!((widget.allTodos || widget.calendar) &&
        widget.todo.task.value != null)) {
      return const SizedBox.shrink();
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

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Wrap(
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
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
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
      ),
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
  Widget _buildCreatedTime(ColorScheme colorScheme) {
    if (widget.todo.createdTime.year < 2000) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.clock_1,
            size: 11,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            '${'created'.tr}: ${_formatCompletionTime(widget.todo.createdTime)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the completion time widget.
  Widget _buildCompletionTime(ColorScheme colorScheme) {
    if (widget.todo.todoCompletedTime == null || widget.calendar) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.calendar_1,
            size: 11,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 3),
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

  /// Format completion time.
  String _formatCompletionTime(DateTime time) {
    final appSettings = ref.watch(appSettingsProvider);
    return DateTimeFormatHelper.formatDateTime(
      time,
      timeformat: appSettings.timeformat,
      languageCode: appSettings.locale.languageCode,
    );
  }

  /// Builds the tags and priority widget.
  Widget _buildTagsAndPriority() {
    if (widget.todo.priority == Priority.none && widget.todo.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [_buildPriorityChip(), _buildTagsChips()]),
      ),
    );
  }

  /// Builds the priority chip widget.
  Widget _buildPriorityChip() {
    if (widget.todo.priority == Priority.none) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: _StatusChip(
        icon: IconsaxPlusBold.flag,
        color: widget.todo.priority.color,
        label: widget.todo.priority.name.tr,
      ),
    );
  }

  /// Builds the tags chips widget.
  Widget _buildTagsChips() {
    if (widget.todo.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: widget.todo.tags
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(right: 5),
              child: _TagsChip(label: e),
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

/// Compact chip displaying a single todo tag label.
class _TagsChip extends StatelessWidget {
  /// Creates a [_TagsChip].
  const _TagsChip({required this.label});

  /// The label.
  final String label;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: AppConstants.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusBold.tag_2,
            size: 12,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip representing a selectable todo status option.
class _StatusChip extends StatelessWidget {
  /// Creates a [_StatusChip].
  const _StatusChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  /// The icon.
  final IconData icon;

  /// The color.
  final Color? color;

  /// The label.
  final String label;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: AppConstants.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Status Change Dialog ====================

/// Widget that status change dialog.
class _StatusChangeDialog extends StatefulWidget {
  /// The todo.
  final Todos todo;

  /// The is mobile.
  final bool isMobile;

  /// The on status changed.
  final Function(TodoStatus) onStatusChanged;

  /// The on bulk completion.
  final VoidCallback onBulkCompletion;

  /// The on bulk cancellation.
  final VoidCallback onBulkCancellation;

  /// Creates a [_StatusChangeDialog].
  const _StatusChangeDialog({
    required this.todo,
    required this.isMobile,
    required this.onStatusChanged,
    required this.onBulkCompletion,
    required this.onBulkCancellation,
  });

  @override
  /// Creates the state for this widget.
  State<_StatusChangeDialog> createState() => _StatusChangeDialogState();
}

/// Widget that status change dialog state.
class _StatusChangeDialogState extends State<_StatusChangeDialog>
    with SingleTickerProviderStateMixin {
  /// The animation controller.
  late AnimationController _animationController;

  /// The scale animation.
  late Animation<double> _scaleAnimation;

  /// The fade animation.
  late Animation<double> _fadeAnimation;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _initAnimation();
  }

  /// Init animation.
  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentStatus = widget.todo.status;
    final hasIncompleteChildren =
        widget.todo.children.isNotEmpty &&
        widget.todo.children.any((child) => child.status != TodoStatus.done);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: widget.isMobile
                  ? double.infinity
                  : AppConstants.maxModalWidth,
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusXXLarge,
                ),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: AppConstants.borderWidthThin,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(colorScheme),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  _buildStatusOptions(
                    colorScheme,
                    currentStatus,
                    hasIncompleteChildren,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header widget.
  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.borderRadiusXLarge),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingS + 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Icon(
              IconsaxPlusBold.status,
              size: AppConstants.iconSizeLarge,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'changeStatus'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS / 2),
                Text(
                  'selectNewStatus'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the status options widget.
  Widget _buildStatusOptions(
    ColorScheme colorScheme,
    TodoStatus currentStatus,
    bool hasIncompleteChildren,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentStatus != TodoStatus.done)
            _buildStatusOption(
              icon: IconsaxPlusBold.tick_circle,
              color: colorScheme.primary,
              title: 'markAsDone'.tr,
              subtitle: 'markAsDoneHint'.tr,
              onTap: () {
                NavigationHelper.back(context);
                widget.onStatusChanged(TodoStatus.done);
              },
            ),
          if (currentStatus != TodoStatus.cancelled)
            _buildStatusOption(
              icon: IconsaxPlusBold.close_circle,
              color: colorScheme.error,
              title: 'markAsCancelled'.tr,
              subtitle: 'markAsCancelledHint'.tr,
              onTap: () {
                NavigationHelper.back(context);
                widget.onStatusChanged(TodoStatus.cancelled);
              },
            ),
          if (currentStatus != TodoStatus.active)
            _buildStatusOption(
              icon: IconsaxPlusBold.refresh,
              color: colorScheme.tertiary,
              title: 'markAsActive'.tr,
              subtitle: 'markAsActiveHint'.tr,
              onTap: () {
                NavigationHelper.back(context);
                widget.onStatusChanged(TodoStatus.active);
              },
            ),
          if (hasIncompleteChildren &&
              currentStatus == TodoStatus.active &&
              widget.todo.status != TodoStatus.done)
            _buildStatusOption(
              icon: IconsaxPlusBold.tick_circle,
              color: colorScheme.secondary,
              title: 'markWithSubtasks'.tr,
              subtitle: 'markWithSubtasksCompleteHint'.tr,
              onTap: () {
                NavigationHelper.back(context);
                widget.onBulkCompletion();
              },
            ),
          if (hasIncompleteChildren && currentStatus == TodoStatus.active)
            _buildStatusOption(
              icon: IconsaxPlusBold.close_circle,
              color: colorScheme.error.withValues(alpha: 0.8),
              title: 'markWithSubtasks'.tr,
              subtitle: 'markWithSubtasksCancelHint'.tr,
              onTap: () {
                NavigationHelper.back(context);
                widget.onBulkCancellation();
              },
            ),
        ],
      ),
    );
  }

  /// Builds the status option widget.
  Widget _buildStatusOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: AppConstants.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: AppConstants.iconSizeMedium,
                    color: color,
                  ),
                ),
                SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            14,
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingXS / 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  IconsaxPlusLinear.arrow_right_3,
                  size: AppConstants.iconSizeSmall,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
