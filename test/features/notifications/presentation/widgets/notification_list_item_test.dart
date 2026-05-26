import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_core/poptart_core.dart';

import '../../../../helpers/robots/notification_list_item_robot.dart';

void main() {
  group('NotificationListItem tap navigation', () {
    testWidgets('follow notification navigates to author profile', (tester) async {
      final robot = NotificationListItemRobot(tester);
      await robot.pump(
        notification: testNotification(reason: bsky.KnownNotificationReason.follow),
        targetPath: '/profile/:actor',
        target: const Scaffold(body: Text('profile')),
      );

      await robot.tapItem();
      robot.expectProfileRoute('did:plc:author');
    });

    testWidgets('like notification uses reasonSubject to navigate to post', (tester) async {
      final postUri = AtUri.parse('at://did:plc:owner/app.bsky.feed.post/post123');
      final robot = NotificationListItemRobot(tester);
      await robot.pump(
        notification: testNotification(
          reason: bsky.KnownNotificationReason.like,
          uri: AtUri.parse('at://did:plc:liker/app.bsky.feed.like/abc'),
          reasonSubject: postUri,
        ),
        targetPath: '/post',
        target: const Scaffold(body: Text('post thread')),
      );

      await robot.tapItem();
      robot.expectPostRoute(postUri);
    });

    testWidgets('repost notification uses reasonSubject to navigate to post', (tester) async {
      final postUri = AtUri.parse('at://did:plc:owner/app.bsky.feed.post/post456');
      final robot = NotificationListItemRobot(tester);
      await robot.pump(
        notification: testNotification(
          reason: bsky.KnownNotificationReason.repost,
          uri: AtUri.parse('at://did:plc:reposter/app.bsky.feed.repost/repost1'),
          reasonSubject: postUri,
        ),
        targetPath: '/post',
        target: const Scaffold(body: Text('post thread')),
      );

      await robot.tapItem();
      robot.expectPostRoute(postUri);
    });

    testWidgets('like-via-repost notification uses reasonSubject to navigate to post', (tester) async {
      final postUri = AtUri.parse('at://did:plc:owner/app.bsky.feed.post/post789');
      final robot = NotificationListItemRobot(tester);
      await robot.pump(
        notification: testNotification(
          reason: bsky.KnownNotificationReason.likeViaRepost,
          uri: AtUri.parse('at://did:plc:liker/app.bsky.feed.like/like-via-repost'),
          reasonSubject: postUri,
        ),
        targetPath: '/post',
        target: const Scaffold(body: Text('post thread')),
      );

      await robot.tapItem();
      robot.expectPostRoute(postUri);
    });

    testWidgets('starterpack-joined notification navigates to starter pack detail route', (tester) async {
      final starterPackUri = AtUri.parse('at://did:plc:author/app.bsky.graph.starterpack/sp1');
      final robot = NotificationListItemRobot(tester);
      await robot.pump(
        notification: testNotification(
          reason: bsky.KnownNotificationReason.starterpackJoined,
          reasonSubject: starterPackUri,
        ),
        targetPath: '/starter-pack',
        target: const Scaffold(body: Text('starter pack detail')),
      );

      await robot.tapItem();
      robot.expectStarterPackRoute(starterPackUri);
    });

    testWidgets('like notification falls back to uri when reasonSubject is null', (tester) async {
      final likeUri = AtUri.parse('at://did:plc:liker/app.bsky.feed.like/fallback');
      final robot = NotificationListItemRobot(tester);
      await robot.pump(
        notification: testNotification(reason: bsky.KnownNotificationReason.like, uri: likeUri, reasonSubject: null),
        targetPath: '/post',
        target: const Scaffold(body: Text('post thread')),
      );

      await robot.tapItem();
      robot.expectPostRoute(likeUri);
    });

    testWidgets('reply notification navigates to post using notification uri', (tester) async {
      final replyUri = AtUri.parse('at://did:plc:replier/app.bsky.feed.post/reply1');
      final robot = NotificationListItemRobot(tester);
      await robot.pump(
        notification: testNotification(reason: bsky.KnownNotificationReason.reply, uri: replyUri),
        targetPath: '/post',
        target: const Scaffold(body: Text('post thread')),
      );

      await robot.tapItem();
      robot.expectPostRoute(replyUri);
    });
  });
}
