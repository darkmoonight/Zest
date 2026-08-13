import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/i18n/tr.dart';

/// Widget that settings section.
class SettingsSection extends ConsumerWidget {
  /// Creates a [SettingsSection].
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  /// The title.
  final String title;

  /// The icon.
  final IconData icon;

  /// The children.
  final List<Widget> children;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final amoledTheme = ref.watch(
      appSettingsProvider.select((s) => s.amoledTheme),
    );

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
          shape: amoledTheme
              ? RoundedRectangleBorder(
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusXLarge,
                  ),
                )
              : null,
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
