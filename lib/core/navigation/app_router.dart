import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/navigation/app_routes.dart';
import 'package:zest/core/navigation/route_transitions.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/onboarding/presentation/onboarding_screen.dart';
import 'package:zest/core/utils/quick_actions_listener.dart';
import 'package:zest/features/shell/presentation/home_screen.dart';

/// Forces [appRouterProvider] to re-evaluate redirects from a [WidgetRef].
void refreshAppRouter(WidgetRef ref) {
  ref.read(_routerRefreshProvider).value++;
}

/// Forces [appRouterProvider] to re-evaluate redirects from a [Ref].
void refreshAppRouterFromRef(Ref ref) {
  ref.read(_routerRefreshProvider).value++;
}

/// Notifier that triggers [appRouterProvider] redirect re-evaluation.
final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier(0);
  ref.onDispose(notifier.dispose);
  ref.listen(settingsProvider, (_, _) => notifier.value++);
  return notifier;
});

/// App-wide [GoRouter] with onboarding guard.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_routerRefreshProvider);

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final settings = container.read(settingsProvider);
      return resolveAppRedirect(settings, state.uri.path);
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => HomeScreen(key: homeScreenKey),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnBoarding(),
      ),
    ],
  );
});

/// Returns a redirect when onboarding is incomplete or should be skipped.
String? resolveAppRedirect(Settings settings, String path) {
  if (!settings.onboard) {
    return path == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }
  if (path == AppRoutes.onboarding) {
    return AppRoutes.home;
  }
  return null;
}

/// Convenience navigation helpers using slide transitions on the root navigator.
extension GoRouterNavigation on BuildContext {
  /// Pushes [page] with a vertical slide transition.
  Future<T?> pushRouteUp<T>(Widget page) => Navigator.of(
    this,
  ).push<T>(slideRoute<T>(child: page, begin: const Offset(0, 1)));
}
