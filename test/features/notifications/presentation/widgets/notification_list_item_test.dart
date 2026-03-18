import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notification_list_item.dart';

bsky.Notification _makeNotification({required bsky.KnownNotificationReason reason, AtUri? uri, AtUri? reasonSubject}) {
  return bsky.Notification(
    uri: uri ?? AtUri.parse('at://did:plc:liker/app.bsky.feed.like/abc'),
    cid: 'cid-abc',
    author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
    reason: bsky.NotificationReason.knownValue(data: reason),
    reasonSubject: reasonSubject,
    record: const {},
    isRead: true,
    indexedAt: DateTime.utc(2026, 3, 17),
  );
}

void main() {
  group('NotificationListItem tap navigation', () {
    testWidgets('follow notification navigates to author profile', (tester) async {
      final notification = _makeNotification(reason: bsky.KnownNotificationReason.follow);
      String? pushedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: NotificationListItem(notification: notification)),
          ),
          GoRoute(
            path: '/profile/view',
            builder: (context, state) {
              pushedRoute = state.uri.toString();
              return const Scaffold(body: Text('profile'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationListItem));
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(Uri.parse(pushedRoute!).path, '/profile/view');
    });

    testWidgets('like notification uses reasonSubject to navigate to post', (tester) async {
      final postUri = AtUri.parse('at://did:plc:owner/app.bsky.feed.post/post123');
      final notification = _makeNotification(
        reason: bsky.KnownNotificationReason.like,
        uri: AtUri.parse('at://did:plc:liker/app.bsky.feed.like/abc'),
        reasonSubject: postUri,
      );
      String? pushedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: NotificationListItem(notification: notification)),
          ),
          GoRoute(
            path: '/post',
            builder: (context, state) {
              pushedRoute = state.uri.toString();
              return const Scaffold(body: Text('post thread'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationListItem));
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(Uri.parse(pushedRoute!).path, '/post');
      expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), postUri.toString());
    });

    testWidgets('repost notification uses reasonSubject to navigate to post', (tester) async {
      final postUri = AtUri.parse('at://did:plc:owner/app.bsky.feed.post/post456');
      final notification = _makeNotification(
        reason: bsky.KnownNotificationReason.repost,
        uri: AtUri.parse('at://did:plc:reposter/app.bsky.feed.repost/repost1'),
        reasonSubject: postUri,
      );
      String? pushedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: NotificationListItem(notification: notification)),
          ),
          GoRoute(
            path: '/post',
            builder: (context, state) {
              pushedRoute = state.uri.toString();
              return const Scaffold(body: Text('post thread'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationListItem));
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(Uri.parse(pushedRoute!).path, '/post');
      expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), postUri.toString());
    });

    testWidgets('like notification falls back to uri when reasonSubject is null', (tester) async {
      final likeUri = AtUri.parse('at://did:plc:liker/app.bsky.feed.like/fallback');
      final notification = _makeNotification(
        reason: bsky.KnownNotificationReason.like,
        uri: likeUri,
        reasonSubject: null,
      );
      String? pushedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: NotificationListItem(notification: notification)),
          ),
          GoRoute(
            path: '/post',
            builder: (context, state) {
              pushedRoute = state.uri.toString();
              return const Scaffold(body: Text('post thread'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationListItem));
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(Uri.parse(pushedRoute!).path, '/post');
      expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), likeUri.toString());
    });

    testWidgets('reply notification navigates to post using notification uri', (tester) async {
      final replyUri = AtUri.parse('at://did:plc:replier/app.bsky.feed.post/reply1');
      final notification = _makeNotification(reason: bsky.KnownNotificationReason.reply, uri: replyUri);
      String? pushedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: NotificationListItem(notification: notification)),
          ),
          GoRoute(
            path: '/post',
            builder: (context, state) {
              pushedRoute = state.uri.toString();
              return const Scaffold(body: Text('post thread'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationListItem));
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(Uri.parse(pushedRoute!).path, '/post');
      expect(Uri.decodeComponent(Uri.parse(pushedRoute!).queryParameters['uri']!), replyUri.toString());
    });
  });
}
