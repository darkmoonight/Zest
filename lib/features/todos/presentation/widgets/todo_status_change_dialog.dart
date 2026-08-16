import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/i18n/tr.dart';

/// Animated dialog for changing item status with optional bulk subtask actions.
class TodoStatusChangeDialog extends StatefulWidget {
  /// Item whose status is being changed.
  final Todos todo;

  /// Whether the layout is mobile width.
  final bool isMobile;

  /// Called when the user picks a new status.
  final Function(TodoStatus) onStatusChanged;

  /// Marks the item and incomplete children as done.
  final VoidCallback onBulkCompletion;

  /// Marks the item and children as cancelled.
  final VoidCallback onBulkCancellation;

  /// Creates a [TodoStatusChangeDialog].
  const TodoStatusChangeDialog({
    super.key,
    required this.todo,
    required this.isMobile,
    required this.onStatusChanged,
    required this.onBulkCompletion,
    required this.onBulkCancellation,
  });

  @override
  /// Creates the state for this widget.
  State<TodoStatusChangeDialog> createState() => TodoStatusChangeDialogState();
}

class TodoStatusChangeDialogState extends State<TodoStatusChangeDialog>
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
