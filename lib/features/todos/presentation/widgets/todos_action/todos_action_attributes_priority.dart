part of '../todos_action.dart';

mixin _TodosActionAttributesPriority
    on
        ConsumerState<TodosAction>,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave {
  /// Builds the priority button widget.
  Widget _buildPriorityButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Material 3 menu defaults: each MenuItemButton has a 48px min height and
    // the menu adds 8px top + 8px bottom vertical padding (16 total).
    const double priorityMenuItemHeight = 48.0;
    const double priorityMenuVerticalPadding = 16.0;
    const double priorityMenuGap = 8.0;
    final double priorityMenuHeight =
        Priority.values.length * priorityMenuItemHeight +
        priorityMenuVerticalPadding;

    // Always open upward: the attributes row sits near the sheet bottom, so a
    // downward menu clips off-screen even when the keyboard is closed.
    final double maxUpwardOffset =
        -(MediaQuery.of(context).size.height - keyboardHeight);
    final double rawDy = -(priorityMenuHeight + priorityMenuGap);
    final double clampedDy = rawDy.clamp(maxUpwardOffset, 0.0);

    return MenuAnchor(
      alignmentOffset: Offset(0, clampedDy),

      style: MenuStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevation: WidgetStateProperty.all(8),
      ),
      menuChildren: [
        for (final priority in Priority.values)
          MenuItemButton(
            leadingIcon: Icon(
              IconsaxPlusLinear.flag,
              color: priority.color ?? colorScheme.onSurface,
            ),
            child: Text(
              priority.name.tr,
              style: TextStyle(
                fontWeight: _todoPriority == priority
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            onPressed: () {
              setState(() {
                _todoPriority = priority;
                if (widget.edit) {
                  _editingController.priority.value = priority;
                }
              });
            },
          ),
      ],
      builder: (context, menuController, _) => FilledButton.tonal(
        onPressed: () {
          if (menuController.isOpen) {
            menuController.close();
          } else {
            menuController.open();
          }
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
          backgroundColor: _todoPriority != Priority.none
              ? _todoPriority.color?.withValues(alpha: 0.15)
              : colorScheme.secondaryContainer,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusLinear.flag,
              size: 18,
              color: _todoPriority != Priority.none
                  ? _todoPriority.color
                  : colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              _todoPriority.name.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: _todoPriority != Priority.none
                    ? _todoPriority.color
                    : colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
