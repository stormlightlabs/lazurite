import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/domain/grouped_notification.dart';
import 'package:lazurite/src/features/notifications/domain/notification.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

Profile _createProfile(String did, String handle, {String? displayName}) {
  return Profile(
    did: did,
    handle: handle,
    displayName: displayName,
    description: null,
    avatar: null,
    banner: null,
    indexedAt: null,
    pronouns: null,
    website: null,
    createdAt: null,
    verificationStatus: null,
    labels: null,
    pinnedPostUri: null,
  );
}

AppNotification _createNotification({
  required String uri,
  required String actorDid,
  required NotificationType type,
  required DateTime indexedAt,
  String? reasonSubjectUri,
  bool isRead = false,
}) {
  return AppNotification(
    uri: uri,
    actor: _createProfile(actorDid, '$actorDid.bsky', displayName: actorDid),
    type: type,
    reasonSubjectUri: reasonSubjectUri,
    indexedAt: indexedAt,
    isRead: isRead,
  );
}

void main() {
  group('GroupedNotification', () {
    group('groupNotifications', () {
      test('returns empty list for empty input', () {
        final result = GroupedNotification.groupNotifications([]);
        expect(result, isEmpty);
      });

      test('single notification returns single group', () {
        final notification = _createNotification(
          uri: 'at://did:plc:1/notif/1',
          actorDid: 'alice',
          type: NotificationType.like,
          indexedAt: DateTime(2026, 1, 8, 12, 0),
          reasonSubjectUri: 'at://did:plc:user/post/1',
        );

        final result = GroupedNotification.groupNotifications([notification]);

        expect(result.length, 1);
        expect(result.first.type, NotificationType.like);
        expect(result.first.totalCount, 1);
        expect(result.first.actors.length, 1);
      });

      test('groups notifications with same type and subject within 24h', () {
        final baseTime = DateTime(2026, 1, 8, 12, 0);
        final notifications = [
          _createNotification(
            uri: 'at://did:plc:1/notif/1',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime,
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/2',
            actorDid: 'bob',
            type: NotificationType.like,
            indexedAt: baseTime.subtract(const Duration(hours: 2)),
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/3',
            actorDid: 'charlie',
            type: NotificationType.like,
            indexedAt: baseTime.subtract(const Duration(hours: 4)),
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
        ];

        final result = GroupedNotification.groupNotifications(notifications);

        expect(result.length, 1);
        expect(result.first.totalCount, 3);
        expect(result.first.actors.length, 3);
      });

      test('separates groups with different notification types', () {
        final baseTime = DateTime(2026, 1, 8, 12, 0);
        final notifications = [
          _createNotification(
            uri: 'at://did:plc:1/notif/1',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime,
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/2',
            actorDid: 'bob',
            type: NotificationType.repost,
            indexedAt: baseTime.subtract(const Duration(hours: 1)),
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
        ];

        final result = GroupedNotification.groupNotifications(notifications);

        expect(result.length, 2);
        expect(result[0].type, NotificationType.like);
        expect(result[1].type, NotificationType.repost);
      });

      test('separates groups with different subject URIs', () {
        final baseTime = DateTime(2026, 1, 8, 12, 0);
        final notifications = [
          _createNotification(
            uri: 'at://did:plc:1/notif/1',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime,
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/2',
            actorDid: 'bob',
            type: NotificationType.like,
            indexedAt: baseTime.subtract(const Duration(hours: 1)),
            reasonSubjectUri: 'at://did:plc:user/post/2',
          ),
        ];

        final result = GroupedNotification.groupNotifications(notifications);

        expect(result.length, 2);
        expect(result[0].subjectUri, 'at://did:plc:user/post/1');
        expect(result[1].subjectUri, 'at://did:plc:user/post/2');
      });

      test('separates groups exceeding 24h window', () {
        final baseTime = DateTime(2026, 1, 8, 12, 0);
        final notifications = [
          _createNotification(
            uri: 'at://did:plc:1/notif/1',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime,
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/2',
            actorDid: 'bob',
            type: NotificationType.like,
            indexedAt: baseTime.subtract(const Duration(hours: 25)),
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
        ];

        final result = GroupedNotification.groupNotifications(notifications);

        expect(result.length, 2);
      });

      test('tracks hasUnread correctly', () {
        final baseTime = DateTime(2026, 1, 8, 12, 0);
        final notifications = [
          _createNotification(
            uri: 'at://did:plc:1/notif/1',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime,
            reasonSubjectUri: 'at://did:plc:user/post/1',
            isRead: true,
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/2',
            actorDid: 'bob',
            type: NotificationType.like,
            indexedAt: baseTime.subtract(const Duration(hours: 1)),
            reasonSubjectUri: 'at://did:plc:user/post/1',
            isRead: false,
          ),
        ];

        final result = GroupedNotification.groupNotifications(notifications);

        expect(result.first.hasUnread, true);
      });

      test('deduplicates actors by DID', () {
        final baseTime = DateTime(2026, 1, 8, 12, 0);
        final notifications = [
          _createNotification(
            uri: 'at://did:plc:1/notif/1',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime,
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/2',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime.subtract(const Duration(hours: 1)),
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
        ];

        final result = GroupedNotification.groupNotifications(notifications);

        expect(result.first.actors.length, 1);
        expect(result.first.totalCount, 1);
        expect(result.first.notifications.length, 2);
      });

      test('preserves most recent timestamp', () {
        final baseTime = DateTime(2026, 1, 8, 12, 0);
        final notifications = [
          _createNotification(
            uri: 'at://did:plc:1/notif/1',
            actorDid: 'alice',
            type: NotificationType.like,
            indexedAt: baseTime.subtract(const Duration(hours: 2)),
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
          _createNotification(
            uri: 'at://did:plc:1/notif/2',
            actorDid: 'bob',
            type: NotificationType.like,
            indexedAt: baseTime,
            reasonSubjectUri: 'at://did:plc:user/post/1',
          ),
        ];

        final result = GroupedNotification.groupNotifications(notifications);

        expect(result.first.mostRecentTimestamp, baseTime);
      });
    });

    group('displayText', () {
      test('single actor returns formatted text', () {
        final group = GroupedNotification(
          type: NotificationType.like,
          actors: [_createProfile('alice', 'alice.bsky', displayName: 'Alice')],
          subjectUri: 'at://did:plc:user/post/1',
          mostRecentTimestamp: DateTime.now(),
          hasUnread: false,
          totalCount: 1,
          notifications: [],
        );

        expect(group.displayText, 'Alice liked your post');
      });

      test('two actors returns "and" format', () {
        final group = GroupedNotification(
          type: NotificationType.repost,
          actors: [
            _createProfile('alice', 'alice.bsky', displayName: 'Alice'),
            _createProfile('bob', 'bob.bsky', displayName: 'Bob'),
          ],
          subjectUri: 'at://did:plc:user/post/1',
          mostRecentTimestamp: DateTime.now(),
          hasUnread: false,
          totalCount: 2,
          notifications: [],
        );

        expect(group.displayText, 'Alice and Bob reposted your post');
      });

      test('many actors returns "and N others" format', () {
        final group = GroupedNotification(
          type: NotificationType.like,
          actors: [
            _createProfile('alice', 'alice.bsky', displayName: 'Alice'),
            _createProfile('bob', 'bob.bsky', displayName: 'Bob'),
            _createProfile('charlie', 'charlie.bsky', displayName: 'Charlie'),
            _createProfile('dave', 'dave.bsky', displayName: 'Dave'),
            _createProfile('eve', 'eve.bsky', displayName: 'Eve'),
          ],
          subjectUri: 'at://did:plc:user/post/1',
          mostRecentTimestamp: DateTime.now(),
          hasUnread: false,
          totalCount: 5,
          notifications: [],
        );

        expect(group.displayText, 'Alice, Bob and 3 others liked your post');
      });

      test('uses handle when displayName is null', () {
        final group = GroupedNotification(
          type: NotificationType.follow,
          actors: [_createProfile('alice', 'alice.bsky')],
          subjectUri: null,
          mostRecentTimestamp: DateTime.now(),
          hasUnread: false,
          totalCount: 1,
          notifications: [],
        );

        expect(group.displayText, 'alice.bsky followed you');
      });
    });

    group('constants', () {
      test('maxDisplayActors is 5', () {
        expect(GroupedNotification.maxDisplayActors, 5);
      });

      test('groupingWindow is 24 hours', () {
        expect(GroupedNotification.groupingWindow, const Duration(hours: 24));
      });
    });
  });
}
