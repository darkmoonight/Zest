import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/caldav/caldav_account.dart';
import 'package:zest/core/caldav/caldav_client.dart';
import 'package:zest/core/caldav/caldav_credentials.dart';
import 'package:zest/core/caldav/caldav_pending_delete.dart';
import 'package:zest/core/caldav/caldav_remote.dart';
import 'package:zest/core/caldav/vtodo_mapper.dart';
import 'package:zest/core/caldav/vtodo_record.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/utils/default_category.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Result of a [CalDavSyncService.syncNow] pass.
class CalDavSyncResult {
  /// Creates a sync result.
  const CalDavSyncResult({
    this.skipped = false,
    this.success = false,
    this.error,
  });

  /// Sync was not configured or already in flight (queued).
  final bool skipped;

  /// Remote round-trip finished without error.
  final bool success;

  /// Failure message when [success] is false and not [skipped].
  final String? error;
}

/// Builds a [CalDavRemote] from account fields.
typedef CalDavRemoteFactory = Future<CalDavRemote> Function({
  required String url,
  required String username,
  required String password,
  required bool allowInsecure,
});

/// Two-way CalDAV VTODO sync against one selected calendar.
class CalDavSyncService {
  /// Creates a sync service.
  CalDavSyncService({
    required this.isar,
    required this.getSettings,
    required this.todoRepo,
    required this.saveSettings,
    required this.credentials,
    this.notifications,
    this.calendarSync,
    this.connect = connectCalDavRemote,
    this.debounce = const Duration(seconds: 2),
  });

  /// App database.
  final Isar isar;

  /// Live settings accessor.
  final Settings Function() getSettings;

  /// Item repository.
  final TodoRepository todoRepo;

  /// Persists settings (CTag, last sync, pending deletes, errors).
  final Future<void> Function(Settings settings) saveSettings;

  /// Password store.
  final CalDavCredentialsStore credentials;

  /// Optional reminder scheduler updated after remote apply.
  final NotificationService? notifications;

  /// Optional Android calendar export updated after remote apply.
  final DeviceCalendarSyncService? calendarSync;

  /// Factory used to open a remote session.
  final CalDavRemoteFactory connect;

  /// Delay before a mutation-triggered sync.
  final Duration debounce;

  Timer? _debounce;
  bool _syncing = false;
  bool _queued = false;

  /// Whether account + calendar are set (password checked at sync time).
  bool get isConfigured {
    final settings = getSettings();
    return settings.caldavEnabled && settings.hasCalDavSyncTarget;
  }

  /// Marks [todo] dirty and schedules a push, skipping nested subtasks.
  Future<void> markDirty(Todos todo) async {
    if (!getSettings().caldavEnabled) return;
    await todo.parent.load();
    if (todo.parent.value != null) return;
    todo.caldavUid = VtodoMapper.allocateUid(todo);
    todo.caldavDirty = true;
    await todoRepo.update(todo);
    scheduleSync();
  }

  /// Queues a remote DELETE for [todo] after the local row is gone.
  Future<void> enqueueDelete(Todos todo) async {
    if (!getSettings().caldavEnabled) return;
    final href = todo.caldavHref;
    final uid = todo.caldavUid;
    if (href == null || href.isEmpty || uid == null || uid.isEmpty) return;
    final settings = getSettings();
    final pending = CalDavPendingDelete.decode(settings.caldavPendingDeletes);
    pending.add(
      CalDavPendingDelete(uid: uid, href: href, etag: todo.caldavEtag),
    );
    settings.caldavPendingDeletes = CalDavPendingDelete.encode(pending);
    await saveSettings(settings);
    scheduleSync();
  }

