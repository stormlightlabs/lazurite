import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/notifications/application/mark_as_seen_service.dart';
import 'package:lazurite/src/features/notifications/application/notifications_notifier.dart';
import 'package:lazurite/src/features/notifications/application/notifications_providers.dart';
import 'package:lazurite/src/features/notifications/domain/notification.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockMarkAsSeenService extends Mock implements MarkAsSeenService {}

void main() {
  late MockNotificationsRepository mockRepository;
  late MockMarkAsSeenService mockMarkAsSeenService;
  late MockLogger mockLogger;

  ProviderContainer createContainer({bool authenticated = true}) {
    return ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(mockRepository),
        markAsSeenServiceProvider.overrideWithValue(mockMarkAsSeenService),
        loggerProvider('NotificationsNotifier').overrideWithValue(mockLogger),
        authProvider.overrideWith(() => _FakeAuthNotifier(authenticated: authenticated)),
      ],
    );
  }

  setUp(() {
    mockRepository = MockNotificationsRepository();
    mockMarkAsSeenService = MockMarkAsSeenService();
    mockLogger = MockLogger();

    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    when(() => mockRepository.watchNotifications(any())).thenAnswer((_) => Stream.value([]));
    when(
      () => mockRepository.fetchNotifications(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        ownerDid: any(named: 'ownerDid'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockRepository.fetchNotifications(ownerDid: any(named: 'ownerDid')),
    ).thenAnswer((_) async {});
    when(() => mockRepository.getCursor(any())).thenAnswer((_) async => null);
    when(() => mockRepository.markAsSeenLocally(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.markAllAsRead(any())).thenAnswer((_) async {});
    when(() => mockRepository.updateSeen(any())).thenAnswer((_) async {});
    when(() => mockMarkAsSeenService.flush()).thenAnswer((_) async {});

    registerFallbackValue(DateTime.now());
  });

  group('NotificationsNotifier', () {
    test('build watches notifications stream', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(notificationsProvider);

      await Future.delayed(Duration.zero);

      verify(() => mockRepository.watchNotifications(any())).called(1);
    });

    test('refresh calls repository fetchNotifications when authenticated', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(notificationsProvider.notifier).refresh();

      verify(() => mockRepository.fetchNotifications(ownerDid: any(named: 'ownerDid'))).called(1);
    });

    test('refresh skips fetch when not authenticated', () async {
      final container = createContainer(authenticated: false);
      addTearDown(container.dispose);

      await container.read(notificationsProvider.notifier).refresh();

      verifyNever(() => mockRepository.fetchNotifications(ownerDid: any(named: 'ownerDid')));
    });

    test('loadMore fetches next page using cursor', () async {
      when(() => mockRepository.getCursor(any())).thenAnswer((_) async => 'next_cursor');
      when(
        () => mockRepository.fetchNotifications(
          cursor: 'next_cursor',
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) async {});

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(notificationsProvider.notifier).loadMore();

      verify(() => mockRepository.getCursor(any())).called(1);
      verify(
        () => mockRepository.fetchNotifications(
          cursor: 'next_cursor',
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    test('loadMore does nothing without cursor', () async {
      when(() => mockRepository.getCursor(any())).thenAnswer((_) async => null);

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(notificationsProvider.notifier).loadMore();

      verify(() => mockRepository.getCursor(any())).called(1);
      verifyNever(
        () => mockRepository.fetchNotifications(
          cursor: any(named: 'cursor'),
          ownerDid: any(named: 'ownerDid'),
        ),
      );
    });

    test('loadMore skips when not authenticated', () async {
      final container = createContainer(authenticated: false);
      addTearDown(container.dispose);

      await container.read(notificationsProvider.notifier).loadMore();

      verifyNever(() => mockRepository.getCursor(any()));
    });

    test('markAllAsRead flushes service and syncs with server', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(notificationsProvider.notifier).markAllAsRead();

      verifyInOrder([
        () => mockMarkAsSeenService.flush(),
        () => mockRepository.markAllAsRead(any()),
        () => mockRepository.markAsSeenLocally(any(), any()),
      ]);
    });

    test('markAllAsRead rethrows errors', () async {
      when(() => mockMarkAsSeenService.flush()).thenAnswer((_) async {});
      when(() => mockRepository.markAllAsRead(any())).thenThrow(Exception('DB error'));

      final container = createContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(notificationsProvider.notifier).markAllAsRead(),
        throwsException,
      );
    });

    test('refresh rethrows errors', () async {
      when(
        () => mockRepository.fetchNotifications(ownerDid: any(named: 'ownerDid')),
      ).thenThrow(Exception('Network error'));

      final container = createContainer();
      addTearDown(container.dispose);

      expect(() => container.read(notificationsProvider.notifier).refresh(), throwsException);

      verify(() => mockLogger.error(any(), any(), any())).called(1);
    });

    test('stream emits notifications from repository', () async {
      final testNotification = AppNotification(
        uri: 'at://did:plc:user/app.bsky.notification/1',
        actor: _createProfile('did:plc:actor1', 'actor1.bsky'),
        type: NotificationType.like,
        indexedAt: DateTime.now(),
        isRead: false,
      );

      when(
        () => mockRepository.watchNotifications(any()),
      ).thenAnswer((_) => Stream.value([testNotification]));

      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(notificationsProvider, (_, _) {});

      await Future.delayed(Duration.zero);

      verify(() => mockRepository.watchNotifications(any())).called(1);
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
