import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/utils/progress_calculator.dart';

void main() {
  group('ProgressCalculator', () {
    test('percentage is zero when total is zero', () {
      const calc = ProgressCalculator(total: 0, completed: 0);
      expect(calc.percentage, 0);
      expect(calc.progress, 0.0);
      expect(calc.percentageString, '0');
      expect(calc.isComplete, false);
      expect(calc.remaining, 0);
    });

    test('calculates percentage and progress', () {
      const calc = ProgressCalculator(total: 10, completed: 3);
      expect(calc.percentage, 30);
      expect(calc.progress, closeTo(0.3, 0.001));
      expect(calc.percentageString, '30');
      expect(calc.remaining, 7);
      expect(calc.isComplete, false);
    });

    test('isComplete when all items are done', () {
      const calc = ProgressCalculator(total: 5, completed: 5);
      expect(calc.isComplete, true);
      expect(calc.remaining, 0);
    });

    test('remaining never goes negative', () {
      const calc = ProgressCalculator(total: 3, completed: 10);
      expect(calc.remaining, 0);
    });

    test('copyWith overrides fields', () {
      const calc = ProgressCalculator(total: 10, completed: 2);
      final updated = calc.copyWith(completed: 8);
      expect(updated.total, 10);
      expect(updated.completed, 8);
      expect(updated.percentage, 80);
    });
  });
}
