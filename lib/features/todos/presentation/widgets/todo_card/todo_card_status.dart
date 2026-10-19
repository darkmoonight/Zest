part of '../todo_card.dart';

mixin _TodoCardStatus on ConsumerState<TodoCard> {
  /// Rejects stale delayed status writes after a newer interaction.
  int _statusWriteGen = 0;

  /// Optimistic status for UI; null means use [widget.todo.status].
  TodoStatus? _optimisticStatus;

  /// Optimistic completion time paired with [_optimisticStatus].
  DateTime? _optimisticCompletionTime;

  TodoStatus get _status => _optimisticStatus ?? widget.todo.status;

  DateTime? get _completionTime => _optimisticStatus != null
      ? _optimisticCompletionTime
      : widget.todo.completedAt;

  Widget _buildCheckbox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Transform.scale(
      scale: ResponsiveUtils.isMobile(context) ? 1.0 : 1.1,
      child: GestureDetector(
        onLongPress: () => _showStatusMenu(context),
        child: _status == TodoStatus.cancelled
            ? IconButton(
                icon: Icon(
                  IconsaxPlusBold.close_circle,
                  color: colorScheme.error.withValues(alpha: 0.7),
                ),
                onPressed: () => _showStatusMenu(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : Checkbox(
                value: _status == TodoStatus.done,
                shape: const CircleBorder(),
                onChanged: (val) {
                  if (val == null) return;

                  _applyLocalStatus(val ? TodoStatus.done : TodoStatus.active);
                  _persistStatus(
                    () => ref
                        .read(todosNotifierProvider.notifier)
                        .updateTodoStatus(_todoForPersist()),
                  );
                },
              ),
      ),
    );
  }

  Todo _todoForPersist() {
    final completion = _completionTime;
    return widget.todo.copyWith(
      status: _status,
      completedAt: completion,
      clearCompletedAt: completion == null,
    );
  }

  void _persistStatus(VoidCallback write) {
    final gen = ++_statusWriteGen;
    Future.delayed(AppConstants.shortAnimation, () {
      if (!mounted || gen != _statusWriteGen) return;
      write();
    });
  }

  void _showStatusMenu(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    showDialog(
      context: context,
      builder: (context) => TodoStatusChangeDialog(
        todo: widget.todo,
        hasIncompleteChildren:
            widget.createdTodos > 0 &&
            widget.completedTodos < widget.createdTodos,
        isMobile: isMobile,
        onStatusChanged: _changeStatus,
        onBulkCompletion: _handleBulkCompletion,
        onBulkCancellation: _handleBulkCancellation,
      ),
    );
  }

  void _changeStatus(TodoStatus newStatus) {
    _applyLocalStatus(newStatus);
    _persistStatus(
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatus(_todoForPersist()),
    );
  }

  void _handleBulkCompletion() {
    _applyLocalStatus(TodoStatus.done);
    _persistStatus(
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatusWithSubtasks(_todoForPersist(), TodoStatus.done),
    );
  }

  void _handleBulkCancellation() {
    _applyLocalStatus(TodoStatus.cancelled);
    _persistStatus(
      () => ref
          .read(todosNotifierProvider.notifier)
          .updateTodoStatusWithSubtasks(
            _todoForPersist(),
            TodoStatus.cancelled,
          ),
    );
  }

  void _applyLocalStatus(TodoStatus status) {
    setState(() {
      _optimisticStatus = status;
      _optimisticCompletionTime =
          (status == TodoStatus.done || status == TodoStatus.cancelled)
          ? DateTime.now()
          : null;
    });
  }
}
