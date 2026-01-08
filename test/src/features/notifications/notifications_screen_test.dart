import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/notifications/application/mark_as_seen_service.dart';
import 'package:lazurite/src/features/notifications/application/notifications_providers.dart';
import 'package:lazurite/src/features/notifications/domain/notification.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';
import 'package:lazurite/src/features/notifications/presentation/notifications_screen.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../helpers/mocks.dart';

class MockMarkAsSeenService extends Mock implements MarkAsSeenService {}

void main() {
  late MockNotificationsRepository mockRepository;
  late MockMarkAsSeenService mockMarkAsSeenService;
  late MockLogger mockLogger;

  Widget createSubject({
    List<AppNotification> notifications = const [],
    bool authenticated = true,
    bool throwError = false,
  }) {
    final overrides = <Override>[
      notificationsRepositoryProvider.overrideWithValue(mockRepository),
      markAsSeenServiceProvider.overrideWithValue(mockMarkAsSeenService),
      loggerProvider('NotificationsNotifier').overrideWithValue(mockLogger),
      authProvider.overrideWith(() => _FakeAuthNotifier(authenticated: authenticated)),
    ];

    if (throwError) {
      when(
        () => mockRepository.watchNotifications(),
      ).thenAnswer((_) => Stream.error(Exception('Network error')));
    } else {
      when(
        () => mockRepository.watchNotifications(),
      ).thenAnswer((_) => Stream.value(notifications));
    }

    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: NotificationsScreen()),
    );
  }

  setUp(() {
    mockRepository = MockNotificationsRepository();
    mockMarkAsSeenService = MockMarkAsSeenService();
    mockLogger = MockLogger();

    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    when(() => mockRepository.watchNotifications()).thenAnswer((_) => Stream.value([]));
    when(
      () => mockRepository.fetchNotifications(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockRepository.fetchNotifications()).thenAnswer((_) async {});
    when(() => mockRepository.getCursor()).thenAnswer((_) async => null);
    when(() => mockRepository.markAllAsRead()).thenAnswer((_) async {});
    when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});
    when(() => mockMarkAsSeenService.flush()).thenAnswer((_) async {});

    registerFallbackValue(DateTime.now());
  });

  group('NotificationsScreen', () {
    testWidgets('shows empty state when no notifications', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('When someone interacts with you, it will show up here'), findsOneWidget);
    });

    testWidgets('shows notification list when notifications exist', (tester) async {
      final notification = AppNotification(
        uri: 'at://did:plc:user/app.bsky.notification/1',
        actor: _createProfile('did:plc:actor1', 'alice.bsky'),
        type: NotificationType.like,
        indexedAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(createSubject(notifications: [notification]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('alice.bsky liked your post'), findsOneWidget);
    });

    testWidgets('shows sign in message when not authenticated', (tester) async {
      await tester.pumpWidget(createSubject(authenticated: false));
      await tester.pump();

      expect(find.text('Sign in to see your notifications'), findsOneWidget);
    });

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Notifications'), findsWidgets);
    });

    testWidgets('calls refresh on initial load', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockRepository.fetchNotifications()).called(1);
    });

    testWidgets('mark all as read button is visible when authenticated', (tester) async {
      final notification = AppNotification(
        uri: 'at://did:plc:user/app.bsky.notification/1',
        actor: _createProfile('did:plc:actor1', 'alice.bsky'),
        type: NotificationType.like,
        indexedAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(createSubject(notifications: [notification]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('mark all as read calls repository', (tester) async {
      final notification = AppNotification(
        uri: 'at://did:plc:user/app.bsky.notification/1',
        actor: _createProfile('did:plc:actor1', 'alice.bsky'),
        type: NotificationType.like,
        indexedAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(createSubject(notifications: [notification]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.done_all));
      await tester.pump();

      verify(() => mockRepository.markAllAsRead()).called(1);
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required this.authenticated});

  final bool authenticated;

  @override
  AuthState build() {
    if (authenticated) {
      return AuthState.authenticated(
        Session(
          did: 'did:plc:test',
          scope: 'test',
          handle: 'test.bsky.social',
          accessJwt: 'access',
          refreshJwt: 'refresh',
          pdsUrl: 'https://bsky.social',
          dpopKey: {'kty': 'OKP'},
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
      );
    }

    return const AuthState.unauthenticated();
  }
}

Profile _createProfile(String did, String handle) {
  return Profile(
    did: did,
    handle: handle,
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
}
