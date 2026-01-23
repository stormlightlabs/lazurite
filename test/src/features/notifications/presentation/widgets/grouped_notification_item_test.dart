import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/features/notifications/application/mark_as_seen_service.dart';
import 'package:lazurite/src/features/notifications/application/notifications_providers.dart';
import 'package:lazurite/src/features/notifications/domain/grouped_notification.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/grouped_notification_item.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

class MockMarkAsSeenService extends Mock implements MarkAsSeenService {}

Author _createProfile(String did, String handle, {String? displayName}) {
  return Author(did: did, handle: handle, displayName: displayName, avatar: null);
}

void main() {
  late MockMarkAsSeenService mockMarkAsSeenService;
  late MockNotificationsRepository mockRepository;

  Widget createSubject(GroupedNotification group, {VoidCallback? onTap}) {
    return ProviderScope(
      overrides: [
        markAsSeenServiceProvider.overrideWithValue(mockMarkAsSeenService),
        notificationsRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: GroupedNotificationItem(group: group, onTap: onTap),
        ),
      ),
    );
  }

  setUp(() {
    mockMarkAsSeenService = MockMarkAsSeenService();
    mockRepository = MockNotificationsRepository();

    registerFallbackValue(DateTime.now());
    when(() => mockMarkAsSeenService.markAsSeen(any(), any())).thenReturn(null);
  });

  group('GroupedNotificationItem', () {
    testWidgets('displays single actor name', (tester) async {
      final group = GroupedNotification(
        type: NotificationType.like,
        actors: [_createProfile('alice', 'alice.bsky', displayName: 'Alice')],
        subjectUri: 'at://did:plc:user/post/1',
        mostRecentTimestamp: DateTime.now(),
        hasUnread: false,
        totalCount: 1,
        notifications: [],
      );

      await tester.pumpWidget(createSubject(group));
      await tester.pump();

      expect(find.text('Alice liked your post'), findsOneWidget);
    });

    testWidgets('displays "and N others" for multiple actors', (tester) async {
      final group = GroupedNotification(
        type: NotificationType.like,
        actors: [
          _createProfile('alice', 'alice.bsky', displayName: 'Alice'),
          _createProfile('bob', 'bob.bsky', displayName: 'Bob'),
          _createProfile('charlie', 'charlie.bsky', displayName: 'Charlie'),
        ],
        subjectUri: 'at://did:plc:user/post/1',
        mostRecentTimestamp: DateTime.now(),
        hasUnread: false,
        totalCount: 3,
        notifications: [],
      );

      await tester.pumpWidget(createSubject(group));
      await tester.pump();

      expect(find.text('Alice, Bob and 1 others liked your post'), findsOneWidget);
    });

    testWidgets('shows expand icon for grouped notifications', (tester) async {
      final group = GroupedNotification(
        type: NotificationType.like,
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

      await tester.pumpWidget(createSubject(group));
      await tester.pump();

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('does not show expand icon for single notification', (tester) async {
      final group = GroupedNotification(
        type: NotificationType.follow,
        actors: [_createProfile('alice', 'alice.bsky', displayName: 'Alice')],
        subjectUri: null,
        mostRecentTimestamp: DateTime.now(),
        hasUnread: false,
        totalCount: 1,
        notifications: [],
      );

      await tester.pumpWidget(createSubject(group));
      await tester.pump();

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('expands to show actor list on tap', (tester) async {
      final group = GroupedNotification(
        type: NotificationType.like,
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

      await tester.pumpWidget(createSubject(group));
      await tester.pump();

      expect(find.text('@alice.bsky'), findsNothing);
      expect(find.text('@bob.bsky'), findsNothing);

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      expect(find.text('@alice.bsky'), findsOneWidget);
      expect(find.text('@bob.bsky'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('renders notification type icon', (tester) async {
      final group = GroupedNotification(
        type: NotificationType.repost,
        actors: [_createProfile('alice', 'alice.bsky', displayName: 'Alice')],
        subjectUri: 'at://did:plc:user/post/1',
        mostRecentTimestamp: DateTime.now(),
        hasUnread: false,
        totalCount: 1,
        notifications: [],
      );

      await tester.pumpWidget(createSubject(group));
      await tester.pump();

      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('displays different background for unread', (tester) async {
      final group = GroupedNotification(
        type: NotificationType.like,
        actors: [_createProfile('alice', 'alice.bsky', displayName: 'Alice')],
        subjectUri: 'at://did:plc:user/post/1',
        mostRecentTimestamp: DateTime.now(),
        hasUnread: true,
        totalCount: 1,
        notifications: [],
      );

      await tester.pumpWidget(createSubject(group));
      await tester.pump();

      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);
      final card = tester.widget<Card>(cardFinder);
      expect(card.color, isNotNull);
    });

    testWidgets('calls onTap callback when provided', (tester) async {
      var tapped = false;
      final group = GroupedNotification(
        type: NotificationType.like,
        actors: [_createProfile('alice', 'alice.bsky', displayName: 'Alice')],
        subjectUri: 'at://did:plc:user/post/1',
        mostRecentTimestamp: DateTime.now(),
        hasUnread: false,
        totalCount: 1,
        notifications: [],
      );

      await tester.pumpWidget(createSubject(group, onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(tapped, true);
    });
  });
}
