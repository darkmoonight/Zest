import 'package:zest/core/caldav/vtodo_record.dart';
import 'package:zest/data/models/db.dart';

/// Maps Zest [Todos] to and from CalDAV [VtodoRecord] snapshots.
abstract final class VtodoMapper {
  static const _xRecMode = 'X-ZEST-REC-MODE';
  static const _xRecMinute = 'X-ZEST-REC-MINUTE';

  static const _weekdayToByDay = <int, String>{
    DateTime.monday: 'MO',
    DateTime.tuesday: 'TU',
    DateTime.wednesday: 'WE',
    DateTime.thursday: 'TH',
    DateTime.friday: 'FR',
    DateTime.saturday: 'SA',
    DateTime.sunday: 'SU',
  };

  static const _byDayToWeekday = <String, int>{
    'MO': DateTime.monday,
    'TU': DateTime.tuesday,
    'WE': DateTime.wednesday,
    'TH': DateTime.thursday,
    'FR': DateTime.friday,
    'SA': DateTime.saturday,
    'SU': DateTime.sunday,
  };

  /// RFC 5545 PRIORITY for [priority] (1 highest, 9 lowest, 0 undefined).
  static int priorityToIcal(Priority priority) => switch (priority) {
    Priority.high => 1,
    Priority.medium => 5,
    Priority.low => 9,
    Priority.none => 0,
  };

  /// Maps RFC 5545 PRIORITY onto [Priority].
  static Priority priorityFromIcal(int? value) {
    if (value == null || value == 0) return Priority.none;
    if (value <= 3) return Priority.high;
    if (value <= 6) return Priority.medium;
    return Priority.low;
  }

  /// RFC 5545 STATUS for [status].
  static String statusToIcal(TodoStatus status) => switch (status) {
    TodoStatus.active => 'NEEDS-ACTION',
    TodoStatus.done => 'COMPLETED',
    TodoStatus.cancelled => 'CANCELLED',
  };

  /// Maps RFC 5545 STATUS onto [TodoStatus].
  static TodoStatus statusFromIcal(String value) {
    return switch (value.toUpperCase()) {
      'COMPLETED' => TodoStatus.done,
      'CANCELLED' => TodoStatus.cancelled,
      _ => TodoStatus.active,
    };
  }

  /// Builds an RRULE body from Zest recurrence fields (null when none).
  static String? rruleFromTodo(Todos todo) {
    return switch (todo.recurrence) {
      RecurrenceFrequency.none => null,
      RecurrenceFrequency.daily => 'FREQ=DAILY',
      RecurrenceFrequency.weekly => _weeklyRrule(todo.recurrenceWeekdays),
      RecurrenceFrequency.monthly => 'FREQ=MONTHLY',
    };
  }

  static String _weeklyRrule(List<int> weekdays) {
    final days = weekdays
        .map((day) => _weekdayToByDay[day])
        .whereType<String>()
        .toList();
    if (days.isEmpty) return 'FREQ=WEEKLY';
    return 'FREQ=WEEKLY;BYDAY=${days.join(',')}';
  }

  /// Parses [rrule] into frequency + weekdays on [todo].
  static void applyRrule(Todos todo, String? rrule) {
    if (rrule == null || rrule.trim().isEmpty) {
      todo.recurrence = RecurrenceFrequency.none;
      todo.recurrenceWeekdays = [];
      return;
    }

    final parts = <String, String>{};
    for (final segment in rrule.split(';')) {
      final trimmed = segment.trim();
      if (trimmed.isEmpty) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      parts[trimmed.substring(0, eq).toUpperCase()] = trimmed.substring(eq + 1);
    }

    final freq = parts['FREQ']?.toUpperCase();
    todo.recurrence = switch (freq) {
      'DAILY' => RecurrenceFrequency.daily,
      'WEEKLY' => RecurrenceFrequency.weekly,
      'MONTHLY' => RecurrenceFrequency.monthly,
      _ => RecurrenceFrequency.none,
    };

    final byDay = parts['BYDAY'];
    if (byDay == null || byDay.isEmpty) {
      todo.recurrenceWeekdays = [];
      return;
    }
    todo.recurrenceWeekdays = byDay
        .split(',')
        .map((part) => part.trim().toUpperCase())
        // Strip optional ordinal prefixes like `1MO` / `-1FR`.
        .map((part) => part.replaceAll(RegExp(r'^[+-]?\d+'), ''))
        .map((code) => _byDayToWeekday[code])
        .whereType<int>()
        .toList();
  }

