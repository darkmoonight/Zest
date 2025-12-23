import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/todos/view/todo_todos.dart';
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
  final todoController = Get.put(TodoController());
  bool tappedRightSide = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, innerState) => ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _animationController.forward();
            final box = context.findRenderObject() as RenderBox;
            final local = details.localPosition;
            final width = box.size.width;

            const rightZoneFraction = 0.15;
            final rightZoneStart = width * (1 - rightZoneFraction);

            tappedRightSide = local.dx >= rightZoneStart;

            if (tappedRightSide) {
              Get.key.currentState!.push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TodosTodo(
                        key: ValueKey(widget.todo.id),
                        todo: widget.todo,
                      ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
          },
          onTapUp: (_) {
            _animationController.reverse();
            if (!tappedRightSide) {
              widget.onTap();
            }
          },
          onTapCancel: () {
            _animationController.reverse();
          },
          onDoubleTap: widget.onDoubleTap,
          child: _buildCard(context, innerState),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, StateSetter innerState) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);
    return Card(
      shape: _getCardShape(),
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: 5),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 4 : 8,
          isMobile ? 12 : 14,
          isMobile ? 12 : 16,
          isMobile ? 12 : 14,
        ),
        child: Row(
          children: [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCheckbox(innerState, colorScheme),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTodoName(colorScheme),
                        _buildTodoDescription(colorScheme),
                        _buildCategoryInfo(colorScheme),
                        _buildCreatedTime(colorScheme),
                        _buildCompletionTime(colorScheme),
                        _buildTagsAndPriority(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildAdditionalInfo(colorScheme),
          ],
        ),
      ),
    );
  }

  RoundedRectangleBorder? _getCardShape() {
    final colorScheme = Theme.of(context).colorScheme;
    return todoController.isMultiSelectionTodo.isTrue &&
            todoController.selectedTodo.contains(widget.todo)
        ? RoundedRectangleBorder(
            side: BorderSide(color: colorScheme.primary, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          )
        : null;
  }

  Widget _buildCheckbox(StateSetter innerState, ColorScheme colorScheme) {
    return Transform.scale(
      scale: ResponsiveUtils.isMobile(context) ? 1.1 : 1.2,
      child: Checkbox(
        value: widget.todo.done,
        shape: const CircleBorder(),
        onChanged: (val) {
          innerState(() {
            widget.todo.done = val!;
            widget.todo.todoCompletionTime = val ? DateTime.now() : null;
          });
          _handleCheckboxChange(val!);
        },
      ),
    );
  }

  void _handleCheckboxChange(bool val) {
    DateTime? date = widget.todo.todoCompletedTime;
    if (val) {
      flutterLocalNotificationsPlugin?.cancel(widget.todo.id);
    } else if (date != null && DateTime.now().isBefore(date)) {
      NotificationShow().showNotification(
        widget.todo.id,
        widget.todo.name,
        widget.todo.description,
        widget.todo.todoCompletedTime,
      );
    }
    Future.delayed(
      const Duration(milliseconds: 300),
      () => todoController.updateTodoCheck(widget.todo),
    );
  }

  Widget _buildTodoName(ColorScheme colorScheme) {
    return Text(
      widget.todo.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.w600,
        color: widget.todo.done
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface,
        decoration: widget.todo.done ? TextDecoration.lineThrough : null,
        decorationColor: colorScheme.onSurfaceVariant,
      ),
      overflow: TextOverflow.visible,
    );
  }

  Widget _buildTodoDescription(ColorScheme colorScheme) {
    return widget.todo.description.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.todo.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                color: colorScheme.onSurfaceVariant,
                decoration: widget.todo.done
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.visible,
              maxLines: 3,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildCategoryInfo(ColorScheme colorScheme) {
    return (widget.allTodos || widget.calendar) &&
            widget.todo.task.value != null
        ? Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(
                  widget.todo.task.value!.taskColor,
                ).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(widget.todo.task.value!.taskColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.todo.task.value!.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          12,
                        ),
                        fontWeight: FontWeight.w600,
                        color: Color(widget.todo.task.value!.taskColor),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildCreatedTime(ColorScheme colorScheme) {
    return widget.todo.createdTime.year >= 2000
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  IconsaxPlusLinear.clock_1,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${'created'.tr}: ${_formatCompletionTime(widget.todo.createdTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      11,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildCompletionTime(ColorScheme colorScheme) {
    return widget.todo.todoCompletedTime != null && !widget.calendar
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  IconsaxPlusLinear.calendar_1,
                  size: 12,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatCompletionTime(widget.todo.todoCompletedTime!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  String _formatCompletionTime(DateTime time) => timeformat.value == '12'
      ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(time)
      : DateFormat.yMMMEd(locale.languageCode).add_Hm().format(time);

  Widget _buildTagsAndPriority() {
    return widget.todo.priority != Priority.none || widget.todo.tags.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [_buildPriorityChip(), _buildTagsChips()]),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildPriorityChip() {
    return widget.todo.priority != Priority.none
        ? Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _StatusChip(
              icon: IconsaxPlusBold.flag,
              color: widget.todo.priority.color,
              label: widget.todo.priority.name.tr,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildTagsChips() {
    return widget.todo.tags.isNotEmpty
        ? Row(
            children: widget.todo.tags
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _TagsChip(label: e),
                  ),
                )
                .toList(),
          )
        : const SizedBox.shrink();
  }

  Widget _buildAdditionalInfo(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.calendar) _buildCalendarTime(colorScheme),
          if (widget.todo.fix) _buildFixedIcon(colorScheme),
          _buildTrailingText(colorScheme),
        ],
      ),
    );
  }

  Widget _buildCalendarTime(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _formatCalendarTime(widget.todo.todoCompletedTime!),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onTertiaryContainer,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCalendarTime(DateTime time) => timeformat.value == '12'
      ? DateFormat.jm(locale.languageCode).format(time)
      : DateFormat.Hm(locale.languageCode).format(time);

  Widget _buildFixedIcon(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        IconsaxPlusBold.attach_square,
        size: 16,
        color: colorScheme.onSecondaryContainer,
      ),
    );
  }

  Widget _buildTrailingText(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${widget.completedTodos}/${widget.createdTodos}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusBold.tag_2,
            size: 14,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
