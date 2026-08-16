import 'package:material_ui/material_ui.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/widgets/todos_list.dart';

/// Configuration for the three status tabs on item list screens.
class TodosTabViewsConfig {
  /// Creates tab view configuration for [TodosTabViews].
  const TodosTabViewsConfig({
    required this.tabController,
    required this.searchFilter,
    required this.sortOption,
    this.calendar = false,
    this.allTodos = false,
    this.task,
    this.todo,
    this.selectedDay,
    this.excludeArchivedCategories = false,
  });

  /// Tab controller shared with the status tab bar.
  final TabController tabController;

  /// Current search query passed to each [TodosList].
  final String searchFilter;

  /// Sort option passed to each [TodosList].
  final SortOption sortOption;

  /// Whether lists show calendar-day filtering.
  final bool calendar;

  /// Whether lists show the global all-items scope.
  final bool allTodos;

  /// Category filter when scoped to a task.
  final Tasks? task;

  /// Parent item filter for subtasks.
  final Todos? todo;

  /// Selected calendar day when [calendar] is true.
  final DateTime? selectedDay;

  /// Hides items from archived categories when true.
  final bool excludeArchivedCategories;
}

/// Three [TodosList] tabs for active, done, and cancelled statuses.
class TodosTabViews extends StatelessWidget {
  /// Creates tab views from [config].
  const TodosTabViews({super.key, required this.config});

  /// Screen-specific list configuration.
  final TodosTabViewsConfig config;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: config.tabController,
      children: [
        for (final status in [
          TodoStatus.active,
          TodoStatus.done,
          TodoStatus.cancelled,
        ])
          TodosList(
            calendar: config.calendar,
            allTodos: config.allTodos,
            statusFilter: status,
            task: config.task,
            todo: config.todo,
            selectedDay: config.selectedDay,
            searchTodo: config.searchFilter,
            sortOption: config.sortOption,
            excludeArchivedCategories: config.excludeArchivedCategories,
          ),
      ],
    );
  }
}
