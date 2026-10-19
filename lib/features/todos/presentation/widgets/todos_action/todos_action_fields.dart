part of '../todos_action.dart';

mixin _TodosActionFields on ConsumerState<TodosAction> {
  /// Form key.
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _tagsKey = GlobalKey();
  final GlobalKey _tagsInputKey = GlobalKey();

  /// The category controller.
  late final TextEditingController _categoryController;

  /// The title controller.
  late final TextEditingController _titleController;

  /// The desc controller.
  late final TextEditingController _descController;

  /// The time controller.
  late final TextEditingController _timeController;

  /// The tags controller.
  late final TextEditingController _tagsController;

  /// The category focus node.
  late final FocusNode _categoryFocusNode;

  /// The tags focus node.
  late final FocusNode _tagsFocusNode;

  /// The scroll controller.
  late final ScrollController _scrollController;

  /// The selected category.
  Category? _selectedCategory;

  /// Item pinned.
  bool _todoPinned = false;

  /// Item priority.
  Priority _todoPriority = Priority.none;

  /// Item recurrence.
  RecurrenceFrequency _todoRecurrence = RecurrenceFrequency.none;

  /// Weekdays for weekly recurrence.
  List<int> _todoRecurrenceWeekdays = [];

  /// Clone vs reopen for this item.
  RecurrenceMode _todoRecurrenceMode = RecurrenceMode.clone;

  /// Fixed reminder minutes from midnight for recurrence.
  int? _todoRecurrenceMinuteOfDay;

  /// String.
  List<String> _todoTags = [];

  /// The editing controller.
  late final _EditingController _editingController;

  /// Previous keyboard height.
  double _previousKeyboardHeight = 0;

  /// Tag options count.
  int _tagOptionsCount = 0;

  /// All tags collected from existing items.
  List<String> _allKnownTags = [];

  /// Tags matching the current query, excluding already selected ones.
  List<String> _filteredTagOptions = [];
}