  /// Debounces [syncNow] after local edits.
  void scheduleSync() {
    if (!isConfigured) return;
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      unawaited(syncNow());
    });
  }

  /// Cancels a pending debounced sync (tests / dispose).
  void cancelScheduled() {
    _debounce?.cancel();
    _debounce = null;
  }

  /// Runs a full push/pull cycle.
  Future<CalDavSyncResult> syncNow() async {
    if (_syncing) {
      _queued = true;
      return const CalDavSyncResult(skipped: true);
    }
    if (!isConfigured) {
      return const CalDavSyncResult(skipped: true);
    }

    final password = await credentials.readPassword();
    if (password == null || password.isEmpty) {
      return const CalDavSyncResult(skipped: true);
    }

    _syncing = true;
    CalDavSyncResult last = const CalDavSyncResult(skipped: true);
    try {
      do {
        _queued = false;
        last = await _syncOnce(password);
      } while (_queued);
      return last;
    } finally {
      _syncing = false;
    }
  }

  Future<CalDavSyncResult> _syncOnce(String password) async {
    final settings = getSettings();
    CalDavRemote? remote;
    try {
      remote = await connect(
        url: settings.caldavUrl!.trim(),
        username: settings.caldavUsername!.trim(),
        password: password,
        allowInsecure: settings.caldavAllowInsecure,
      );
      final calendar = await remote.calendarByHref(
        settings.caldavCalendarHref!,
      );
      if (calendar == null) {
        throw StateError('Selected CalDAV calendar is no longer available');
      }

      var pushed = await _flushPendingDeletes(remote, settings);
      pushed = await _pushDirty(remote, calendar) || pushed;
      final ctagUnchanged =
          calendar.ctag != null &&
          calendar.ctag == settings.caldavCtag &&
          !pushed;
      if (!ctagUnchanged) {
        await _pull(remote, calendar, settings);
      }

      settings.caldavCtag = calendar.ctag;
      settings.caldavLastSyncTime = DateTime.now();
      settings.caldavLastError = null;
      await saveSettings(settings);
      return const CalDavSyncResult(success: true);
    } catch (e, stack) {
      debugPrint('CalDAV sync failed: $e\n$stack');
      settings.caldavLastError = '$e';
      await saveSettings(settings);
      return CalDavSyncResult(error: '$e');
    } finally {
      remote?.close();
    }
  }

  Future<bool> _flushPendingDeletes(
    CalDavRemote remote,
    Settings settings,
  ) async {
    final pending = CalDavPendingDelete.decode(settings.caldavPendingDeletes);
    if (pending.isEmpty) return false;
    final remaining = <CalDavPendingDelete>[];
    var changed = false;
    for (final item in pending) {
      try {
        await remote.deleteTodo(
          VtodoRecord(
            uid: item.uid,
            href: item.href,
            etag: item.etag,
            summary: '',
          ),
        );
        changed = true;
      } catch (e) {
        debugPrint('CalDAV pending delete failed for ${item.uid}: $e');
        remaining.add(item);
      }
    }
    if (remaining.length != pending.length) {
      settings.caldavPendingDeletes = CalDavPendingDelete.encode(remaining);
      await saveSettings(settings);
    }
    return changed;
  }

  Future<bool> _pushDirty(
    CalDavRemote remote,
    CalDavCalendarInfo calendar,
  ) async {
    final dirty = await todoRepo.getDirtyCalDav();
    var changed = false;
    for (final todo in dirty) {
      await todo.parent.load();
      if (todo.parent.value != null) {
        todo.caldavDirty = false;
        await todoRepo.update(todo);
        continue;
      }
      todo.caldavUid = VtodoMapper.allocateUid(todo);
      final record = VtodoMapper.toRecord(todo);
      try {
        final saved = record.href == null || record.href!.isEmpty
            ? await remote.createTodo(calendar, record)
            : await remote.updateTodo(calendar, record);
        todo.caldavHref = saved.href;
        todo.caldavEtag = saved.etag;
        todo.caldavDirty = false;
        await todoRepo.update(todo);
        changed = true;
      } on CalDavConflict {
        await _applyServerCopy(remote, calendar, todo);
        changed = true;
      }
    }
    return changed;
  }

  Future<void> _applyServerCopy(
    CalDavRemote remote,
    CalDavCalendarInfo calendar,
    Todos todo,
  ) async {
    final uid = todo.caldavUid;
    if (uid == null) return;
    final remoteTodo = await remote.getTodoByUid(calendar, uid);
    if (remoteTodo == null) {
      await _deleteLocal(todo);
      return;
    }
    VtodoMapper.applyToTodo(todo, remoteTodo);
    await todoRepo.update(todo);
    await _refreshSideEffects(todo);
  }

  Future<void> _pull(
    CalDavRemote remote,
    CalDavCalendarInfo calendar,
    Settings settings,
  ) async {
    final remotes = await remote.getTodos(calendar);
    final remoteByUid = {for (final item in remotes) item.uid: item};
    final category = await getFallbackCategory(isar, settings);

    for (final remoteTodo in remotes) {
      final existing = await todoRepo.getByCalDavUid(remoteTodo.uid);
      if (existing == null) {
        if (category == null) continue;
        final created = await todoRepo.create(
          name: remoteTodo.summary,
          description: remoteTodo.description,
          completedTime: remoteTodo.due,
          fix: false,
          priority: VtodoMapper.priorityFromIcal(remoteTodo.priority),
          tags: remoteTodo.categories,
          index: (await todoRepo.getAll()).length,
          task: category,
        );
        VtodoMapper.applyToTodo(created, remoteTodo);
        await todoRepo.update(created);
        await _refreshSideEffects(created);
        continue;
      }
      if (existing.caldavDirty) continue;
      VtodoMapper.applyToTodo(existing, remoteTodo);
      await todoRepo.update(existing);
      await _refreshSideEffects(existing);
    }

    final locals = await todoRepo.getWithCalDavUid();
    for (final local in locals) {
      final uid = local.caldavUid;
      if (uid == null || remoteByUid.containsKey(uid)) continue;
      if (local.caldavDirty) continue;
      await _deleteLocal(local);
    }
  }

  Future<void> _deleteLocal(Todos todo) async {
    await notifications?.cancel(todo.id);
    await calendarSync?.removeSynced(todo);
    await todoRepo.delete(todo.id);
  }

  Future<void> _refreshSideEffects(Todos todo) async {
    if (todo.status.isCompleted || todo.dueAt == null) {
      await notifications?.cancel(todo.id);
    } else {
      await notifications?.scheduleForTodo(todo);
    }
    await calendarSync?.ensureSynced(todo);
  }
}
