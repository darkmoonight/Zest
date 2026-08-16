import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/settings_repository.dart';

/// Single write path for live [Settings]: mutate → revision bump → persist.
///
/// UI clones ([settingsProvider]) refresh on the revision bump.
abstract final class SettingsWriter {
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
    unawaited(
      _persist(
        settings: settings,
        rollback: rollback,
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
  }) async {
    final rollback = _applyMutation(settings, revision, mutate);
    await _persist(
      settings: settings,
      rollback: rollback,
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
    revision.bump();
    return rollback;
  }

  static Future<void> _persist({
    required Settings settings,
    required Settings rollback,
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
      settings.copyValuesFrom(rollback);
      revision.bump();
      debugPrint('Failed to save settings: $e\n$stackTrace');
    }
  }
}
