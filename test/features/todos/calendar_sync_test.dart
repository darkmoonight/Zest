import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zest/core/di/home_tab_index_notifier.dart';
import 'package:zest/core/navigation/home_tabs.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/provider_overrides.dart';

/// Mirrors [CalendarTodos._syncCalendarToTodayIfNeeded] guard logic.
bool shouldSyncCalendarToToday(DateTime? selectedDay, DateTime today) {
  return !isSameDay(selectedDay, today);
}

void main() {
  group('calendar sync to today', () {
    test('syncs when selected day is in the past', () {
      final today = DateTime(2026, 6, 25);
      final past = DateTime(2026, 6, 21);

      expect(shouldSyncCalendarToToday(past, today), isTrue);
    });

    test('does not sync when already on today', () {
      final today = DateTime(2026, 6, 25, 14, 30);
      final sameDay = DateTime(2026, 6, 25, 8, 0);

      expect(shouldSyncCalendarToToday(sameDay, today), isFalse);
    });

    test('syncs when selection is null', () {
      expect(shouldSyncCalendarToToday(null, DateTime(2026, 6, 25)), isTrue);
    });
  });

  group('homeTabIndexProvider', () {
    late Isar isar;

    setUp(() async {
      isar = await openTestIsar();
    });

    tearDown(() async {
      await closeTestIsar(isar);
    });

    test('initial index follows defaultScreen setting', () {
      final container = createTestContainer(
        isar: isar,
        settings: Settings()..defaultScreen = 'calendar',
      );
      addTearDown(container.dispose);

      expect(container.read(homeTabIndexProvider), calendarTabIndex);
    });

    test('setIndex updates active tab', () {
      final container = createTestContainer(isar: isar);
      addTearDown(container.dispose);

      container.read(homeTabIndexProvider.notifier).setIndex(1);
      expect(container.read(homeTabIndexProvider), 1);
    });
  });

  group('homeTabIndexForDefaultScreen', () {
    test('resolves calendar key', () {
      expect(homeTabIndexForDefaultScreen('calendar'), calendarTabIndex);
    });

    test('falls back to first tab for unknown key', () {
      expect(homeTabIndexForDefaultScreen('unknown'), 0);
    });
  });
}
