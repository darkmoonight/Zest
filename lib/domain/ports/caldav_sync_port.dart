import 'package:zest/domain/entities/todo.dart';

/// Two-way CalDAV VTODO sync side-effects used by domain usecases.
abstract interface class CalDavSyncPort {
  /// Marks [todo] dirty and schedules a push.
  Future<void> markDirty(Todo todo);

  /// Enqueues a remote DELETE for [todo] and schedules sync.
  Future<void> enqueueDelete(Todo todo);

  /// Schedules a debounced sync pass.
  void scheduleSync();
}
