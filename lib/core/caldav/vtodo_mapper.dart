import 'package:zest/core/caldav/vtodo_record.dart';
import 'package:zest/data/models/db.dart';

/// Maps Zest [Todos] to and from CalDAV [VtodoRecord] snapshots.
abstract final class VtodoMapper {
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

  /// Builds a VTODO snapshot from [todo]. [todo.caldavUid] must be set.
  static VtodoRecord toRecord(Todos todo) {
    final uid = todo.caldavUid;
    if (uid == null || uid.isEmpty) {
      throw StateError('CalDAV UID is required before mapping to VTODO');
    }
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
    if (ics == null || ics.isEmpty) return const [];
    for (final rawLine in ics.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      final upper = line.toUpperCase();
      if (!upper.startsWith('CATEGORIES')) continue;
      final colon = line.indexOf(':');
      if (colon < 0) continue;
      return line
          .substring(colon + 1)
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
    }
    return const [];
  }

  /// Stable UID assigned on first push.
  static String allocateUid(Todos todo) {
    final existing = todo.caldavUid;
    if (existing != null && existing.isNotEmpty) return existing;
    return 'zest-${todo.id}-${todo.createdTime.millisecondsSinceEpoch}';
  }
}
