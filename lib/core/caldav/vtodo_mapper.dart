import 'package:zest/core/caldav/vtodo_record.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';

/// Maps Zest [Todo] to and from CalDAV [VtodoRecord] snapshots.
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
  static String? rruleFromTodo(Todo todo) {
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

  /// Parses [rrule] into frequency + weekdays.
  static ({RecurrenceFrequency recurrence, List<int> weekdays}) parseRrule(
    String? rrule,
  ) {
    if (rrule == null || rrule.trim().isEmpty) {
      return (recurrence: RecurrenceFrequency.none, weekdays: const []);
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
    final recurrence = switch (freq) {
      'DAILY' => RecurrenceFrequency.daily,
      'WEEKLY' => RecurrenceFrequency.weekly,
      'MONTHLY' => RecurrenceFrequency.monthly,
      _ => RecurrenceFrequency.none,
    };

    final byDay = parts['BYDAY'];
    if (byDay == null || byDay.isEmpty) {
      return (recurrence: recurrence, weekdays: const []);
    }
    final weekdays = byDay
        .split(',')
        .map((part) => part.trim().toUpperCase())
        .map((part) => part.replaceAll(RegExp(r'^[+-]?\d+'), ''))
        .map((code) => _byDayToWeekday[code])
        .whereType<int>()
        .toList();
    return (recurrence: recurrence, weekdays: weekdays);
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
  static VtodoRecord toRecord(Todo todo) {
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
  static Todo applyToTodo(Todo todo, VtodoRecord remote) {
    final rrule = remote.rrule ?? rruleFromIcs(remote.rawIcalendar);
    final parsed = parseRrule(rrule);

    final modeRaw =
        remote.recurrenceMode ?? icsProperty(remote.rawIcalendar, _xRecMode);
    final RecurrenceMode recurrenceMode;
    final int? recurrenceMinuteOfDay;
    if (rrule != null && rrule.isNotEmpty) {
      recurrenceMode = recurrenceModeFromIcal(modeRaw);
      final minuteRaw =
          remote.recurrenceMinuteOfDay?.toString() ??
          icsProperty(remote.rawIcalendar, _xRecMinute);
      recurrenceMinuteOfDay = int.tryParse(minuteRaw ?? '');
    } else {
      recurrenceMode = RecurrenceMode.clone;
      recurrenceMinuteOfDay = null;
    }

    var status = statusFromIcal(remote.status);
    DateTime? completedAt = remote.completed;
    if (status.isCompleted && completedAt == null) {
      completedAt = DateTime.now();
    }
    if (!status.isCompleted) {
      completedAt = null;
    }

    return todo.copyWith(
      caldavUid: remote.uid,
      caldavHref: remote.href,
      caldavEtag: remote.etag,
      name: remote.summary,
      description: remote.description,
      dueAt: remote.due,
      clearDueAt: remote.due == null,
      completedAt: completedAt,
      clearCompletedAt: completedAt == null,
      priority: priorityFromIcal(remote.priority),
      status: status,
      tags: List<String>.from(remote.categories),
      recurrence: parsed.recurrence,
      recurrenceWeekdays: parsed.weekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
      clearRecurrenceMinuteOfDay: recurrenceMinuteOfDay == null,
      caldavDirty: false,
    );
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
  static String allocateUid(Todo todo) {
    final existing = todo.caldavUid;
    if (existing != null && existing.isNotEmpty) return existing;
    return 'zest-${todo.id}-${todo.createdAt.millisecondsSinceEpoch}';
  }
}
