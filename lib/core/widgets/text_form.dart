import 'package:flutter/material.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';

/// Visual style variants for [MyTextForm].
enum TextFieldVariant {
  /// Outlined border text field.
  outlined,

  /// Filled background without visible border.
  filled,

  /// Text field embedded inside a card container.
  card,
}

/// Reusable text form field with responsive styling and variant support.
class MyTextForm extends StatelessWidget {
  /// Creates a text form field with the given configuration.
  const MyTextForm({
    super.key,
    required this.labelText,
    required this.type,
    required this.icon,
    required this.controller,
    required this.margin,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.validator,
    this.iconButton,
    this.elevation,
    this.focusNode,
    this.maxLine = 1,
    this.autofocus = false,
    this.helperText,
    this.hintText,
    this.variant = TextFieldVariant.outlined,
  });

  /// Label displayed above or inside the field.
  final String labelText;

  /// Keyboard input type for the field.
  final TextInputType type;

  /// Prefix icon shown at the start of the field.
  final Icon icon;

  /// Optional suffix widget, typically an icon button.
  final Widget? iconButton;

  /// Controller for the text field value.
  final TextEditingController controller;

  /// Tap handler used when [readOnly] is true.
  final VoidCallback? onTap;

  /// Called when the field text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onFieldSubmitted;

  /// Outer padding or card margin around the field.
  final EdgeInsets margin;

  /// Optional validator for form submission.
  final String? Function(String?)? validator;

  /// When true, the field cannot be edited directly.
  final bool readOnly;

  /// Card elevation when using the card variant.
  final double? elevation;

  /// Optional focus node for the underlying [TextFormField].
  final FocusNode? focusNode;

  /// Maximum number of lines for multiline input.
  final int? maxLine;

  /// Whether the field should request focus on build.
  final bool autofocus;

  /// Optional helper text below the field.
  final String? helperText;

  /// Optional hint text shown when empty.
  final String? hintText;

  /// Visual variant controlling decoration and container.
  final TextFieldVariant variant;

  @override
  /// Builds the text form field, optionally wrapped in a card.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    if (variant == TextFieldVariant.card ||
        (elevation != null && elevation! > 0)) {
      return Card(
        elevation: elevation,
        margin: margin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: _buildTextFormField(context, colorScheme, isMobile),
      );
    }

    return Padding(
      padding: margin,
      child: _buildTextFormField(context, colorScheme, isMobile),
    );
  }

  /// Builds the underlying [TextFormField] with theme-aware text style.
  Widget _buildTextFormField(
    BuildContext context,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    return TextFormField(
      focusNode: focusNode,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: readOnly ? onTap : null,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      keyboardType: type,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
        color: colorScheme.onSurface,
      ),
      decoration: _buildInputDecoration(context, colorScheme, isMobile),
      validator: validator,
      maxLines: maxLine,
      autofocus: autofocus,
    );
  }

  /// Builds input decoration for the active [variant].
  InputDecoration _buildInputDecoration(
    BuildContext context,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    if (variant == TextFieldVariant.card ||
        (elevation != null && elevation! > 0)) {
      return InputDecoration(
        prefixIcon: icon,
        suffixIcon: iconButton,
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          color: colorScheme.primary,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
        ),
        helperStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
          color: colorScheme.error,
        ),
      );
    }

    if (variant == TextFieldVariant.filled) {
      return InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 6),
          child: IconTheme(
            data: IconThemeData(
              color: colorScheme.onSurfaceVariant,
              size: isMobile ? 18 : 20,
            ),
            child: icon,
          ),
        ),
        suffixIcon: iconButton != null
            ? Padding(
                padding: const EdgeInsets.only(right: 6),
                child: iconButton,
              )
            : null,
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
        ),
        helperStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
          color: colorScheme.error,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 12 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
      );
    }

    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 8, right: 6),
        child: IconTheme(
          data: IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: isMobile ? 18 : 20,
          ),
          child: icon,
        ),
      ),
      suffixIcon: iconButton != null
          ? Padding(padding: const EdgeInsets.only(right: 6), child: iconButton)
          : null,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
      ),
      helperStyle: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
        color: colorScheme.onSurfaceVariant,
      ),
      errorStyle: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
        color: colorScheme.error,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 14,
        vertical: isMobile ? 12 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
    );
  }
}
