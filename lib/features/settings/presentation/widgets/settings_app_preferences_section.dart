import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/setting_enum_pickers.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/constants/app_languages.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/features/settings/presentation/widgets/selection_dialog.dart';
import 'package:zest/features/settings/presentation/widgets/settings_selection.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';

/// Default screen and language preferences.
class SettingsAppPreferencesSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsAppPreferencesSection].
  const SettingsAppPreferencesSection({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<SettingsAppPreferencesSection> createState() =>
      _SettingsAppPreferencesSectionState();
}

/// Widget that settings app preferences section state.
class _SettingsAppPreferencesSectionState
    extends SettingsSectionConsumerState<SettingsAppPreferencesSection> {
  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final defaultScreen = ref.watch(
      settingsProvider.select((s) => s.defaultScreen),
    );
    final locale = ref.watch(appSettingsProvider.select((s) => s.locale));

    return SettingsSection(
      title: 'appPreferences',
      icon: IconsaxPlusBold.mobile,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.monitor_mobbile),
          title: 'defaultScreen',
          value: defaultScreen.isNotEmpty
              ? defaultScreen.tr
              : AppConstants.defaultScreen.tr,
          onTap: () => _showDefaultScreenDialog(context),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.language_square),
          title: 'language',
          value:
              appLanguages.firstWhere(
                    (element) => (element['locale'] == locale),
                    orElse: () => {'name': ''},
                  )['name']
                  as String,
          onTap: () => _showLanguageDialog(context),
        ),
      ],
    );
  }

  /// Show default screen dialog.
  void _showDefaultScreenDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final picker = settingDefaultScreenPicker;
    showSettingsSelection<String>(
      context: context,
      title: picker.titleKey,
      icon: IconsaxPlusBold.monitor_mobbile,
      items: picker.items,
      currentValue: picker.read(settings),
      itemBuilder: (screen) => screen.tr,
      onSelected: actions.updateDefaultScreen,
    );
  }

  /// Show language dialog.
  void _showLanguageDialog(BuildContext context) {
    final appSettings = ref.read(appSettingsProvider);
    showSelectionDialog<Map<String, dynamic>>(
      context: context,
      title: 'language'.tr,
      icon: IconsaxPlusBold.language_square,
      items: appLanguages,
      currentValue: appLanguages.firstWhere(
        (element) =>
            (element['locale'] as Locale).languageCode ==
            appSettings.locale.languageCode,
        orElse: () => <String, dynamic>{
          'name': 'English',
          'locale': AppConstants.defaultLocale,
        },
      ),
      itemBuilder: (lang) => lang['name'] as String,
      onSelected: (value) {
        actions.updateLanguage(value['locale'] as Locale);
      },
      enableSearch: true,
    );
  }
}
