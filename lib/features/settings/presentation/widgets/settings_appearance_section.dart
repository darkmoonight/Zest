import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app.dart';
import 'package:zest/core/config/setting_appearance_pickers.dart';
import 'package:zest/core/config/setting_enum_pickers.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/theme/color_palette.dart';
import 'package:zest/core/theme/theme_mode_notifier.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/settings/presentation/widgets/selection_dialog.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';

/// Theme, palette, font, and image appearance settings.
class SettingsAppearanceSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsAppearanceSection].
  const SettingsAppearanceSection({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<SettingsAppearanceSection> createState() =>
      _SettingsAppearanceSectionState();
}

class _SettingsAppearanceSectionState
    extends SettingsSectionConsumerState<SettingsAppearanceSection> {
  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorPalette = ref.watch(
      appSettingsProvider.select((s) => s.colorPalette),
    );
    final appFont = ref.watch(appSettingsProvider.select((s) => s.appFont));
    final themeMode = ref.watch(themeModeProvider);
    final themeKey = switch (themeMode) {
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
    };
    final amoledTheme = ref.watch(
      appSettingsProvider.select((s) => s.amoledTheme),
    );
    final materialColor = ref.watch(
      appSettingsProvider.select((s) => s.materialColor),
    );
    final isImage = ref.watch(appSettingsProvider.select((s) => s.isImage));
    final settings = ref.read(settingsProvider);

    return SettingsSection(
      title: 'appearance',
      icon: IconsaxPlusBold.brush_1,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.moon),
          title: 'theme',
          value: themePreferenceLabel(themeKey),
          onTap: () => _showThemeDialog(context),
        ),
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.mobile),
          title: 'amoledTheme',
          value: amoledTheme,
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).saveOledTheme(value);
          },
        ),
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.colorfilter),
          title: 'materialColor',
          value: materialColor,
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).saveMaterialTheme(value);
          },
        ),
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.image),
          title: 'isImages',
          value: isImage,
          onChanged: (value) {
            actions.saveSettingsOptimistic(
              mutate: (s) => s.isImage = value,
              onOptimistic: () =>
                  ZestApp.updateAppState(ref, newIsImage: value),
            );
          },
        ),
        _buildColorPaletteTile(context, settings, materialColor, colorPalette),
        for (final def in settingAppearanceCatalogPickers)
          if (def.titleKey != 'colorPalette')
            _buildCatalogTile(context, settings, def, appFont),
      ],
    );
  }

  /// Builds the color palette tile widget.
  SettingsTile _buildColorPaletteTile(
    BuildContext context,
    Settings settings,
    bool materialColor,
    String colorPalette,
  ) {
    final disabled = materialColor;
    final muted = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.38);

    return SettingsTile(
      leading: const Icon(IconsaxPlusLinear.color_swatch),
      title: 'colorPalette',
      subtitle: disabled ? 'colorPaletteSystemHint' : null,
      value: disabled
          ? null
          : AppColorPalette.label(AppColorPalette.resolve(colorPalette)),
      titleColor: disabled ? muted : null,
      iconColor: disabled ? muted : null,
      onTap: disabled
          ? null
          : () => _showCatalogDialog(
              context,
              settingAppearanceCatalogPickers.first,
              settings,
            ),
    );
  }

  /// Builds the catalog tile widget.
  SettingsTile _buildCatalogTile(
    BuildContext context,
    Settings settings,
    SettingAppearancePickerDefinition def,
    String appFont,
  ) {
    final displayValue = def.titleKey == 'appFont'
        ? appFont
        : def.read(settings);
    return SettingsTile(
      leading: Icon(def.icon),
      title: def.titleKey,
      value: def.itemBuilder(displayValue),
      onTap: () => _showCatalogDialog(context, def, settings),
    );
  }

  /// Show theme dialog.
  void _showThemeDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final picker = settingThemePicker;
    showSelectionDialog<String>(
      context: context,
      title: picker.titleKey.tr,
      icon: picker.icon,
      items: picker.items,
      currentValue: picker.read(settings),
      itemBuilder: (theme) => theme.tr,
      onSelected: (value) async {
        await ref.read(themeModeProvider.notifier).setTheme(value);
      },
    );
  }

  /// Show catalog dialog.
  void _showCatalogDialog(
    BuildContext context,
    SettingAppearancePickerDefinition def,
    Settings settings,
  ) {
    showSelectionDialog<String>(
      context: context,
      title: def.titleKey.tr,
      icon: def.icon,
      items: def.items,
      currentValue: def.read(settings),
      itemBuilder: def.itemBuilder,
      leadingBuilder: def.leadingBuilder,
      enableSearch: def.enableSearch,
      onSelected: (value) {
        actions.saveSettingsOptimistic(
          mutate: (s) => def.write(s, value),
          onOptimistic: () {
            if (def.titleKey == 'colorPalette') {
              ZestApp.updateAppState(ref, newColorPalette: value);
            } else if (def.titleKey == 'appFont') {
              ZestApp.updateAppState(ref, newAppFont: value);
            }
          },
        );
      },
    );
  }
}
