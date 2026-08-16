import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/notifications/notification_migration.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late FakeNotificationShow fake;

  setUp(() async {
    isar = await openTestIsar();
    fake = FakeNotificationShow();
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('reschedules active todos with due times once', () async {
    final task = await createTestTask(isar);
    final due = DateTime.now().add(const Duration(hours: 1));
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Reminder',
      completedTime: due,
      priority: Priority.medium,
    );

    final service = NotificationService(notificationShow: fake);

    await migrateNotificationChannelsIfNeeded(
      isar: isar,
      notificationService: service,
    );

    expect(fake.cancelled, [todo.id]);
    expect(fake.shown, hasLength(1));
    expect(fake.shown.first.priority, Priority.medium);

    fake.clear();
    await migrateNotificationChannelsIfNeeded(
      isar: isar,
      notificationService: service,
    );
    expect(fake.shown, isEmpty);

    final settings = await isar.settings.where().findFirst();
    expect(settings?.notificationChannelsMigrated, isTrue);
  });

  test('skips completed todos during migration', () async {
    final task = await createTestTask(isar);
    await createTestTodo(
      isar,
      task: task,
      completedTime: DateTime.now().add(const Duration(hours: 1)),
      status: TodoStatus.done,
    );

    await migrateNotificationChannelsIfNeeded(
      isar: isar,
      notificationService: NotificationService(notificationShow: fake),
    );

    expect(fake.shown, isEmpty);
  });

  test('does not set migrated flag when reschedule fails', () async {
    final task = await createTestTask(isar);
    await createTestTodo(
      isar,
      task: task,
      name: 'Broken',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );

    fake.throwOnShow = true;
    await migrateNotificationChannelsIfNeeded(
      isar: isar,
      notificationService: NotificationService(notificationShow: fake),
    );

    final settings = await isar.settings.where().findFirst();
    expect(settings?.notificationChannelsMigrated, isNot(isTrue));
  });
}
