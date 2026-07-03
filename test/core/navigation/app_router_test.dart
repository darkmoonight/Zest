import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/navigation/app_router.dart';
import 'package:zest/core/navigation/app_routes.dart';
import 'package:zest/data/models/db.dart';

void main() {
  group('resolveAppRedirect', () {
    test('redirects to onboarding when not completed', () {
      final settings = Settings()..onboard = false;

      expect(
        resolveAppRedirect(settings, AppRoutes.home),
        AppRoutes.onboarding,
      );
      expect(resolveAppRedirect(settings, AppRoutes.onboarding), isNull);
    });

    test('redirects away from onboarding when already completed', () {
      final settings = Settings()..onboard = true;

      expect(
        resolveAppRedirect(settings, AppRoutes.onboarding),
        AppRoutes.home,
      );
      expect(resolveAppRedirect(settings, AppRoutes.home), isNull);
    });
  });
}
