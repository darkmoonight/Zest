import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/utils/text_utils.dart';

void main() {
  group('TextUtils.trimText', () {
    test('collapses repeated spaces within a line', () {
      expect(TextUtils.trimText('hello   world'), 'hello world');
    });

    test('trims tabs and spaces on each line', () {
      expect(TextUtils.trimText('  hello \t world  '), 'hello world');
    });

    test('preserves blank lines between content lines', () {
      expect(
        TextUtils.trimText('\n\nfirst line\n\nsecond line\n\n'),
        'first line\n\nsecond line',
      );
    });

    test('returns empty string for whitespace-only input', () {
      expect(TextUtils.trimText('   \n  \n  '), '');
    });
  });
}
