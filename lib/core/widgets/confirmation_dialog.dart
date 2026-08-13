import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/i18n/tr.dart';

/// Modal dialog that asks the user to confirm or cancel an action.
class ConfirmationDialog extends StatelessWidget {
  /// Creates a confirmation dialog with customizable actions and styling.
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = IconsaxPlusBold.warning_2,
    this.iconColor,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showCancelButton = true,
  });

  /// Dialog title text (translated via `.tr`).
  final String title;

  /// Dialog body message text (translated via `.tr`).
  final String message;

  /// Icon displayed above the title.
  final IconData icon;

  /// Optional override for the icon color.
  final Color? iconColor;

  /// Optional confirm button label (defaults to `confirm`).
  final String? confirmText;

  /// Optional cancel button label (defaults to `cancel`).
  final String? cancelText;

  /// Callback invoked when the user confirms.
  final VoidCallback? onConfirm;

  /// Callback invoked when the user cancels.
  final VoidCallback? onCancel;

  /// When true, uses error styling for destructive actions.
  final bool isDestructive;

  /// When false, hides the cancel button.
  final bool showCancelButton;

  @override
  /// Builds the confirmation dialog layout with icon, text, and actions.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    final resolvedIconColor =
        iconColor ?? (isDestructive ? colorScheme.error : colorScheme.primary);

    final buttonBgColor = isDestructive
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;

    final buttonTextColor = isDestructive
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : AppConstants.maxDialogWidth,
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusXXLarge,
            ),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: AppConstants.borderWidthThin,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(resolvedIconColor, colorScheme),
                const SizedBox(height: AppConstants.spacingL),
                _buildTitle(context, colorScheme),
                const SizedBox(height: AppConstants.spacingM),
                _buildMessage(context, colorScheme),
                const SizedBox(height: AppConstants.spacingXXL),
                _buildActions(
                  context,
                  colorScheme,
                  buttonBgColor,
                  buttonTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the circular icon container at the top of the dialog.
  Widget _buildIcon(Color resolvedIconColor, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: resolvedIconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: AppConstants.iconSizeXLarge,
        color: resolvedIconColor,
      ),
    );
  }

  /// Builds the centered dialog title text.
  Widget _buildTitle(BuildContext context, ColorScheme colorScheme) {
    return Text(
      title.tr,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the centered dialog message text.
  Widget _buildMessage(BuildContext context, ColorScheme colorScheme) {
    return Text(
      message.tr,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the cancel and confirm action buttons.
  Widget _buildActions(
    BuildContext context,
    ColorScheme colorScheme,
    Color buttonBgColor,
    Color buttonTextColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showCancelButton) ...[
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXL,
                vertical: AppConstants.spacingM,
              ),
            ),
            child: Text(
              (cancelText ?? 'cancel').tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
        ],
        FilledButton.tonal(
          onPressed: () {
            onConfirm?.call();
            NavigationHelper.back(context, result: true);
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXL,
              vertical: AppConstants.spacingM,
            ),
            backgroundColor: buttonBgColor,
            foregroundColor: buttonTextColor,
          ),
          child: Text(
            (confirmText ?? 'confirm').tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows a [ConfirmationDialog] and returns whether the user confirmed.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,

  /// Icon.
  IconData icon = IconsaxPlusBold.warning_2,
  Color? iconColor,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,

  /// Whether is destructive.
  bool isDestructive = false,

  /// Shows cancel button.
  bool showCancelButton = true,
}) async {
  /// Result.
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: isDestructive,
      showCancelButton: showCancelButton,
    ),
  );
  return result ?? false;
}

/// Shows a destructive delete confirmation dialog.
Future<bool> showDeleteConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  VoidCallback? onConfirm,
}) async {
  return showConfirmationDialog(
    context: context,
    title: title,
    message: message,
    icon: IconsaxPlusBold.trash,
    confirmText: 'delete',
    isDestructive: true,
    onConfirm: onConfirm,
  );
}

/// Shows an archive or unarchive confirmation dialog.
Future<bool> showArchiveConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  required bool isUnarchive,
  VoidCallback? onConfirm,
}) async {
  /// Color scheme.
  final colorScheme = Theme.of(context).colorScheme;

  return showConfirmationDialog(
    context: context,
    title: title,
    message: message,
    icon: isUnarchive
        ? IconsaxPlusBold.refresh_left_square
        : IconsaxPlusBold.archive_add,
    iconColor: colorScheme.primary,
    confirmText: isUnarchive ? 'noArchive' : 'archive',
    isDestructive: false,
    onConfirm: onConfirm,
  );
}

/// Shows a confirmation dialog for clearing text input.
Future<bool> showClearTextConfirmation({
  required BuildContext context,
  VoidCallback? onConfirm,
}) async {
  return showConfirmationDialog(
    context: context,
    title: 'clearText',
    message: 'clearTextWarning',
    icon: IconsaxPlusBold.warning_2,
    confirmText: 'delete',
    isDestructive: true,
    onConfirm: onConfirm,
  );
}
