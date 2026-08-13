import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/utils/color_extensions.dart';

void main() {
  test('toHexString returns uppercase RGB hex', () {
    expect(const Color(0xFF112233).toHexString(), '#112233');
    expect(Colors.white.toHexString(), '#FFFFFF');
    expect(Colors.black.toHexString(), '#000000');
  });
}
