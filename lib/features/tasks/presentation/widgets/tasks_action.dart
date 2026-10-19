// app/ui/tasks/widgets/tasks_action.dart
import 'package:flutter/foundation.dart' hide Category;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/utils/default_category.dart';
import 'package:zest/domain/entities/entities.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/core/widgets/form_dirty_tracker.dart';
import 'package:zest/core/widgets/icon_container.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/core/widgets/modal_sheet_animation_mixin.dart';
import 'package:zest/core/widgets/modal_sheet_header.dart';
import 'package:zest/core/widgets/modal_sheet_save_button.dart';
import 'package:zest/core/widgets/modal_sheet_scaffold.dart';
import 'package:zest/core/widgets/recurrence_form_fields.dart';
import 'package:zest/core/widgets/text_form.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/color_extensions.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/utils/text_utils.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/features/tasks/presentation/widgets/task_sheet_option_card.dart';
import 'package:zest/features/todos/presentation/widgets/recurrence_picker.dart';

/// Bottom sheet form for creating or editing a task.
part 'tasks_action/tasks_action_fields.dart';
part 'tasks_action/tasks_action_form_state.dart';
part 'tasks_action/tasks_action_save.dart';
part 'tasks_action/tasks_action_color_picker.dart';

class TasksAction extends ConsumerStatefulWidget {
  /// Creates a [TasksAction].
  const TasksAction({
    super.key,
    required this.text,
    required this.edit,
    this.task,
    this.updateTaskName,
  });

  /// Sheet title shown in the modal header.
  final String text;

  /// Whether this sheet edits an existing task (`true`) or creates one.
  final bool edit;

  /// Existing category when [edit] is true; null when creating.
  final Category? task;

  /// Optional callback after the task title is saved (e.g. refresh parent UI).
  final VoidCallback? updateTaskName;

  @override
  /// Creates the state for this widget.
  ConsumerState<TasksAction> createState() => _TasksActionState();
}

class _TasksActionState extends ConsumerState<TasksAction>
    with
        SingleTickerProviderStateMixin,
        ModalSheetAnimationMixin,
        _TasksActionFields,
        _TasksActionFormState,
        _TasksActionSave {
  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ModalSheetScaffold(
      isMobile: isMobile,
      maxHeightFractionMobile: AppConstants.modalHeightFractionLargeMobile,
      maxHeightFractionDesktop: AppConstants.modalHeightFractionLargeDesktop,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      fadeAnimation: modalSheetFadeAnimation,
      slideAnimation: modalSheetSlideAnimation,
      header: ModalSheetHeader(
        padding: padding,
        title: widget.text,
        subtitle: widget.edit ? 'editCategoryHint'.tr : 'createCategoryHint'.tr,
        leading: Hero(
          tag: widget.edit ? 'task_icon_${widget.task!.id}' : 'task_icon_new',
          child: IconContainer(
            icon: widget.edit
                ? IconsaxPlusBold.edit
                : IconsaxPlusBold.folder_add,
            iconSize: AppConstants.iconSizeLarge,
          ),
        ),
        trailing: ModalSheetSaveButton(
          canComposeListenable: _editingController.canCompose,
          onSave: _onSavePressed,
          accentColor: colorScheme.primary,
          onAccentColor: colorScheme.onPrimary,
          label: 'ready'.tr,
        ),
      ),
      body: _buildForm(context, padding),
    );
  }

  /// Builds the form widget.
  Widget _buildForm(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
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
                    _buildColorPicker(),
                    SizedBox(height: padding * 1.2),
                    _buildDefaultToggle(),
                    SizedBox(height: padding * 1.2),
                    _buildRecurrenceRow(context),
                    SizedBox(height: padding * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
