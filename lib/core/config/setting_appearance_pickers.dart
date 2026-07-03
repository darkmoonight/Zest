import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/theme/app_font.dart';
import 'package:zest/core/theme/color_palette.dart';
import 'package:zest/data/models/db.dart';

/// Catalog-driven appearance picker saved via settings repository.
class SettingAppearancePickerDefinition {
  /// Creates an appearance picker definition.
  const SettingAppearancePickerDefinition({
    required this.titleKey,
    required this.icon,
    required this.items,
    required this.read,
    required this.write,
    required this.itemBuilder,
    this.leadingBuilder,
    this.enableSearch = false,
  });

  /// Slang translation key for the dialog title.
  final String titleKey;

  /// Leading icon shown in the settings tile.
  final IconData icon;

  /// Selectable values shown in the picker.
  final List<String> items;

  /// Reads the current value from persisted [Settings].
  final String Function(Settings settings) read;

  /// Writes the selected value to [Settings].
  final void Function(Settings settings, String value) write;

  /// Builds the localized label for a picker item.
  final String Function(String value) itemBuilder;

  /// Optional leading widget builder for list items.
  final Widget? Function(String value)? leadingBuilder;

  /// Whether the picker dialog includes a search field.
  final bool enableSearch;
}

/// Appearance pickers for color palette and app font.
final settingAppearanceCatalogPickers = [
  SettingAppearancePickerDefinition(
    titleKey: 'colorPalette',
    icon: IconsaxPlusLinear.color_swatch,
    items: AppColorPalette.choices,
    read: _readColorPalette,
    write: _writeColorPalette,
    itemBuilder: AppColorPalette.label,
    leadingBuilder: AppColorPalette.previewLeading,
    enableSearch: true,
  ),
  SettingAppearancePickerDefinition(
    titleKey: 'appFont',
    icon: IconsaxPlusLinear.text,
    items: AppFont.choices,
    read: _readAppFont,
    write: _writeAppFont,
    itemBuilder: AppFont.label,
  ),
];

/// Reads the persisted color palette id from [s].
String _readColorPalette(Settings s) => AppColorPalette.resolve(s.colorPalette);

/// Writes [v] as the color palette id on [s].
void _writeColorPalette(Settings s, String v) => s.colorPalette = v;

/// Reads the persisted app font id from [s].
String _readAppFont(Settings s) => AppFont.resolve(s.appFont);

/// Writes [v] as the app font id on [s].
void _writeAppFont(Settings s, String v) => s.appFont = v;
