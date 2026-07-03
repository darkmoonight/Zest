import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/i18n/tr.dart';

/// Widget that settings tile.
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

  /// The leading.
  final Widget leading;

  /// The title.
  final String? title;

  /// The title text.
  final String? titleText;

  /// The subtitle.
  final String? subtitle;

  /// The subtitle text.
  final String? subtitleText;

  /// The value.
  final String? value;

  /// The trailing.
  final Widget? trailing;

  /// The on tap.
  final VoidCallback? onTap;

  /// The title color.
  final Color? titleColor;

  /// The icon color.
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
