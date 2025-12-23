import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class SettingCard extends StatelessWidget {
  const SettingCard({
    super.key,
    required this.icon,
    required this.text,
    this.switcher = false,
    this.dropdown = false,
    this.info = false,
    this.infoSettings = false,
    this.textInfo,
    this.dropdownName,
    this.dropdownList,
    this.dropdownChange,
    this.value,
    this.onPressed,
    this.onChange,
    this.elevation,
  });

  final Widget icon;
  final String text;
  final bool switcher;
  final bool dropdown;
  final bool info;
  final bool infoSettings;
  final String? textInfo;
  final String? dropdownName;
  final List<String>? dropdownList;
  final ValueChanged<String?>? dropdownChange;
  final bool? value;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onChange;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      elevation: elevation,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onPressed,
        leading: IconTheme(
          data: IconThemeData(color: colorScheme.primary, size: 24),
          child: icon,
        ),
        title: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          ),
          overflow: TextOverflow.visible,
        ),
        trailing: _buildTrailingWidget(context, colorScheme),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context, ColorScheme colorScheme) {
    if (switcher) {
      return Transform.scale(
        scale: ResponsiveUtils.isMobile(context) ? 0.85 : 0.9,
        child: Switch(value: value ?? false, onChanged: onChange),
      );
    } else if (dropdown) {
      return _buildDropdownButton(context, colorScheme);
    } else if (info) {
      return _buildInfoWidget(context, colorScheme);
    } else {
      return Icon(
        IconsaxPlusLinear.arrow_right_3,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      );
    }
  }

  Widget _buildDropdownButton(BuildContext context, ColorScheme colorScheme) {
    return DropdownButton<String>(
      icon: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(
          IconsaxPlusLinear.arrow_down,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      alignment: AlignmentDirectional.centerEnd,
      borderRadius: BorderRadius.circular(16),
      underline: const SizedBox.shrink(),
      value: dropdownName,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
      ),
      items: dropdownList!
          .map<DropdownMenuItem<String>>(
            (String value) =>
                DropdownMenuItem(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: dropdownChange,
    );
  }

  Widget _buildInfoWidget(BuildContext context, ColorScheme colorScheme) {
    if (infoSettings) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textInfo ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            ),
            overflow: TextOverflow.visible,
          ),
          const SizedBox(width: 8),
          Icon(
            IconsaxPlusLinear.arrow_right_3,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      );
    } else {
      return Text(
        textInfo ?? '',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.visible,
      );
    }
  }
}
