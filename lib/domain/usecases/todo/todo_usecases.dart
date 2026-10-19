import 'package:flutter/foundation.dart' hide Category;
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/reorder_filtered.dart';
import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/ports/caldav_sync_port.dart';
import 'package:zest/domain/ports/device_calendar_sync_port.dart';
import 'package:zest/domain/ports/notification_scheduler_port.dart';
import 'package:zest/domain/repositories/todo_repository.dart';

part 'todo_mutations.dart';
part 'todo_hierarchy.dart';
part 'todo_queries.dart';

/// Shared accessors for [TodoService] mixins in this library.
abstract class _TodoServiceBase {
  TodoRepositoryPort get _todoRepo;
  NotificationSchedulerPort get _notificationService;
  DeviceCalendarSyncPort? get _calendarSync;
  CalDavSyncPort? get _caldavSync;
  String get _timeformat;
  String get _languageCode;

  Future<Set<int>> collectSubtreeIds(Todo root);
  Future<Set<int>> collectSubtreeIdsForRoots(Iterable<Todo> roots);
}

/// Item CRUD, status changes, moves, and notification scheduling.
class TodoService extends _TodoServiceBase
    with _TodoMutations, _TodoHierarchy, _TodoQueries {
  /// Creates a service with repository, notifications, and locale formatting.
  TodoService({
    required this._todoRepo,
    required this._notificationService,
    this._calendarSync,
    this._caldavSync,
    this._timeformat = AppConstants.defaultTimeformat,
    this._languageCode = AppConstants.defaultLanguageCode,
  });

  @override
  final TodoRepositoryPort _todoRepo;

  @override
  final NotificationSchedulerPort _notificationService;

  @override
  final DeviceCalendarSyncPort? _calendarSync;

  @override
  final CalDavSyncPort? _caldavSync;

  @override
  final String _timeformat;

  @override
  final String _languageCode;
}
