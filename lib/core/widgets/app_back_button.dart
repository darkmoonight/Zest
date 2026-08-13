import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/i18n/tr.dart';

/// Standard back navigation icon used across the app.
const IconData appBackButtonIcon = IconsaxPlusLinear.arrow_left_3;

/// Default size for [appBackButtonIcon].
const double appBackButtonIconSize = 20;

/// Icon button that navigates back using [NavigationHelper].
class AppBackButton extends StatelessWidget {
  /// Creates an app back button.
  const AppBackButton({super.key, this.onPressed});

  /// Optional override; defaults to [NavigationHelper.back].
  final VoidCallback? onPressed;

  @override
  /// Builds the back navigation icon button.
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed ?? () => NavigationHelper.back(context),
    tooltip: 'navigateBack'.tr,
    icon: const Icon(appBackButtonIcon, size: appBackButtonIconSize),
  );
}
