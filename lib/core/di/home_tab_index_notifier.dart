import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/navigation/home_tabs.dart';
import 'package:zest/core/di/provider_refs.dart';

/// Tracks the selected bottom-navigation tab on [HomeScreen].
class HomeTabIndexNotifier extends Notifier<int> {
  @override
  int build() =>
      homeTabIndexForDefaultScreen(ref.watch(settingsProvider).defaultScreen);

  /// Updates the active tab index.
  void setIndex(int index) => state = index;
}

/// Exposes the currently selected home tab index.
final homeTabIndexProvider = NotifierProvider<HomeTabIndexNotifier, int>(
  HomeTabIndexNotifier.new,
);
