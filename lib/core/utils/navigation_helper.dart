import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/navigation/app_router.dart';
import 'package:zest/core/utils/responsive_utils.dart';

/// Thin wrappers around common navigation and modal presentation patterns.
class NavigationHelper {
  /// Pushes [page] with a bottom-to-top slide transition.
  static Future<T?>? toDownToUp<T>(
    BuildContext context,
    Widget Function() page,
  ) => context.pushRouteUp<T>(page());

  /// Pops the innermost route: dialog/bottom sheet first, then GoRouter.
  static void back<T>(BuildContext context, {T? result}) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(result);
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop(result);
    }
  }

  /// Presents [child] as a modal bottom sheet.
  static Future<T?> showModalSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => child,
    );
  }

  /// Presents [child] as a dialog.
  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => child,
  );

  /// Create/edit form presentation: bottom sheet on phone, dialog on tablet+.
  ///
  /// Prefer this over raw [showModalBottomSheet] for TasksAction / TodosAction /
  /// TodosTransfer so desktop gets a centered max-width dialog.
  static Future<T?> showFormModal<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool barrierDismissible = true,
  }) {
    if (ResponsiveUtils.useDialogForForms(context)) {
      return showAppDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible && isDismissible,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingXL,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxModalWidth,
            ),
            child: child,
          ),
        ),
      );
    }

    return showModalSheet<T>(
      context: context,
      child: child,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }
}
