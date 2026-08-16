import 'package:material_ui/material_ui.dart';
import 'package:zest/core/navigation/home_screen_key.dart';

/// Default max post-frame retries when waiting for a navigable home context.
const kWhenHomeContextReadyMaxAttempts = 120;

/// Pops nested routes back to the home root before switching tabs.
void popToHomeRoot(BuildContext context) {
  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}

/// Runs [action] once [homeScreenKey] has a mounted context with
/// [MaterialLocalizations].
///
/// Retries are capped at [maxAttempts] so onboarding / pre-Material ancestors
/// cannot spin forever. Prefer [homeScreenKey] over [fallback] — listeners often
/// sit above [MaterialApp] and lack localizations.
void whenHomeContextReady({
  required BuildContext fallback,
  required void Function(BuildContext context) action,
  int maxAttempts = kWhenHomeContextReadyMaxAttempts,
  int attempt = 0,
  bool Function()? shouldContinue,
}) {
  if (shouldContinue != null && !shouldContinue()) {
    return;
  }

  final homeContext = homeScreenKey.currentContext;
  if (homeContext != null && homeContext.mounted) {
    final hasMaterialLocalizations =
        Localizations.of<MaterialLocalizations>(
          homeContext,
          MaterialLocalizations,
        ) !=
        null;
    if (hasMaterialLocalizations) {
      action(homeContext);
      return;
    }
  }

  if (attempt >= maxAttempts) {
    debugPrint(
      'whenHomeContextReady: gave up after $maxAttempts attempts '
      '(home mounted=${homeContext?.mounted})',
    );
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback(
    (_) => whenHomeContextReady(
      fallback: fallback,
      action: action,
      maxAttempts: maxAttempts,
      attempt: attempt + 1,
      shouldContinue: shouldContinue,
    ),
  );
}
