import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

/// Reloads category and list-item notifiers after DB maintenance.
Future<void> reloadTodosAndCategories(WidgetRef ref) async {
  await ref.read(todosNotifierProvider.notifier).reloadTodos();
  await ref.read(categoriesNotifierProvider.notifier).reloadCategories();
}
