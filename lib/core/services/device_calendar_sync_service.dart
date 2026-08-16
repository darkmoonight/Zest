import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:zest/core/utils/iterable_extensions.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Platform calendar operations used by [DeviceCalendarSyncService].
abstract class DeviceCalendarGateway {
  /// Requests calendar permission at [level].
  Future<CalendarPermissionStatus> requestPermissions({
    CalendarAccessLevel level = CalendarAccessLevel.full,
  });

  /// Lists device calendars (requires full access).
  Future<List<Calendar>> listCalendars();

  /// Creates a calendar and returns its platform id.
  Future<String> createCalendar({
    required String name,
    String? colorHex,
    CreateCalendarPlatformOptions? platformOptions,
  });

  /// Creates an event and returns its platform id.
  Future<String> createEvent({
    String? calendarId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  });

  /// Updates an existing event.
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  });

  /// Deletes an event by id.
  Future<void> deleteEvent({required String eventId});
}

/// [DeviceCalendarGateway] backed by [DeviceCalendar.instance].
class DeviceCalendarClient implements DeviceCalendarGateway {
  /// Creates a client backed by [DeviceCalendar.instance] unless overridden.
  DeviceCalendarClient({DeviceCalendar? plugin})
    : _plugin = plugin ?? DeviceCalendar.instance;

  final DeviceCalendar _plugin;

  @override
  Future<CalendarPermissionStatus> requestPermissions({
    CalendarAccessLevel level = CalendarAccessLevel.full,
  }) => _plugin.requestPermissions(level: level);

  @override
  Future<List<Calendar>> listCalendars() => _plugin.listCalendars();

  @override
  Future<String> createCalendar({
    required String name,
    String? colorHex,
    CreateCalendarPlatformOptions? platformOptions,
  }) => _plugin.createCalendar(
    name: name,
    colorHex: colorHex,
    platformOptions: platformOptions,
  );

  @override
  Future<String> createEvent({
    String? calendarId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) => _plugin.createEvent(
    calendarId: calendarId,
    title: title,
    startDate: startDate,
    endDate: endDate,
    description: description,
  );

  @override
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) => _plugin.updateEvent(
    eventId: eventId,
    title: title,
    startDate: startDate,
    endDate: endDate,
    description: description == null
        ? const Patch.clear()
        : Patch.set(description),
  );

  @override
  Future<void> deleteEvent({required String eventId}) =>
      _plugin.deleteEvent(eventId: eventId);
}

/// One-way export of Zest items with deadlines to the device calendar.
class DeviceCalendarSyncService {
  /// Creates a sync service reading live [getSettings] and persisting via [todoRepo].
  DeviceCalendarSyncService({
    required this._getSettings,
    required this._todoRepo,
    DeviceCalendarGateway? client,
    bool? isAndroid,
    this._saveSettings,
  }) : _client = client ?? DeviceCalendarClient(),
       _isAndroid = isAndroid ?? PlatformFeatures.isAndroid;

  /// Live settings reader.
  final Settings Function() _getSettings;

  /// Persists linked event ids on items.
  final TodoRepository _todoRepo;

  /// Platform calendar API.
  final DeviceCalendarGateway _client;

  /// When false, all sync methods no-op (non-Android).
  final bool _isAndroid;

  /// Optional persistence for [Settings.deviceCalendarId] changes.
  final Future<void> Function(Settings settings)? _saveSettings;

  /// Default event duration when mapping a list item deadline to a timed event.
  static const eventDuration = Duration(hours: 1);

  /// Display name for the auto-created local calendar.
  static const zestCalendarName = 'Zest';

  /// Platform account type for device-local calendars.
  static const localAccountType = 'local';

  /// Platform account type for Google calendars.
  static const googleAccountType = 'com.google';

  /// Color for the auto-created local [zestCalendarName] calendar.
  static const zestCalendarColorHex = '#2196F3';

  /// Whether [item] should currently have a linked device-calendar event.
  static bool shouldSyncTodo(Todos todo, Settings settings) {
    return settings.deviceCalendarSyncEnabled &&
        todo.todoCompletedTime != null &&
        todo.status == TodoStatus.active;
  }

  /// Event end time for a list item deadline start.
  static DateTime eventEnd(DateTime start) => start.add(eventDuration);

  /// Whether [calendar] is a device-local (non-synced) calendar.
  static bool isLocalCalendar(Calendar calendar) =>
      (calendar.accountType ?? '').toLowerCase() == localAccountType;

  /// Whether [calendar] is backed by a Google account (shown in Google Calendar).
  static bool isGoogleCalendar(Calendar calendar) {
    final type = (calendar.accountType ?? '').toLowerCase();
    return type == googleAccountType || type.contains('google');
  }

  /// Requests full calendar access (needed for update/delete and calendar list).
  Future<CalendarPermissionStatus> requestPermission() {
    if (!_isAndroid) return Future.value(CalendarPermissionStatus.denied);
    return _client.requestPermissions(level: CalendarAccessLevel.full);
  }

