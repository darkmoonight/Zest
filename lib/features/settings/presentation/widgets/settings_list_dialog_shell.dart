import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/features/settings/presentation/widgets/settings_card_shape.dart';
import 'package:zest/i18n/tr.dart';

/// Widget that settings list dialog shell.
class SettingsListDialogShell extends StatelessWidget {
  /// Creates a [SettingsListDialogShell].
  const SettingsListDialogShell({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.maxHeightFraction = 0.7,
  });

  /// The header.
  final Widget? header;

  /// The body.
  final Widget body;

  /// The footer.
  final Widget? footer;

  /// The max height fraction.
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

/// Widget that settings list dialog header.
class SettingsListDialogHeader extends StatelessWidget {
  /// Creates a [SettingsListDialogHeader].
  const SettingsListDialogHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  /// The title.
  final String title;

  /// The icon.
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

/// Widget that settings list dialog dismiss action.
class SettingsListDialogDismissAction extends StatelessWidget {
  /// Creates a [SettingsListDialogDismissAction].
  const SettingsListDialogDismissAction({super.key, this.labelKey = 'close'});

  /// The label key.
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

/// Widget that settings dialog list tile.
class SettingsDialogListTile extends StatelessWidget {
  /// Creates a [SettingsDialogListTile].
  const SettingsDialogListTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.leading,
  });

  /// The title.
  final String title;

  /// The is selected.
  final bool isSelected;

  /// The on tap.
  final VoidCallback onTap;

  /// The leading.
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

/// Widget that settings list dialog actions footer.
class SettingsListDialogActionsFooter extends StatelessWidget {
  /// Creates a [SettingsListDialogActionsFooter].
  const SettingsListDialogActionsFooter({super.key, required this.child});

  /// The child.
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

/// Widget that settings list dialog tonal button.
class SettingsListDialogTonalButton extends StatelessWidget {
  /// Creates a [SettingsListDialogTonalButton].
  const SettingsListDialogTonalButton({
    super.key,
    required this.labelKey,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The label key.
  final String labelKey;

  /// The on pressed.
  final VoidCallback onPressed;

  /// The background color.
  final Color? backgroundColor;

  /// The foreground color.
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
