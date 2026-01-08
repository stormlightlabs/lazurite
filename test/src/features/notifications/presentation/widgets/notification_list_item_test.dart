import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/domain/notification.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('NotificationListItem', () {
    late AppNotification notification;
    late Profile actor;

    setUp(() {
      actor = const Profile(
        did: 'did:plc:actor1',
        handle: 'alice.bsky.social',
        displayName: 'Alice',
        description: null,
        avatar: 'https://example.com/avatar.jpg',
        banner: null,
        indexedAt: null,
        pronouns: null,
        website: null,
        createdAt: null,
        verificationStatus: null,
        labels: null,
        pinnedPostUri: null,
      );

      notification = AppNotification(
        uri: 'at://did:plc:user/app.bsky.notification/1',
        actor: actor,
        type: NotificationType.like,
        reasonSubjectUri: 'at://did:plc:user/app.bsky.feed.post/1',
        indexedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      );
    });

    testWidgets('displays actor display name', (tester) async {
      await tester.pumpApp(NotificationListItem(notification: notification));

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('displays actor handle', (tester) async {
      await tester.pumpApp(NotificationListItem(notification: notification));

      expect(find.text('@alice.bsky.social'), findsOneWidget);
    });

    testWidgets('displays notification type text', (tester) async {
      await tester.pumpApp(NotificationListItem(notification: notification));

      expect(find.text('liked your post'), findsOneWidget);
    });

    testWidgets('displays notification type icon', (tester) async {
      await tester.pumpApp(NotificationListItem(notification: notification));

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays relative timestamp', (tester) async {
      await tester.pumpApp(NotificationListItem(notification: notification));

      expect(find.text('2h'), findsOneWidget);
    });

    testWidgets('unread notification has highlighted background', (tester) async {
      await tester.pumpApp(NotificationListItem(notification: notification));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNotNull);
    });

    testWidgets('read notification has no special background', (tester) async {
      final readNotification = notification.copyWith(isRead: true);
      await tester.pumpApp(NotificationListItem(notification: readNotification));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNull);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        NotificationListItem(notification: notification, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('displays handle when displayName is null', (tester) async {
      const noDisplayNameActor = Profile(
        did: 'did:plc:actor2',
        handle: 'bob.bsky.social',
        displayName: null,
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
      final noDisplayNameNotification = notification.copyWith(actor: noDisplayNameActor);
      await tester.pumpApp(NotificationListItem(notification: noDisplayNameNotification));

      expect(find.text('bob.bsky.social'), findsOneWidget);
    });

    testWidgets('shows follow type icon and text for follow notifications', (tester) async {
      final followNotification = notification.copyWith(
        type: NotificationType.follow,
        reasonSubjectUri: null,
      );
      await tester.pumpApp(NotificationListItem(notification: followNotification));

      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.text('followed you'), findsOneWidget);
    });

    testWidgets('shows reply type icon and text for reply notifications', (tester) async {
      final replyNotification = notification.copyWith(type: NotificationType.reply);
      await tester.pumpApp(NotificationListItem(notification: replyNotification));

      expect(find.byIcon(Icons.reply), findsOneWidget);
      expect(find.text('replied to your post'), findsOneWidget);
    });
  });
}
