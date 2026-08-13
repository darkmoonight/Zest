import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/text_form.dart';
import 'package:zest/i18n/tr.dart';

/// Search field sliver shared by todo list screens.
class TodosSearchSliver extends StatelessWidget {
  /// Creates a todo search field inside a [SliverToBoxAdapter].
  const TodosSearchSliver({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  /// Text controller bound to the search field.
  final TextEditingController controller;

  /// Called when the query changes.
  final ValueChanged<String> onChanged;

  /// Clears the search field and filter.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return SliverToBoxAdapter(
      child: MyTextForm(
        labelText: 'searchTodo'.tr,
        variant: TextFieldVariant.card,
        type: TextInputType.text,
        icon: Icon(
          IconsaxPlusLinear.search_normal_1,
          size: AppConstants.iconSizeMedium,
          color: colorScheme.onSurfaceVariant,
        ),
        controller: controller,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile
              ? AppConstants.spacingS + 2
              : AppConstants.spacingL,
          vertical: isMobile
              ? AppConstants.spacingXS + 1
              : AppConstants.spacingS,
        ),
        onChanged: onChanged,
        iconButton: controller.text.isNotEmpty
            ? IconButton(
                onPressed: onClear,
                icon: Icon(
                  IconsaxPlusLinear.close_circle,
                  color: colorScheme.onSurfaceVariant,
                  size: AppConstants.iconSizeMedium,
                ),
              )
            : null,
      ),
    );
  }
}