  /// Writable calendars for the Settings picker; empty when unavailable.
  Future<List<Calendar>> listWritableCalendars() async {
    if (!_isAndroid) return const [];
    try {
      final calendars = await _client.listCalendars();
      return calendars.where((c) => !c.readOnly && !c.hidden).toList();
    } catch (e, stackTrace) {
      debugPrint('listWritableCalendars failed: $e\n$stackTrace');
      return const [];
    }
  }

  /// Ensures a writable calendar id is stored in settings (creates one if needed).
  ///
  /// Resolution order:
  /// 1. Saved [Settings.deviceCalendarId] if it still exists and is writable
  ///    (respects the Settings picker, including Google calendars).
  /// 2. Writable Google calendar (primary first) — visible in Google Calendar.
  /// 3. Existing local [zestCalendarName], then any other local calendar.
  /// 4. Create a local [zestCalendarName] calendar.
  ///
  /// Auto-created local calendars are often invisible in the Google Calendar
  /// app until enabled in its drawer, so Google targets are preferred when
  /// present. Update/delete reliability is handled by recreate-on-miss.
  Future<String?> ensureWritableCalendarId() async {
    if (!_isAndroid) return null;

    final settings = _getSettings();
    final existingId = settings.deviceCalendarId;
    final writable = await listWritableCalendars();

    if (existingId != null && existingId.isNotEmpty) {
      final matched = writable.firstWhereOrNull((c) => c.id == existingId);
      if (matched != null) {
        // Previous builds auto-saved local "Zest", which Google Calendar often
        // does not show. Migrate that leftover to Google when available; any
        // other saved pick (including an explicit local calendar) is kept.
        if (isLocalCalendar(matched) && matched.name == zestCalendarName) {
          final google = _preferredGoogleCalendar(writable);
          if (google != null) {
            await _persistCalendarId(settings, google.id);
            debugPrint(
              'Device calendar migrated local Zest → Google '
              '"${google.name}" (${google.id})',
            );
            return google.id;
          }
        }
        debugPrint(
          'Device calendar using saved "${matched.name}" '
          '(${matched.id}, ${matched.accountType})',
        );
        return matched.id;
      }
    }

    final google = _preferredGoogleCalendar(writable);
    if (google != null) {
      await _persistCalendarId(settings, google.id);
      debugPrint(
        'Device calendar auto-selected Google "${google.name}" (${google.id})',
      );
      return google.id;
    }

    final zestLocal = writable.firstWhereOrNull(
      (c) => isLocalCalendar(c) && c.name == zestCalendarName,
    );
    if (zestLocal != null) {
      await _persistCalendarId(settings, zestLocal.id);
      return zestLocal.id;
    }

    final anyLocal = writable.firstWhereOrNull(isLocalCalendar);
    if (anyLocal != null) {
      await _persistCalendarId(settings, anyLocal.id);
      return anyLocal.id;
    }

    try {
      final createdId = await _client.createCalendar(
        name: zestCalendarName,
        colorHex: zestCalendarColorHex,
        platformOptions: const CreateCalendarOptionsAndroid(
          accountName: zestCalendarName,
        ),
      );
      await _persistCalendarId(settings, createdId);
      debugPrint(
        'Device calendar created local "$zestCalendarName" ($createdId)',
      );
      return createdId;
    } catch (e, stackTrace) {
      debugPrint('createCalendar failed: $e\n$stackTrace');
      return null;
    }
  }

