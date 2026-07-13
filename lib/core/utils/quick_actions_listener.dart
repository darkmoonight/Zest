import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/navigation/home_navigation.dart';
import 'package:zest/core/navigation/home_screen_key.dart';
import 'package:zest/core/navigation/home_tabs.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/features/todos/presentation/view/all_todos.dart';
import 'package:zest/features/todos/presentation/view/calendar_todos.dart';
import 'package:zest/features/tasks/presentation/widgets/tasks_action.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/i18n/tr.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Initializes Android/iOS quick actions and handles shortcut navigation.
class QuickActionsListener extends ConsumerStatefulWidget {
  /// Creates a listener that wraps [child] and handles launcher shortcuts.
  const QuickActionsListener({super.key, required this.child});

  /// Widget tree receiving quick-action navigation.
  final Widget child;

  @override
  ConsumerState<QuickActionsListener> createState() =>
      _QuickActionsListenerState();
}

/// State for [QuickActionsListener] managing shortcut registration and routing.
class _QuickActionsListenerState extends ConsumerState<QuickActionsListener> {
  String? _pendingShortcut;
  bool _isShowingBottomSheet = false;

  /// Registers quick-action callbacks and processes any pending shortcut.
  @override
  void initState() {
    super.initState();
    PlatformFeatures.initializeQuickActions(
      onShortcut: (type) {
        _pendingShortcut = type;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _tryHandlePending(),
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setQuickActionsItems();
      _tryHandlePending();
    });
  }

  /// Rebuilds quick-action labels when locale changes.
  @override
  Widget build(BuildContext context) {
    ref.listen(appSettingsProvider.select((s) => s.locale), (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setQuickActionsItems();
      });
    });
    return widget.child;
  }

  /// Pushes localized shortcut items to the platform quick-actions API.
  void _setQuickActionsItems() {
    if (!PlatformFeatures.supportsQuickActions) return;

    PlatformFeatures.setQuickActionItems([
      QuickActionItem(
        type: 'action_new_categories',
        localizedTitle: 'addCategory'.tr,
        icon: 'ic_shortcut_new_categories',
      ),
      QuickActionItem(
        type: 'action_new_todo',
        localizedTitle: 'addTodo'.tr,
        icon: 'ic_shortcut_new_todo',
      ),
      QuickActionItem(
        type: 'action_all_todos',
        localizedTitle: 'allTodos'.tr,
        icon: 'ic_shortcut_all_todos',
      ),
      QuickActionItem(
        type: 'action_calendar_todos',
        localizedTitle: 'calendar'.tr,
        icon: 'ic_shortcut_calendar_todos',
      ),
      QuickActionItem(
        type: 'action_statistics',
        localizedTitle: 'statistics'.tr,
        icon: 'ic_shortcut_calendar_todos',
      ),
    ]);
  }

  /// Handles a deferred shortcut once [HomeScreen] context is available.
  void _tryHandlePending() {
    if (_pendingShortcut == null) return;

    whenHomeContextReady(
      fallback: context,
      action: (ctx) {
        final type = _pendingShortcut!;
        _pendingShortcut = null;
        _handleShortcut(type, ctx);
      },
    );
  }

  /// Shows [sheet] as a modal bottom sheet, guarding against re-entry.
  Future<void> _showCreateSheet(BuildContext ctx, Widget sheet) async {
    if (_isShowingBottomSheet) return;
    _isShowingBottomSheet = true;
    await showModalBottomSheet(
      enableDrag: false,
      context: ctx,
      isScrollControlled: true,
      builder: (context) => sheet,
    );
    _isShowingBottomSheet = false;
  }

  /// Routes [type] to the matching tab or creation sheet.
  void _handleShortcut(String type, BuildContext ctx) {
    switch (type) {
      case 'action_new_categories':
        popToHomeRoot(ctx);
        homeScreenKey.currentState?.changeTabIndex(categoriesTabIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCreateSheet(ctx, TasksAction(text: 'create'.tr, edit: false));
        });
        break;
      case 'action_new_todo':
        popToHomeRoot(ctx);
        homeScreenKey.currentState?.changeTabIndex(allTodosTabIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCreateSheet(
            ctx,
            TodosAction(text: 'create'.tr, edit: false, category: true),
          );
        });
        break;
      case 'action_all_todos':
        if (homeScreenKey.currentState != null) {
          popToHomeRoot(ctx);
          homeScreenKey.currentState!.changeTabIndex(allTodosTabIndex);
        } else {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) => const AllTodos()));
        }
        break;
      case 'action_calendar_todos':
        if (homeScreenKey.currentState != null) {
          popToHomeRoot(ctx);
          homeScreenKey.currentState!.changeTabIndex(calendarTabIndex);
        } else {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) => const CalendarTodos()));
        }
        break;
      case 'action_statistics':
        popToHomeRoot(ctx);
        homeScreenKey.currentState?.changeTabIndex(statisticsTabIndex);
        break;
      default:
        break;
    }
  }
}