  /// Serializes [RecurrenceMode] for `X-ZEST-REC-MODE`.
  static String recurrenceModeToIcal(RecurrenceMode mode) => switch (mode) {
    RecurrenceMode.clone => 'CLONE',
    RecurrenceMode.reopen => 'REOPEN',
  };

  /// Parses `X-ZEST-REC-MODE` (defaults to clone).
  static RecurrenceMode recurrenceModeFromIcal(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'REOPEN' => RecurrenceMode.reopen,
      _ => RecurrenceMode.clone,
    };
  }

  /// Builds a VTODO snapshot from [todo]. [todo.caldavUid] must be set.
  static VtodoRecord toRecord(Todos todo) {
    final uid = todo.caldavUid;
    if (uid == null || uid.isEmpty) {
      throw StateError('CalDAV UID is required before mapping to VTODO');
    }
    final rrule = rruleFromTodo(todo);
    return VtodoRecord(
      uid: uid,
      href: todo.caldavHref,
      etag: todo.caldavEtag,
      summary: todo.name,
      description: todo.description,
      due: todo.dueAt,
      completed: todo.completedAt,
      priority: priorityToIcal(todo.priority),
      status: statusToIcal(todo.status),
      categories: List<String>.from(todo.tags),
      rrule: rrule,
      recurrenceMode: rrule == null
          ? null
          : recurrenceModeToIcal(todo.recurrenceMode),
      recurrenceMinuteOfDay: rrule == null ? null : todo.recurrenceMinuteOfDay,
    );
  }

  /// Copies VTODO fields from [remote] onto [todo] (does not persist).
  static void applyToTodo(Todos todo, VtodoRecord remote) {
    todo.caldavUid = remote.uid;
    todo.caldavHref = remote.href;
    todo.caldavEtag = remote.etag;
    todo.name = remote.summary;
    todo.description = remote.description;
    todo.dueAt = remote.due;
    todo.completedAt = remote.completed;
    todo.priority = priorityFromIcal(remote.priority);
    todo.status = statusFromIcal(remote.status);
    todo.tags = List<String>.from(remote.categories);

    final rrule = remote.rrule ?? rruleFromIcs(remote.rawIcalendar);
    applyRrule(todo, rrule);

    final modeRaw =
        remote.recurrenceMode ?? icsProperty(remote.rawIcalendar, _xRecMode);
    if (rrule != null && rrule.isNotEmpty) {
      todo.recurrenceMode = recurrenceModeFromIcal(modeRaw);
      final minuteRaw =
          remote.recurrenceMinuteOfDay?.toString() ??
          icsProperty(remote.rawIcalendar, _xRecMinute);
      todo.recurrenceMinuteOfDay = int.tryParse(minuteRaw ?? '');
    } else {
      todo.recurrenceMode = RecurrenceMode.clone;
      todo.recurrenceMinuteOfDay = null;
    }

    if (todo.status.isCompleted && todo.completedAt == null) {
      todo.completedAt = DateTime.now();
    }
    if (!todo.status.isCompleted) {
      todo.completedAt = null;
    }
    todo.caldavDirty = false;
  }

  /// Parses `CATEGORIES` from raw ICS, ignoring folded-line edge cases.
  static List<String> categoriesFromIcs(String? ics) {
    final value = icsProperty(ics, 'CATEGORIES');
    if (value == null || value.isEmpty) return const [];
    return value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  /// Parses `RRULE` from raw ICS.
  static String? rruleFromIcs(String? ics) => icsProperty(ics, 'RRULE');

  /// First value of an iCalendar property named [name] (case-insensitive).
  static String? icsProperty(String? ics, String name) {
    if (ics == null || ics.isEmpty) return null;
    final needle = name.toUpperCase();
    for (final rawLine in ics.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      final upper = line.toUpperCase();
      if (!upper.startsWith(needle)) continue;
      // Allow `NAME;PARAM=...:value` and `NAME:value`.
      final afterName = upper.length > needle.length
          ? upper[needle.length]
          : '';
      if (afterName.isNotEmpty && afterName != ':' && afterName != ';') {
        continue;
      }
      final colon = line.indexOf(':');
      if (colon < 0) continue;
      return line.substring(colon + 1).trim();
    }
    return null;
  }

  /// Stable UID assigned on first push.
  static String allocateUid(Todos todo) {
    final existing = todo.caldavUid;
    if (existing != null && existing.isNotEmpty) return existing;
    return 'zest-${todo.id}-${todo.createdTime.millisecondsSinceEpoch}';
  }
}
