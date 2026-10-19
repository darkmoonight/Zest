part of 'todo_usecases.dart';

mixin _TodoHierarchy on _TodoServiceBase {
  /// Moves [todos] and their subtrees to [category].
  Future<void> moveTodos({
    required List<Todo> todos,
    required Category category,
  }) async {
    if (todos.isEmpty) return;

    final todosCopy = List<Todo>.from(todos);
    final allIds = <int>{};

    for (final root in todosCopy) {
      final subtreeIds = await collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _todoRepo.moveToCategory(todoIds: allIds, categoryId: category.id);
    await _syncCalDavAfterHierarchyChange(allIds);
  }

  /// Reparents [rootTodos] under [newParent], preserving nested subtrees.
  Future<void> moveTodosToParent({
    required List<Todo> rootTodos,
    required Todo? newParent,
  }) async {
    if (rootTodos.isEmpty) return;

    final rootTodosCopy = List<Todo>.from(rootTodos);
    final subtreeByRoot = <int, Set<int>>{};
    for (final root in rootTodosCopy) {
      subtreeByRoot[root.id] = await collectSubtreeIds(root);
    }

    final effectiveRoots = rootTodosCopy.where((root) {
      return !rootTodosCopy.any(
        (other) =>
            other.id != root.id &&
            (subtreeByRoot[other.id]?.contains(root.id) ?? false),
      );
    }).toList();

    final rootIds = <int>{};
    final allIds = <int>{};
    for (final root in effectiveRoots) {
      rootIds.add(root.id);
      allIds.addAll(subtreeByRoot[root.id] ?? {root.id});
    }

    if (allIds.isEmpty) return;

    if (newParent != null && allIds.contains(newParent.id)) {
      debugPrint(
        'moveTodosToParent rejected: newParent ${newParent.id} is in moved subtree',
      );
      return;
    }

    await _todoRepo.moveToParent(
      rootIds: rootIds,
      subtreeIds: allIds,
      newParentId: newParent?.id,
      newCategoryId: newParent?.categoryId,
    );
    await _syncCalDavAfterHierarchyChange(allIds);
  }

  Future<void> _syncCalDavAfterHierarchyChange(Set<int> todoIds) async {
    final caldav = _caldavSync;
    if (caldav == null) return;

    for (final id in todoIds) {
      final todo = await _todoRepo.getById(id);
      if (todo == null) continue;
      if (todo.parentId != null) {
        await caldav.enqueueDelete(todo);
        await _todoRepo.update(
          todo.copyWith(
            clearCaldavUid: true,
            clearCaldavHref: true,
            clearCaldavEtag: true,
            caldavDirty: false,
          ),
        );
      } else {
        await caldav.markDirty(todo);
      }
    }
  }

  /// Collects ids for [root] and every descendant item.
  @override
  Future<Set<int>> collectSubtreeIds(Todo root) async {
    final ids = <int>{};
    final stack = <Todo>[root];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (!ids.add(node.id)) continue;

      final children = await _todoRepo.getChildren(node.id);
      for (final child in children) {
        if (!ids.contains(child.id)) {
          stack.add(child);
        }
      }
    }

    return ids;
  }

  /// Collects ids for every root in [roots] and their descendants.
  @override
  Future<Set<int>> collectSubtreeIdsForRoots(Iterable<Todo> roots) async {
    final ids = <int>{};
    for (final root in roots) {
      ids.addAll(await collectSubtreeIds(root));
    }
    return ids;
  }
}
