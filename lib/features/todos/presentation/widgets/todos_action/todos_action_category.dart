part of '../todos_action.dart';

mixin _TodosActionCategory
    on ConsumerState<TodosAction>, _TodosActionFields, _TodosActionFormState {
  Widget _buildCategorySection(BuildContext context) {
    return RawAutocomplete<Category>(
      focusNode: _categoryFocusNode,
      textEditingController: _categoryController,
      fieldViewBuilder: _buildCategoryFieldView,
      optionsBuilder: _buildCategoryOptions,
      onSelected: _onCategorySelected,
      displayStringForOption: (Category option) => option.title,
      optionsViewBuilder: _buildCategoryOptionsView,
    );
  }

  /// Builds the category field view widget.
  Widget _buildCategoryFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    VoidCallback onFieldSubmitted,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: _categoryController,
      focusNode: _categoryFocusNode,
      labelText: 'categoryOptionalHint'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.folder_2, color: colorScheme.primary),
      iconButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_categoryController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                IconsaxPlusLinear.close_square,
                size: AppConstants.iconSizeSmall,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                _categoryController.clear();
                _selectedCategory = null;
                _editingController.category.value = null;
                setState(() {});
              },
            ),
          IconButton(
            icon: Icon(
              fieldFocusNode.hasFocus
                  ? IconsaxPlusLinear.arrow_up_1
                  : IconsaxPlusLinear.arrow_down,
              size: AppConstants.iconSizeSmall,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              if (fieldFocusNode.hasFocus) {
                fieldFocusNode.unfocus();
              } else {
                fieldFocusNode.requestFocus();
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  /// Categories matching the autocomplete query.
  Future<Iterable<Category>> _buildCategoryOptions(
    TextEditingValue textEditingValue,
  ) async {
    final categories = await ref
        .read(categoriesNotifierProvider.notifier)
        .getActiveSorted();

    final query = textEditingValue.text.toLowerCase();
    if (query.isEmpty) return categories;

    return categories.where((category) {
      return category.title.toLowerCase().contains(query);
    });
  }

  /// On category selected.
  void _onCategorySelected(Category selection) {
    _categoryController.text = selection.title;
    _selectedCategory = selection;
    setState(() {
      if (widget.edit) {
        _editingController.category.value = _selectedCategory;
      } else {
        _applyCategoryHabitDue(selection);
      }
    });
    _categoryFocusNode.unfocus();
  }

  /// Builds the category options view widget.
  Widget _buildCategoryOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Category> onSelected,
    Iterable<Category> options,
  ) {
    return AutocompleteOptionsDropdown<Category>(
      options: options,
      onSelected: onSelected,
      itemBuilder: (context, category) {
        return Row(
          children: [
            Expanded(
              child: Text(
                category.title,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            AutocompleteColorSwatch(color: Color(category.colorArgb)),
          ],
        );
      },
    );
  }

  /// Builds the basic info section widget.
}
