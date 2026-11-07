part of '../todos_action.dart';

mixin _TodosActionAttributes
    on
        ConsumerState<TodosAction>,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave,
        _TodosActionAttributesSubtasks,
        _TodosActionAttributesDateTime,
        _TodosActionAttributesPriority,
        _TodosActionAttributesRecurrence,
        _TodosActionAttributesPin {
  Widget _buildAttributesSection(BuildContext context, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'todoAttributes'.tr,
          IconsaxPlusBold.setting_2,
        ),
        SizedBox(height: padding),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppConstants.spacingS,
            children: [
              _buildSubTaskButton(context),
              _buildDateTimeButton(context),
              _buildPriorityButton(context),
              _buildRecurrenceButton(context),
              _buildPinButton(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the section header widget.
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: AppConstants.iconSizeSmall + 2,
          color: colorScheme.primary,
        ),
        SizedBox(width: AppConstants.spacingS),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          ),
        ),
      ],
    );
  }
}
