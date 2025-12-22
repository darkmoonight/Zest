import 'package:flutter/foundation.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/widgets/header_compact.dart';
import 'package:zest/app/utils/show_dialog.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TasksAction extends StatefulWidget {
  const TasksAction({
    super.key,
    required this.text,
    required this.edit,
    this.task,
    this.updateTaskName,
  });

  final String text;
  final bool edit;
  final Tasks? task;
  final VoidCallback? updateTaskName;

  @override
  State<TasksAction> createState() => _TasksActionState();
}

class _TasksActionState extends State<TasksAction> {
  final formKey = GlobalKey<FormState>();
  final todoController = Get.put(TodoController());
  Color myColor = const Color(0xFF2196F3);

  final TextEditingController titleCategoryEdit = TextEditingController();
  final TextEditingController descCategoryEdit = TextEditingController();

  late final _EditingController controller;

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      _initializeEditMode();
    }
    controller = _EditingController(
      titleCategoryEdit.text,
      descCategoryEdit.text,
      myColor,
    );
  }

  void _initializeEditMode() {
    titleCategoryEdit.text = widget.task!.title;
    descCategoryEdit.text = widget.task!.description;
    myColor = Color(widget.task!.taskColor);
  }

  void textTrim(TextEditingController controller) {
    controller.text = controller.text.trim();
    while (controller.text.contains('  ')) {
      controller.text = controller.text.replaceAll('  ', ' ');
    }
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
        titleCategoryEdit.clear();
        descCategoryEdit.clear();
        Get.back(result: true);
      },
    );

    if (shouldPop == true && mounted) {
      Get.back();
    }
  }

  void onPressed() {
    if (formKey.currentState!.validate()) {
      textTrim(titleCategoryEdit);
      textTrim(descCategoryEdit);
      if (widget.edit) {
        _updateTask();
      } else {
        _addTask();
      }
      Get.back();
    }
  }

  void _updateTask() {
    todoController.updateTask(
      widget.task!,
      titleCategoryEdit.text,
      descCategoryEdit.text,
      myColor,
    );
    widget.updateTaskName?.call();
  }

  void _addTask() {
    todoController.addTask(
      titleCategoryEdit.text,
      descCategoryEdit.text,
      myColor,
    );
    titleCategoryEdit.clear();
    descCategoryEdit.clear();
  }

  @override
  void dispose() {
    titleCategoryEdit.dispose();
    descCategoryEdit.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
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
                _buildTitleInput(),
                _buildDescriptionInput(),
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

  Widget _buildTitle() => buildBottomSheetHeaderCompact(context, widget.text);

  Widget _buildTitleInput() => MyTextForm(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    controller: titleCategoryEdit,
    labelText: 'name'.tr,
    type: TextInputType.text,
    icon: const Icon(IconsaxPlusLinear.edit),
    onChanged: (value) => controller.title.value = value,
    autofocus: !widget.edit,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'validateName'.tr;
      }
      return null;
    },
  );

  Widget _buildDescriptionInput() => MyTextForm(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    controller: descCategoryEdit,
    labelText: 'description'.tr,
    type: TextInputType.multiline,
    icon: const Icon(IconsaxPlusLinear.note_text),
    maxLine: null,
    onChanged: (value) => controller.description.value = value,
  );

  Widget _buildColorInput() => ActionChip(
    elevation: 4,
    avatar: ColorIndicator(
      height: 15,
      width: 15,
      borderRadius: 20,
      color: myColor,
      onSelectFocus: false,
    ),
    label: Text(
      'color'.tr,
      style: context.textTheme.labelLarge,
      overflow: TextOverflow.visible,
    ),
    onPressed: _showColorPicker,
  );

  Future<void> _showColorPicker() async {
    final Color newColor = await showColorPickerDialog(
      context,
      myColor,
      borderRadius: 20,
      enableShadesSelection: false,
      enableTonalPalette: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.accent: false,
        ColorPickerType.primary: true,
        ColorPickerType.wheel: false,
        ColorPickerType.both: false,
      },
    );
    setState(() {
      myColor = newColor;
      if (widget.edit) controller.color.value = newColor;
    });
  }

  Widget _buildAttributes() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    child: Row(children: [_buildColorInput()]),
  );

  Widget _buildSubmitButton() => ValueListenableBuilder(
    valueListenable: controller.canCompose,
    builder: (context, canCompose, _) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: MyTextButton(
        text: 'ready'.tr,
        onPressed: canCompose ? onPressed : null,
      ),
    ),
  );
}

class _EditingController extends ChangeNotifier {
  _EditingController(
    this.initialTitle,
    this.initialDescription,
    this.initialColor,
  ) {
    title.value = initialTitle;
    description.value = initialDescription;
    color.value = initialColor;

    title.addListener(_updateCanCompose);
    description.addListener(_updateCanCompose);
    color.addListener(_updateCanCompose);
  }

  final String? initialTitle;
  final String? initialDescription;
  final Color? initialColor;

  final title = ValueNotifier<String?>(null);
  final description = ValueNotifier<String?>(null);
  final color = ValueNotifier<Color?>(null);

  final _canCompose = ValueNotifier(false);
  ValueListenable<bool> get canCompose => _canCompose;

  void _updateCanCompose() => _canCompose.value =
      (title.value != initialTitle) ||
      (description.value != initialDescription) ||
      (color.value != initialColor);

  @override
  void dispose() {
    title.removeListener(_updateCanCompose);
    description.removeListener(_updateCanCompose);
    color.removeListener(_updateCanCompose);
    super.dispose();
  }
}
