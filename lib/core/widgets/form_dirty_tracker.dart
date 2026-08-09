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

  /// Registers [hasChanges] against every item in [sources].
  void watchAll(Iterable<Listenable> sources, bool Function() hasChanges) {
    for (final source in sources) {
      watch(source, hasChanges);
    }
  }

  /// Releases listeners and notifiers.
  void dispose() {
    for (final (source, listener) in _bindings) {
      source.removeListener(listener);
    }
    canCompose.dispose();
  }
}
