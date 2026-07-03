import 'package:flutter_test/flutter_test.dart';
import 'package:zest/features/shell/application/fab_notifier.dart';

import '../../helpers/provider_overrides.dart';

void main() {
  group('FabNotifier', () {
    test('starts visible', () {
      final (notifier, container) = createFabTestScope();
      addTearDown(container.dispose);

      expect(container.read(fabNotifierProvider).isVisible, isTrue);
      expect(notifier, isNotNull);
    });

    test('setVisibility updates state', () {
      final (notifier, container) = createFabTestScope();
      addTearDown(container.dispose);

      notifier.setVisibility(false);
      expect(container.read(fabNotifierProvider).isVisible, isFalse);

      notifier.setVisibility(true);
      expect(container.read(fabNotifierProvider).isVisible, isTrue);
    });

    test('setVisibility ignores redundant updates', () {
      final (notifier, container) = createFabTestScope();
      addTearDown(container.dispose);

      final before = container.read(fabNotifierProvider);
      notifier.setVisibility(true);
      expect(identical(before, container.read(fabNotifierProvider)), isTrue);
    });
  });
}
