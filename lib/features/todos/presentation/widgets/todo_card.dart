import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/todo_card_layout_config.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/domain/entities/entities.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/features/todos/presentation/utils/priority_colors.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/features/todos/presentation/view/todo_todos.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/card_tap_scale_mixin.dart';
import 'package:zest/core/widgets/metadata_chip.dart';
import 'package:zest/core/widgets/selectable_card_shell.dart';
import 'package:zest/features/todos/presentation/widgets/todo_status_change_dialog.dart';

part 'todo_card/todo_card_status.dart';
part 'todo_card/todo_card_meta.dart';
part 'todo_card/todo_card_layout.dart';

const _metadataGapTight = 3.0;
const _metadataGap = 5.0;
const _metadataSectionGap = 6.0;

/// Card widget displaying a single item with status, tags, and actions.
class TodoCard extends ConsumerStatefulWidget {
  /// Creates a [TodoCard].
  const TodoCard({
    super.key,
    required this.todo,
    required this.allTodos,
    required this.calendar,
    required this.createdTodos,
    required this.completedTodos,
    required this.isSelected,
    required this.onDoubleTap,
    required this.onTap,
  });

  /// Item shown by this card.
  final Todo todo;

  /// Whether the card is rendered in the all-items list.
  final bool allTodos;

  /// Whether the card is rendered in the calendar list.
  final bool calendar;

  /// Number of subtasks under this item.
  final int createdTodos;

  /// Number of completed subtasks under this item.
  final int completedTodos;

  /// Whether the card is currently selected in multi-select mode.
  final bool isSelected;

  /// Called when the card is double tapped.
  final VoidCallback onDoubleTap;

  /// Called when the card is tapped outside the detail preview zone.
  final VoidCallback onTap;

  @override
  ConsumerState<TodoCard> createState() => _TodoCardState();
}

/// State for [TodoCard] managing tap animations and status changes.
class _TodoCardState extends ConsumerState<TodoCard>
    with
        SingleTickerProviderStateMixin,
        CardTapScaleMixin,
        _TodoCardStatus,
        _TodoCardMeta,
        _TodoCardLayout {
  static const double _detailPreviewZoneFraction = 0.15;

  /// Whether the last tap started in the detail-preview zone.
  bool _tappedRightSide = false;

  @override
  void initState() {
    super.initState();
    initCardTapScaleAnimation();
  }

  @override
  void didUpdateWidget(covariant TodoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todo.id != widget.todo.id ||
        oldWidget.todo.status != widget.todo.status ||
        oldWidget.todo.completedAt != widget.todo.completedAt) {
      _optimisticStatus = null;
      _optimisticCompletionTime = null;
    }
  }

  @override
  void dispose() {
    _statusWriteGen++;
    disposeCardTapScaleAnimation();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    handleCardTapDown(details);

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = details.localPosition;
    final width = box.size.width;
    final rightZoneStart = width * (1 - _detailPreviewZoneFraction);

    _tappedRightSide = local.dx >= rightZoneStart;

    if (_tappedRightSide) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TodosTodo(key: ValueKey(widget.todo.id), todo: widget.todo),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: AppConstants.cardTapAnimation,
        ),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    handleCardTapUp(details);
    if (!_tappedRightSide) {
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    handleCardTapCancel();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppConstants.spacingS + 2
            : AppConstants.spacingM,
        vertical: AppConstants.spacingXS,
      ),
      child: ScaleTransition(
        scale: cardTapScaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onDoubleTap: widget.onDoubleTap,
          child: _buildCardContent(
            context,
            colorScheme,
            isMobile,
            widget.isSelected,
          ),
        ),
      ),
    );
  }
}
