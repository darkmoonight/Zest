import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/features/settings/presentation/view/app_license_page.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';
import 'package:zest/core/utils/url_launcher_utils.dart';

/// Licenses, GitHub, and app version.
class SettingsAboutSection extends ConsumerWidget {
  /// Creates a [SettingsAboutSection].
  const SettingsAboutSection({super.key});

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider).value;

    return SettingsSection(
      title: 'aboutApp',
      icon: IconsaxPlusBold.info_circle,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.document_text),
          title: 'license',
          onTap: () {
            NavigationHelper.toDownToUp(context, () => const AppLicensePage());
          },
        ),
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.github),
          title: '${'project'.tr} ${'github'.tr}',
          onTap: () =>
              launchExternalUrl('https://github.com/darkmoonight/Zest'),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.code_circle),
          title: 'version',
          value: appVersion ?? '...',
        ),
      ],
    );
  }
}
