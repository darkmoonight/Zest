import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/utils/string_utils.dart';

void main() {
  group('capitalizeFirst', () {
    test('capitalizes the first character', () {
      expect(capitalizeFirst('monday'), 'Monday');
    });

    test('returns empty string unchanged', () {
      expect(capitalizeFirst(''), '');
    });

    test('leaves already capitalized strings as-is except first char', () {
      expect(capitalizeFirst('hello'), 'Hello');
    });
  });
}
