part of '../todos_transfer.dart';

mixin _TodosTransferFormState
    on
        ConsumerState<TodosTransfer>,
        SingleTickerProviderStateMixin<TodosTransfer>,
        ModalSheetAnimationMixin<TodosTransfer>,
        _TodosTransferFields {
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    initModalSheetAnimations(duration: AppConstants.animationDuration);
  }

  /// Initialize controllers.
  void _initializeControllers() {
    _categoryController = TextEditingController();
    _todosController = TextEditingController();
    _categoryFocusNode = FocusNode();
    _todoFocusNode = FocusNode();
    _formKey = GlobalKey<FormState>();
    _editingController = _EditingController();
    _categoryController.addListener(_onCategoryTextChanged);
    _todosController.addListener(_onTodoTextChanged);
  }

  void _onCategoryTextChanged() {
    final selected = _selectedCategory;
    if (selected == null) return;
    if (_categoryController.text == selected.title) return;
    setState(() {
      _selectedCategory = null;
      _editingController.setCategory(null);
    });
  }

  void _onTodoTextChanged() {
    final selected = _selectedTodo;
    if (selected == null) return;
    if (_todosController.text == selected.name) return;
    setState(() {
      _selectedTodo = null;
      _editingController.setTodo(null);
    });
  }

  @override
  void dispose() {
    _categoryController.removeListener(_onCategoryTextChanged);
    _todosController.removeListener(_onTodoTextChanged);
    _categoryController.dispose();
    _todosController.dispose();
    _categoryFocusNode.dispose();
    _todoFocusNode.dispose();
    _editingController.dispose();
    disposeModalSheetAnimations();
    super.dispose();
  }

  /// Void.
  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) return;

    if (!_editingController.canCompose.value) {
      NavigationHelper.back(context);
      return;
    }

    final shouldPop = await showClearTextConfirmation(
      context: context,
      onConfirm: () {
        _categoryController.clear();
        _todosController.clear();
        NavigationHelper.back(context);
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back(context);
    }
  }
}

/// Tracks dirty state for the transfer form.
class _EditingController {
  _EditingController() {
    _dirtyTracker.watch(_category, _hasSelection);
    _dirtyTracker.watch(_todo, _hasSelection);
  }

  final ValueNotifier<Category?> _category = ValueNotifier(null);
  final ValueNotifier<Todo?> _todo = ValueNotifier(null);
  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  /// Whether the transfer form has a destination selected.
  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  /// Sets the destination category for the transfer.
  void setCategory(Category? category) => _category.value = category;

  /// Sets the destination parent item for the transfer.
  void setTodo(Todo? todo) => _todo.value = todo;

  bool _hasSelection() => _category.value != null || _todo.value != null;

  void dispose() {
    _dirtyTracker.dispose();
    _category.dispose();
    _todo.dispose();
  }
}
