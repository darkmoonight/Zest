import 'package:zest/domain/enums/enums.dart';

/// Domain model for a list item (todo).
class Todo {
  const Todo({
    required this.id,
    required this.name,
    this.description = '',
    this.dueAt,
    required this.createdAt,
    this.completedAt,
    this.fix = false,
    this.priority = Priority.none,
    this.status = TodoStatus.active,
    this.tags = const [],
    this.index,
    this.childrenSortOption = SortOption.none,
    this.categoryId,
    this.parentId,
    this.deviceCalendarEventId,
    this.caldavUid,
    this.caldavHref,
    this.caldavEtag,
    this.caldavDirty = false,
    this.recurrence = RecurrenceFrequency.none,
    this.recurrenceWeekdays = const [],
    this.recurrenceMode = RecurrenceMode.clone,
    this.recurrenceMinuteOfDay,
  });

  final int id;
  final String name;
  final String description;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool fix;
  final Priority priority;
  final TodoStatus status;
  final List<String> tags;
  final int? index;
  final SortOption childrenSortOption;
  final int? categoryId;
  final int? parentId;
  final String? deviceCalendarEventId;
  final String? caldavUid;
  final String? caldavHref;
  final String? caldavEtag;
  final bool caldavDirty;
  final RecurrenceFrequency recurrence;
  final List<int> recurrenceWeekdays;
  final RecurrenceMode recurrenceMode;
  final int? recurrenceMinuteOfDay;

  Todo copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? dueAt,
    bool clearDueAt = false,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool? fix,
    Priority? priority,
    TodoStatus? status,
    List<String>? tags,
    int? index,
    bool clearIndex = false,
    SortOption? childrenSortOption,
    int? categoryId,
    bool clearCategoryId = false,
    int? parentId,
    bool clearParentId = false,
    String? deviceCalendarEventId,
    bool clearDeviceCalendarEventId = false,
    String? caldavUid,
    bool clearCaldavUid = false,
    String? caldavHref,
    bool clearCaldavHref = false,
    String? caldavEtag,
    bool clearCaldavEtag = false,
    bool? caldavDirty,
    RecurrenceFrequency? recurrence,
    List<int>? recurrenceWeekdays,
    RecurrenceMode? recurrenceMode,
    int? recurrenceMinuteOfDay,
    bool clearRecurrenceMinuteOfDay = false,
  }) {
    return Todo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      fix: fix ?? this.fix,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      index: clearIndex ? null : (index ?? this.index),
      childrenSortOption: childrenSortOption ?? this.childrenSortOption,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      deviceCalendarEventId: clearDeviceCalendarEventId
          ? null
          : (deviceCalendarEventId ?? this.deviceCalendarEventId),
      caldavUid: clearCaldavUid ? null : (caldavUid ?? this.caldavUid),
      caldavHref: clearCaldavHref ? null : (caldavHref ?? this.caldavHref),
      caldavEtag: clearCaldavEtag ? null : (caldavEtag ?? this.caldavEtag),
      caldavDirty: caldavDirty ?? this.caldavDirty,
      recurrence: recurrence ?? this.recurrence,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      recurrenceMode: recurrenceMode ?? this.recurrenceMode,
      recurrenceMinuteOfDay: clearRecurrenceMinuteOfDay
          ? null
          : (recurrenceMinuteOfDay ?? this.recurrenceMinuteOfDay),
    );
  }
}
