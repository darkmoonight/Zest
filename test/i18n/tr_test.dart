import 'package:flutter_test/flutter_test.dart';
import 'package:zest/i18n/tr.dart';

void main() {
  group('toSlangKey', () {
    test('passes through snake_case keys', () {
      expect(toSlangKey('snooze_duration'), 'snooze_duration');
    });

    test('passes through lowercase keys', () {
      expect(toSlangKey('snooze'), 'snooze');
    });

    test('converts camelCase to snake_case', () {
      expect(toSlangKey('activityHeatmap'), 'activity_heatmap');
      expect(toSlangKey('markAsDone'), 'mark_as_done');
    });

    test('maps numeric slang keys', () {
      expect(toSlangKey('12'), 'k_12');
      expect(toSlangKey('24'), 'k_24');
    });
  });

  group('trDynamic', () {
    test('returns key when translation is missing', () {
      expect(trDynamic('nonexistentKey_xyz'), 'nonexistentKey_xyz');
    });
  });
}
