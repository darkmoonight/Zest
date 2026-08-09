import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

import '../../helpers/isar_test_helper.dart';

Calendar _googlePrimary({
  String id = 'google-primary',
  String name = 'Personal',
}) {
  return Calendar(
    id: id,
    name: name,
    readOnly: false,
    accountType: DeviceCalendarSyncService.googleAccountType,
    isPrimary: true,
  );
}

Calendar _localZest({String id = 'local-zest'}) {
  return Calendar(
    id: id,
    name: DeviceCalendarSyncService.zestCalendarName,
    readOnly: false,
    accountType: DeviceCalendarSyncService.localAccountType,
  );
}

Calendar _localPhone({String id = 'existing-local', String name = 'Phone'}) {
  return Calendar(
    id: id,
    name: name,
    readOnly: false,
    accountType: DeviceCalendarSyncService.localAccountType,
  );
}

void main() {
  group('DeviceCalendarSyncService.shouldSyncTodo', () {
    late Tasks task;

    setUp(() {
      task = Tasks(id: 1, title: 'T', taskColor: 1);
    });

    test('true only when enabled, has deadline, and active', () {
      final settings = Settings()..deviceCalendarSyncEnabled = true;
      final todo = buildTodo(id: 1, task: task, priority: Priority.high)
        ..todoCompletedTime = DateTime(2026, 8, 9, 12);

      expect(DeviceCalendarSyncService.shouldSyncTodo(todo, settings), isTrue);

      settings.deviceCalendarSyncEnabled = false;
      expect(DeviceCalendarSyncService.shouldSyncTodo(todo, settings), isFalse);

      settings.deviceCalendarSyncEnabled = true;
      todo.todoCompletedTime = null;
      expect(DeviceCalendarSyncService.shouldSyncTodo(todo, settings), isFalse);

      todo.todoCompletedTime = DateTime(2026, 8, 9, 12);
      todo.status = TodoStatus.done;
      expect(DeviceCalendarSyncService.shouldSyncTodo(todo, settings), isFalse);
    });

    test('eventEnd is one hour after start', () {
      final start = DateTime(2026, 1, 1, 10);
      expect(
        DeviceCalendarSyncService.eventEnd(start),
        DateTime(2026, 1, 1, 11),
      );
    });

    test('isLocalCalendar detects local account type', () {
      expect(DeviceCalendarSyncService.isLocalCalendar(_localZest()), isTrue);
      expect(
        DeviceCalendarSyncService.isLocalCalendar(_googlePrimary()),
        isFalse,
      );
    });

    test('isGoogleCalendar detects Google account type', () {
      expect(
        DeviceCalendarSyncService.isGoogleCalendar(_googlePrimary()),
        isTrue,
      );
      expect(DeviceCalendarSyncService.isGoogleCalendar(_localZest()), isFalse);
    });
  });

  group('DeviceCalendarSyncService.ensureSynced', () {
    late Isar isar;
    late TodoRepository todoRepo;
    late Settings settings;
    late FakeDeviceCalendarGateway gateway;
    late DeviceCalendarSyncService sync;
    late Tasks task;

    setUp(() async {
      isar = await openTestIsar();
      todoRepo = TodoRepository(isar);
      settings = Settings()..deviceCalendarSyncEnabled = true;
      gateway = FakeDeviceCalendarGateway();
      sync = DeviceCalendarSyncService(
        getSettings: () => settings,
        todoRepo: todoRepo,
        client: gateway,
        isAndroid: true,
      );
      task = await createTestTask(isar);
    });

    tearDown(() async {
      await closeTestIsar(isar);
    });

    test('creates event and stores deviceCalendarEventId', () async {
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Meeting',
        completedTime: DateTime(2026, 8, 10, 15),
      );

      await sync.ensureSynced(todo);

      expect(gateway.createdCalendars, [
        DeviceCalendarSyncService.zestCalendarName,
      ]);
      expect(gateway.created.length, 1);
      expect(gateway.created.single.calendarId, 'cal-1');
      expect(gateway.created.single.title, 'Meeting');
      expect(gateway.created.single.startDate, DateTime(2026, 8, 10, 15));
      expect(gateway.created.single.endDate, DateTime(2026, 8, 10, 16));
      expect(todo.deviceCalendarEventId, 'evt-1');
      expect(settings.deviceCalendarId, 'cal-1');

      final reloaded = await todoRepo.getById(todo.id);
      expect(reloaded?.deviceCalendarEventId, 'evt-1');
    });

    test('auto-selects Google primary over local Zest', () async {
      gateway.calendars = [_googlePrimary(), _localZest()];
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Visible',
        completedTime: DateTime(2026, 8, 10, 15),
      );

      await sync.ensureSynced(todo);

      expect(gateway.createdCalendars, isEmpty);
      expect(gateway.created.single.calendarId, 'google-primary');
      expect(settings.deviceCalendarId, 'google-primary');
    });

    test('migrates leftover local Zest id to Google when available', () async {
      settings.deviceCalendarId = 'local-zest';
      gateway.calendars = [_googlePrimary(), _localZest()];
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Migrate',
        completedTime: DateTime(2026, 8, 10, 15),
      );
      todo.deviceCalendarEventId = 'old-zest-evt';
      await todoRepo.update(todo);

      await sync.ensureSynced(todo);

      expect(gateway.created.single.calendarId, 'google-primary');
      expect(gateway.created.single.title, 'Migrate');
      expect(todo.deviceCalendarEventId, 'evt-1');
      expect(settings.deviceCalendarId, 'google-primary');
    });

    test('keeps non-Zest local calendar when explicitly saved', () async {
      settings.deviceCalendarId = 'existing-local';
      gateway.calendars = [_googlePrimary(), _localPhone()];
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Call',
        completedTime: DateTime(2026, 8, 10, 15),
      );

      await sync.ensureSynced(todo);

      expect(gateway.created.single.calendarId, 'existing-local');
      expect(settings.deviceCalendarId, 'existing-local');
    });

    test('creates local Zest when no Google calendar exists', () async {
      gateway.calendars = const [];
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Offline',
        completedTime: DateTime(2026, 8, 10, 15),
      );

      await sync.ensureSynced(todo);

      expect(gateway.createdCalendars, [
        DeviceCalendarSyncService.zestCalendarName,
      ]);
      expect(gateway.created.single.calendarId, 'cal-1');
    });

    test('updates existing event when already linked', () async {
      gateway.calendars = [_localZest(id: 'local-1')];
      settings.deviceCalendarId = 'local-1';
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Old',
        completedTime: DateTime(2026, 8, 10, 15),
      );
      todo.deviceCalendarEventId = 'evt-9';
      await todoRepo.update(todo);

      todo.name = 'New';
      await todoRepo.update(todo);
      await sync.ensureSynced(todo);

      expect(gateway.created, isEmpty);
      expect(gateway.updated.length, 1);
      expect(gateway.updated.single.eventId, 'evt-9');
      expect(gateway.updated.single.title, 'New');
    });

    test('recreates event when update fails', () async {
      gateway.calendars = [_localZest(id: 'local-1')];
      settings.deviceCalendarId = 'local-1';
      gateway.failUpdateForIds.add('missing-evt');
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Recover',
        completedTime: DateTime(2026, 8, 10, 15),
      );
      todo.deviceCalendarEventId = 'missing-evt';
      await todoRepo.update(todo);

      await sync.ensureSynced(todo);

      expect(gateway.updated, isEmpty);
      expect(gateway.created.length, 1);
      expect(todo.deviceCalendarEventId, 'evt-1');
      final reloaded = await todoRepo.getById(todo.id);
      expect(reloaded?.deviceCalendarEventId, 'evt-1');
    });

    test('removes linked event when sync should stop', () async {
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Done soon',
        completedTime: DateTime(2026, 8, 10, 15),
      );
      todo.deviceCalendarEventId = 'evt-3';
      await todoRepo.update(todo);

      settings.deviceCalendarSyncEnabled = false;
      await sync.ensureSynced(todo);

      expect(gateway.deleted, ['evt-3']);
      expect(todo.deviceCalendarEventId, isNull);
    });

    test('removeSynced deletes by stored id from DB', () async {
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Delete me',
        completedTime: DateTime(2026, 8, 10, 15),
      );
      todo.deviceCalendarEventId = 'evt-del';
      await todoRepo.update(todo);

      final stale = await todoRepo.getById(todo.id);
      stale!.deviceCalendarEventId = null;

      await sync.removeSynced(stale);

      expect(gateway.deleted, ['evt-del']);
      expect(stale.deviceCalendarEventId, isNull);
    });

    test('no-ops when not Android', () async {
      final offline = DeviceCalendarSyncService(
        getSettings: () => settings,
        todoRepo: todoRepo,
        client: gateway,
        isAndroid: false,
      );
      final todo = await createTestTodo(
        isar,
        task: task,
        name: 'Skip',
        completedTime: DateTime(2026, 8, 10, 15),
      );

      await offline.ensureSynced(todo);

      expect(gateway.created, isEmpty);
      expect(todo.deviceCalendarEventId, isNull);
    });
  });
}

