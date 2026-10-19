import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:zest/core/utils/app_log.dart';
import 'package:zest/core/utils/iterable_extensions.dart';
import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/ports/device_calendar_sync_port.dart';
import 'package:zest/domain/repositories/todo_repository.dart';
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
    CalendarOptionsAndroid? android,
    CalendarOptionsIos? ios,
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
    CalendarOptionsAndroid? android,
    CalendarOptionsIos? ios,
  }) => _plugin.createCalendar(
    name: name,
    colorHex: colorHex,
    android: android,
    ios: ios,
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
    instanceId: eventId,
    title: title,
    startDate: startDate,
    endDate: endDate,
    description: description == null
        ? const Patch.clear()
        : Patch.set(description),
  );

  @override
  Future<void> deleteEvent({required String eventId}) =>
      _plugin.deleteEvent(instanceId: eventId);
}

/// One-way export of Zest items with deadlines to the device calendar.
class DeviceCalendarSyncService implements DeviceCalendarSyncPort {
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
  final AppSettings Function() _getSettings;

  /// Persists linked event ids on items.
  final TodoRepositoryPort _todoRepo;

  /// Platform calendar API.
  final DeviceCalendarGateway _client;

  /// When false, all sync methods no-op (non-Android).
  final bool _isAndroid;

  /// Optional persistence for [Settings.deviceCalendarId] changes.
  final Future<void> Function(AppSettings settings)? _saveSettings;

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
  static bool shouldSyncTodo(Todo todo, AppSettings settings) {
    return settings.deviceCalendarSyncEnabled &&
        todo.dueAt != null &&
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
      AppLog.d('listWritableCalendars failed: $e\n$stackTrace');
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
            AppLog.d(
              'Device calendar migrated local Zest → Google '
              '"${google.name}" (${google.id})',
            );
            return google.id;
          }
        }
        AppLog.d(
          'Device calendar using saved "${matched.name}" '
          '(${matched.id}, ${matched.accountType})',
        );
        return matched.id;
      }
    }

    final google = _preferredGoogleCalendar(writable);
    if (google != null) {
      await _persistCalendarId(settings, google.id);
      AppLog.d(
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
        android: const CalendarOptionsAndroid(accountName: zestCalendarName),
      );
      await _persistCalendarId(settings, createdId);
      AppLog.d(
        'Device calendar created local "$zestCalendarName" ($createdId)',
      );
      return createdId;
    } catch (e, stackTrace) {
      AppLog.d('createCalendar failed: $e\n$stackTrace');
      return null;
    }
  }

  /// Creates, updates, or removes the device-calendar event for [item].
  @override
  Future<void> ensureSynced(Todo todo) async {
    if (!_isAndroid) return;

    final settings = _getSettings();
    try {
      var latest = await _todoRepo.getById(todo.id) ?? todo;

      if (!shouldSyncTodo(latest, settings)) {
        await _removeLinkedEvent(latest, persist: true);
        return;
      }

      final previousCalendarId = settings.deviceCalendarId;
      final calendarId = await ensureWritableCalendarId();
      if (calendarId == null) {
        AppLog.d(
          'Device calendar sync skipped for todo ${latest.id}: no writable calendar',
        );
        return;
      }

      final start = latest.dueAt!;
      final end = eventEnd(start);
      final description = latest.description.isEmpty
          ? null
          : latest.description;
      var existingId = latest.deviceCalendarEventId;

      if (existingId != null &&
          existingId.isNotEmpty &&
          previousCalendarId != null &&
          previousCalendarId != calendarId) {
        AppLog.d(
          'Device calendar target changed ($previousCalendarId → $calendarId); '
          'recreating event for todo ${latest.id}',
        );
        await _removeLinkedEvent(latest, persist: true);
        latest = latest.copyWith(clearDeviceCalendarEventId: true);
        existingId = null;
      }

      if (existingId == null || existingId.isEmpty) {
        await _createAndPersistEvent(
          todo: latest,
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
        AppLog.d(
          'Device calendar updated event $existingId for todo ${latest.id}',
        );
      } catch (e, stackTrace) {
        AppLog.d(
          'Device calendar update failed for $existingId, recreating: $e\n$stackTrace',
        );
        await _removeLinkedEvent(latest, persist: true);
        await _createAndPersistEvent(
          todo: latest.copyWith(clearDeviceCalendarEventId: true),
          calendarId: calendarId,
          start: start,
          end: end,
          description: description,
        );
      }
    } catch (e, stackTrace) {
      AppLog.d(
        'Device calendar sync failed for todo ${todo.id}: $e\n$stackTrace',
      );
    }
  }

  /// Deletes the linked event for [item] if any (e.g. before hard delete).
  @override
  Future<void> removeSynced(Todo todo) async {
    if (!_isAndroid) return;
    try {
      final latest = await _todoRepo.getById(todo.id) ?? todo;
      await _removeLinkedEvent(latest, persist: true);
      AppLog.d('Device calendar removed event for todo ${todo.id}');
    } catch (e, stackTrace) {
      AppLog.d(
        'Device calendar remove failed for todo ${todo.id}: $e\n$stackTrace',
      );
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

  /// Creates a calendar event and stores its id on [todo].
  Future<void> _createAndPersistEvent({
    required Todo todo,
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
    await _todoRepo.update(todo.copyWith(deviceCalendarEventId: eventId));
    AppLog.d(
      'Device calendar created event $eventId on $calendarId for todo ${todo.id}',
    );
  }

  /// Persists [calendarId] on [settings] when it changed.
  Future<void> _persistCalendarId(
    AppSettings settings,
    String calendarId,
  ) async {
    if (settings.deviceCalendarId == calendarId) return;
    final save = _saveSettings;
    if (save != null) {
      await save(settings.copyWith(deviceCalendarId: calendarId));
    }
  }

  /// Deletes the linked device event for [todo], optionally persisting a null id.
  Future<void> _removeLinkedEvent(Todo todo, {bool persist = true}) async {
    final eventId = todo.deviceCalendarEventId;
    if (eventId == null || eventId.isEmpty) return;

    try {
      await _client.deleteEvent(eventId: eventId);
      AppLog.d('Device calendar deleted event $eventId');
    } catch (e, stackTrace) {
      AppLog.d(
        'Device calendar deleteEvent failed for $eventId: $e\n$stackTrace',
      );
    }

    if (persist) {
      await _todoRepo.update(todo.copyWith(clearDeviceCalendarEventId: true));
    }
  }
}
