import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/domain/usecases/todo_usecases.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/domain/repositories/todo_repository.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';

part 'todos_state.dart';
part 'todos_notifier_crud.dart';
part 'todos_notifier_queries.dart';
part 'todos_notifier_selection.dart';

/// Shared surface for [TodosNotifier] mixins (repos, load, selection sync).
abstract class _TodosNotifierBase extends Notifier<TodosState> {
  TodoRepositoryPort get todoRepo;
  TodoService get todoService;
  Timer? get loadDebounce;
  set loadDebounce(Timer? value);
  Future<void> loadTodos();
  void resyncSelectedTodoFromIds();
  void debounceLoad();
}

/// Loads and mutates items; subscribes to Isar watch streams for live updates.
class TodosNotifier extends _TodosNotifierBase
    with _TodosNotifierCrud, _TodosNotifierQueries, _TodosNotifierSelection {
  CategoryRepositoryPort? _categoryRepo;

  TodoRepositoryPort? _todoRepo;

  Timer? _loadDebounce;

  int _loadGeneration = 0;

  CategoryRepositoryPort get categoryRepo {
    final cached = _categoryRepo;
    if (cached != null) return cached;
    final created = ref.read(categoryRepositoryProvider);
    _categoryRepo = created;
    return created;
  }

  @override
  TodoRepositoryPort get todoRepo {
    final cached = _todoRepo;
    if (cached != null) return cached;
    final created = ref.read(todoRepositoryProvider);
    _todoRepo = created;
    return created;
  }

  @override
  TodoService get todoService => ref.read(todoServiceProvider);

  @override
  Timer? get loadDebounce => _loadDebounce;

  @override
  set loadDebounce(Timer? value) => _loadDebounce = value;

  @override
  TodosState build() {
    StreamSubscription<void>? todoWatcherSubscription;

    todoWatcherSubscription = todoRepo.watchLazy().listen((_) {
      debounceLoad();
    });

    ref.onDispose(() {
      _loadDebounce?.cancel();
      todoWatcherSubscription?.cancel();
    });

    Future.microtask(loadTodos);

    return const TodosState();
  }

  @override
  void debounceLoad() {
    _loadDebounce?.cancel();
    _loadDebounce = Timer(AppConstants.debounceDelay, () async {
      await loadTodos();
    });
  }

  @override
  Future<void> loadTodos() async {
    final generation = ++_loadGeneration;
    final preservedSelectedIds = state.selectedTodoIds.toSet();
    final newTodos = await todoRepo.getAll();
    if (generation != _loadGeneration) return;
    state = state.copyWith(
      todos: newTodos,
      selectedTodoIds: preservedSelectedIds,
    );
    resyncSelectedTodoFromIds();
  }

  /// Reloads list items from the database while preserving multi-select ids.
  Future<void> reloadTodos() => loadTodos();

  /// Computes child counts for [todos] (used when building [TodosState]).
  static Map<int, (int, int)> computeChildCountsByParentId(List<Todo> todos) {
    final counts = <int, (int, int)>{};
    for (final todo in todos) {
      final parentId = todo.parentId;
      if (parentId == null) continue;
      final prev = counts[parentId] ?? (0, 0);
      counts[parentId] = (
        prev.$1 + 1,
        prev.$2 + (todo.status.isCompleted ? 1 : 0),
      );
    }
    return counts;
  }
}

/// Items notifier provider.
final todosNotifierProvider = NotifierProvider<TodosNotifier, TodosState>(
  TodosNotifier.new,
);
