import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/utils/scroll_fab_handler.dart';

void main() {
  tearDown(ScrollFabHandler.dispose);

  testWidgets('hides FAB when scrolling reverse after debounce', (
    tester,
  ) async {
    var visible = true;

    await tester.pumpWidget(
      MaterialApp(
        home: _ScrollFabHarness(
          onVisibilityChanged: (value) => visible = value,
        ),
      ),
    );
    await tester.pump();

    final harness = tester.state<_ScrollFabHarnessState>(
      find.byType(_ScrollFabHarness),
    );
    final context = tester.element(find.byType(_ScrollFabHarness));
    ScrollFabHandler.handleScrollFabVisibility(
      notification: UserScrollNotification(
        direction: ScrollDirection.reverse,
        metrics: _testMetrics(),
        context: context,
      ),
      tabController: harness.tabController,
      setFabVisibility: (value) => visible = value,
    );

    await tester.pump(const Duration(milliseconds: 200));
    expect(visible, isFalse);
  });

  testWidgets('shows FAB when scrolling forward after debounce', (
    tester,
  ) async {
    var visible = false;

    await tester.pumpWidget(
      MaterialApp(
        home: _ScrollFabHarness(
          onVisibilityChanged: (value) => visible = value,
        ),
      ),
    );
    await tester.pump();

    final harness = tester.state<_ScrollFabHarnessState>(
      find.byType(_ScrollFabHarness),
    );
    final context = tester.element(find.byType(_ScrollFabHarness));
    ScrollFabHandler.handleScrollFabVisibility(
      notification: UserScrollNotification(
        direction: ScrollDirection.forward,
        metrics: _testMetrics(),
        context: context,
      ),
      tabController: harness.tabController,
      setFabVisibility: (value) => visible = value,
    );

    await tester.pump(const Duration(milliseconds: 200));
    expect(visible, isTrue);
  });

  testWidgets('hides FAB on configured tab index', (tester) async {
    var visible = true;

    await tester.pumpWidget(
      MaterialApp(
        home: _ScrollFabHarness(
          initialTabIndex: 1,
          onVisibilityChanged: (value) => visible = value,
        ),
      ),
    );
    await tester.pump();

    final harness = tester.state<_ScrollFabHarnessState>(
      find.byType(_ScrollFabHarness),
    );
    final context = tester.element(find.byType(_ScrollFabHarness));
    ScrollFabHandler.handleScrollFabVisibility(
      notification: UserScrollNotification(
        direction: ScrollDirection.forward,
        metrics: _testMetrics(),
        context: context,
      ),
      tabController: harness.tabController,
      setFabVisibility: (value) => visible = value,
      hideFabOnTabIndex: 1,
    );

    await tester.pump(const Duration(milliseconds: 200));
    expect(visible, isFalse);
  });
}

FixedScrollMetrics _testMetrics() {
  return FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: 100,
    pixels: 0,
    viewportDimension: 100,
    devicePixelRatio: 1,
    axisDirection: AxisDirection.down,
  );
}

class _ScrollFabHarness extends StatefulWidget {
  const _ScrollFabHarness({
    required this.onVisibilityChanged,
    this.initialTabIndex = 0,
  });

  final ValueChanged<bool> onVisibilityChanged;
  final int initialTabIndex;

  @override
  State<_ScrollFabHarness> createState() => _ScrollFabHarnessState();
}

class _ScrollFabHarnessState extends State<_ScrollFabHarness>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
