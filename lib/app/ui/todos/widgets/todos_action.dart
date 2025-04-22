import 'package:flutter/foundation.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/utils/show_dialog.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/main.dart';

class TodosAction extends StatefulWidget {
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    required this.category,
    this.task,
    this.todo,
  });

  final String text;
  final Tasks? task;
  final Todos? todo;
  final bool edit;
  final bool category;

  @override
  State<TodosAction> createState() => _TodosActionState();
}

class _TodosActionState extends State<TodosAction> {
  final formKey = GlobalKey<FormState>();
  final todoController = Get.put(TodoController());
  Tasks? selectedTask;
  List<Tasks>? task;
  final FocusNode categoryFocusNode = FocusNode();
  final FocusNode titleFocusNode = FocusNode();
  final TextEditingController textTodoController = TextEditingController();
  final TextEditingController titleTodoEdit = TextEditingController();
  final TextEditingController descTodoEdit = TextEditingController();
  final TextEditingController timeTodoEdit = TextEditingController();
  final TextEditingController tagsTodoEdit = TextEditingController();

  bool todoPined = false;
  Priority todoPriority = Priority.none;
  List<String> todoTags = [];

  late final _EditingController controller;

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      _initializeEditMode();
    }
    controller = _EditingController(
      titleTodoEdit.text,
      descTodoEdit.text,
      timeTodoEdit.text,
      todoPined,
      selectedTask,
      todoPriority,
      todoTags,
    );
  }

  void _initializeEditMode() {
    selectedTask = widget.todo!.task.value;
    textTodoController.text = widget.todo!.task.value!.title;
    titleTodoEdit.text = widget.todo!.name;
    descTodoEdit.text = widget.todo!.description;
    timeTodoEdit.text = _formatDateTime(widget.todo!.todoCompletedTime);
    todoPined = widget.todo!.fix;
    todoPriority = widget.todo!.priority;
    todoTags = widget.todo!.tags;
  }

  String _formatDateTime(DateTime? dateTime) {
    return dateTime != null
        ? timeformat == '12'
            ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(dateTime)
            : DateFormat.yMMMEd(locale.languageCode).add_Hm().format(dateTime)
        : '';
  }

  Future<void> onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) {
      return;
    } else if (!controller.canCompose.value) {
      Get.back();
      return;
    }

    final shouldPop = await showAdaptiveDialogTextIsNotEmpty(
      context: context,
      onPressed: () {
        _clearControllers();
        Get.back(result: true);
      },
    );

    if (shouldPop == true && mounted) {
      Get.back();
    }
  }

  void _clearControllers() {
    titleTodoEdit.clear();
    descTodoEdit.clear();
    timeTodoEdit.clear();
    textTodoController.clear();
    tagsTodoEdit.clear();
  }

  void onPressed() {
    if (formKey.currentState!.validate()) {
      _trimControllers();
      _saveTodo();
      _clearControllers();
      Get.back();
    }
  }

  void _trimControllers() {
    titleTodoEdit.text = titleTodoEdit.text.trim();
    descTodoEdit.text = descTodoEdit.text.trim();
  }

  void _saveTodo() {
    if (widget.edit) {
      todoController.updateTodo(
        widget.todo!,
        selectedTask!,
        titleTodoEdit.text,
        descTodoEdit.text,
        timeTodoEdit.text,
        todoPined,
        todoPriority,
        todoTags,
      );
    } else if (widget.category) {
      todoController.addTodo(
        selectedTask!,
        titleTodoEdit.text,
        descTodoEdit.text,
        timeTodoEdit.text,
        todoPined,
        todoPriority,
        todoTags,
      );
    } else {
      todoController.addTodo(
        widget.task!,
        titleTodoEdit.text,
        descTodoEdit.text,
        timeTodoEdit.text,
        todoPined,
        todoPriority,
        todoTags,
      );
    }
  }

  @override
  void dispose() {
    textTodoController.dispose();
    titleTodoEdit.dispose();
    descTodoEdit.dispose();
    timeTodoEdit.dispose();
    tagsTodoEdit.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<List<Tasks>> getTaskAll(String pattern) async {
    final getTask = isar.tasks.filter().archiveEqualTo(false).findAllSync();
    return getTask.where((element) {
      final title = element.title.toLowerCase();
      final query = pattern.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  Widget _buildChips() {
    List<Widget> chips = [];

    for (int i = 0; i < todoTags.length; i++) {
      Padding actionChip = Padding(
        padding: const EdgeInsets.only(right: 5, top: 2),
        child: InputChip(
          elevation: 4,
          label: Text(todoTags[i]),
          deleteIcon: const Icon(IconsaxPlusLinear.close_square, size: 15),
          onDeleted: () {
            setState(() {
              todoTags = List<String>.from(todoTags)..removeAt(i);
              controller.tags.value = todoTags;
            });
          },
        ),
      );

      chips.add(actionChip);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: chips),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(),
                  _buildCategoryField(),
                  _buildTitleInput(),
                  _buildDescriptionInput(),
                  _buildTagsInput(),
                  _buildChips(),
                  _buildAttributes(),
                  _buildSubmitButton(),
                  const Gap(10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 7),
      child: Text(
        widget.text,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCategoryField() {
    return widget.category
        ? RawAutocomplete<Tasks>(
          focusNode: categoryFocusNode,
          textEditingController: textTodoController,
          fieldViewBuilder: _buildCategoryFieldView,
          optionsBuilder: _buildCategoryOptions,
          onSelected: _onCategorySelected,
          displayStringForOption: (Tasks option) => option.title,
          optionsViewBuilder: _buildCategoryOptionsView,
        )
        : const Offstage();
  }

  Widget _buildCategoryFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return MyTextForm(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      controller: textTodoController,
      focusNode: categoryFocusNode,
      labelText: 'selectCategory'.tr,
      type: TextInputType.text,
      icon: const Icon(IconsaxPlusLinear.folder_2),
      iconButton:
          textTodoController.text.isNotEmpty
              ? IconButton(
                icon: const Icon(IconsaxPlusLinear.close_square, size: 18),
                onPressed: () {
                  textTodoController.clear();
                  setState(() {});
                },
              )
              : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'selectCategory'.tr;
        }
        return null;
      },
    );
  }

  Future<Iterable<Tasks>> _buildCategoryOptions(
    TextEditingValue textEditingValue,
  ) async {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Tasks>.empty();
    }
    return getTaskAll(textEditingValue.text);
  }

  void _onCategorySelected(Tasks selection) async {
    textTodoController.text = selection.title;
    selectedTask = selection;
    setState(() {
      if (widget.edit) controller.task.value = selectedTask;
    });

    Future.microtask(() {
      if (context.mounted) {
        FocusScope.of(context).requestFocus(titleFocusNode);
      }
    });

    categoryFocusNode.unfocus();
  }

  Widget _buildCategoryOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          borderRadius: BorderRadius.circular(20),
          elevation: 4.0,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final Tasks task = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(task),
                child: ListTile(
                  title: Text(task.title, style: context.textTheme.labelLarge),
                  trailing: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(task.taskColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return MyTextForm(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      controller: titleTodoEdit,
      labelText: 'name'.tr,
      type: TextInputType.multiline,
      icon: const Icon(IconsaxPlusLinear.edit),
      focusNode: titleFocusNode,
      onChanged: (value) => controller.title.value = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'validateName'.tr;
        }
        return null;
      },
      maxLine: null,
    );
  }

  Widget _buildDescriptionInput() {
    return MyTextForm(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      controller: descTodoEdit,
      labelText: 'description'.tr,
      type: TextInputType.multiline,
      icon: const Icon(IconsaxPlusLinear.note_text),
      maxLine: null,
      onChanged: (value) => controller.description.value = value,
    );
  }

  Widget _buildTagsInput() {
    return MyTextForm(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      controller: tagsTodoEdit,
      labelText: 'tags'.tr,
      type: TextInputType.text,
      icon: const Icon(IconsaxPlusLinear.tag),
      onFieldSubmitted: (value) {
        setState(() {
          if (tagsTodoEdit.text.trim().isNotEmpty) {
            todoTags = List<String>.from(todoTags)
              ..add(tagsTodoEdit.text.trim());
            tagsTodoEdit.clear();
            controller.tags.value = todoTags;
          }
        });
      },
    );
  }

  Widget _buildAttributes() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        spacing: 10,
        children: [
          _buildDateTimeWidget(),
          _buildPriorityWidget(),
          _buildFixedWidget(),
        ],
      ),
    );
  }

  Widget _buildDateTimeWidget() {
    return RawChip(
      elevation: 4,
      avatar: const Icon(IconsaxPlusLinear.calendar_search),
      label: Text(
        timeTodoEdit.text.isNotEmpty ? timeTodoEdit.text : 'timeComplete'.tr,
      ),
      deleteIcon: const Icon(IconsaxPlusLinear.close_square, size: 15),
      onDeleted: () {
        timeTodoEdit.clear();
        setState(() {
          if (widget.edit) {
            controller.time.value = timeTodoEdit.text;
          }
        });
      },
      onPressed: _showDateTimePicker,
    );
  }

  Future<void> _showDateTimePicker() async {
    final DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      is24HourMode: timeformat != '12',
      minutesInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      transitionDuration: const Duration(milliseconds: 200),
    );

    if (dateTime != null) {
      final String formattedDate =
          timeformat == '12'
              ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(dateTime)
              : DateFormat.yMMMEd(
                locale.languageCode,
              ).add_Hm().format(dateTime);

      timeTodoEdit.text = formattedDate;

      setState(() {
        if (widget.edit) controller.time.value = formattedDate;
      });
    }
  }

  Widget _buildPriorityWidget() {
    return MenuAnchor(
      alignmentOffset: const Offset(0, -160),
      style: MenuStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        alignment: AlignmentDirectional.bottomStart,
      ),
      menuChildren: [
        for (final priority in Priority.values)
          MenuItemButton(
            leadingIcon: Icon(IconsaxPlusLinear.flag, color: priority.color),
            child: Text(priority.name.tr),
            onPressed: () {
              todoPriority = priority;
              controller.priority.value = priority;
            },
          ),
      ],
      builder: (context, menuController, _) {
        return ValueListenableBuilder(
          valueListenable: controller.priority,
          builder: (context, priority, _) {
            return ActionChip(
              elevation: 4,
              avatar: Icon(IconsaxPlusLinear.flag, color: priority.color),
              label: Text(priority.name.tr),
              onPressed: () {
                if (menuController.isOpen) {
                  menuController.close();
                } else {
                  menuController.open();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFixedWidget() {
    return ChoiceChip(
      elevation: 4,
      avatar: const Icon(IconsaxPlusLinear.attach_square),
      label: Text('todoPined'.tr),
      selected: todoPined,
      onSelected: (value) {
        setState(() {
          todoPined = value;
          if (widget.edit) controller.pined.value = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder(
      valueListenable: controller.canCompose,
      builder: (context, canCompose, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: MyTextButton(
            text: 'ready'.tr,
            onPressed: canCompose ? onPressed : null,
          ),
        );
      },
    );
  }
}

class _EditingController extends ChangeNotifier {
  _EditingController(
    this.initialTitle,
    this.initialDescription,
    this.initialTime,
    this.initialPined,
    this.initialTask,
    this.initialPriority,
    this.initialTags,
  ) {
    title.value = initialTitle;
    description.value = initialDescription;
    time.value = initialTime;
    pined.value = initialPined;
    task.value = initialTask;
    priority.value = initialPriority;
    tags.value = initialTags;

    title.addListener(_updateCanCompose);
    description.addListener(_updateCanCompose);
    time.addListener(_updateCanCompose);
    pined.addListener(_updateCanCompose);
    task.addListener(_updateCanCompose);
    priority.addListener(_updateCanCompose);
    tags.addListener(_updateCanCompose);
  }

  final String? initialTitle;
  final String? initialDescription;
  final String? initialTime;
  final bool? initialPined;
  final Tasks? initialTask;
  final Priority initialPriority;
  final List<String>? initialTags;

  final title = ValueNotifier<String?>(null);
  final description = ValueNotifier<String?>(null);
  final time = ValueNotifier<String?>(null);
  final pined = ValueNotifier<bool?>(null);
  final task = ValueNotifier<Tasks?>(null);
  final priority = ValueNotifier(Priority.none);
  final tags = ValueNotifier<List<String>?>(null);

  final _canCompose = ValueNotifier(false);
  ValueListenable<bool> get canCompose => _canCompose;

  void _updateCanCompose() {
    _canCompose.value =
        (title.value != initialTitle) ||
        (description.value != initialDescription) ||
        (time.value != initialTime) ||
        (pined.value != initialPined) ||
        (task.value != initialTask) ||
        (priority.value != initialPriority) ||
        (tags.value != initialTags);
  }

  @override
  void dispose() {
    title.removeListener(_updateCanCompose);
    description.removeListener(_updateCanCompose);
    time.removeListener(_updateCanCompose);
    pined.removeListener(_updateCanCompose);
    task.removeListener(_updateCanCompose);
    priority.removeListener(_updateCanCompose);
    tags.removeListener(_updateCanCompose);
    super.dispose();
  }
}
