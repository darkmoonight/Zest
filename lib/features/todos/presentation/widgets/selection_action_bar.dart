import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/widgets/multi_select_action_bar.dart';
import 'package:zest/i18n/tr.dart';

/// Floating action bar for bulk todo selection.
class SelectionActionBar extends ConsumerWidget {
  /// Creates a [SelectionActionBar].
  const SelectionActionBar({
    super.key,
    required this.onTransfer,
    required this.onDelete,
    required this.onSelectAll,
    required this.isAllSelected,
    required this.selectedCount,
  });

  /// Opens the transfer sheet for selected todos.
  final VoidCallback onTransfer;

  /// Deletes selected todos after confirmation.
  final VoidCallback onDelete;

  /// Toggles select-all for the current list.
  final VoidCallback onSelectAll;

  /// Whether all visible todos are selected.
  final bool isAllSelected;

  /// Number of selected todos.
  final int selectedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiSelectActionBar(
      selectedCount: selectedCount,
      isAllSelected: isAllSelected,
      onSelectAll: onSelectAll,
      onClose: ref
          .read(todosNotifierProvider.notifier)
          .doMultiSelectionTodoClear,
      actions: [
        MultiSelectAction(
          icon: IconsaxPlusLinear.repeat,
          color: colorScheme.tertiary,
          onPressed: onTransfer,
          tooltip: 'transfer'.tr,
        ),
        MultiSelectAction(
          icon: IconsaxPlusLinear.trash,
          color: colorScheme.error,
          onPressed: onDelete,
          tooltip: 'delete'.tr,
        ),
      ],
    );
  }
}
