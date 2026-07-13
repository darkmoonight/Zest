import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/features/settings/presentation/widgets/settings_card_shape.dart';
import 'package:zest/i18n/tr.dart';

/// Shared card dialog layout for settings pickers with optional header and footer.
class SettingsListDialogShell extends StatelessWidget {
  /// Creates a [SettingsListDialogShell].
  const SettingsListDialogShell({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.maxHeightFraction = 0.7,
  });

  /// Optional widget shown above the scrollable body.
  final Widget? header;

  /// Main scrollable content of the dialog.
  final Widget body;

  /// Optional widget pinned below the body, typically action buttons.
  final Widget? footer;

  /// Maximum dialog height as a fraction of screen height.
  final double maxHeightFraction;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : AppConstants.maxDialogWidth,
          maxHeight: MediaQuery.of(context).size.height * maxHeightFraction,
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusXXLarge,
            ),
            side: BorderSide(
              color: SettingsCardShape.settingsDividerColor(colorScheme),
              width: AppConstants.borderWidthThin,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?header,
              Flexible(child: body),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

/// Title row with icon for settings list dialogs.
class SettingsListDialogHeader extends StatelessWidget {
  /// Creates a [SettingsListDialogHeader].
  const SettingsListDialogHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  /// Dialog title text.
  final String title;

  /// Icon displayed beside the title.
  final IconData icon;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXXL),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Icon(
              icon,
              size: AppConstants.iconSizeLarge,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer with a single close button that pops the dialog.
class SettingsListDialogDismissAction extends StatelessWidget {
  /// Creates a [SettingsListDialogDismissAction].
  const SettingsListDialogDismissAction({super.key, this.labelKey = 'close'});

  /// Translation key for the dismiss button label.
  final String labelKey;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) => SettingsListDialogActionsFooter(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SettingsListDialogTonalButton(
          labelKey: labelKey,
          onPressed: () => NavigationHelper.back(context),
        ),
      ],
    ),
  );
}

/// Selectable list row with optional leading widget and checkmark.
class SettingsDialogListTile extends StatelessWidget {
  /// Creates a [SettingsDialogListTile].
  const SettingsDialogListTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.leading,
  });

  /// Row label text.
  final String title;

  /// Whether this option is currently selected.
  final bool isSelected;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  /// Optional widget shown before the title.
  final Widget? leading;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingXXL,
        vertical: AppConstants.spacingXS,
      ),
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
        ),
      ),
      trailing: isSelected
          ? Icon(
              IconsaxPlusBold.tick_circle,
              color: colorScheme.primary,
              size: AppConstants.iconSizeMedium,
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Padded footer container for dialog action buttons.
class SettingsListDialogActionsFooter extends StatelessWidget {
  /// Creates a [SettingsListDialogActionsFooter].
  const SettingsListDialogActionsFooter({super.key, required this.child});

  /// Action widgets laid out in the footer.
  final Widget child;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppConstants.spacingXXL,
      AppConstants.spacingS,
      AppConstants.spacingXXL,
      AppConstants.spacingXXL,
    ),
    child: child,
  );
}

/// Tonal filled button using a translation key for its label.
class SettingsListDialogTonalButton extends StatelessWidget {
  /// Creates a [SettingsListDialogTonalButton].
  const SettingsListDialogTonalButton({
    super.key,
    required this.labelKey,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Translation key for the button label.
  final String labelKey;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// Optional override for the button background.
  final Color? backgroundColor;

  /// Optional override for the button text and icon color.
  final Color? foregroundColor;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXL,
          vertical: AppConstants.spacingM,
        ),
        backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
        foregroundColor: foregroundColor ?? colorScheme.onPrimaryContainer,
      ),
      child: Text(
        labelKey.tr,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
