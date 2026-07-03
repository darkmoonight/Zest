import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/progress_calculator.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/metadata_chip.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/tasks/presentation/widgets/circular_progress_widget.dart';
import 'package:zest/i18n/tr.dart';

/// Card widget displaying a task with progress and selection state.
class TaskCard extends StatefulWidget {
  /// Creates a [TaskCard].
  const TaskCard({
    super.key,
    required this.task,
    required this.createdTodos,
    required this.completedTodos,
    required this.percent,
    required this.isSelected,
    required this.onDoubleTap,
    required this.onTap,
  });

  /// The task.
  final Tasks task;

  /// The created todos.
  final int createdTodos;

  /// The completed todos.
  final int completedTodos;

  /// The percent.
  final String percent;

  /// The is selected.
  final bool isSelected;

  /// The on double tap.
  final VoidCallback onDoubleTap;

  /// The on tap.
  final VoidCallback onTap;

  @override
  /// Creates the state for this widget.
  State<TaskCard> createState() => _TaskCardState();
}

/// Widget that task card state.
class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  /// The animation controller.
  late final AnimationController _animationController;

  /// The scale animation.
  late final Animation<double> _scaleAnimation;

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
  void _handleTapDown(TapDownDetails details) => _animationController.forward();

  /// Handle tap up.
  void _handleTapUp(TapUpDetails details) => _animationController.reverse();

  /// Handle tap cancel.
  void _handleTapCancel() => _animationController.reverse();

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    final progress = ProgressCalculator(
      total: widget.createdTodos,
      completed: widget.completedTodos,
    );
    final taskColor = Color(widget.task.taskColor);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.spacingS : AppConstants.spacingM,
        vertical: AppConstants.spacingXS,
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: _buildCardWithSelection(
            context,
            isMobile,
            progress,
            taskColor,
          ),
        ),
      ),
    );
  }

  /// Builds the card with selection widget.
  Widget _buildCardWithSelection(
    BuildContext context,
    bool isMobile,
    ProgressCalculator progress,
    Color taskColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = widget.isSelected;

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
        child: _buildCardContent(
          context,
          colorScheme,
          isMobile,
          isSelected,
          progress,
          taskColor,
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
    ProgressCalculator progress,
    Color taskColor,
  ) {
    return AnimatedPadding(
      duration: AppConstants.shortAnimation,
      padding: EdgeInsets.all(
        isMobile
            ? AppConstants.spacingM
            : (isSelected ? AppConstants.spacingL + 2 : AppConstants.spacingL),
      ),
      child: Row(
        children: [
          _buildProgressCircle(taskColor),
          SizedBox(
            width: isMobile ? AppConstants.spacingS : AppConstants.spacingM + 2,
          ),
          Expanded(child: _buildContent(context, colorScheme)),
          SizedBox(
            width: isMobile ? AppConstants.spacingS : AppConstants.spacingS + 2,
          ),
          _buildTrailingInfo(context, colorScheme, progress, taskColor),
        ],
      ),
    );
  }

  /// Builds the progress circle widget.
  Widget _buildProgressCircle(Color taskColor) {
    return CircularProgressWidget(
      total: widget.createdTodos,
      completed: widget.completedTodos,
      progressColor: taskColor,
      showCompletedIcon: true,
    );
  }

  /// Builds the content widget.
  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.task.description.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            widget.task.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Builds the trailing info widget.
  Widget _buildTrailingInfo(
    BuildContext context,
    ColorScheme colorScheme,
    ProgressCalculator progress,
    Color taskColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildTaskCounter(context, colorScheme),
        if (progress.isComplete) ...[
          SizedBox(height: AppConstants.spacingXS + 1),
          _buildCompletedBadge(context, taskColor),
        ],
      ],
    );
  }

  /// Builds the task counter widget.
  Widget _buildTaskCounter(BuildContext context, ColorScheme colorScheme) {
    final hasNoTodos = widget.createdTodos == 0;
    final allComplete =
        widget.createdTodos > 0 && widget.completedTodos == widget.createdTodos;
    final shouldDim = hasNoTodos || allComplete;

    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS + 2,
        vertical: AppConstants.spacingXS + 1,
      ),
      decoration: BoxDecoration(
        color: shouldDim
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall + 2),
      ),
      child: Text(
        '${widget.completedTodos}/${widget.createdTodos}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: shouldDim
              ? colorScheme.onSurface.withValues(alpha: 0.4)
              : colorScheme.onSurface,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  /// Builds the completed badge widget.
  Widget _buildCompletedBadge(BuildContext context, Color taskColor) {
    return MetadataChip(
      accentColor: taskColor,
      backgroundAlpha: 0.15,
      borderAlpha: 0.3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IconsaxPlusBold.tick_circle, size: 12, color: taskColor),
          const SizedBox(width: 3),
          Text(
            'completed'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
              fontWeight: FontWeight.w600,
              color: taskColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
