import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

part 'db.g.dart';

@collection
class Settings {
  Id id = Isar.autoIncrement;
  bool onboard = false;
  String? theme = 'system';
  String timeformat = '24';
  bool materialColor = true;
  bool amoledTheme = false;
  bool? isImage = false;
  bool? screenPrivacy = false;
  String? language;
  String firstDay = 'monday';
  String calendarFormat = 'week';
  String defaultScreen = 'categories';
  int snoozeDuration = 10;
  @enumerated
  SortOption allTodosSortOption = SortOption.none;
  @enumerated
  SortOption calendarSortOption = SortOption.none;
}

enum SortOption {
  none,
  alphaAsc,
  alphaDesc,
  dateAsc,
  dateDesc,
  dateNotifAsc,
  dateNotifDesc,
  priorityAsc,
  priorityDesc,
  random,
}

@collection
class Tasks {
  Id id;
  String title;
  String description;
  int taskColor;
  bool archive;
  int? index;
  @enumerated
  SortOption sortOption = SortOption.none;

  @Backlink(to: 'task')
  final todos = IsarLinks<Todos>();

  Tasks({
    this.id = Isar.autoIncrement,
    required this.title,
    this.description = '',
    this.archive = false,
    required this.taskColor,
    this.index,
    this.sortOption = SortOption.none,
  });
}

@collection
class Todos {
  Id id;
  String name;
  String description;
  DateTime? todoCompletedTime;
  DateTime createdTime;
  DateTime? todoCompletionTime;
  bool done;
  bool fix;
  @enumerated
  Priority priority;
  List<String> tags = [];
  int? index;
  @enumerated
  SortOption childrenSortOption = SortOption.none;

  final parent = IsarLink<Todos>();

  @Backlink(to: 'parent')
  final children = IsarLinks<Todos>();

  final task = IsarLink<Tasks>();

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
    this.tags = const [],
    this.index,
  });
}

enum Priority {
  high(name: 'highPriority', color: Colors.red),
  medium(name: 'mediumPriority', color: Colors.orange),
  low(name: 'lowPriority', color: Colors.green),
  none(name: 'noPriority');

  const Priority({required this.name, this.color});

  final String name;
  final Color? color;
}
