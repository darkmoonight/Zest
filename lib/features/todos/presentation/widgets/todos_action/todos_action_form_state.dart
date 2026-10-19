part of '../todos_action.dart';

mixin _TodosActionFormState
    on
        ConsumerState<TodosAction>,
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin<TodosAction>,
        ModalSheetAnimationMixin<TodosAction>,
        _TodosActionFields {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
    _initializeEditMode();
    _initializeEditingController();
    initModalSheetAnimations();
    _setupListeners();
    _loadAllTags();
    _preSelectDefaultCategory();
  }

  /// Prefills the category field with the resolved default when creating.
  void _preSelectDefaultCategory() {
    if (!widget.showCategory || widget.edit) return;
    getFallbackCategoryViaRepo(
          ref.read(categoryRepositoryProvider),
          ref.read(settingsProvider),
        )
        .then((defaultCategory) {
          if (!mounted || defaultCategory == null) return;
          if (_selectedCategory != null ||
              _categoryController.text.isNotEmpty) {
            return;
          }
          setState(() {
            _selectedCategory = defaultCategory;
            _categoryController.text = defaultCategory.title;
            _applyCategoryHabitDue(defaultCategory);
          });
        })
        .catchError((Object e, StackTrace stack) {
          AppLog.d('preSelectDefaultCategory failed: $e\n$stack');
          return null;
        });
  }

  /// Prefills due from a category habit reminder without copying recurrence onto the item.
  ///
  /// Category recurrence stays on [category]; items keep `recurrence: none` so midnight
  /// reopen and notifications use the category rule.
  void _applyCategoryHabitDue(Category category) {
    if (widget.edit) return;
    if (RecurrenceService.isRecurring(_todoRecurrence)) return;
    _setFormDue(
      RecurrenceService.resolveDueForTodoInCategory(
        now: DateTime.now(),
        category: category,
        todoRecurrence: RecurrenceFrequency.none,
        todoWeekdays: const [],
        todoMinuteOfDay: null,
      ),
    );
  }

  /// Writes [due] into the due field (and dirty tracker when editing).
  void _setFormDue(DateTime? due) {
    if (due == null) return;
    _timeController.text = _formatDateTime(due);
    if (widget.edit) {
      _editingController.time.value = _timeController.text;
    }
  }

  /// Finds [categoryId] in the live categories list.
  Category? _findCategoryById(int? categoryId) {
    if (categoryId == null) return null;
    for (final category in ref.read(tasksNotifierProvider).tasks) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  @override
  /// Did change metrics.
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final keyboardOpened = keyboardHeight > 0 && _previousKeyboardHeight == 0;

      if (keyboardOpened && _tagsFocusNode.hasFocus && _tagOptionsCount > 0) {
        _scrollToTagsIfNeeded();
      }

      _previousKeyboardHeight = keyboardHeight;
    });
  }

  /// Initialize controllers.
  void _initializeControllers() {
    _categoryController = TextEditingController();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _timeController = TextEditingController();
    _tagsController = TextEditingController();
    _categoryFocusNode = FocusNode();
    _tagsFocusNode = FocusNode();
    _scrollController = ScrollController();
  }

  /// Initialize edit mode.
  void _initializeEditMode() {
    if (widget.edit && widget.todo != null) {
      _selectedCategory = _findCategoryById(widget.todo!.categoryId);
      _categoryController.text = _selectedCategory?.title ?? '';
      _titleController.text = widget.todo!.name;
      _descController.text = widget.todo!.description;
      _timeController.text = _formatDateTime(widget.todo!.dueAt);
      _todoPinned = widget.todo!.fix;
      _todoPriority = widget.todo!.priority;
      _todoTags = List<String>.from(widget.todo!.tags);
      _todoRecurrence = widget.todo!.recurrence;
      _todoRecurrenceWeekdays = List<int>.from(widget.todo!.recurrenceWeekdays);
      _todoRecurrenceMode = widget.todo!.recurrenceMode;
      _todoRecurrenceMinuteOfDay = widget.todo!.recurrenceMinuteOfDay;
    } else if (!widget.edit && widget.category != null) {
      // Keep item recurrence as none; category habit owns the rule.
      _selectedCategory = widget.category;
      _applyCategoryHabitDue(widget.category!);
    }
  }

  /// Initialize editing controller.
  void _initializeEditingController() {
    _editingController = _EditingController(
      _titleController.text,
      _descController.text,
      _timeController.text,
      _todoPinned,
      _selectedCategory,
      _todoPriority,
      _todoTags,
      _todoRecurrence,
      List<int>.from(_todoRecurrenceWeekdays),
      _todoRecurrenceMode,
      _todoRecurrenceMinuteOfDay,
    );
  }

  @override
  /// Releases resources when the widget is removed.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _categoryController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _timeController.dispose();
    _tagsController.removeListener(_refreshFilteredTags);
    _tagsController.dispose();
    _categoryFocusNode.dispose();
    _tagsFocusNode.dispose();
    _editingController.dispose();
    disposeModalSheetAnimations();
    _scrollController.dispose();
    super.dispose();
  }

  /// Setup listeners.
  void _setupListeners() {
    _categoryFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _tagsController.addListener(_refreshFilteredTags);

    _tagsFocusNode.addListener(() {
      if (!mounted) return;

      if (_tagsFocusNode.hasFocus) {
        _loadAllTags()
            .then((_) {
              if (mounted && _tagOptionsCount > 0) {
                _scrollToTagsIfNeeded();
              }
            })
            .catchError((Object e, StackTrace stack) {
              AppLog.d('loadAllTags on focus failed: $e\n$stack');
            });
      }

      setState(() {});
    });
  }

  /// Scroll to tags if needed.
  void _scrollToTagsIfNeeded() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final inputCtx = _tagsInputKey.currentContext;
        if (inputCtx == null) return;

        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        if (keyboardHeight == 0) return;

        final inputBox = inputCtx.findRenderObject() as RenderBox?;
        if (inputBox == null) return;

        final inputPosition = inputBox.localToGlobal(Offset.zero);
        final inputBottom = inputPosition.dy + inputBox.size.height;

        final screenHeight = MediaQuery.of(context).size.height;
        final visibleBottom = screenHeight - keyboardHeight;

        const itemHeight = 40.0;
        const listPadding = 8.0;
        const dropdownMargin = 4.0;
        const maxDropdownHeight = 400.0;

        final dropdownHeight = (_tagOptionsCount * itemHeight + listPadding)
            .clamp(0.0, maxDropdownHeight);

        final dropdownBottom = inputBottom + dropdownMargin + dropdownHeight;

        const safeMargin = 16.0;

        if (dropdownBottom <= visibleBottom - safeMargin) return;

        const scrollDuration = Duration(milliseconds: 350);
        const scrollCurve = Curves.easeOutCubic;

        if (_scrollController.hasClients) {
          try {
            Scrollable.ensureVisible(
              inputCtx,
              alignment: 0.3,
              duration: scrollDuration,
              curve: scrollCurve,
            );
          } catch (e) {
            final scrollOffset =
                _scrollController.offset +
                (dropdownBottom - visibleBottom + safeMargin);
            final clampedOffset = scrollOffset.clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            );
            _scrollController.animateTo(
              clampedOffset,
              duration: scrollDuration,
              curve: scrollCurve,
            );
          }
        }
      });
    });
  }

  /// Format date time using a one-shot read (not a build-time watch).
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final appSettings = ref.read(appSettingsProvider);
    return DateTimeFormatHelper.formatDateTime(
      dateTime,
      timeformat: appSettings.timeformat,
      languageCode: appSettings.locale.languageCode,
    );
  }

  /// Confirms discard when leaving a dirty create/edit form.
  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) return;

    if (!_editingController.canCompose.value) {
      NavigationHelper.back(context);
      return;
    }

    final shouldPop = await showClearTextConfirmation(
      context: context,
      onConfirm: () {
        _clearControllers();
        NavigationHelper.back(context);
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back(context);
    }
  }

  /// Clear controllers.
  void _clearControllers() {
    _titleController.clear();
    _descController.clear();
    _timeController.clear();
    _categoryController.clear();
    _tagsController.clear();
    _todoTags = [];
  }

  /// Loads all unique tags from persisted items.
  Future<void> _loadAllTags() async {
    final tags = await ref
        .read(todosNotifierProvider.notifier)
        .collectUniqueTags();

    if (!mounted) return;

    setState(() {
      _allKnownTags = tags;
      _filteredTagOptions = _computeFilteredTags();
      _tagOptionsCount = _filteredTagOptions.length;
    });
  }

  /// Computes tags matching the query and excluding selected tags.
  List<String> _computeFilteredTags() {
    final query = _tagsController.text.trim().toLowerCase();
    final lowerCaseTodoTags = _todoTags.map((e) => e.toLowerCase()).toSet();

    return _allKnownTags
        .where((tag) => !lowerCaseTodoTags.contains(tag.toLowerCase()))
        .where((tag) => query.isEmpty || tag.toLowerCase().contains(query))
        .toList();
  }

  /// Refreshes the inline tag picker list.
  void _refreshFilteredTags() {
    if (!mounted) return;

    setState(() {
      _filteredTagOptions = _computeFilteredTags();
      _tagOptionsCount = _filteredTagOptions.length;
    });
  }

  /// Add tag.
  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _todoTags.contains(tag)) return;

    setState(() {
      _todoTags = List.from(_todoTags)..add(tag);
      _editingController.tags.value = _todoTags;
    });
  }

  /// On tag selected.
  void _onTagSelected(String tag) {
    _addTag(tag);
    _tagsController.clear();
    _refreshFilteredTags();
  }
}

