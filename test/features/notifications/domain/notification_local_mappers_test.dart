import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/domain/notification_local_mappers.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';

void main() {
  group('NotificationLocalMapper', () {
    test('maps follow notifications to profile route with go navigation', () {
      final notification = bsky.Notification(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/abc'),
        cid: 'cid-123',
        author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.follow),
        record: const {},
        isRead: false,
        indexedAt: DateTime.utc(2026, 5, 1, 12),
      );

      final request = NotificationLocalMapper.requestFromNotification(notification);

      expect(request, isNotNull);
      expect(request!.reasonFamily, NotificationReasonFamily.follows);
      expect(request.deepLink.navigationMode, NotificationTapNavigationMode.go);
      expect(request.deepLink.route, '/profile/${Uri.encodeComponent('did:plc:author')}');
    });

    test('maps like notifications to post route using reasonSubject', () {
      final reasonSubject = AtUri.parse('at://did:plc:target/app.bsky.feed.post/xyz');
      final notification = bsky.Notification(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.like/abc'),
        cid: 'cid-123',
        author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        reasonSubject: reasonSubject,
        record: const {},
        isRead: false,
        indexedAt: DateTime.utc(2026, 5, 1, 12),
      );

      final request = NotificationLocalMapper.requestFromNotification(notification);

      expect(request, isNotNull);
      expect(request!.reasonFamily, NotificationReasonFamily.likes);
      expect(request.deepLink.navigationMode, NotificationTapNavigationMode.push);
      expect(request.deepLink.route, '/post?uri=${Uri.encodeQueryComponent(reasonSubject.toString())}');
    });
  });

  group('NotificationPayloadCodec', () {
    test('encodes and decodes deep links', () {
      const deepLink = NotificationDeepLink(
        route: '/post?uri=at%3A%2F%2Fabc',
        navigationMode: NotificationTapNavigationMode.push,
      );

      final payload = NotificationPayloadCodec.encode(deepLink);
      final decoded = NotificationPayloadCodec.decode(payload);

      expect(decoded, isNotNull);
      expect(decoded!.route, deepLink.route);
      expect(decoded.navigationMode, NotificationTapNavigationMode.push);
    });

    test('returns null for invalid payload', () {
      expect(NotificationPayloadCodec.decode('not-json'), isNull);
      expect(NotificationPayloadCodec.decode('{"mode":"go"}'), isNull);
      expect(NotificationPayloadCodec.decode(''), isNull);
    });
  });
}
