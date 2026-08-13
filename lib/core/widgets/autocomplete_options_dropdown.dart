import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Material dropdown list used by [RawAutocomplete] option views.
class AutocompleteOptionsDropdown<T extends Object> extends StatelessWidget {
  /// Creates an options dropdown aligned and sized for autocomplete overlays.
  const AutocompleteOptionsDropdown({
    super.key,
    required this.options,
    required this.onSelected,
    required this.itemBuilder,
    this.alignment = Alignment.topCenter,
    this.margin = const EdgeInsets.only(top: AppConstants.spacingXS),
    this.maxHeight = 250,
  });

  /// Options currently offered by the autocomplete field.
  final Iterable<T> options;

  /// Called when the user taps an option.
  final AutocompleteOnSelected<T> onSelected;

  /// Builds the row content for each option (inside the tap target padding).
  final Widget Function(BuildContext context, T option) itemBuilder;

  /// Where the dropdown anchors relative to the field.
  final AlignmentGeometry alignment;

  /// Outer padding around the material surface.
  final EdgeInsetsGeometry margin;

  /// Maximum height before the list scrolls.
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: margin,
      child: Align(
        alignment: alignment,
        child: Material(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          elevation: AppConstants.elevationHigh,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingXS,
              ),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return InkWell(
                  onTap: () => onSelected(option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                      vertical: AppConstants.spacingM,
                    ),
                    child: itemBuilder(context, option),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular color swatch used next to category autocomplete options.
class AutocompleteColorSwatch extends StatelessWidget {
  /// Creates a 20dp circle filled with [color].
  const AutocompleteColorSwatch({super.key, required this.color});

  /// Fill color for the swatch.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: AppConstants.borderWidthThin,
        ),
      ),
    );
  }
}
