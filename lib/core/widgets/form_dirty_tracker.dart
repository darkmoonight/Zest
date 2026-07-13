import 'package:flutter/foundation.dart';

/// Tracks whether a form has unsaved changes via [canCompose].
class FormDirtyTracker {
  /// Creates a [FormDirtyTracker].
  FormDirtyTracker();

  /// Whether the form differs from its initial state.
  final ValueNotifier<bool> canCompose = ValueNotifier(false);

  final List<(Listenable, VoidCallback)> _bindings = [];

  /// Re-evaluates [canCompose] whenever [source] notifies.
  void watch(Listenable source, bool Function() hasChanges) {
    void listener() => canCompose.value = hasChanges();
    source.addListener(listener);
    _bindings.add((source, listener));
    listener();
  }

  /// Releases listeners and notifiers.
  void dispose() {
    for (final (source, listener) in _bindings) {
      source.removeListener(listener);
    }
    canCompose.dispose();
  }
}
