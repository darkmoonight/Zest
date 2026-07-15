import 'package:isar_community/isar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/main.dart';

const String kDefaultCategoryTitle = 'Default';
const int kDefaultCategoryColor = 0xFF607D8B;

// Seeds the built-in "Default" category exactly once for the lifetime of the
// install. Gated by Settings.defaultCategorySeeded, so a renamed, archived, or
// deleted Default is never re-created. Adopt any legacy title-based "Default"
// (from the prior title-only seeding) instead of duplicating it.
Future<void> seedDefaultCategoryOnce() async {
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

// Persists the user-selected default category. Used as the preselection and
// save-time fallback when creating top-level todos. Pass `null` to clear the
// preference (e.g. when the user explicitly clears the field).
Future<void> setDefaultCategory(Tasks? task) async {
  settings.defaultCategoryId = task?.id;
  defaultCategoryId.value = task?.id;
  await isar.writeTxn(() => isar.settings.put(settings));
}

// Returns the user-selected default category if it still exists and is not
// archived; null otherwise. Never creates.
Future<Tasks?> getUserDefaultCategory() async {
  final id = settings.defaultCategoryId;
  if (id == null) return null;
  final task = await isar.tasks.get(id);
  if (task == null || task.archive) return null;
  return task;
}

// Read-only lookup of the system Default. Never creates. Returns null if the
// user archived or deleted it.
Future<Tasks?> getDefaultCategory() async {
  return isar.tasks
      .filter()
      .isSystemEqualTo(true)
      .archiveEqualTo(false)
      .findFirst();
}

// Preselection/safe-time lookup priority:
//   1. user-selected default (if still valid)
//   2. system Default
//   3. any non-archived category
// Returns null only when there are no categories at all.
Future<Tasks?> getFallbackCategory() async {
  final userDefault = await getUserDefaultCategory();
  if (userDefault != null) return userDefault;
  final def = await getDefaultCategory();
  if (def != null) return def;
  return isar.tasks.filter().archiveEqualTo(false).findFirst();
}

// Whether the given task is the currently selected user default. Returns false
// when no default is set. Used by the category list to render the default badge.
bool isUserDefaultCategory(Tasks task) {
  final id = settings.defaultCategoryId;
  return id != null && id == task.id;
}