  /// Creates, updates, or removes the device-calendar event for [item].
  Future<void> ensureSynced(Todos todo) async {
    if (!_isAndroid) return;

    final settings = _getSettings();
    try {
      final latest = await _todoRepo.getById(todo.id) ?? todo;
      _applyLatestToCaller(todo, latest);

      if (!shouldSyncTodo(latest, settings)) {
        await _removeLinkedEvent(latest, persist: true);
        todo.deviceCalendarEventId = latest.deviceCalendarEventId;
        return;
      }

      final previousCalendarId = settings.deviceCalendarId;
      final calendarId = await ensureWritableCalendarId();
      if (calendarId == null) {
        debugPrint(
          'Device calendar sync skipped for todo ${latest.id}: no writable calendar',
        );
        return;
      }

      final start = latest.todoCompletedTime!;
      final end = eventEnd(start);
      final description = latest.description.isEmpty
          ? null
          : latest.description;
      var existingId = latest.deviceCalendarEventId;

      // Target calendar changed (e.g. local Zest → Google): delete the old
      // event before recreate so we don't orphan it on the previous calendar.
      if (existingId != null &&
          existingId.isNotEmpty &&
          previousCalendarId != null &&
          previousCalendarId != calendarId) {
        debugPrint(
          'Device calendar target changed ($previousCalendarId → $calendarId); '
          'recreating event for todo ${latest.id}',
        );
        await _removeLinkedEvent(latest, persist: true);
        todo.deviceCalendarEventId = null;
        existingId = null;
      }

      if (existingId == null || existingId.isEmpty) {
        await _createAndPersistEvent(
          todo: latest,
          callerTodo: todo,
          calendarId: calendarId,
          start: start,
          end: end,
          description: description,
        );
        return;
      }

      try {
        await _client.updateEvent(
          eventId: existingId,
          title: latest.name,
          startDate: start,
          endDate: end,
          description: description,
        );
        debugPrint(
          'Device calendar updated event $existingId for todo ${latest.id}',
        );
      } catch (e, stackTrace) {
        debugPrint(
          'Device calendar update failed for $existingId, recreating: $e\n$stackTrace',
        );
        await _removeLinkedEvent(latest, persist: true);
        todo.deviceCalendarEventId = null;
        await _createAndPersistEvent(
          todo: latest,
          callerTodo: todo,
          calendarId: calendarId,
          start: start,
          end: end,
          description: description,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Device calendar sync failed for todo ${todo.id}: $e\n$stackTrace',
      );
    }
  }

  /// Deletes the linked event for [item] if any (e.g. before hard delete).
  Future<void> removeSynced(Todos todo) async {
    if (!_isAndroid) return;
    try {
      final latest = await _todoRepo.getById(todo.id) ?? todo;
      todo.deviceCalendarEventId = latest.deviceCalendarEventId;
      await _removeLinkedEvent(latest, persist: true);
      todo.deviceCalendarEventId = null;
      debugPrint('Device calendar removed event for todo ${todo.id}');
    } catch (e, stackTrace) {
      debugPrint(
        'Device calendar remove failed for todo ${todo.id}: $e\n$stackTrace',
      );
      todo.deviceCalendarEventId = null;
    }
  }

  /// Creates/updates events for all active items with a due date (sync enable).
  Future<void> backfillAllEligible() async {
    if (!_isAndroid) return;
    final todos = await _todoRepo.getAll();
    for (final todo in todos) {
      await ensureSynced(todo);
    }
  }

  /// Deletes all linked device-calendar events and clears stored ids (sync disable).
  Future<void> removeAllSynced() async {
    if (!_isAndroid) return;
    final todos = await _todoRepo.getAll();
    for (final todo in todos) {
      final eventId = todo.deviceCalendarEventId;
      if (eventId == null || eventId.isEmpty) continue;
      await removeSynced(todo);
    }
  }

  /// Deletes existing events then recreates them on the current target calendar.
  Future<void> recreateAllSyncedEvents() async {
    if (!_isAndroid) return;
    final todos = await _todoRepo.getAll();
    for (final todo in todos) {
      final eventId = todo.deviceCalendarEventId;
      if (eventId == null || eventId.isEmpty) continue;
      await _removeLinkedEvent(todo, persist: true);
      await ensureSynced(todo);
    }
  }

  /// Primary Google calendar, or any Google calendar if none is primary.
  Calendar? _preferredGoogleCalendar(List<Calendar> writable) {
    return writable.firstWhereOrNull(
          (c) => isGoogleCalendar(c) && c.isPrimary,
        ) ??
        writable.firstWhereOrNull(isGoogleCalendar);
  }

  /// Copies sync-relevant fields from [latest] onto the caller-visible [item].
  void _applyLatestToCaller(Todos todo, Todos latest) {
    todo.deviceCalendarEventId = latest.deviceCalendarEventId;
    todo.name = latest.name;
    todo.description = latest.description;
    todo.todoCompletedTime = latest.todoCompletedTime;
    todo.status = latest.status;
  }

  /// Creates a calendar event and stores its id on [item] and [callerTodo].
  Future<void> _createAndPersistEvent({
    required Todos todo,
    required Todos callerTodo,
    required String calendarId,
    required DateTime start,
    required DateTime end,
    required String? description,
  }) async {
    final eventId = await _client.createEvent(
      calendarId: calendarId,
      title: todo.name,
      startDate: start,
      endDate: end,
      description: description,
    );
    todo.deviceCalendarEventId = eventId;
    callerTodo.deviceCalendarEventId = eventId;
    await _todoRepo.update(todo);
    debugPrint(
      'Device calendar created event $eventId on $calendarId for todo ${todo.id}',
    );
  }

  /// Persists [calendarId] on [settings] when it changed.
  Future<void> _persistCalendarId(Settings settings, String calendarId) async {
    if (settings.deviceCalendarId == calendarId) return;
    settings.deviceCalendarId = calendarId;
    final save = _saveSettings;
    if (save != null) {
      await save(settings);
    }
  }

  /// Deletes the linked device event for [item], optionally persisting a null id.
  Future<void> _removeLinkedEvent(Todos todo, {bool persist = true}) async {
    final eventId = todo.deviceCalendarEventId;
    if (eventId == null || eventId.isEmpty) return;

    try {
      await _client.deleteEvent(eventId: eventId);
      debugPrint('Device calendar deleted event $eventId');
    } catch (e, stackTrace) {
      // Event may already be gone from the device calendar.
      debugPrint(
        'Device calendar deleteEvent failed for $eventId: $e\n$stackTrace',
      );
    }

    todo.deviceCalendarEventId = null;
    if (persist) {
      await _todoRepo.update(todo);
    }
  }
}
