import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/navigation/home_navigation.dart';
import 'package:zest/core/navigation/home_screen_key.dart';
import 'package:zest/core/navigation/home_tabs.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/i18n/tr.dart';

/// Opens the todo edit sheet when the user taps a notification body.
class NotificationNavigationListener extends ConsumerStatefulWidget {
  /// Wraps [child] and handles deferred notification navigation.
  const NotificationNavigationListener({super.key, required this.child});

  /// Widget subtree below this listener.
  final Widget child;

  @override
  ConsumerState<NotificationNavigationListener> createState() =>
      _NotificationNavigationListenerState();
}

class _NotificationNavigationListenerState
    extends ConsumerState<NotificationNavigationListener>
    with WidgetsBindingObserver {
  int? _pendingTodoId;
  bool _isShowingBottomSheet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationHandlerBridge.onTodoOpenRequested = _queueTodoOpen;
    _pendingTodoId = NotificationHandlerBridge.pendingTodoId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenPending());
  }

  @override
  void dispose() {
    if (identical(
      NotificationHandlerBridge.onTodoOpenRequested,
      _queueTodoOpen,
    )) {
      NotificationHandlerBridge.onTodoOpenRequested = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        NotificationHandlerBridge.pendingTodoId != null) {
      _pendingTodoId = NotificationHandlerBridge.pendingTodoId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenPending());
    }
  }

  void _queueTodoOpen(int todoId) {
    _pendingTodoId = todoId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenPending());
  }

  void _tryOpenPending() {
    final todoId = _pendingTodoId ?? NotificationHandlerBridge.pendingTodoId;
    if (todoId == null) return;

    whenHomeContextReady(
      fallback: context,
      action: (ctx) {
        _pendingTodoId = null;
        NotificationHandlerBridge.pendingTodoId = null;
        unawaited(_openTodo(todoId, ctx));
      },
    );
  }

  Future<void> _openTodo(int todoId, BuildContext ctx) async {
    final todo = await ref.read(todoRepositoryProvider).getById(todoId);
    if (todo == null || !ctx.mounted) return;

    await todo.task.load();
    if (!ctx.mounted) return;

    popToHomeRoot(ctx);
    homeScreenKey.currentState?.changeTabIndex(allTodosTabIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!ctx.mounted || _isShowingBottomSheet) return;

      _isShowingBottomSheet = true;
      await NavigationHelper.showFormModal(
        context: ctx,
        child: TodosAction(
          text: 'editing'.tr,
          edit: true,
          todo: todo,
          category: true,
        ),
        enableDrag: false,
      );
      _isShowingBottomSheet = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
