import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/caldav/caldav_credentials.dart';
import 'package:zest/core/caldav/caldav_remote.dart';
import 'package:zest/core/caldav/caldav_sync_service.dart';
import 'package:zest/core/caldav/vtodo_record.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

import '../../helpers/isar_test_helper.dart';

class _FakeRemote implements CalDavRemote {
  _FakeRemote({required this.calendar, Map<String, VtodoRecord>? todos})
    : todos = todos ?? {};

  final CalDavCalendarInfo calendar;
  final Map<String, VtodoRecord> todos;
  bool conflictNextUpdate = false;
  final deleted = <String>[];

  @override
  Future<List<CalDavCalendarInfo>> listTodoCalendars() async => [calendar];

  @override
  Future<CalDavCalendarInfo?> calendarByHref(String href) async {
    return href == calendar.href ? calendar : null;
  }

  @override
  Future<List<VtodoRecord>> getTodos(CalDavCalendarInfo calendar) async {
    return todos.values.toList();
  }

  @override
  Future<VtodoRecord> createTodo(
    CalDavCalendarInfo calendar,
    VtodoRecord todo,
  ) async {
    final saved = todo.copyWith(
      href: '${calendar.href}${todo.uid}.ics',
      etag: 'etag-created',
    );
    todos[todo.uid] = saved;
    return saved;
  }

  @override
  Future<VtodoRecord> updateTodo(
    CalDavCalendarInfo calendar,
    VtodoRecord todo,
  ) async {
    if (conflictNextUpdate) {
      conflictNextUpdate = false;
      throw const CalDavConflict('etag mismatch');
    }
    final saved = todo.copyWith(etag: 'etag-updated');
    todos[todo.uid] = saved;
    return saved;
  }

  @override
  Future<void> deleteTodo(VtodoRecord todo) async {
    todos.remove(todo.uid);
    deleted.add(todo.uid);
  }

  @override
  Future<VtodoRecord?> getTodoByUid(
    CalDavCalendarInfo calendar,
    String uid,
  ) async {
    return todos[uid];
  }

  @override
  void close() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Settings settings;
  late TodoRepository todoRepo;
  late CalDavCredentialsStore credentials;
  late _FakeRemote remote;
  late CalDavSyncService sync;
  late Tasks category;

  const calendar = CalDavCalendarInfo(
    href: 'https://cal.example/tasks/',
    uid: 'cal-1',
    displayName: 'Tasks',
    ctag: 'ctag-1',
  );

  setUp(() async {
    isar = await openTestIsar();
    settings = Settings()
      ..caldavEnabled = true
      ..caldavUrl = 'https://cal.example'
      ..caldavUsername = 'user'
      ..caldavCalendarHref = calendar.href
      ..caldavAllowInsecure = false;
    await isar.writeTxn(() => isar.settings.put(settings));

    todoRepo = TodoRepository(isar);
    credentials = CalDavCredentialsStore.memory();
    await credentials.savePassword('secret');
    remote = _FakeRemote(calendar: calendar);
    category = await createTestTask(isar, title: 'Default');
    category.isSystem = true;
    await isar.writeTxn(() => isar.tasks.put(category));
    settings.defaultCategoryId = category.id;
    await isar.writeTxn(() => isar.settings.put(settings));

    sync = CalDavSyncService(
      isar: isar,
      getSettings: () => settings,
      todoRepo: todoRepo,
      saveSettings: (updated) async {
        settings.copyValuesFrom(updated, includeId: true);
        await isar.writeTxn(() => isar.settings.put(settings));
      },
      credentials: credentials,
      connect: ({
        required String url,
        required String username,
        required String password,
        required bool allowInsecure,
      }) async => remote,
      debounce: Duration.zero,
    );
  });

  tearDown(() async {
    sync.cancelScheduled();
    await closeTestIsar(isar);
  });

