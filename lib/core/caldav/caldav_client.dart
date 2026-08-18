import 'package:caldav/caldav.dart' as caldav;
import 'package:zest/core/caldav/caldav_remote.dart';
import 'package:zest/core/caldav/vtodo_mapper.dart';
import 'package:zest/core/caldav/vtodo_record.dart';

/// Connects to [url] and returns a [CalDavRemote] after discovery.
Future<CalDavRemote> connectCalDavRemote({
  required String url,
  required String username,
  required String password,
  bool allowInsecure = false,
}) async {
  final client = await caldav.CalDavClient.connect(
    baseUrl: url,
    username: username,
    password: password,
    allowInsecure: allowInsecure,
  );
  return PackageCalDavRemote(client);
}

/// [CalDavRemote] backed by `package:caldav`.
class PackageCalDavRemote implements CalDavRemote {
  /// Wraps an already-connected [client].
  PackageCalDavRemote(this._client);

  final caldav.CalDavClient _client;

  @override
  Future<List<CalDavCalendarInfo>> listTodoCalendars() async {
    final calendars = await _client.getCalendars();
    final writable = calendars.where((calendar) => !calendar.isReadOnly);
    final todos = writable.where((calendar) => calendar.supportsTodos);
    final selected = todos.isNotEmpty ? todos : writable;
    return [for (final calendar in selected) _info(calendar)];
  }

  @override
  Future<CalDavCalendarInfo?> calendarByHref(String href) async {
    final calendars = await listTodoCalendars();
    for (final calendar in calendars) {
      if (calendar.href == href) return calendar;
    }
    return null;
  }

  @override
  Future<List<VtodoRecord>> getTodos(CalDavCalendarInfo calendar) async {
    final remote = await _calendar(calendar);
    final todos = await _client.getTodos(remote);
    return [for (final todo in todos) _fromPackage(todo)];
  }

  @override
  Future<VtodoRecord> createTodo(
    CalDavCalendarInfo calendar,
    VtodoRecord todo,
  ) async {
    final remote = await _calendar(calendar);
    try {
      final created = await _client.createTodo(
        remote,
        _toPackage(todo, calendar.uid),
      );
      return _fromPackage(created, categories: todo.categories);
    } on caldav.ConflictException catch (e) {
      throw CalDavConflict(e.message);
    }
  }

  @override
  Future<VtodoRecord> updateTodo(
    CalDavCalendarInfo calendar,
    VtodoRecord todo,
  ) async {
    try {
      final updated = await _client.updateTodo(_toPackage(todo, calendar.uid));
      return _fromPackage(updated, categories: todo.categories);
    } on caldav.ConflictException catch (e) {
      throw CalDavConflict(e.message);
    }
  }

  @override
  Future<void> deleteTodo(VtodoRecord todo) async {
    final href = todo.href;
    if (href == null || href.isEmpty) return;
    try {
      await _client.deleteTodo(
        caldav.CalendarTodo(
          uid: todo.uid,
          calendarId: '',
          href: Uri.parse(href),
          etag: todo.etag,
          summary: todo.summary,
        ),
      );
    } on caldav.NotFoundException {
      return;
    } on caldav.ConflictException catch (e) {
      throw CalDavConflict(e.message);
    }
  }

  @override
  Future<VtodoRecord?> getTodoByUid(
    CalDavCalendarInfo calendar,
    String uid,
  ) async {
    final remote = await _calendar(calendar);
    final todo = await _client.getTodos(remote).then((todos) {
      for (final item in todos) {
        if (item.uid == uid) return item;
      }
      return null;
    });
    return todo == null ? null : _fromPackage(todo);
  }

  @override
  void close() => _client.close();

  Future<caldav.Calendar> _calendar(CalDavCalendarInfo info) async {
    final calendars = await _client.getCalendars();
    for (final calendar in calendars) {
      if (calendar.href.toString() == info.href || calendar.uid == info.uid) {
        return calendar;
      }
    }
    throw caldav.NotFoundException('Calendar not found: ${info.href}');
  }

  static CalDavCalendarInfo _info(caldav.Calendar calendar) {
    return CalDavCalendarInfo(
      href: calendar.href.toString(),
      uid: calendar.uid,
      displayName: calendar.displayName,
      ctag: calendar.ctag,
      isReadOnly: calendar.isReadOnly,
    );
  }

  static VtodoRecord _fromPackage(
    caldav.CalendarTodo todo, {
    List<String>? categories,
  }) {
    return VtodoRecord(
      uid: todo.uid,
      href: todo.href?.toString(),
      etag: todo.etag,
      summary: todo.summary,
      description: todo.description ?? '',
      due: todo.due,
      completed: todo.completed,
      priority: todo.priority ?? 0,
      status: _statusToIcal(todo.status),
      categories:
          categories ?? VtodoMapper.categoriesFromIcs(todo.rawIcalendar),
      rawIcalendar: todo.rawIcalendar,
    );
  }

  static _TaggedCalendarTodo _toPackage(VtodoRecord todo, String calendarId) {
    return _TaggedCalendarTodo(
      uid: todo.uid,
      calendarId: calendarId,
      href: todo.href == null ? null : Uri.parse(todo.href!),
      etag: todo.etag,
      summary: todo.summary,
      description: todo.description.isEmpty ? null : todo.description,
      due: todo.due,
      status: _statusFromIcal(todo.status),
      completed: todo.completed,
      percentComplete: todo.status == 'COMPLETED' ? 100 : null,
      priority: todo.priority,
      categories: todo.categories,
    );
  }

  static String _statusToIcal(caldav.TodoStatus status) => switch (status) {
    caldav.TodoStatus.needsAction => 'NEEDS-ACTION',
    caldav.TodoStatus.inProcess => 'IN-PROCESS',
    caldav.TodoStatus.completed => 'COMPLETED',
    caldav.TodoStatus.cancelled => 'CANCELLED',
  };

  static caldav.TodoStatus _statusFromIcal(String status) =>
      switch (status.toUpperCase()) {
        'COMPLETED' => caldav.TodoStatus.completed,
        'CANCELLED' => caldav.TodoStatus.cancelled,
        'IN-PROCESS' => caldav.TodoStatus.inProcess,
        _ => caldav.TodoStatus.needsAction,
      };
}

/// Injects CATEGORIES into ICS emitted by `package:caldav`.
class _TaggedCalendarTodo extends caldav.CalendarTodo {
  _TaggedCalendarTodo({
    required super.uid,
    required super.calendarId,
    super.href,
    super.etag,
    required super.summary,
    super.description,
    super.due,
    super.status,
    super.completed,
    super.percentComplete,
    super.priority,
    required this.categories,
  });

  final List<String> categories;

  @override
  String toIcalendar() {
    final ics = super.toIcalendar();
    if (categories.isEmpty) return ics;
    final escaped = categories.map(_escapeIcalText).join(',');
    return ics.replaceFirst('\nEND:VTODO', '\nCATEGORIES:$escaped\nEND:VTODO');
  }

  static String _escapeIcalText(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
  }
}
