part of '../tasks_action.dart';

// ==================== Color Picker Dialog ====================
class _ColorPickerDialog extends StatefulWidget {
  /// The initial color.
  final Color initialColor;

  /// The color scheme.
  final ColorScheme colorScheme;

  /// The is mobile.
  final bool isMobile;

  /// Creates a [_ColorPickerDialog].
  const _ColorPickerDialog({
    required this.initialColor,
    required this.colorScheme,
    required this.isMobile,
  });

  @override
  /// Creates the state for this widget.
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog>
    with SingleTickerProviderStateMixin {
  /// The temp color.
  late Color _tempColor;

  /// The animation controller.
  late AnimationController _animationController;

  /// The scale animation.
  late Animation<double> _scaleAnimation;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _tempColor = widget.initialColor;
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: widget.isMobile
                ? double.infinity
                : AppConstants.maxModalWidth,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusXXLarge,
              ),
              side: BorderSide(
                color: widget.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: AppConstants.borderWidthThin,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: widget.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                Flexible(child: _buildColorPicker()),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header widget.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.borderRadiusXLarge),
      child: Row(
        children: [
          IconContainer(
            icon: IconsaxPlusBold.colorfilter,
            size: 44,
            iconSize: AppConstants.iconSizeLarge,
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'selectColor'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS / 2),
                Text(
                  'selectColorHint'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.colorScheme.onSurfaceVariant,
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

  /// Builds the color picker widget.
  Widget _buildColorPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.borderRadiusXLarge),
      child: ColorPicker(
        color: _tempColor,
        onColorChanged: (color) => setState(() => _tempColor = color),
        borderRadius: AppConstants.borderRadiusMedium,
        padding: EdgeInsets.zero,
        spacing: AppConstants.spacingS,
        runSpacing: AppConstants.spacingS,
        wheelDiameter: widget.isMobile ? 180 : 220,
        wheelWidth: AppConstants.spacingL,
        wheelSquarePadding: AppConstants.spacingS,
        wheelSquareBorderRadius: AppConstants.spacingS,
        wheelHasBorder: false,
        enableShadesSelection: false,
        enableTonalPalette: true,
        tonalColorSameSize: true,
        enableOpacity: false,
        actionButtons: const ColorPickerActionButtons(
          visualDensity: VisualDensity.compact,
          dialogActionButtons: false,
        ),
        pickersEnabled: const {
          ColorPickerType.accent: false,
          ColorPickerType.primary: true,
          ColorPickerType.wheel: false,
          ColorPickerType.both: false,
          ColorPickerType.bw: false,
          ColorPickerType.custom: false,
        },
      ),
    );
  }

  /// Builds the actions widget.
  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: AppConstants.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => NavigationHelper.back(context),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppConstants.spacingS),
          FilledButton(
            onPressed: () => NavigationHelper.back(context, result: _tempColor),
            child: Text(
              'select'.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
