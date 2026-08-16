import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/features/tasks/application/tasks_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

/// Reloads category and list-item notifiers after DB maintenance.
Future<void> reloadTodosAndTasks(WidgetRef ref) async {
  await ref.read(todosNotifierProvider.notifier).reloadTodos();
  await ref.read(tasksNotifierProvider.notifier).reloadTasks();
}
