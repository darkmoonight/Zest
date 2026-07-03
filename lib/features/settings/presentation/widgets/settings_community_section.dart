import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/core/utils/url_launcher_utils.dart';

/// Community links: Discord, Telegram.
class SettingsCommunitySection extends ConsumerWidget {
  /// Creates a [SettingsCommunitySection].
  const SettingsCommunitySection({super.key});

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSection(
      title: 'groups',
      icon: IconsaxPlusBold.people,
      children: [
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.discord),
          title: 'discord',
          onTap: () => launchExternalUrl('https://discord.gg/JMMa9aHh8f'),
        ),
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.telegram),
          title: 'telegram',
          onTap: () => launchExternalUrl('https://t.me/darkmoonightX'),
        ),
      ],
    );
  }
}
