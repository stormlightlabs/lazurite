import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/notifications_dao.dart';

void main() {
  late AppDatabase database;
  late NotificationsDao dao;
  const ownerDid = 'did:plc:owner';

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.notificationsDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('NotificationsDao', () {
    group('insertNotificationsBatch', () {
      test('inserts notifications and profiles', () async {
        final profiles = [
          ProfilesCompanion.insert(
            did: 'did:plc:actor1',
            handle: 'actor1.bsky.social',
            displayName: const Value('Actor One'),
          ),
        ];

        final notifications = [
          NotificationsCompanion.insert(
            uri: 'at://did:plc:user/app.bsky.notification/1',
            actorDid: 'did:plc:actor1',
            ownerDid: ownerDid,
            type: 'like',
            indexedAt: DateTime.now(),
            cachedAt: DateTime.now(),
          ),
        ];

        await dao.insertNotificationsBatch(
          newNotifications: notifications,
          newProfiles: profiles,
          newCursor: null,
          ownerDid: ownerDid,
        );

        final results = await dao.watchNotifications(ownerDid).first;
        expect(results, hasLength(1));
        expect(results.first.notification.type, 'like');
        expect(results.first.actor.handle, 'actor1.bsky.social');
      });

      test('updates cursor when provided', () async {
        await dao.insertNotificationsBatch(
          newNotifications: [],
          newProfiles: [],
          newCursor: 'cursor123',
          ownerDid: ownerDid,
        );

        final cursor = await dao.getCursor(ownerDid);
        expect(cursor, 'cursor123');
      });

      test('upserts existing notifications', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:actor1', handle: 'actor1.bsky.social'),
        ];

        final notification1 = NotificationsCompanion.insert(
          uri: 'at://did:plc:user/app.bsky.notification/1',
          actorDid: 'did:plc:actor1',
          ownerDid: ownerDid,
          type: 'like',
          isRead: const Value(false),
          indexedAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        await dao.insertNotificationsBatch(
          newNotifications: [notification1],
          newProfiles: profiles,
          newCursor: null,
          ownerDid: ownerDid,
        );

        final notification2 = NotificationsCompanion.insert(
          uri: 'at://did:plc:user/app.bsky.notification/1',
          actorDid: 'did:plc:actor1',
          ownerDid: ownerDid,
          type: 'like',
          isRead: const Value(true),
          indexedAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        await dao.insertNotificationsBatch(
          newNotifications: [notification2],
          newProfiles: profiles,
          newCursor: null,
          ownerDid: ownerDid,
        );

        final results = await dao.watchNotifications(ownerDid).first;
        expect(results, hasLength(1));
        expect(results.first.notification.isRead, isTrue);
      });
    });

    group('watchNotifications', () {
      test('returns notifications ordered by indexedAt descending', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:actor1', handle: 'actor1.bsky.social'),
        ];

        final now = DateTime.now();
        final notifications = [
          NotificationsCompanion.insert(
            uri: 'at://did:plc:user/app.bsky.notification/1',
            actorDid: 'did:plc:actor1',
            ownerDid: ownerDid,
            type: 'like',
            indexedAt: now.subtract(const Duration(hours: 2)),
            cachedAt: now,
          ),
          NotificationsCompanion.insert(
            uri: 'at://did:plc:user/app.bsky.notification/2',
            actorDid: 'did:plc:actor1',
            ownerDid: ownerDid,
            type: 'follow',
            indexedAt: now.subtract(const Duration(hours: 1)),
            cachedAt: now,
          ),
          NotificationsCompanion.insert(
            uri: 'at://did:plc:user/app.bsky.notification/3',
            actorDid: 'did:plc:actor1',
            ownerDid: ownerDid,
            type: 'repost',
            indexedAt: now,
            cachedAt: now,
          ),
        ];

        await dao.insertNotificationsBatch(
          newNotifications: notifications,
          newProfiles: profiles,
          newCursor: null,
          ownerDid: ownerDid,
        );

        final results = await dao.watchNotifications(ownerDid).first;
        expect(results, hasLength(3));
        expect(results[0].notification.type, 'repost'); // Most recent
        expect(results[1].notification.type, 'follow');
        expect(results[2].notification.type, 'like'); // Oldest
      });

      test('emits updates when notifications change', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:actor1', handle: 'actor1.bsky.social'),
        ];

        final stream = dao.watchNotifications(ownerDid);
        final emissions = <List<NotificationWithActor>>[];
        final subscription = stream.listen(emissions.add);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        await dao.insertNotificationsBatch(
          newNotifications: [
            NotificationsCompanion.insert(
              uri: 'at://did:plc:user/app.bsky.notification/1',
              actorDid: 'did:plc:actor1',
              ownerDid: ownerDid,
              type: 'like',
              indexedAt: DateTime.now(),
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
          newCursor: null,
          ownerDid: ownerDid,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        await subscription.cancel();

        expect(emissions.length, greaterThanOrEqualTo(2));
        expect(emissions.first, isEmpty);
        expect(emissions.last, hasLength(1));
      });
    });

    group('getCursor', () {
      test('returns null when no cursor exists', () async {
        final cursor = await dao.getCursor(ownerDid);
        expect(cursor, isNull);
      });

      test('returns stored cursor', () async {
        await dao.insertNotificationsBatch(
          newNotifications: [],
          newProfiles: [],
          newCursor: 'test_cursor',
          ownerDid: ownerDid,
        );

        final cursor = await dao.getCursor(ownerDid);
        expect(cursor, 'test_cursor');
      });
    });

    group('clearNotifications', () {
      test('removes all notifications', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:actor1', handle: 'actor1.bsky.social'),
        ];

        await dao.insertNotificationsBatch(
          newNotifications: [
            NotificationsCompanion.insert(
              uri: 'at://did:plc:user/app.bsky.notification/1',
              actorDid: 'did:plc:actor1',
              ownerDid: ownerDid,
              type: 'like',
              indexedAt: DateTime.now(),
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
          newCursor: 'cursor123',
          ownerDid: ownerDid,
        );

        await dao.clearNotifications(ownerDid);

        final results = await dao.watchNotifications(ownerDid).first;
        expect(results, isEmpty);

        final cursor = await dao.getCursor(ownerDid);
        expect(cursor, isNull);
      });
    });

    group('deleteStaleNotifications', () {
      test('deletes notifications older than threshold', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:actor1', handle: 'actor1.bsky.social'),
        ];

        final now = DateTime.now();
        final stale = now.subtract(const Duration(days: 31));
        final fresh = now.subtract(const Duration(days: 1));

        await dao.insertNotificationsBatch(
          newNotifications: [
            NotificationsCompanion.insert(
              uri: 'at://did:plc:user/app.bsky.notification/old',
              actorDid: 'did:plc:actor1',
              ownerDid: ownerDid,
              type: 'like',
              indexedAt: stale,
              cachedAt: stale,
            ),
            NotificationsCompanion.insert(
              uri: 'at://did:plc:user/app.bsky.notification/new',
              actorDid: 'did:plc:actor1',
              ownerDid: ownerDid,
              type: 'follow',
              indexedAt: fresh,
              cachedAt: fresh,
            ),
          ],
          newProfiles: profiles,
          newCursor: null,
          ownerDid: ownerDid,
        );

        final threshold = now.subtract(const Duration(days: 30));
        final deletedCount = await dao.deleteStaleNotifications(threshold, ownerDid);

        expect(deletedCount, 1);

        final results = await dao.watchNotifications(ownerDid).first;
        expect(results, hasLength(1));
        expect(results.first.notification.type, 'follow');
      });
    });

    group('markAllAsRead', () {
      test('marks all unread notifications as read', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:actor1', handle: 'actor1.bsky.social'),
        ];

        await dao.insertNotificationsBatch(
          newNotifications: [
            NotificationsCompanion.insert(
              uri: 'at://did:plc:user/app.bsky.notification/1',
              actorDid: 'did:plc:actor1',
              ownerDid: ownerDid,
              type: 'like',
              isRead: const Value(false),
              indexedAt: DateTime.now(),
              cachedAt: DateTime.now(),
            ),
            NotificationsCompanion.insert(
              uri: 'at://did:plc:user/app.bsky.notification/2',
              actorDid: 'did:plc:actor1',
              ownerDid: ownerDid,
              type: 'follow',
              isRead: const Value(false),
              indexedAt: DateTime.now(),
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
          newCursor: null,
          ownerDid: ownerDid,
        );

        await dao.markAllAsRead(ownerDid);

        final results = await dao.watchNotifications(ownerDid).first;
        expect(results, hasLength(2));
        expect(results.every((n) => n.notification.isRead), isTrue);
      });
    });
  });
}
