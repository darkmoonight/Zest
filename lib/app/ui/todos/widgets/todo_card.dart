import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/todos/view/todo_todos.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/notification.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/main.dart';

class TodoCard extends StatefulWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.allTodos,
    required this.calendar,
    required this.createdTodos,
    required this.completedTodos,
    required this.onDoubleTap,
    required this.onTap,
  });

  final Todos todo;
  final bool allTodos;
  final bool calendar;
  final int createdTodos;
  final int completedTodos;
  final VoidCallback onDoubleTap;
  final VoidCallback onTap;

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard>
    with SingleTickerProviderStateMixin {
  late final TodoController _todoController = Get.find<TodoController>();
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  bool _tappedRightSide = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      Get.key.currentState!.push(
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
          transitionDuration: const Duration(milliseconds: 240),
        ),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    if (!_tappedRightSide) {
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    _animationController.reverse();
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
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onDoubleTap: widget.onDoubleTap,
          child: Obx(() {
            final isSelected =
                _todoController.isMultiSelectionTodo.isTrue &&
                _todoController.selectedTodo.contains(widget.todo);

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
                    isMobile
                        ? AppConstants.spacingS + 2
                        : AppConstants.spacingM,
                    isMobile
                        ? AppConstants.spacingS + 2
                        : AppConstants.spacingM + 2,
                    isMobile
                        ? AppConstants.spacingS + 2
                        : AppConstants.spacingM,
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
          }),
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

  void _handleCheckboxChange(bool val) {
    final date = widget.todo.todoCompletedTime;

    if (val) {
      flutterLocalNotificationsPlugin?.cancel(id: widget.todo.id);
    } else if (date != null && DateTime.now().isBefore(date)) {
      NotificationShow().showNotification(
        widget.todo.id,
        widget.todo.name,
        widget.todo.description,
        widget.todo.todoCompletedTime,
      );
    }

    Future.delayed(
      AppConstants.shortAnimation,
      () => _todoController.updateTodoStatus(widget.todo),
    );
  }

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
      flutterLocalNotificationsPlugin?.cancel(id: widget.todo.id);
    } else if (date != null && DateTime.now().isBefore(date)) {
      NotificationShow().showNotification(
        widget.todo.id,
        widget.todo.name,
        widget.todo.description,
        widget.todo.todoCompletedTime,
      );
    }

    Future.delayed(
      AppConstants.shortAnimation,
      () => _todoController.updateTodoStatus(widget.todo),
    );
  }

  void _handleBulkCompletion() {
    setState(() {
      widget.todo.status = TodoStatus.done;
      widget.todo.todoCompletionTime = DateTime.now();
    });

    Future.delayed(
      AppConstants.shortAnimation,
      () => _todoController.updateTodoStatusWithSubtasks(
        widget.todo,
        TodoStatus.done,
      ),
    );
  }

  void _handleBulkCancellation() {
    setState(() {
      widget.todo.status = TodoStatus.cancelled;
      widget.todo.todoCompletionTime = DateTime.now();
    });

    Future.delayed(
      AppConstants.shortAnimation,
      () => _todoController.updateTodoStatusWithSubtasks(
        widget.todo,
        TodoStatus.cancelled,
      ),
    );
  }

  Widget _buildTodoName(ColorScheme colorScheme) {
    final isCancelled = widget.todo.status == TodoStatus.cancelled;
    final isDone = widget.todo.status == TodoStatus.done;

    return Text(
      widget.todo.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
        fontWeight: FontWeight.w600,
        color: isCancelled
            ? colorScheme.error.withValues(alpha: 0.6)
            : (isDone ? colorScheme.onSurfaceVariant : colorScheme.onSurface),
        decoration: (isDone || isCancelled) ? TextDecoration.lineThrough : null,
        decorationColor: isCancelled
            ? colorScheme.error.withValues(alpha: 0.6)
            : colorScheme.onSurfaceVariant,
      ),
      overflow: TextOverflow.visible,
    );
  }

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
              color: colorScheme.onSurfaceVariant,
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

  Widget _buildCategoryInfo() {
    if (!((widget.allTodos || widget.calendar) &&
        widget.todo.task.value != null)) {
      return const SizedBox.shrink();
    }

    final task = widget.todo.task.value!;
    final categoryColor = Color(task.taskColor);
    final luminance = categoryColor.computeLuminance();
    final isDarkColor = luminance < 0.5;
    final textColor = isDarkColor
        ? categoryColor.withValues(alpha: 1.0)
        : _darkenColor(categoryColor, 0.4);

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.35),
            width: AppConstants.borderWidthThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness * (1 - amount)).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

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

  String _formatCompletionTime(DateTime time) {
    return timeformat.value == '12'
        ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(time)
        : DateFormat.yMMMEd(locale.languageCode).add_Hm().format(time);
  }

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

  Widget _buildCalendarTime(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        _formatCalendarTime(widget.todo.todoCompletedTime!),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onTertiaryContainer,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCalendarTime(DateTime time) {
    return timeformat.value == '12'
        ? DateFormat.jm(locale.languageCode).format(time)
        : DateFormat.Hm(locale.languageCode).format(time);
  }

  Widget _buildFixedIcon(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(
        IconsaxPlusBold.attach_square,
        size: 14,
        color: colorScheme.onSecondaryContainer,
      ),
    );
  }

  Widget _buildTrailingText(ColorScheme colorScheme) {
    final hasNoSubtasks = widget.createdTodos == 0;
    final allComplete =
        widget.createdTodos > 0 && widget.completedTodos == widget.createdTodos;
    final shouldDim = hasNoSubtasks || allComplete;

    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: shouldDim
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(7),
      ),
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
    );
  }
}

class _TagsChip extends StatelessWidget {
  const _TagsChip({required this.label});

  final String label;

  @override
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color? color;
  final String label;

  @override
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

class _StatusChangeDialog extends StatefulWidget {
  final Todos todo;
  final bool isMobile;
  final Function(TodoStatus) onStatusChanged;
  final VoidCallback onBulkCompletion;
  final VoidCallback onBulkCancellation;

  const _StatusChangeDialog({
    required this.todo,
    required this.isMobile,
    required this.onStatusChanged,
    required this.onBulkCompletion,
    required this.onBulkCancellation,
  });

  @override
  State<_StatusChangeDialog> createState() => _StatusChangeDialogState();
}

class _StatusChangeDialogState extends State<_StatusChangeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
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
                NavigationHelper.back();
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
                NavigationHelper.back();
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
                NavigationHelper.back();
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
                NavigationHelper.back();
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
                NavigationHelper.back();
                widget.onBulkCancellation();
              },
            ),
        ],
      ),
    );
  }

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
