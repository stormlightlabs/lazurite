import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/notifications/application/notifications_providers.dart';
import 'package:lazurite/src/features/notifications/application/unread_count_notifier.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockNotificationsRepository mockRepository;
  late MockLogger mockLogger;

  setUpAll(() {
    registerFallbackValue(const AsyncLoading<int>());
  });

  ProviderContainer createContainer({bool authenticated = true}) {
    return ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(mockRepository),
        loggerProvider('UnreadCountNotifier').overrideWithValue(mockLogger),
        authProvider.overrideWith(() => _FakeAuthNotifier(authenticated: authenticated)),
      ],
    );
  }

  setUp(() {
    mockRepository = MockNotificationsRepository();
    mockLogger = MockLogger();

    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    when(
      () => mockRepository.watchUnreadCount(any(named: 'ownerDid')),
    ).thenAnswer((_) => Stream.value(0));
  });

  group('UnreadCountNotifier', () {
    test('build watches unread count stream when authenticated', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(unreadCountProvider);

      await pumpEventQueue();

      verify(() => mockRepository.watchUnreadCount(any(named: 'ownerDid'))).called(1);
    });

    test('build returns 0 when not authenticated', () async {
      final container = createContainer(authenticated: false);
      addTearDown(container.dispose);

      int? emittedValue;
      container.listen(unreadCountProvider, (previous, next) {
        next.whenData((value) => emittedValue = value);
      });

      await pumpEventQueue();

      expect(emittedValue, 0);
      verifyNever(() => mockRepository.watchUnreadCount(any(named: 'ownerDid')));
    });

    test('stream emits unread count from repository', () async {
      when(
        () => mockRepository.watchUnreadCount(any(named: 'ownerDid')),
      ).thenAnswer((_) => Stream.value(5));

      final container = createContainer();
      addTearDown(container.dispose);

      int? emittedValue;
      container.listen(unreadCountProvider, (previous, next) {
        next.whenData((value) => emittedValue = value);
      });

      await pumpEventQueue();

      expect(emittedValue, 5);
      verify(() => mockRepository.watchUnreadCount(any(named: 'ownerDid'))).called(1);
    });

    test('stream emits multiple updates as count changes', () async {
      final controller = StreamController<int>();
      when(
        () => mockRepository.watchUnreadCount(any(named: 'ownerDid')),
      ).thenAnswer((_) => controller.stream);

      final container = createContainer();
      addTearDown(() {
        controller.close();
        container.dispose();
      });

      final emittedValues = <int>[];
      container.listen(unreadCountProvider, (previous, next) {
        next.whenData((value) => emittedValues.add(value));
      });

      controller.add(3);
      await pumpEventQueue();

      controller.add(5);
      await pumpEventQueue();

      controller.add(0);
      await pumpEventQueue();

      expect(emittedValues, [3, 5, 0]);
    });

    test('stream handles zero unread count', () async {
      when(
        () => mockRepository.watchUnreadCount(any(named: 'ownerDid')),
      ).thenAnswer((_) => Stream.value(0));

      final container = createContainer();
      addTearDown(container.dispose);

      int? emittedValue;
      container.listen(unreadCountProvider, (previous, next) {
        next.whenData((value) => emittedValue = value);
      });

      await pumpEventQueue();

      expect(emittedValue, 0);
      verify(() => mockRepository.watchUnreadCount(any(named: 'ownerDid'))).called(1);
    });

    test('stream handles large unread counts', () async {
      when(
        () => mockRepository.watchUnreadCount(any(named: 'ownerDid')),
      ).thenAnswer((_) => Stream.value(9999));

      final container = createContainer();
      addTearDown(container.dispose);

      int? emittedValue;
      container.listen(unreadCountProvider, (previous, next) {
        next.whenData((value) => emittedValue = value);
      });

      await pumpEventQueue();

      expect(emittedValue, 9999);
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
