import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/services/auto_backup_lifecycle_listener.dart';

void main() {
  testWidgets('calls onResumed when app returns to foreground', (tester) async {
    var resumed = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AutoBackupLifecycleListener(
            onResumed: () async {
              resumed = true;
            },
            child: const SizedBox(),
          ),
        ),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(resumed, isTrue);
  });
}
