import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart' as app_actor;
import 'package:bluesky_poptart/chat/bsky/actor/defs.dart' as chat_actor;
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/alerts/presentation/alerts_screen.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/notification.dart';
import '../../../helpers/connectivity_helpers.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockConvoRepository extends Mock implements ConvoRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

void main() {
  late MockNotificationRepository notificationRepository;
  late MockConvoRepository convoRepository;
  late MockConnectivityCubit connectivityCubit;

  setUp(() {
    notificationRepository = MockNotificationRepository();
    convoRepository = MockConvoRepository();
    connectivityCubit = MockConnectivityCubit();
    stubConnectivityCubit(connectivityCubit, state: const ConnectivityState.online());

    when(
      () => notificationRepository.listNotifications(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => NotificationListResult(
        notifications: [
          testNotification(
            uri: 'at://did:plc:alice/app.bsky.feed.post/abc',
            author: const app_actor.ProfileView(did: 'did:plc:alice', handle: 'alice.bsky.social'),
            record: const {'text': 'Test post'},
            indexedAt: DateTime.now(),
          ),
        ],
        cursor: null,
      ),
    );
    when(() => notificationRepository.getUnreadCount()).thenAnswer((_) async => 1);
    when(() => notificationRepository.updateSeen()).thenAnswer((_) async {});

    when(
      () => convoRepository.listConvos(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => ConvoListResult(
        convos: [
          const ConvoView(
            id: 'c1',
            rev: 'rev-1',
            members: [
              chat_actor.ProfileViewBasic(did: 'did:plc:me', handle: 'me.bsky.social'),
              chat_actor.ProfileViewBasic(did: 'did:plc:other', handle: 'other.bsky.social'),
            ],
            muted: false,
            unreadCount: 2,
          ),
          const ConvoView(
            id: 'c2',
            rev: 'rev-2',
            members: [
              chat_actor.ProfileViewBasic(did: 'did:plc:me', handle: 'me.bsky.social'),
              chat_actor.ProfileViewBasic(did: 'did:plc:req', handle: 'requester.bsky.social'),
            ],
            muted: false,
            unreadCount: 0,
            status: ConvoStatus.knownValue(data: KnownConvoStatus.request),
          ),
        ],
        cursor: null,
      ),
    );
    when(() => convoRepository.muteConvo(any())).thenAnswer(
      (_) async => const ConvoView(
        id: 'c1',
        rev: 'rev-1',
        members: [
          chat_actor.ProfileViewBasic(did: 'did:plc:me', handle: 'me.bsky.social'),
          chat_actor.ProfileViewBasic(did: 'did:plc:other', handle: 'other.bsky.social'),
        ],
        muted: true,
        unreadCount: 2,
      ),
    );
    when(() => convoRepository.unmuteConvo(any())).thenAnswer(
      (_) async => const ConvoView(
        id: 'c1',
        rev: 'rev-1',
        members: [
          chat_actor.ProfileViewBasic(did: 'did:plc:me', handle: 'me.bsky.social'),
          chat_actor.ProfileViewBasic(did: 'did:plc:other', handle: 'other.bsky.social'),
        ],
        muted: false,
        unreadCount: 2,
      ),
    );
  });

  Widget buildSubject(String initialLocation) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/alerts',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => NotificationBloc(notificationRepository: notificationRepository)),
              BlocProvider(create: (_) => UnreadCountCubit(notificationRepository: notificationRepository)),
              BlocProvider(create: (_) => ConvoListBloc(convoRepository: convoRepository)),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
              RepositoryProvider<String>.value(value: 'did:plc:me'),
            ],
            child: const AlertsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'messages',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => NotificationBloc(notificationRepository: notificationRepository)),
                  BlocProvider(create: (_) => UnreadCountCubit(notificationRepository: notificationRepository)),
                  BlocProvider(create: (_) => ConvoListBloc(convoRepository: convoRepository)),
                  BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
                  RepositoryProvider<String>.value(value: 'did:plc:me'),
                ],
                child: const AlertsScreen(initialTab: AlertsTab.messages),
              ),
            ),
            GoRoute(
              path: 'requests',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => NotificationBloc(notificationRepository: notificationRepository)),
                  BlocProvider(create: (_) => UnreadCountCubit(notificationRepository: notificationRepository)),
                  BlocProvider(create: (_) => ConvoListBloc(convoRepository: convoRepository)),
                  BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
                  RepositoryProvider<String>.value(value: 'did:plc:me'),
                ],
                child: const AlertsScreen(initialTab: AlertsTab.requests),
              ),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows notifications, messages, and requests tabs', (tester) async {
    await tester.pumpWidget(buildSubject('/alerts'));
    await tester.pumpAndSettle();
    expect(find.byType(AppScreenEntrance), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Mark All Read'), findsOneWidget);
  });

  testWidgets('shows unread badges for notifications and messages tabs', (tester) async {
    await tester.pumpWidget(buildSubject('/alerts'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('alerts-tab-unread-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('alerts-tab-unread-messages')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('opens messages tab from deep link', (tester) async {
    await tester.pumpWidget(buildSubject('/alerts/messages'));
    await tester.pumpAndSettle();
    expect(find.text('other.bsky.social'), findsOneWidget);
    expect(find.text('Mark All Read'), findsNothing);
  });

  testWidgets('opens requests tab from deep link', (tester) async {
    await tester.pumpWidget(buildSubject('/alerts/requests'));
    await tester.pumpAndSettle();
    expect(find.text('requester.bsky.social'), findsOneWidget);
    expect(find.text('No message requests'), findsNothing);
  });
}
