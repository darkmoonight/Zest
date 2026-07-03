import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/utils/navigation_helper.dart';

/// Icon button that navigates back using [NavigationHelper].
class AppBackButton extends StatelessWidget {
  /// Creates an app back button.
  const AppBackButton({super.key});

  @override
  /// Builds the back navigation icon button.
  Widget build(BuildContext context) => IconButton(
    onPressed: () => NavigationHelper.back(context),
    icon: const Icon(IconsaxPlusLinear.arrow_left_3, size: 20),
  );
}
