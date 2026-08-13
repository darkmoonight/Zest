import 'package:material_ui/material_ui.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';

/// [SettingsTile] with a scaled [Switch] trailing control.
class SettingsSwitchTile extends StatelessWidget {
  /// Creates a [SettingsSwitchTile].
  const SettingsSwitchTile({
    super.key,
    required this.leading,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  /// The leading.
  final Widget leading;

  /// i18n key for the title.
  final String title;

  /// The value.
  final bool value;

  /// The on changed.
  final ValueChanged<bool> onChanged;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    return SettingsTile(
      leading: leading,
      title: title,
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
