import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable FAB visibility state.
class FabState {
  /// Creates a [FabState].
  const FabState({this.isVisible = true});

  /// Whether the FAB is currently visible.
  final bool isVisible;

  /// Returns a copy with the given fields replaced.
  FabState copyWith({bool? isVisible}) =>
      FabState(isVisible: isVisible ?? this.isVisible);
}

/// Riverpod notifier controlling FAB visibility.
class FabNotifier extends Notifier<FabState> {
  @override
  /// Returns the initial [FabState].
  FabState build() => const FabState();

  /// Updates whether the FAB should be visible.
  void setVisibility(bool visible) {
    if (state.isVisible != visible) {
      state = state.copyWith(isVisible: visible);
    }
  }
}

/// Riverpod provider for [FabNotifier].
final fabNotifierProvider = NotifierProvider<FabNotifier, FabState>(
  FabNotifier.new,
);
