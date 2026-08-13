import 'package:material_ui/material_ui.dart';
import 'package:zest/core/theme/theme_text.dart';
import 'package:zest/core/widgets/app_back_button.dart';

/// Widget that settings secondary app bar.
class SettingsSecondaryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates a [SettingsSecondaryAppBar].
  const SettingsSecondaryAppBar({super.key, required this.title});

  /// The title.
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    centerTitle: true,
    leading: const AppBackButton(),
    title: Text(title, style: ThemeText.appBarTitle(Theme.of(context))),
  );
}
