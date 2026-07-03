import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/settings/app_settings_state.dart';
import 'package:zest/core/widgets/list_empty.dart';

void main() {
  Widget buildSubject({
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    bool isImage = false,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith(
          () => _FixedAppSettingsNotifier(AppSettingsState(isImage: isImage)),
        ),
      ],
      child: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(
          home: Scaffold(
            body: ListEmpty(
              img: 'assets/images/Task.png',
              text: 'Empty title',
              subtitle: subtitle,
              icon: icon,
              iconColor: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows title and subtitle', (tester) async {
    await tester.pumpWidget(buildSubject(subtitle: 'Empty subtitle'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Empty title'), findsOneWidget);
    expect(find.text('Empty subtitle'), findsOneWidget);
  });

  testWidgets('shows icon with custom color', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        icon: IconsaxPlusBold.chart,
        iconColor: Colors.orange,
        isImage: false,
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, IconsaxPlusBold.chart);
    expect(icon.color, Colors.orange);
  });

  testWidgets('applies max width constraint on mobile', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 700));

    final constrainedBoxes = tester.widgetList<ConstrainedBox>(
      find.byType(ConstrainedBox),
    );
    expect(constrainedBoxes.last.constraints.maxWidth, 300);
  });
}

class _FixedAppSettingsNotifier extends AppSettingsNotifier {
  _FixedAppSettingsNotifier(this._state);

  final AppSettingsState _state;

  @override
  AppSettingsState build() => _state;
}
