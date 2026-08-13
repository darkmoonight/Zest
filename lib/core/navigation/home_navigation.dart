import 'package:material_ui/material_ui.dart';
import 'package:zest/core/navigation/home_screen_key.dart';

/// Pops nested routes back to the home root before switching tabs.
void popToHomeRoot(BuildContext context) {
  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}

/// Runs [action] once [homeScreenKey] or [fallback] has [MaterialLocalizations].
void whenHomeContextReady({
  required BuildContext fallback,
  required void Function(BuildContext context) action,
}) {
  final context = homeScreenKey.currentContext ?? fallback;
  if (!context.mounted) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => whenHomeContextReady(fallback: fallback, action: action),
    );
    return;
  }

  final hasMaterialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) !=
      null;
  if (!hasMaterialLocalizations) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => whenHomeContextReady(fallback: fallback, action: action),
    );
    return;
  }

  action(context);
}