  test('pushes a dirty local item', () async {
    final todo = await createTestTodo(isar, task: category, name: 'Local');
    await sync.markDirty(todo);
    sync.cancelScheduled();

    final result = await sync.syncNow();
    expect(result.success, isTrue);

    final stored = await todoRepo.getById(todo.id);
    expect(stored?.caldavDirty, isFalse);
    expect(stored?.caldavHref, isNotNull);
    expect(remote.todos, hasLength(1));
    expect(remote.todos.values.single.summary, 'Local');
  });

  test('imports a remote-only VTODO into the default category', () async {
    remote.todos['remote-1'] = const VtodoRecord(
      uid: 'remote-1',
      href: 'https://cal.example/tasks/remote-1.ics',
      etag: 'e1',
      summary: 'From server',
      description: 'desc',
      priority: 1,
      status: 'NEEDS-ACTION',
      categories: ['tag'],
    );

    final result = await sync.syncNow();
    expect(result.success, isTrue);

    final imported = await todoRepo.getByCalDavUid('remote-1');
    expect(imported, isNotNull);
    expect(imported!.name, 'From server');
    expect(imported.description, 'desc');
    expect(imported.priority, Priority.high);
    expect(imported.tags, ['tag']);
    await imported.task.load();
    expect(imported.task.value?.id, category.id);
  });

  test('server wins on 412 conflict', () async {
    final todo = await createTestTodo(
      isar,
      task: category,
      name: 'Local title',
    );
    todo.caldavUid = 'uid-conflict';
    todo.caldavHref = 'https://cal.example/tasks/uid-conflict.ics';
    todo.caldavEtag = 'old';
    todo.caldavDirty = true;
    await todoRepo.update(todo);

    remote.todos['uid-conflict'] = const VtodoRecord(
      uid: 'uid-conflict',
      href: 'https://cal.example/tasks/uid-conflict.ics',
      etag: 'server',
      summary: 'Server title',
    );
    remote.conflictNextUpdate = true;

    final result = await sync.syncNow();
    expect(result.success, isTrue);
    expect(result.conflicts, 1);

    final stored = await todoRepo.getByCalDavUid('uid-conflict');
    expect(stored?.name, 'Server title');
    expect(stored?.caldavDirty, isFalse);
    expect(stored?.caldavEtag, 'server');
    expect(settings.caldavLastError, contains('conflicting item'));
  });

  test(
    'deletes local item when it disappeared remotely and is not dirty',
    () async {
      final todo = await createTestTodo(isar, task: category, name: 'Gone');
      todo.caldavUid = 'gone';
      todo.caldavHref = 'https://cal.example/tasks/gone.ics';
      todo.caldavEtag = 'e';
      todo.caldavDirty = false;
      await todoRepo.update(todo);

      // Prior successful sync (known ctag) required for empty-list tombstones.
      settings.caldavCtag = 'previous-ctag';
      await isar.writeTxn(() => isar.settings.put(settings));

      final result = await sync.syncNow();
      expect(result.success, isTrue);
      expect(await todoRepo.getById(todo.id), isNull);
    },
  );

  test('local delete is pushed as remote DELETE', () async {
    final todo = await createTestTodo(isar, task: category, name: 'Remove me');
    todo.caldavUid = 'del-1';
    todo.caldavHref = 'https://cal.example/tasks/del-1.ics';
    await todoRepo.update(todo);
    remote.todos['del-1'] = _recordOf(todo);

    await sync.enqueueDelete(todo);
    sync.cancelScheduled();
    await todoRepo.delete(todo.id);

    final result = await sync.syncNow();
    expect(result.success, isTrue);
    expect(remote.deleted, contains('del-1'));
    expect(remote.todos.containsKey('del-1'), isFalse);
  });
}

VtodoRecord _recordOf(Todos todo) {
  return VtodoRecord(
    uid: todo.caldavUid!,
    href: todo.caldavHref,
    etag: todo.caldavEtag,
    summary: todo.name,
  );
}
