import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/features/settings/presentation/widgets/settings_about_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_app_preferences_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_caldav_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_community_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_datetime_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_privacy_security_section.dart';

/// Root settings screen composing feature-specific sections.
class SettingsPage extends ConsumerWidget {
  /// Creates a [SettingsPage].
  const SettingsPage({super.key});

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final sectionGap = padding * 1.5;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? padding : padding * 2,
            vertical: padding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsAppearanceSection(),
              SizedBox(height: sectionGap),
              const SettingsDateTimeSection(),
              SizedBox(height: sectionGap),
              const SettingsPrivacySecuritySection(),
              SizedBox(height: sectionGap),
              const SettingsAppPreferencesSection(),
              SizedBox(height: sectionGap),
              const SettingsCalDavSection(),
              SizedBox(height: sectionGap),
              const SettingsDataSection(),
              SizedBox(height: sectionGap),
              const SettingsCommunitySection(),
              SizedBox(height: sectionGap),
              const SettingsAboutSection(),
              SizedBox(height: padding * 2),
            ],
          ),
        ),
      ),
    );
  }
}
