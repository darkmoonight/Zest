part of '../todos_action.dart';

mixin _TodosActionAttributesPin
    on
        ConsumerState<TodosAction>,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave {
  /// Builds the pin button widget.
  Widget _buildPinButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: () {
        setState(() {
          _todoPinned = !_todoPinned;
          if (widget.edit) {
            _editingController.pinned.value = _todoPinned;
          }
        });
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 36),
        backgroundColor: _todoPinned
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _todoPinned
                ? IconsaxPlusBold.attach_square
                : IconsaxPlusLinear.attach_square,
            size: 18,
            color: _todoPinned
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'todoPined'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: _todoPinned
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
