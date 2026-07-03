import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/features/settings/presentation/widgets/settings_save_actions.dart';

/// Base [ConsumerState] for settings sections with shared [actions] helpers.
abstract class SettingsSectionConsumerState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  /// The actions.
  late final SettingsSaveActions actions;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    actions = SettingsSaveActions(ref);
  }
}
