import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/utils/show_dialog.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/main.dart';

class TodosTransfer extends StatefulWidget {
  const TodosTransfer({super.key, required this.text, required this.todos});
  final String text;
  final List<Todos> todos;

  @override
  State<TodosTransfer> createState() => _TodosTransferState();
}

class _TodosTransferState extends State<TodosTransfer> {
  final todoController = Get.put(TodoController());
  final FocusNode focusNode = FocusNode();
  Tasks? selectedTask;
  final formKeyTransfer = GlobalKey<FormState>();
  final TextEditingController transferTodoController = TextEditingController();

  late final _EditingController controller;

  @override
  void initState() {
    super.initState();
    controller = _EditingController(selectedTask);
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
        transferTodoController.clear();
        Get.back(result: true);
      },
    );

    if (shouldPop == true && mounted) {
      Get.back();
    }
  }

  Future<List<Tasks>> getTaskAll(String pattern) async {
    final getTask = isar.tasks.filter().archiveEqualTo(false).findAllSync();
    return getTask.where((element) {
      final title = element.title.toLowerCase();
      final query = pattern.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  void onPressed() {
    if (formKeyTransfer.currentState!.validate()) {
      if (selectedTask != null) {
        todoController.transferTodos(widget.todos, selectedTask!);
        todoController.doMultiSelectionTodoClear();
        transferTodoController.clear();
        Get.back();
      }
    }
  }

  @override
  void dispose() {
    transferTodoController.dispose();
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
        key: formKeyTransfer,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(context),
                _buildTodoCategory(context),
                _buildSubmitButton(context),
                const Gap(10),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildTitle(BuildContext context) => Padding(
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

  Widget _buildTodoCategory(BuildContext context) => RawAutocomplete<Tasks>(
    focusNode: focusNode,
    optionsViewOpenDirection: OptionsViewOpenDirection.up,
    textEditingController: transferTodoController,
    fieldViewBuilder: _buildFieldView,
    optionsBuilder: _buildOptions,
    onSelected: _onSelected,
    displayStringForOption: (Tasks option) => option.title,
    optionsViewBuilder: _buildOptionsView,
  );

  Widget _buildFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    VoidCallback onFieldSubmitted,
  ) => MyTextForm(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    controller: transferTodoController,
    focusNode: focusNode,
    labelText: 'selectCategory'.tr,
    type: TextInputType.text,
    icon: const Icon(IconsaxPlusLinear.folder_2),
    iconButton: transferTodoController.text.isNotEmpty
        ? IconButton(
            icon: const Icon(IconsaxPlusLinear.close_square, size: 18),
            onPressed: () {
              transferTodoController.clear();
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

  Future<Iterable<Tasks>> _buildOptions(
    TextEditingValue textEditingValue,
  ) async {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Tasks>.empty();
    }
    return getTaskAll(textEditingValue.text);
  }

  void _onSelected(Tasks selection) {
    transferTodoController.text = selection.title;
    selectedTask = selection;
    setState(() => controller.task.value = selectedTask);
    focusNode.unfocus();
  }

  Widget _buildOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
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

  Widget _buildSubmitButton(BuildContext context) => ValueListenableBuilder(
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
  _EditingController(this.initialTask) {
    task.value = initialTask;
    task.addListener(_updateCanCompose);
  }

  final Tasks? initialTask;
  final task = ValueNotifier<Tasks?>(null);
  final _canCompose = ValueNotifier(false);

  ValueListenable<bool> get canCompose => _canCompose;

  void _updateCanCompose() => _canCompose.value = (task.value != initialTask);

  @override
  void dispose() {
    task.removeListener(_updateCanCompose);
    super.dispose();
  }
}
