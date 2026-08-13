import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/core/notifications/notification_settings_launcher.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/settings/app_settings_state.dart';
import 'package:zest/features/settings/presentation/view/notification_channels_page.dart';
import 'package:zest/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.enUs);
  });

  group('NotificationSettingsLauncher intents', () {
    test('channelSettingsIntent uses channel settings action and extras', () {
      final intent = NotificationSettingsLauncher.channelSettingsIntent(
        channelId: NotificationChannelIds.high,
        packageName: AppConstants.androidPackageName,
      );

      expect(intent.action, NotificationSettingsLauncher.channelSettingsAction);
      expect(intent.arguments, {
        NotificationSettingsLauncher.extraAppPackage:
            AppConstants.androidPackageName,
        NotificationSettingsLauncher.extraChannelId:
            NotificationChannelIds.high,
      });
    });

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

  group('NotificationChannelsPage', () {
    testWidgets('shows manage tile and all priority channels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWith(
              () => _FixedAppSettingsNotifier(const AppSettingsState()),
            ),
          ],
          child: const MediaQuery(
            data: MediaQueryData(size: Size(390, 844)),
            child: MaterialApp(home: NotificationChannelsPage()),
          ),
        ),
      );

      expect(find.text('Manage app notifications'), findsOneWidget);
      for (final config in allNotificationChannelConfigs) {
        expect(find.text(config.localizedName), findsOneWidget);
        expect(find.text(config.localizedHint), findsOneWidget);
      }
    });
  });
}

class _FixedAppSettingsNotifier extends AppSettingsNotifier {
  _FixedAppSettingsNotifier(this._state);

  final AppSettingsState _state;

  @override
  AppSettingsState build() => _state;
}
