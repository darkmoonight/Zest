import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/utils/default_category.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Isar isar;
  late Settings settings;

  setUp(() async {
    await ensureIsarTestCore();
    tempDir = await Directory.systemTemp.createTemp('zest_default_cat_');
    for (final name in Isar.instanceNames) {
      await Isar.getInstance(name)?.close(deleteFromDisk: true);
    }
    isar = await Isar.open([
      TasksSchema,
      TodosSchema,
      SettingsSchema,
    ], directory: tempDir.path);
    settings = Settings();
    await isar.writeTxn(() => isar.settings.put(settings));
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('seedDefaultCategoryOnce creates system Default once', () async {
    await seedDefaultCategoryOnce(isar, settings);

    final task = await getDefaultCategory(isar);
    expect(task, isNotNull);
    expect(task!.title, kDefaultCategoryTitle);
    expect(task.isSystem, isTrue);
    expect(settings.defaultCategorySeeded, isTrue);

    final countBefore = await isar.tasks.count();
    await seedDefaultCategoryOnce(isar, settings);
    expect(await isar.tasks.count(), countBefore);
  });

  test('seedDefaultCategoryOnce adopts legacy Default title', () async {
    final legacy = Tasks(
      title: kDefaultCategoryTitle,
      taskColor: 0xFF000000,
      index: 0,
    );
    await isar.writeTxn(() => isar.tasks.put(legacy));

    await seedDefaultCategoryOnce(isar, settings);

    final all = await isar.tasks.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.isSystem, isTrue);
  });

  test('getFallbackCategory prefers user default over system', () async {
    await seedDefaultCategoryOnce(isar, settings);
    final user = Tasks(title: 'Inbox', taskColor: 0xFF112233, index: 1);
    await isar.writeTxn(() => isar.tasks.put(user));
    settings.defaultCategoryId = user.id;
    await isar.writeTxn(() => isar.settings.put(settings));

    final fallback = await getFallbackCategory(isar, settings);
    expect(fallback?.id, user.id);
  });

  test('getFallbackCategory skips archived user default', () async {
    await seedDefaultCategoryOnce(isar, settings);
    final system = await getDefaultCategory(isar);
    final user = Tasks(
      title: 'Archived Inbox',
      taskColor: 0xFF112233,
      archive: true,
      index: 1,
    );
    await isar.writeTxn(() => isar.tasks.put(user));
    settings.defaultCategoryId = user.id;
    await isar.writeTxn(() => isar.settings.put(settings));

    final fallback = await getFallbackCategory(isar, settings);
    expect(fallback?.id, system?.id);
  });
}
