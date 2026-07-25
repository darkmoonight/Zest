import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/data/models/db.dart';

/// Fixed title for the one-time seeded Default category.
const String kDefaultCategoryTitle = 'Default';

/// Accent color used when creating the system Default category.
const int kDefaultCategoryColor = 0xFF607D8B;

/// Seeds the built-in Default category exactly once for the install lifetime.
///
/// Gated by [Settings.defaultCategorySeeded], so a renamed, archived, or
/// deleted Default is never re-created. Adopts any legacy title-based Default
/// instead of duplicating it.
Future<void> seedDefaultCategoryOnce(Isar isar, Settings settings) async {
  if (settings.defaultCategorySeeded) return;

  final legacy = await isar.tasks
      .filter()
      .titleEqualTo(kDefaultCategoryTitle)
      .findFirst();

  await isar.writeTxn(() async {
    if (legacy != null) {
      legacy.isSystem = true;
      await isar.tasks.put(legacy);
    } else {
      await isar.tasks.put(
        Tasks(
          title: kDefaultCategoryTitle,
          taskColor: kDefaultCategoryColor,
          index: 0,
          isSystem: true,
        ),
      );
    }
    settings.defaultCategorySeeded = true;
    await isar.settings.put(settings);
  });
}

/// Persists the user-selected default category via [settingsRepositoryProvider].
///
/// Pass `null` [task] to clear the preference.
Future<void> setDefaultCategory(WidgetRef ref, {Tasks? task}) async {
  final settings = ref.read(settingsProvider);
  settings.defaultCategoryId = task?.id;
  await ref.read(settingsRepositoryProvider).save(settings);
}

/// Returns the user-selected default category if it still exists and is active.
Future<Tasks?> getUserDefaultCategory(Isar isar, Settings settings) async {
  final id = settings.defaultCategoryId;
  if (id == null) return null;
  final task = await isar.tasks.get(id);
  if (task == null || task.archive) return null;
  return task;
}

/// Read-only lookup of the system Default; never creates.
Future<Tasks?> getDefaultCategory(Isar isar) async {
  return isar.tasks
      .filter()
      .isSystemEqualTo(true)
      .archiveEqualTo(false)
      .findFirst();
}

/// Fallback used for preselection and save-time category resolution.
///
/// Priority: user default → system Default → any non-archived category.
Future<Tasks?> getFallbackCategory(Isar isar, Settings settings) async {
  final userDefault = await getUserDefaultCategory(isar, settings);
  if (userDefault != null) return userDefault;
  final systemDefault = await getDefaultCategory(isar);
  if (systemDefault != null) return systemDefault;
  return isar.tasks.filter().archiveEqualTo(false).findFirst();
}