class _EditingController {
  _EditingController(
    this._initialTitle,
    this._initialDesc,
    this._initialTime,
    this._initialPinned,
    this._initialCategory,
    this._initialPriority,
    this._initialTags,
    RecurrenceFrequency initialRecurrence,
    List<int> initialRecurrenceWeekdays,
    RecurrenceMode initialRecurrenceMode,
    int? initialRecurrenceMinuteOfDay,
  ) : recurrence = RecurrenceFormFields(
        frequency: initialRecurrence,
        weekdays: initialRecurrenceWeekdays,
        mode: initialRecurrenceMode,
        minuteOfDay: initialRecurrenceMinuteOfDay,
      ) {
    title.value = _initialTitle;
    description.value = _initialDesc;
    time.value = _initialTime;
    pinned.value = _initialPinned;
    category.value = _initialCategory;
    priority.value = _initialPriority;
    tags.value = List.from(_initialTags);

    _dirtyTracker.watchAll([
      title,
      description,
      time,
      pinned,
      category,
      priority,
      tags,
      ...recurrence.listenables,
    ], _hasChanges);
  }

  final String _initialTitle;
  final String _initialDesc;
  final String _initialTime;
  final bool _initialPinned;
  final Category? _initialCategory;
  final Priority _initialPriority;
  final List<String> _initialTags;

  final title = ValueNotifier<String>('');
  final description = ValueNotifier<String>('');
  final ValueNotifier<String> time = ValueNotifier<String>('');
  final ValueNotifier<bool> pinned = ValueNotifier<bool>(false);
  final ValueNotifier<Category?> category = ValueNotifier<Category?>(null);
  final ValueNotifier<Priority> priority = ValueNotifier<Priority>(
    Priority.none,
  );
  final ValueNotifier<List<String>> tags = ValueNotifier<List<String>>([]);

  /// Recurrence dirty fields shared with the item repeat picker.
  final RecurrenceFormFields recurrence;

  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  /// Whether the item form has unsaved changes.
  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  bool _hasChanges() =>
      title.value != _initialTitle ||
      description.value != _initialDesc ||
      time.value != _initialTime ||
      pinned.value != _initialPinned ||
      category.value?.id != _initialCategory?.id ||
      priority.value != _initialPriority ||
      !listEquals(tags.value, _initialTags) ||
      recurrence.hasChanges;

  void dispose() {
    _dirtyTracker.dispose();
    title.dispose();
    description.dispose();
    time.dispose();
    pinned.dispose();
    category.dispose();
    priority.dispose();
    tags.dispose();
    recurrence.dispose();
  }
}
