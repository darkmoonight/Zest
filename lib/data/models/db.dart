import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/constants/app_constants.dart';

part 'db.g.dart';

/// App preferences persisted in Isar.
@collection
class Settings {
  /// Isar primary key.
  Id id = Isar.autoIncrement;

  /// Whether the user has completed onboarding.
  bool onboard = false;

  /// Theme mode key (`light`, `dark`, or `system`).
  String? theme = AppConstants.defaultTheme;

  /// Clock format (`12` or `24`).
  String timeformat = AppConstants.defaultTimeformat;

  /// Whether to use dynamic Material You colors when available.
  bool materialColor = true;

  /// Whether dark theme uses pure black (AMOLED) surfaces.
  bool amoledTheme = false;

  /// Accent palette id from [AppColorPalette].
  String colorPalette = AppConstants.defaultColorPalette;

  /// App font id from [AppFont].
  String appFont = AppConstants.defaultAppFont;

  /// Whether task cards show a background image.
  bool? isImage = AppConstants.defaultIsImage;

  /// Whether screen capture is blocked via FLAG_SECURE.
  bool? screenPrivacy = false;

  /// Selected app language as `language_COUNTRY`.
  String? language;

  /// First day of week key for calendars.
  String firstDay = AppConstants.defaultFirstDay;

  /// Default calendar view format key.
  String calendarFormat = AppConstants.defaultCalendarFormat;

  /// Default home tab key on launch.
  String defaultScreen = AppConstants.defaultScreen;

  /// Notification snooze duration in minutes.
  int snoozeDuration = AppConstants.defaultSnoozeDuration;

  /// Sort order for the all-todos list.
  @enumerated
  SortOption allTodosSortOption = SortOption.none;

  /// Whether All Todos includes todos from archived categories.
  bool showArchivedInAllTodos = false;

  /// Whether Calendar includes todos from archived categories.
  bool showArchivedInCalendar = false;

  /// Whether Statistics includes todos from archived categories.
  bool showArchivedInStatistics = false;

  /// Sort order for the calendar todos list.
  @enumerated
  SortOption calendarSortOption = SortOption.none;

  /// Whether periodic auto-backup is enabled.
  bool autoBackupEnabled = false;

  /// How often auto-backup runs.
  @enumerated
  AutoBackupFrequency autoBackupFrequency = AutoBackupFrequency.daily;

  /// Timestamp of the last successful auto-backup.
  DateTime? lastAutoBackupTime;

  /// Maximum number of auto-backup files to retain.
  int maxAutoBackups = AppConstants.defaultMaxAutoBackups;

  /// Directory path for auto-backup files.
  String? autoBackupPath;

  /// Whether priority-based notification channels migration has completed.
  bool notificationChannelsMigrated = false;

  /// Whether the built-in Default category has already been seeded once.
  bool defaultCategorySeeded = false;

  /// User-selected default category id used when creating todos without a pick.
  int? defaultCategoryId;

  /// Bumped when the Settings Isar layout changes; triggers a re-save migration.
  int settingsSchemaVersion = 0;

  /// Copies preference fields from [other].
  ///
  /// When [includeId] is false (default), this instance keeps its own [id]
  /// (used for in-place UI rollback).
  void copyValuesFrom(Settings other, {bool includeId = false}) {
    if (includeId) id = other.id;
    onboard = other.onboard;
    theme = other.theme;
    timeformat = other.timeformat;
    materialColor = other.materialColor;
    amoledTheme = other.amoledTheme;
    colorPalette = other.colorPalette;
    appFont = other.appFont;
    isImage = other.isImage;
    screenPrivacy = other.screenPrivacy;
    language = other.language;
    firstDay = other.firstDay;
    calendarFormat = other.calendarFormat;
    defaultScreen = other.defaultScreen;
    snoozeDuration = other.snoozeDuration;
    allTodosSortOption = other.allTodosSortOption;
    showArchivedInAllTodos = other.showArchivedInAllTodos;
    showArchivedInCalendar = other.showArchivedInCalendar;
    showArchivedInStatistics = other.showArchivedInStatistics;
    calendarSortOption = other.calendarSortOption;
    autoBackupEnabled = other.autoBackupEnabled;
    autoBackupFrequency = other.autoBackupFrequency;
    lastAutoBackupTime = other.lastAutoBackupTime;
    maxAutoBackups = other.maxAutoBackups;
    autoBackupPath = other.autoBackupPath;
    notificationChannelsMigrated = other.notificationChannelsMigrated;
    defaultCategorySeeded = other.defaultCategorySeeded;
    defaultCategoryId = other.defaultCategoryId;
    settingsSchemaVersion = other.settingsSchemaVersion;
  }

