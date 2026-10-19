import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/navigation/app_router.dart';
import 'package:zest/core/navigation/app_routes.dart';
import 'package:zest/domain/entities/app_settings.dart';

void main() {
  group('resolveAppRedirect', () {
    test('redirects to onboarding when not completed', () {
      const settings = AppSettings(onboard: false);

      expect(
        resolveAppRedirect(settings, AppRoutes.home),
        AppRoutes.onboarding,
      );
      expect(resolveAppRedirect(settings, AppRoutes.onboarding), isNull);
    });

    test('redirects away from onboarding when already completed', () {
      const settings = AppSettings(onboard: true);

      expect(
        resolveAppRedirect(settings, AppRoutes.onboarding),
        AppRoutes.home,
      );
      expect(resolveAppRedirect(settings, AppRoutes.home), isNull);
    });
  });
}
