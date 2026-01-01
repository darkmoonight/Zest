import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spacingL,
            bottom: AppConstants.spacingM,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                title.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
