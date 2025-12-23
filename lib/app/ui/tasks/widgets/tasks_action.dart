import 'package:flutter/foundation.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/utils/responsive_utils.dart';
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

class _TasksActionState extends State<TasksAction>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final todoController = Get.put(TodoController());
  Color myColor = const Color(0xFF2196F3);

  final TextEditingController titleCategoryEdit = TextEditingController();
  final TextEditingController descCategoryEdit = TextEditingController();

  late final _EditingController controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final maxWidth = isMobile ? double.infinity : 500.0;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight:
              MediaQuery.of(context).size.height * (isMobile ? 0.95 : 0.85),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(colorScheme, isMobile),
            _buildHeader(colorScheme, padding),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Flexible(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(padding * 1.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildTitleInput(),
                                  SizedBox(height: padding * 1.2),
                                  _buildDescriptionInput(),
                                  SizedBox(height: padding * 1.5),
                                  _buildColorSection(colorScheme),
                                  SizedBox(height: padding),
                                ],
                              ),
                            ),
                          ),
                          _buildSubmitButton(colorScheme, padding),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme, bool isMobile) {
    if (!isMobile) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 1.5,
        vertical: padding,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.edit ? IconsaxPlusBold.edit : IconsaxPlusBold.folder_add,
              size: 24,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.edit ? 'editCategoryHint'.tr : 'createCategoryHint'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'name'.tr,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
        const SizedBox(height: 8),
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: titleCategoryEdit,
          labelText: 'enterCategoryName'.tr,
          type: TextInputType.text,
          icon: Icon(IconsaxPlusLinear.edit, color: colorScheme.primary),
          onChanged: (value) => controller.title.value = value,
          autofocus: !widget.edit,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'validateName'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'description'.tr,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
        const SizedBox(height: 8),
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: descCategoryEdit,
          labelText: 'enterDescription'.tr,
          type: TextInputType.multiline,
          icon: Icon(IconsaxPlusLinear.note_text, color: colorScheme.primary),
          maxLine: null,
          onChanged: (value) => controller.description.value = value,
        ),
      ],
    );
  }

  Widget _buildColorSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'categoryColor'.tr,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
        const SizedBox(height: 12),
        _buildColorPicker(colorScheme),
      ],
    );
  }

  Widget _buildColorPicker(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: myColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: myColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'selectedColor'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getColorName(myColor),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: _showColorPicker,
            icon: const Icon(IconsaxPlusLinear.colorfilter, size: 18),
            label: Text(
              'change'.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    final argb = color.toARGB32();
    final hex = '#${argb.toRadixString(16).substring(2).toUpperCase()}';
    return hex;
  }

  Future<void> _showColorPicker() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    final Color? newColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = myColor;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            IconsaxPlusBold.colorfilter,
                            size: 24,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'selectColor'.tr,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            20,
                                          ),
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'selectColorHint'.tr,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            12,
                                          ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: StatefulBuilder(
                        builder: (context, setDialogState) {
                          return ColorPicker(
                            color: tempColor,
                            onColorChanged: (Color color) {
                              setDialogState(() => tempColor = color);
                            },
                            borderRadius: 12,
                            padding: EdgeInsets.zero,
                            spacing: 8,
                            runSpacing: 8,
                            wheelDiameter: isMobile ? 180 : 220,
                            wheelWidth: 16,
                            wheelSquarePadding: 8,
                            wheelSquareBorderRadius: 8,
                            wheelHasBorder: false,
                            enableShadesSelection: false,
                            enableTonalPalette: true,
                            tonalColorSameSize: true,
                            enableOpacity: false,
                            actionButtons: const ColorPickerActionButtons(
                              visualDensity: VisualDensity.compact,
                              dialogActionButtons: false,
                            ),
                            pickersEnabled: const <ColorPickerType, bool>{
                              ColorPickerType.accent: false,
                              ColorPickerType.primary: true,
                              ColorPickerType.wheel: false,
                              ColorPickerType.both: false,
                              ColorPickerType.bw: false,
                              ColorPickerType.custom: false,
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(tempColor),
                          child: Text(
                            'select'.tr,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (newColor != null) {
      setState(() {
        myColor = newColor;
        if (widget.edit) controller.color.value = newColor;
      });
    }
  }

  Widget _buildSubmitButton(ColorScheme colorScheme, double padding) {
    return ValueListenableBuilder(
      valueListenable: controller.canCompose,
      builder: (context, canCompose, _) => Container(
        padding: EdgeInsets.all(padding * 1.5),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: MyTextButton(
            text: 'ready'.tr,
            onPressed: canCompose ? onPressed : null,
          ),
        ),
      ),
    );
  }
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
