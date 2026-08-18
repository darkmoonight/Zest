import 'package:zest/core/caldav/vtodo_record.dart';

/// A VTODO-capable CalDAV collection.
class CalDavCalendarInfo {
  /// Creates calendar metadata used by sync and the settings picker.
  const CalDavCalendarInfo({
    required this.href,
    required this.uid,
    required this.displayName,
    this.ctag,
    this.isReadOnly = false,
  });

  /// Collection href.
  final String href;

  /// Server calendar uid.
  final String uid;

  /// User-visible name.
  final String displayName;

  /// Collection tag; changes when members change.
  final String? ctag;

  /// Whether writes are forbidden.
  final bool isReadOnly;
}

/// Network operations used by [CalDavSyncService] and discovery.
abstract class CalDavRemote {
  /// Lists writable calendars that advertise VTODO (falls back to all writable).
  Future<List<CalDavCalendarInfo>> listTodoCalendars();

  /// Returns the calendar whose href matches [href], or null.
  Future<CalDavCalendarInfo?> calendarByHref(String href);

  /// Fetches every VTODO in [calendar].
  Future<List<VtodoRecord>> getTodos(CalDavCalendarInfo calendar);

  /// Creates [todo] in [calendar] and returns href/etag.
  Future<VtodoRecord> createTodo(CalDavCalendarInfo calendar, VtodoRecord todo);

  /// Updates [todo] using its ETag.
  Future<VtodoRecord> updateTodo(CalDavCalendarInfo calendar, VtodoRecord todo);

  /// Deletes the resource at [todo.href].
  Future<void> deleteTodo(VtodoRecord todo);

  /// Looks up [uid] in [calendar].
  Future<VtodoRecord?> getTodoByUid(CalDavCalendarInfo calendar, String uid);

  /// Releases the underlying HTTP client.
  void close();
}

/// Thrown when a write collides with a newer server copy (HTTP 412/409).
class CalDavConflict implements Exception {
  /// Creates a conflict error.
  const CalDavConflict([this.message = 'CalDAV resource conflict']);

  /// Error detail.
  final String message;

  @override
  String toString() => message;
}
