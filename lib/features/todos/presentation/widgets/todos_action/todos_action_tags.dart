part of '../todos_action.dart';

mixin _TodosActionTags
    on ConsumerState<TodosAction>, _TodosActionFields, _TodosActionFormState {
  Widget _buildTagsSection(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: _tagsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextForm(
          key: _tagsInputKey,
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: _tagsController,
          labelText: 'addTags'.tr,
          type: TextInputType.text,
          icon: Icon(IconsaxPlusLinear.tag, color: colorScheme.primary),
          focusNode: _tagsFocusNode,
          onTap: () {
            if (_tagsFocusNode.hasFocus && _tagOptionsCount > 0) {
              _scrollToTagsIfNeeded();
            }
          },
          onChanged: (_) => _refreshFilteredTags(),
          onFieldSubmitted: (value) {
            _addTag(value);
            _tagsController.clear();
            _tagsFocusNode.requestFocus();
            _refreshFilteredTags();
          },
        ),
        if (_tagsFocusNode.hasFocus && _filteredTagOptions.isNotEmpty) ...[
          SizedBox(height: padding * 0.75),
          _buildInlineTagPicker(context),
        ],
        if (_todoTags.isNotEmpty) ...[
          SizedBox(height: padding),
          _buildTagsChips(context),
        ],
      ],
    );
  }

  /// Maximum height for the tag picker before it becomes scrollable.
  double _tagPickerMaxHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;

    // Cap to ~5 rows so the list does not dominate the bottom of the sheet.
    return (availableHeight * 0.28).clamp(120.0, 220.0);
  }

  /// Builds the inline tag picker shown while the field is focused.
  Widget _buildInlineTagPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const itemExtent = 44.0;
    const verticalPadding = AppConstants.spacingXS * 2;

    final maxHeight = _tagPickerMaxHeight(context);
    final contentHeight =
        _filteredTagOptions.length * itemExtent + verticalPadding;
    final height = contentHeight.clamp(itemExtent + verticalPadding, maxHeight);

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: AppConstants.elevationLow,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXS),
          itemExtent: itemExtent,
          itemCount: _filteredTagOptions.length,
          itemBuilder: (BuildContext context, int index) {
            final tag = _filteredTagOptions[index];
            return InkWell(
              onTap: () => _onTagSelected(tag),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                ),
                child: Row(
                  children: [
                    Icon(
                      IconsaxPlusLinear.tag,
                      color: colorScheme.primary,
                      size: AppConstants.iconSizeSmall,
                    ),
                    SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the tags chips widget.
  Widget _buildTagsChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingXS,
      children: List.generate(
        _todoTags.length,
        (i) => InputChip(
          label: Text(_todoTags[i]),
          deleteIcon: Icon(
            IconsaxPlusLinear.close_circle,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSecondaryContainer,
          ),
          onDeleted: () {
            setState(() {
              _todoTags = List.from(_todoTags)..removeAt(i);
              _editingController.tags.value = _todoTags;
            });
            _refreshFilteredTags();
          },
          backgroundColor: colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }

  /// Builds the attributes section widget.
}
