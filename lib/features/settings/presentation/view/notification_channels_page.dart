import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/core/notifications/notification_settings_launcher.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/settings/presentation/widgets/settings_secondary_app_bar.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';

/// Lists Android notification channels and deep-links into system Settings.
///
/// Channel importance, sound, and vibration can only be changed by the user in
/// the system UI after a channel is created.
class NotificationChannelsPage extends StatelessWidget {
  /// Creates a [NotificationChannelsPage].
  const NotificationChannelsPage({super.key});

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      appBar: SettingsSecondaryAppBar(title: 'notificationChannels'.tr),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? padding : padding * 2,
            vertical: padding,
          ),
          children: [
            SettingsSection(
              title: 'notificationChannels',
              icon: IconsaxPlusBold.notification,
              children: [
                SettingsTile(
                  leading: const Icon(IconsaxPlusLinear.setting_2),
                  title: 'manageAppNotifications',
                  onTap: () => _openSettings(
                    context,
                    NotificationSettingsLauncher.openAppSettings,
                  ),
                ),
                for (final config in allNotificationChannelConfigs)
                  SettingsTile(
                    leading: Icon(_leadingIconFor(config.priority)),
                    title: config.nameKey,
                    subtitle: config.hintKey,
                    iconColor: config.priority.color,
                    onTap: () => _openSettings(
                      context,
                      () => NotificationSettingsLauncher.openChannelSettings(
                        config.id,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: padding * 2),
          ],
        ),
      ),
    );
  }

  /// Leading icon for a priority channel row.
  static IconData _leadingIconFor(Priority priority) {
    return switch (priority) {
      Priority.none => IconsaxPlusLinear.notification,
      _ => IconsaxPlusLinear.flag,
    };
  }

  /// Runs [action] and shows a localized snackbar if launching Settings fails.
  static Future<void> _openSettings(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('failedToOpenSettings'.trFormat({'error': '$e'})),
        ),
      );
    }
  }
}
