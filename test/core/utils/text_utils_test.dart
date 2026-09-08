import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zest/core/utils/text_utils.dart';

void main() {
  group('TextUtils.trimController', () {
    test('collapses spaces in controller text', () {
      final controller = TextEditingController(text: 'hello   world');
      TextUtils.trimController(controller);
      expect(controller.text, 'hello world');
    });

    test('trims and collapses mixed whitespace', () {
      final controller = TextEditingController(text: '  hello \t world  ');
      TextUtils.trimController(controller);
      expect(controller.text, 'hello world');
    });

    test('trims empty leading and trailing lines', () {
      final controller = TextEditingController(
        text: '\n\nfirst line\n\nsecond line\n\n',
      );
      TextUtils.trimController(controller);
      expect(controller.text, 'first line\n\nsecond line');
    });

    test('returns empty for whitespace-only input', () {
      final controller = TextEditingController(text: '   \n  \n  ');
      TextUtils.trimController(controller);
      expect(controller.text, '');
    });
  });
}