class CalendarEventSnapshot {
  CalendarEventSnapshot({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.calendarId,
    this.eventId,
  });

  final String? calendarId;
  final String? eventId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
}

class FakeDeviceCalendarGateway implements DeviceCalendarGateway {
  final List<CalendarEventSnapshot> created = [];
  final List<CalendarEventSnapshot> updated = [];
  final List<String> deleted = [];
  final List<String> createdCalendars = [];
  final Set<String> failUpdateForIds = {};
  List<Calendar> calendars = const [];
  int _nextId = 1;
  int _nextCalendarId = 1;

  @override
  Future<CalendarPermissionStatus> requestPermissions({
    CalendarAccessLevel level = CalendarAccessLevel.full,
  }) async => CalendarPermissionStatus.granted;

  @override
  Future<List<Calendar>> listCalendars() async => calendars;

  @override
  Future<String> createCalendar({
    required String name,
    String? colorHex,
    CreateCalendarPlatformOptions? platformOptions,
  }) async {
    final id = 'cal-${_nextCalendarId++}';
    createdCalendars.add(name);
    calendars = [
      ...calendars,
      Calendar(
        id: id,
        name: name,
        readOnly: false,
        accountType: DeviceCalendarSyncService.localAccountType,
        accountName: name,
      ),
    ];
    return id;
  }

  @override
  Future<String> createEvent({
    String? calendarId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    if (calendarId == null && calendars.isEmpty) {
      throw DeviceCalendarException(
        errorCode: DeviceCalendarError.operationFailed,
        message: 'No writable calendar available',
      );
    }
    created.add(
      CalendarEventSnapshot(
        calendarId: calendarId,
        title: title,
        startDate: startDate,
        endDate: endDate,
        description: description,
      ),
    );
    return 'evt-${_nextId++}';
  }

  @override
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    if (failUpdateForIds.contains(eventId)) {
      throw DeviceCalendarException(
        errorCode: DeviceCalendarError.notFound,
        message: 'Event with ID $eventId not found',
      );
    }
    updated.add(
      CalendarEventSnapshot(
        eventId: eventId,
        title: title,
        startDate: startDate,
        endDate: endDate,
        description: description,
      ),
    );
  }

  @override
  Future<void> deleteEvent({required String eventId}) async {
    deleted.add(eventId);
  }
}
