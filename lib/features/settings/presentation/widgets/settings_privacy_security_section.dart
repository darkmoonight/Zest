import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_switch_tile.dart';

/// Screen privacy settings.
class SettingsPrivacySecuritySection extends ConsumerStatefulWidget {
  /// Creates a [SettingsPrivacySecuritySection].
  const SettingsPrivacySecuritySection({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<SettingsPrivacySecuritySection> createState() =>
      _SettingsPrivacySecuritySectionState();
}

class _SettingsPrivacySecuritySectionState
    extends SettingsSectionConsumerState<SettingsPrivacySecuritySection> {
  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final screenPrivacy = ref.watch(
      settingsProvider.select((s) => s.screenPrivacy ?? false),
    );

    return SettingsSection(
      title: 'privacySecurity',
      icon: IconsaxPlusBold.security,
      children: [
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.security_safe),
          title: 'screenPrivacy',
          value: screenPrivacy,
          onChanged: actions.saveScreenPrivacy,
        ),
      ],
    );
  }
}
