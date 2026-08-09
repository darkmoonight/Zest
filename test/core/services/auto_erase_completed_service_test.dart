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

    test('weekly waits seven days', () {
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

    test('monthly waits thirty days', () {
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
    final retention = const Duration(days: 7);
    final now = DateTime(2026, 7, 15, 12);

    test('keeps recent completed todos', () {
      final todo = Todos(
        name: 'Recent',
        description: '',
        createdTime: DateTime(2026, 7, 10),
        status: TodoStatus.done,
        todoCompletionTime: DateTime(2026, 7, 12, 9),
      );
      expect(
        AutoEraseCompletedService.isEligible(todo, retention, now),
        isFalse,
      );
    });

    test('erases completed todos older than retention', () {
      final todo = Todos(
        name: 'Old',
        description: '',
        createdTime: DateTime(2026, 6, 1),
        status: TodoStatus.done,
        todoCompletionTime: DateTime(2026, 7, 1, 9),
      );
      expect(
        AutoEraseCompletedService.isEligible(todo, retention, now),
        isTrue,
      );
    });

    test('never erases active todos', () {
      final todo = Todos(
        name: 'Active',
        description: '',
        createdTime: DateTime(2026, 6, 1),
        status: TodoStatus.active,
        todoCompletionTime: DateTime(2026, 6, 1),
      );
      expect(
        AutoEraseCompletedService.isEligible(todo, retention, now),
        isFalse,
      );
    });

    test('falls back to createdTime when completion time is missing', () {
      final todo = Todos(
        name: 'Legacy',
        description: '',
        createdTime: DateTime(2026, 6, 1),
        status: TodoStatus.done,
      );
      expect(
        AutoEraseCompletedService.isEligible(todo, retention, now),
        isTrue,
      );
    });
  });

  group('AutoEraseCompletedService.retentionFor', () {
    test('maps frequencies to windows', () {
      expect(
        AutoEraseCompletedService.retentionFor(
          AutoEraseCompletedFrequency.weekly,
        ),
        const Duration(days: 7),
      );
      expect(
        AutoEraseCompletedService.retentionFor(
          AutoEraseCompletedFrequency.monthly,
        ),
        const Duration(days: 30),
      );
    });
  });
}
