import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/settings_repository.dart';

/// Single write path for live [Settings]: mutate → revision bump → persist.
///
/// UI clones ([settingsProvider]) refresh on the revision bump.
///
/// Persists are serialized on a chain. Rollback after a failed save only
/// applies when no newer mutation has been applied (epoch match), so an older
/// failure cannot wipe a newer in-memory settings change.
abstract final class SettingsWriter {
  static int _epoch = 0;
  static Future<void> _persistChain = Future<void>.value();

  /// Applies [mutate] immediately, bumps revision, persists in the background.
  static void writeOptimistic({
    required Settings settings,
    required SettingsRevisionNotifier revision,
    required SettingsRepository repository,
    required void Function(Settings settings) mutate,
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) {
    final rollback = _applyMutation(settings, revision, mutate);
    final epoch = _epoch;
    unawaited(
      _enqueuePersist(
        settings: settings,
        rollback: rollback,
        epoch: epoch,
        revision: revision,
        repository: repository,
        afterSave: afterSave,
        backgroundAfterSave: backgroundAfterSave,
      ),
    );
  }

  /// Applies [mutate], bumps revision, awaits persist (and optional [afterSave]).
  static Future<void> write({
    required Settings settings,
    required SettingsRevisionNotifier revision,
    required SettingsRepository repository,
    required void Function(Settings settings) mutate,
    Future<void> Function()? afterSave,
  }) {
    final rollback = _applyMutation(settings, revision, mutate);
    final epoch = _epoch;
    return _enqueuePersist(
      settings: settings,
      rollback: rollback,
      epoch: epoch,
      revision: revision,
      repository: repository,
      afterSave: afterSave,
    );
  }

  static Settings _applyMutation(
    Settings settings,
    SettingsRevisionNotifier revision,
    void Function(Settings settings) mutate,
  ) {
    final rollback = settings.clone();
    mutate(settings);
    _epoch++;
    revision.bump();
    return rollback;
  }

  static Future<void> _enqueuePersist({
    required Settings settings,
    required Settings rollback,
    required int epoch,
    required SettingsRevisionNotifier revision,
    required SettingsRepository repository,
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) {
    final next = _persistChain.then((_) {
      return _persist(
        settings: settings,
        rollback: rollback,
        epoch: epoch,
        revision: revision,
        repository: repository,
        afterSave: afterSave,
        backgroundAfterSave: backgroundAfterSave,
      );
    });
    // Keep the chain alive even if one persist fails.
    _persistChain = next.catchError((_) {});
    return next;
  }

  static Future<void> _persist({
    required Settings settings,
    required Settings rollback,
    required int epoch,
    required SettingsRevisionNotifier revision,
    required SettingsRepository repository,
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) async {
    try {
      await repository.save(settings);
      if (afterSave != null) {
        if (backgroundAfterSave) {
          unawaited(afterSave());
        } else {
          await afterSave();
        }
      }
    } catch (e, stackTrace) {
      // Only roll back if nothing newer mutated live settings since this write.
      if (epoch == _epoch) {
        settings.copyValuesFrom(rollback);
        revision.bump();
      }
      debugPrint('Failed to save settings: $e\n$stackTrace');
    }
  }
}
