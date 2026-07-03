import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/features/settings/application/package_licenses.dart';

void main() {
  group('licenseParagraphsText', () {
    test('joins paragraph text with blank lines', () {
      final text = licenseParagraphsText(const [
        LicenseParagraph('Line one', 0),
        LicenseParagraph('Line two', 0),
      ]);

      expect(text, 'Line one\n\nLine two');
    });
  });
}
