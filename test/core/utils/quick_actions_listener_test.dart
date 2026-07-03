import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/utils/quick_actions_listener.dart';

void main() {
  testWidgets('QuickActionsListener mounts inside ProviderScope', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: QuickActionsListener(child: const Scaffold(body: Text('Home'))),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(QuickActionsListener), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
