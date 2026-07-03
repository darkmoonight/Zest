import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/widgets/sort_menu.dart';
import 'package:zest/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.enUs);
  });

  testWidgets('SortMenu shows archived toggle when configured', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SortMenu(
            currentSortOption: SortOption.none,
            onSortChanged: (_) {},
            showArchived: false,
            onShowArchivedChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SortMenu));
    await tester.pumpAndSettle();

    expect(find.text('Show archived'), findsOneWidget);
  });

  testWidgets('SortMenu hides archived toggle when not configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SortMenu(
            currentSortOption: SortOption.none,
            onSortChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SortMenu));
    await tester.pumpAndSettle();

    expect(find.text('Show archived'), findsNothing);
  });
}
