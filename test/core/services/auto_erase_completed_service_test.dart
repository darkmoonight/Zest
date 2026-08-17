import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/services/auto_erase_completed_service.dart';
import 'package:zest/data/models/db.dart';

void main() {
  group('AutoEraseCompletedService.shouldErase', () {
    test('never runs when disabled', () {
      expect(
        AutoEraseCompletedService.shouldErase(
          enabled: false,
          frequency: AutoEraseCompletedFrequency.weekly,
          lastEraseTime: null,
        ),
        isFalse,
      );
    });

    test('runs when never erased before', () {
      expect(
        AutoEraseCompletedService.shouldErase(
          enabled: true,
          frequency: AutoEraseCompletedFrequency.weekly,
          lastEraseTime: null,
        ),
        isTrue,
      );
    });

    test('weekly waits seven calendar days', () {
      final last = DateTime(2026, 7, 1, 12);
      expect(
        AutoEraseCompletedService.shouldErase(
          enabled: true,
          frequency: AutoEraseCompletedFrequency.weekly,
          lastEraseTime: last,
          now: DateTime(2026, 7, 7, 12),
        ),
        isFalse,
      );
      expect(
        AutoEraseCompletedService.shouldErase(
          enabled: true,
          frequency: AutoEraseCompletedFrequency.weekly,
          lastEraseTime: last,
          now: DateTime(2026, 7, 8, 12),
        ),
        isTrue,
      );
    });

    test('monthly waits until the next calendar month', () {
      final last = DateTime(2026, 6, 1, 12);
      expect(
        AutoEraseCompletedService.shouldErase(
          enabled: true,
          frequency: AutoEraseCompletedFrequency.monthly,
          lastEraseTime: last,
          now: DateTime(2026, 6, 30, 12),
        ),
        isFalse,
      );
      expect(
        AutoEraseCompletedService.shouldErase(
          enabled: true,
          frequency: AutoEraseCompletedFrequency.monthly,
          lastEraseTime: last,
          now: DateTime(2026, 7, 1, 12),
        ),
        isTrue,
      );
    });
  });

  group('AutoEraseCompletedService.isEligible', () {
    final cutoff = DateTime(2026, 7, 8);

    test('keeps recent completed todos', () {
      final todo = Todos(
        name: 'Recent',
        description: '',
        createdTime: DateTime(2026, 7, 10),
        status: TodoStatus.done,
        todoCompletionTime: DateTime(2026, 7, 12, 9),
      );
      expect(AutoEraseCompletedService.isEligible(todo, cutoff), isFalse);
    });

    test('erases completed todos on or before cutoff', () {
      final todo = Todos(
        name: 'Old',
        description: '',
        createdTime: DateTime(2026, 6, 1),
        status: TodoStatus.done,
        todoCompletionTime: DateTime(2026, 7, 1, 9),
      );
      expect(AutoEraseCompletedService.isEligible(todo, cutoff), isTrue);
    });

    test('never erases active todos', () {
      final todo = Todos(
        name: 'Active',
        description: '',
        createdTime: DateTime(2026, 6, 1),
        status: TodoStatus.active,
        todoCompletionTime: DateTime(2026, 6, 1),
      );
      expect(AutoEraseCompletedService.isEligible(todo, cutoff), isFalse);
    });

    test('falls back to createdTime when completion time is missing', () {
      final todo = Todos(
        name: 'Legacy',
        description: '',
        createdTime: DateTime(2026, 6, 1),
        status: TodoStatus.done,
      );
      expect(AutoEraseCompletedService.isEligible(todo, cutoff), isTrue);
    });
  });

  group('AutoEraseCompletedService.retentionCutoff', () {
    test('maps frequencies to calendar cutoffs', () {
      final now = DateTime(2026, 7, 15, 12);
      expect(
        AutoEraseCompletedService.retentionCutoff(
          AutoEraseCompletedFrequency.weekly,
          now,
        ),
        DateTime(2026, 7, 8),
      );
      expect(
        AutoEraseCompletedService.retentionCutoff(
          AutoEraseCompletedFrequency.monthly,
          now,
        ),
        DateTime(2026, 6, 15),
      );
    });
  });
}
