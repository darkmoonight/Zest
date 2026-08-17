import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/notifications/notification_settings_launcher.dart';

void main() {
  group('NotificationSettingsLauncher intents', () {
    test('appSettingsIntent uses app notification settings action', () {
      final intent = NotificationSettingsLauncher.appSettingsIntent(
        packageName: AppConstants.androidPackageName,
      );

      expect(intent.action, NotificationSettingsLauncher.appSettingsAction);
      expect(intent.arguments, {
        NotificationSettingsLauncher.extraAppPackage:
            AppConstants.androidPackageName,
      });
    });
  });
}
