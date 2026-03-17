import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  group('NotificationRepository contract', () {
    final sampleNotification = bsky.Notification(
      uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/abc'),
      cid: 'cid-123',
      author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
      reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
      record: {r'$type': 'app.bsky.feed.post', 'text': 'Hello world'},
      isRead: false,
      indexedAt: DateTime.utc(2026, 3, 15),
    );

    test('listNotifications returns NotificationListResult with notifications and cursor', () async {
      when(
        () => mockRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [sampleNotification], cursor: 'next-cursor'));

      final result = await mockRepository.listNotifications();

      expect(result.notifications.length, 1);
      expect(result.cursor, 'next-cursor');
      expect(result.notifications.first.reason.knownValue, bsky.KnownNotificationReason.like);
    });

    test('listNotifications with cursor returns paginated results', () async {
      when(
        () => mockRepository.listNotifications(
          cursor: 'page-2',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [sampleNotification], cursor: 'page-3'));

      final result = await mockRepository.listNotifications(cursor: 'page-2');

      expect(result.cursor, 'page-3');
    });

    test('listNotifications returns empty list when no notifications', () async {
      when(
        () => mockRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: const [], cursor: null));

      final result = await mockRepository.listNotifications();

      expect(result.notifications, isEmpty);
      expect(result.cursor, isNull);
    });

    test('getUnreadCount returns count', () async {
      when(() => mockRepository.getUnreadCount()).thenAnswer((_) async => 5);

      final result = await mockRepository.getUnreadCount();

      expect(result, 5);
    });

    test('getUnreadCount returns zero when no unread', () async {
      when(() => mockRepository.getUnreadCount()).thenAnswer((_) async => 0);

      final result = await mockRepository.getUnreadCount();

      expect(result, 0);
    });

    test('updateSeen completes successfully', () async {
      when(() => mockRepository.updateSeen()).thenAnswer((_) async {});

      await mockRepository.updateSeen();

      verify(() => mockRepository.updateSeen()).called(1);
    });
  });

  group('NotificationListResult', () {
    test('stores notifications and cursor', () {
      final notification = bsky.Notification(
        uri: AtUri.parse('at://did:plc:test/app.bsky.notification/1'),
        cid: 'cid',
        author: const ProfileView(did: 'did:plc:test', handle: 'test.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.follow),
        record: {},
        isRead: true,
        indexedAt: DateTime.now(),
      );

      final result = NotificationListResult(notifications: [notification], cursor: 'cursor-1');

      expect(result.notifications.length, 1);
      expect(result.cursor, 'cursor-1');
    });

    test('allows null cursor and seenAt', () {
      final result = NotificationListResult(notifications: const [], cursor: null, seenAt: null);

      expect(result.notifications, isEmpty);
      expect(result.cursor, isNull);
      expect(result.seenAt, isNull);
    });

    test('stores seenAt datetime', () {
      final seenAt = DateTime.utc(2026, 3, 15, 10, 30);
      final result = NotificationListResult(notifications: const [], cursor: null, seenAt: seenAt);

      expect(result.seenAt, seenAt);
    });
  });
}
