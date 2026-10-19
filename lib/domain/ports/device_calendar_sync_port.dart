import 'package:zest/domain/entities/todo.dart';

/// One-way export of item deadlines to the device calendar.
abstract interface class DeviceCalendarSyncPort {
  /// Creates or updates the calendar event for [todo] when sync is enabled.
  Future<void> ensureSynced(Todo todo);

  /// Removes the linked calendar event for [todo], if any.
  Future<void> removeSynced(Todo todo);
}
