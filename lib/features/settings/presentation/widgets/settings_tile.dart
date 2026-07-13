import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/i18n/tr.dart';

/// Standard list row used on settings screens for a single preference or action.
class SettingsTile extends StatelessWidget {
  /// Creates a [SettingsTile].
  const SettingsTile({
    super.key,
    required this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.value,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  /// Icon or widget shown at the start of the row.
  final Widget leading;

  /// Localized title key passed to [tr].
  final String? title;

  /// Pre-translated title text when no localization key is used.
  final String? titleText;

  /// Localized subtitle key passed to [tr].
  final String? subtitle;

  /// Pre-translated subtitle text when no localization key is used.
  final String? subtitleText;

  /// Current value shown before the trailing chevron.
  final String? value;

  /// Optional widget replacing the default trailing chevron or value row.
  final Widget? trailing;

  /// Called when the row is tapped; also controls chevron visibility.
  final VoidCallback? onTap;

  /// Override color for the title text.
  final Color? titleColor;

  /// Override color for the leading icon.
  final Color? iconColor;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    assert(
      title != null || titleText != null,
      'SettingsTile needs title or titleText',
    );
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingXS,
      ),
      leading: IconTheme(
        data: IconThemeData(
          color: iconColor ?? titleColor ?? colorScheme.onSurfaceVariant,
          size: 24,
        ),
        child: leading,
      ),
      title: Text(
        titleText ?? title!.tr,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: titleColor ?? colorScheme.onSurface,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
        ),
      ),
      subtitle: _buildSubtitle(context, colorScheme),
      trailing: trailing ?? _buildDefaultTrailing(context, colorScheme),
    );
  }

  /// Builds the subtitle widget.
  Widget? _buildSubtitle(BuildContext context, ColorScheme colorScheme) {
    final text = subtitleText ?? subtitle?.tr;
    if (text == null) return null;

    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
      ),
    );
  }

  /// Builds the default trailing widget.
  Widget? _buildDefaultTrailing(BuildContext context, ColorScheme colorScheme) {
    if (value != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.35,
            ),
            child: Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Icon(
            IconsaxPlusLinear.arrow_right_3,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      );
    }

    if (onTap != null) {
      return Icon(
        IconsaxPlusLinear.arrow_right_3,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return null;
  }
}