  /// Returns a new [Settings] with the same preference values.
  Settings clone({bool includeId = false}) {
    final copy = Settings();
    copy.copyValuesFrom(this, includeId: includeId);
    return copy;
  }
}

/// Todo list sort options stored in settings and task/todo records.
enum SortOption {
  /// No custom sort applied.
  none,

  /// Alphabetical ascending.
  alphaAsc,

  /// Alphabetical descending.
  alphaDesc,

  /// Due date ascending.
  dateAsc,

  /// Due date descending.
  dateDesc,

  /// Notification date ascending.
  dateNotifAsc,

  /// Notification date descending.
  dateNotifDesc,

  /// Priority ascending.
  priorityAsc,

  /// Priority descending.
  priorityDesc,

  /// Random order.
  random,
}

/// Auto-backup schedule frequency.
enum AutoBackupFrequency {
  /// Backup once per day.
  daily,

  /// Backup once per week.
  weekly,

  /// Backup once per month.
  monthly,
}

/// Task category grouping todos.
@collection
class Tasks {
  /// Isar primary key.
  Id id;

  /// Display title.
  String title;

  /// Optional description.
  String description;

  /// Accent color as 32-bit ARGB.
  int taskColor;

  /// Whether the task is archived.
  bool archive;

  /// Manual sort index in the task list.
  int? index;

  /// Default sort for todos within this task.
  @enumerated
  SortOption sortOption = SortOption.none;

  /// Whether this is the built-in system Default category.
  bool isSystem;

  /// Todos belonging to this task.
  @Backlink(to: 'task')
  final todos = IsarLinks<Todos>();

  /// Creates a task with required title and color.
  Tasks({
    this.id = Isar.autoIncrement,
    required this.title,
    this.description = '',
    this.archive = false,
    required this.taskColor,
    this.index,
    this.isSystem = false,
    this.sortOption = SortOption.none,
  });
}

/// A todo item, optionally nested under a parent todo.
@collection
class Todos {
  /// Isar primary key.
  Id id;

  /// Display name.
  String name;

  /// Optional description.
  String description;

  /// Scheduled completion or reminder time.
  DateTime? todoCompletedTime;

  /// When the todo was created.
  DateTime createdTime;

  /// When the todo was marked done or cancelled.
  DateTime? todoCompletionTime;

  /// Legacy completion flag; prefer [status].
  @Deprecated('Use status field instead')
  bool done;

  /// Whether the todo is pinned.
  bool fix;

  /// Priority level for sorting and display.
  @enumerated
  Priority priority;

  /// Current lifecycle status.
  @enumerated
  TodoStatus status;

  /// User-defined tags.
  List<String> tags = [];

  /// Manual sort index within its list.
  int? index;

  /// Default sort for child todos.
  @enumerated
  SortOption childrenSortOption = SortOption.none;

  /// Parent todo when this is a subtask.
  final parent = IsarLink<Todos>();

  /// Direct child subtasks.
  @Backlink(to: 'parent')
  final children = IsarLinks<Todos>();

  /// Owning task category.
  final task = IsarLink<Tasks>();

  /// Creates a todo with required name and creation time.
  Todos({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description = '',
    this.todoCompletedTime,
    this.todoCompletionTime,
    required this.createdTime,
    this.done = false,
    this.fix = false,
    this.priority = Priority.none,
    this.status = TodoStatus.active,
    this.tags = const [],
    this.index,
  });
}

/// Todo priority levels with display labels and colors.
enum Priority {
  /// High priority.
  high(name: 'highPriority', color: Colors.red),

  /// Medium priority.
  medium(name: 'mediumPriority', color: Colors.orange),

  /// Low priority.
  low(name: 'lowPriority', color: Colors.green),

  /// No priority set.
  none(name: 'noPriority');

  /// Creates a priority with slang [name] and optional [color].
  const Priority({required this.name, this.color});

  /// Slang translation key for the priority label.
  final String name;

  /// Optional chip color for this priority.
  final Color? color;
}

/// Todo lifecycle status.
enum TodoStatus {
  /// Open and not completed.
  active,

  /// Completed successfully.
  done,

  /// Cancelled without completion.
  cancelled;

  /// Whether this status counts as finished.
  bool get isCompleted =>
      this == TodoStatus.done || this == TodoStatus.cancelled;

  /// Maps a status tab index to the corresponding [TodoStatus].
  static TodoStatus fromTabIndex(int index) => switch (index) {
    0 => TodoStatus.active,
    1 => TodoStatus.done,
    _ => TodoStatus.cancelled,
  };
}
