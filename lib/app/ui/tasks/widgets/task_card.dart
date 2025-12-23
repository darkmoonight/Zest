import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.createdTodos,
    required this.completedTodos,
    required this.percent,
    required this.onDoubleTap,
    required this.onTap,
  });

  final Tasks task;
  final int createdTodos;
  final int completedTodos;
  final String percent;
  final VoidCallback onDoubleTap;
  final VoidCallback onTap;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected =
        todoController.isMultiSelectionTask.isTrue &&
        todoController.selectedTask.contains(widget.task);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: 5,
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Card(
            shape: isSelected
                ? RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.primary, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  )
                : RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Row(
                children: [
                  _buildProgressCircle(context, colorScheme),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(child: _buildContent(context, colorScheme)),
                  SizedBox(width: isMobile ? 8 : 12),
                  _buildTrailingInfo(context, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCircle(BuildContext context, ColorScheme colorScheme) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final size = isMobile ? 68.0 : (isDesktop ? 80.0 : 74.0);
    final percentage = widget.createdTodos != 0
        ? (widget.completedTodos / widget.createdTodos * 100).round()
        : 0;
    final isCompleted =
        widget.createdTodos > 0 && widget.completedTodos == widget.createdTodos;
    final taskColor = Color(widget.task.taskColor);

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isCompleted)
            Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: taskColor.withValues(alpha: 0.15),
                border: Border.all(
                  color: taskColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                IconsaxPlusBold.tick_circle,
                size: size * 0.45,
                color: taskColor,
              ),
            )
          else
            SleekCircularSlider(
              appearance: CircularSliderAppearance(
                animationEnabled: false,
                angleRange: 360,
                startAngle: 270,
                size: size,
                infoProperties: InfoProperties(
                  modifier: (value) => '$percentage%',
                  mainLabelStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      isMobile ? 15 : (isDesktop ? 17 : 16),
                    ),
                    letterSpacing: -0.5,
                    color: colorScheme.onSurface,
                  ),
                ),
                customColors: CustomSliderColors(
                  progressBarColor: taskColor,
                  trackColor: colorScheme.surfaceContainerHighest,
                  gradientStartAngle: 270,
                  gradientEndAngle: 270 + 360,
                  shadowColor: taskColor.withValues(alpha: 0.3),
                  shadowMaxOpacity: 0.1,
                ),
                customWidths: CustomSliderWidths(
                  progressBarWidth: isMobile ? 6 : (isDesktop ? 8 : 7),
                  trackWidth: isMobile ? 6 : (isDesktop ? 8 : 7),
                  handlerSize: 0,
                  shadowWidth: 4,
                ),
              ),
              min: 0,
              max: widget.createdTodos != 0
                  ? widget.createdTodos.toDouble()
                  : 1,
              initialValue: widget.completedTodos.toDouble(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.task.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingInfo(BuildContext context, ColorScheme colorScheme) {
    final isCompleted =
        widget.createdTodos > 0 && widget.completedTodos == widget.createdTodos;
    final taskColor = Color(widget.task.taskColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.completedTodos}/${widget.createdTodos}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (isCompleted) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: taskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: taskColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(IconsaxPlusBold.tick_circle, size: 14, color: taskColor),
                const SizedBox(width: 4),
                Text(
                  'completed'.tr,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      11,
                    ),
                    fontWeight: FontWeight.w600,
                    color: taskColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
