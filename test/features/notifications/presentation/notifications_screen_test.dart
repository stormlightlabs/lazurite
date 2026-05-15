import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/presentation/notifications_screen.dart';
import 'package:lazurite/features/notifications/presentation/widgets/grouped_notification_list_item.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

void main() {
  group('NotificationsScreen', () {
    late MockNotificationRepository mockNotificationRepository;
    late MockConnectivityCubit connectivityCubit;

    setUp(() {
      mockNotificationRepository = MockNotificationRepository();
      connectivityCubit = MockConnectivityCubit();
      when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
      whenListen(
        connectivityCubit,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityState.online(),
      );
      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: const [], cursor: null));
      when(() => mockNotificationRepository.getUnreadCount()).thenAnswer((_) async => 0);
      when(() => mockNotificationRepository.updateSeen()).thenAnswer((_) async {});
    });

    Widget buildSubject() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NotificationBloc>(
              create: (_) => NotificationBloc(notificationRepository: mockNotificationRepository),
            ),
            BlocProvider<UnreadCountCubit>(
              create: (_) => UnreadCountCubit(notificationRepository: mockNotificationRepository),
            ),
            BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
          ],
          child: const NotificationsScreen(),
        ),
      );
    }

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays notifications when loaded', (tester) async {
      final notification = bsky.Notification(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/abc'),
        cid: 'cid-123',
        author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        record: {'text': 'Test post'},
        isRead: false,
        indexedAt: DateTime.now(),
      );

      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [notification], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays empty state when no notifications', (tester) async {
      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: const [], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('displays offline empty state when offline with no notifications', (tester) async {
      when(() => connectivityCubit.state).thenReturn(const ConnectivityState.offline());
      whenListen(
        connectivityCubit,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityState.offline(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('Reconnect to load notifications.'), findsOneWidget);
    });

    testWidgets('displays error state on failure', (tester) async {
      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load notifications'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping retry reloads notifications', (tester) async {
      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final retryButton = find.text('Retry');
      await tester.tap(retryButton);
      await tester.pump();

      verify(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('Mark All Read button calls updateSeen', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final markAllReadButton = find.text('Mark All Read');
      expect(markAllReadButton, findsOneWidget);

      await tester.tap(markAllReadButton);
      await tester.pump();

      verify(() => mockNotificationRepository.updateSeen()).called(2);
    });

    testWidgets('groups notifications by day', (tester) async {
      final todayNotification = bsky.Notification(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/1'),
        cid: 'cid-1',
        author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        record: {'text': 'Post 1'},
        isRead: true,
        indexedAt: DateTime.now(),
      );

      final yesterdayNotification = bsky.Notification(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/2'),
        cid: 'cid-2',
        author: const ProfileView(did: 'did:plc:author2', handle: 'author2.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.follow),
        record: {},
        isRead: true,
        indexedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => NotificationListResult(notifications: [todayNotification, yesterdayNotification], cursor: null),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('groups repeated likes on the same post into one row', (tester) async {
      final postUri = AtUri.parse('at://did:plc:owner/app.bsky.feed.post/post1');
      final firstLike = bsky.Notification(
        uri: AtUri.parse('at://did:plc:alice/app.bsky.feed.like/1'),
        cid: 'cid-1',
        author: const ProfileView(did: 'did:plc:alice', handle: 'alice.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        reasonSubject: postUri,
        record: {'text': 'Shared post'},
        isRead: true,
        indexedAt: DateTime.now(),
      );
      final secondLike = bsky.Notification(
        uri: AtUri.parse('at://did:plc:bob/app.bsky.feed.like/2'),
        cid: 'cid-2',
        author: const ProfileView(did: 'did:plc:bob', handle: 'bob.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        reasonSubject: postUri,
        record: {'text': 'Shared post'},
        isRead: true,
        indexedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [firstLike, secondLike], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(GroupedNotificationListItem), findsOneWidget);
      expect(find.byType(NotificationListItem), findsNothing);
    });

    testWidgets('displays day header for older notifications', (tester) async {
      final oldNotification = bsky.Notification(
        uri: AtUri.parse('at://did:plc:author/app.bsky.feed.post/old'),
        cid: 'cid-old',
        author: const ProfileView(did: 'did:plc:author', handle: 'author.bsky.social'),
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        record: {'text': 'Old post'},
        isRead: true,
        indexedAt: DateTime(2026, 1, 15),
      );

      when(
        () => mockNotificationRepository.listNotifications(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => NotificationListResult(notifications: [oldNotification], cursor: null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('January 15'), findsOneWidget);
    });
  });
}
