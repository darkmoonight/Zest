import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/settings/app_settings_state.dart';
import 'package:zest/features/statistics/application/statistics_provider.dart';
import 'package:zest/features/statistics/presentation/models/statistics_data.dart';
import 'package:zest/features/statistics/presentation/view/statistics.dart';
import 'package:zest/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.enUs);
  });

  testWidgets('shows ListEmpty when there are no todos', (tester) async {
    final emptyData = StatisticsData(
      totalTodos: 0,
      completedTodos: 0,
      completionRate: 0,
      completionHeatmap: const {},
      todayCompleted: 0,
      weekCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      weeklyProgress: const {},
      hourlyProgress: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsProvider.overrideWith((ref) async => emptyData),
          appSettingsProvider.overrideWith(
            () => _FixedAppSettingsNotifier(
              const AppSettingsState(isImage: false),
            ),
          ),
        ],
        child: const MaterialApp(home: StatisticsPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Complete todos to see your stats'), findsOneWidget);
  });
}

class _FixedAppSettingsNotifier extends AppSettingsNotifier {
  _FixedAppSettingsNotifier(this._state);

  final AppSettingsState _state;

  @override
  AppSettingsState build() => _state;
}
