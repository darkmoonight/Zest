part of '../todos_transfer.dart';

mixin _TodosTransferFields on ConsumerState<TodosTransfer> {
  /// The task controller.
  late final TextEditingController _taskController;

  /// The items controller.
  late final TextEditingController _todosController;

  /// The task focus node.
  late final FocusNode _taskFocusNode;

  /// The item focus node.
  late final FocusNode _todoFocusNode;

  /// The form key.
  late final GlobalKey<FormState> _formKey;

  /// Mode.
  TransferMode _mode = TransferMode.category;

  /// The selected category.
  Category? _selectedCategories;

  /// The selected item.
  Todo? _selectedTodo;

  /// The editing controller.
  late final _EditingController _editingController;

  /// Int.
  Future<Set<int>> _collectExcludedIds() async {
    return ref
        .read(todoServiceProvider)
        .collectSubtreeIdsForRoots(widget.todos);
  }

  /// Categories matching the autocomplete query.
  Future<Iterable<Category>> _getAvailableTasks(String pattern) async {
    final tasks = await ref
        .read(categoriesNotifierProvider.notifier)
        .getActiveSorted();

    final query = pattern.toLowerCase();

    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(query);
    });
  }

  /// Items.
  Future<Iterable<Todo>> _getAvailableTodos(String pattern) async {
    final todoRepo = ref.read(todoRepositoryProvider);
    final allTodos = await todoRepo.getAll();
    final excludedIds = await _collectExcludedIds();
    final query = pattern.toLowerCase();

    return allTodos.where((todo) {
      if (excludedIds.contains(todo.id)) return false;
      if (query.isEmpty) return true;
      return todo.name.toLowerCase().contains(query);
    });
  }

  Category? _categoryForTodo(Todo todo) {
    final categoryId = todo.categoryId;
    if (categoryId == null) return null;
    for (final category in ref.read(categoriesNotifierProvider).categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  /// Builds the info card widget.
  Widget _buildInfoCard(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: AppConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.info_circle,
            size: AppConstants.iconSizeMedium,
            color: colorScheme.primary,
          ),
          SizedBox(width: padding),
          Expanded(
            child: Text(
              'movingTodosCount'.trFormat({'count': widget.todos.length}),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the mode toggle widget.
  Widget _buildModeToggle(BuildContext context) {
    return SegmentedButton<TransferMode>(
      segments: [
        ButtonSegment<TransferMode>(
          value: TransferMode.category,
          label: Text('categories'.tr),
          icon: Icon(
            IconsaxPlusLinear.folder_2,
            size: AppConstants.iconSizeSmall,
          ),
        ),
        ButtonSegment<TransferMode>(
          value: TransferMode.todo,
          label: Text('todo'.tr),
          icon: Icon(
            IconsaxPlusLinear.task_square,
            size: AppConstants.iconSizeSmall,
          ),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (Set<TransferMode> newSelection) {
        _onModeChanged(newSelection.first);
      },
      style: ButtonStyle(visualDensity: VisualDensity.comfortable),
    );
  }

  /// Builds the destination section widget.
  Widget _buildDestinationSection(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppConstants.shortAnimation,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _mode == TransferMode.category
          ? _buildTaskAutocomplete(context)
          : _buildTodoAutocomplete(context),
    );
  }

  /// Builds the task autocomplete widget.
  Widget _buildTaskAutocomplete(BuildContext context) {
    return RawAutocomplete<Category>(
      key: const ValueKey('task'),
      focusNode: _taskFocusNode,
      textEditingController: _taskController,
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
          _buildTaskField(context, controller, focusNode),
      optionsBuilder: (textEditingValue) =>
          _getAvailableTasks(textEditingValue.text),
      onSelected: _onTaskSelected,
      displayStringForOption: (Category option) => option.title,
      optionsViewBuilder: _buildTaskOptionsView,
    );
  }

  /// Builds the task field widget.
  Widget _buildTaskField(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: controller,
      focusNode: focusNode,
      labelText: 'selectCategory'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.folder_2, color: colorScheme.primary),
      iconButton: _buildFieldActions(
        controller: controller,
        focusNode: focusNode,
        onClear: () {
          setState(() {
            controller.clear();
            _selectedCategories = null;
            _editingController.setTask(null);
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'selectCategory'.tr;
        }
        if (_selectedCategories == null) {
          return 'transfer_todo_hint'.tr;
        }
        return null;
      },
    );
  }

  /// Builds the item autocomplete widget.
  Widget _buildTodoAutocomplete(BuildContext context) {
    return RawAutocomplete<Todo>(
      key: const ValueKey('todo'),
      focusNode: _todoFocusNode,
      textEditingController: _todosController,
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
          _buildTodoField(context, controller, focusNode),
      optionsBuilder: (textEditingValue) =>
          _getAvailableTodos(textEditingValue.text),
      onSelected: _onTodoSelected,
      displayStringForOption: (Todo option) => option.name,
      optionsViewBuilder: _buildTodoOptionsView,
    );
  }

  /// Builds the item field widget.
  Widget _buildTodoField(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: controller,
      focusNode: focusNode,
      labelText: 'selectTodoParent'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.task_square, color: colorScheme.primary),
      iconButton: _buildFieldActions(
        controller: controller,
        focusNode: focusNode,
        onClear: () {
          setState(() {
            controller.clear();
            _selectedTodo = null;
            _editingController.setTodo(null);
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'selectTodoParent'.tr;
        }
        if (_selectedTodo == null) {
          return 'transfer_todo_hint'.tr;
        }
        return null;
      },
    );
  }

  /// Builds the field actions widget.
  Widget _buildFieldActions({
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.text.isNotEmpty)
          IconButton(
            icon: Icon(
              IconsaxPlusLinear.close_circle,
              size: AppConstants.iconSizeSmall,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: onClear,
          ),
        IconButton(
          icon: Icon(
            focusNode.hasFocus
                ? IconsaxPlusLinear.arrow_up_1
                : IconsaxPlusLinear.arrow_down,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            if (focusNode.hasFocus) {
              focusNode.unfocus();
            } else {
              focusNode.requestFocus();
            }
            setState(() {});
          },
        ),
      ],
    );
  }

  /// Builds the task options view widget.
  Widget _buildTaskOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Category> onSelected,
    Iterable<Category> options,
  ) {
    return AutocompleteOptionsDropdown<Category>(
      options: options,
      onSelected: onSelected,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingXS),
      maxHeight: 200,
      itemBuilder: (context, task) {
        return Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            AutocompleteColorSwatch(color: Color(task.colorArgb)),
          ],
        );
      },
    );
  }

  /// Builds the item options view widget.
  Widget _buildTodoOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Todo> onSelected,
    Iterable<Todo> options,
  ) {
    return AutocompleteOptionsDropdown<Todo>(
      options: options,
      onSelected: onSelected,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      maxHeight: 200,
      itemBuilder: (context, todo) {
        final colorScheme = Theme.of(context).colorScheme;
        final category = _categoryForTodo(todo);
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    todo.name,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (category != null) ...[
                    const SizedBox(height: AppConstants.spacingXS / 2),
                    Text(
                      category.title,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            if (category != null) ...[
              const SizedBox(width: AppConstants.spacingM),
              AutocompleteColorSwatch(color: Color(category.colorArgb)),
            ],
          ],
        );
      },
    );
  }

  /// On task selected.
  void _onTaskSelected(Category selection) {
    setState(() {
      _taskController.text = selection.title;
      _selectedCategories = selection;
      _editingController.setTask(selection);
    });
    _taskFocusNode.unfocus();
  }

  /// On item selected.
  void _onTodoSelected(Todo selection) {
    setState(() {
      _todosController.text = selection.name;
      _selectedTodo = selection;
      _editingController.setTodo(selection);
    });
    _todoFocusNode.unfocus();
  }

  /// On mode changed.
  void _onModeChanged(TransferMode newMode) {
    if (_mode == newMode) return;

    setState(() {
      _mode = newMode;

      if (_mode == TransferMode.category) {
        _selectedTodo = null;
        _todosController.clear();
        _editingController.setTodo(null);
        _todoFocusNode.unfocus();
      } else {
        _selectedCategories = null;
        _taskController.clear();
        _editingController.setTask(null);
        _taskFocusNode.unfocus();
      }
    });
  }
}
