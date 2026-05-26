import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/notification.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
  });

  group('NotificationBloc', () {
    final sampleNotification = testNotification();

    blocTest<NotificationBloc, NotificationState>(
      'emits loading and loaded when NotificationsRequested succeeds',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      setUp: () {
        when(
          () => mockNotificationRepository.listNotifications(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => NotificationListResult(notifications: [sampleNotification], cursor: 'cursor-1'));
      },
      act: (bloc) => bloc.add(const NotificationsRequested()),
      expect: () => [
        const NotificationState.loading(),
        predicate<NotificationState>(
          (state) =>
              state.status == NotificationStatus.loaded &&
              state.notifications.length == 1 &&
              state.cursor == 'cursor-1' &&
              state.hasMore == true,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits error when NotificationsRequested fails',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      setUp: () {
        when(
          () => mockNotificationRepository.listNotifications(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const NotificationsRequested()),
      expect: () => [
        const NotificationState.loading(),
        predicate<NotificationState>((state) => state.status == NotificationStatus.error),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'loads more notifications on NotificationsPageLoaded',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      seed: () => NotificationState.loaded(notifications: [sampleNotification], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        final secondNotification = testNotification(
          uri: 'at://did:plc:author2/app.bsky.feed.post/def',
          cid: 'cid-456',
          author: const ProfileView(did: 'did:plc:author2', handle: 'author2.bsky.social'),
          reason: bsky.KnownNotificationReason.follow,
          record: const {},
          isRead: true,
          indexedAt: DateTime.utc(2026, 3, 14),
        );
        when(
          () => mockNotificationRepository.listNotifications(
            cursor: 'cursor-1',
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => NotificationListResult(notifications: [secondNotification], cursor: null));
      },
      act: (bloc) => bloc.add(const NotificationsPageLoaded()),
      expect: () => [
        predicate<NotificationState>((state) => state.isLoadingMore),
        predicate<NotificationState>(
          (state) =>
              state.status == NotificationStatus.loaded &&
              state.notifications.length == 2 &&
              !state.hasMore &&
              !state.isLoadingMore,
        ),
      ],
      verify: (_) {
        verify(
          () => mockNotificationRepository.listNotifications(
            cursor: 'cursor-1',
            limit: any(named: 'limit'),
          ),
        ).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'does not load more when already loading more',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      seed: () => NotificationState.loaded(
        notifications: [sampleNotification],
        cursor: 'cursor-1',
        hasMore: true,
      ).copyWith(isLoadingMore: true),
      act: (bloc) => bloc.add(const NotificationsPageLoaded()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockNotificationRepository.listNotifications(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'does not load more when no cursor',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      seed: () => NotificationState.loaded(notifications: [sampleNotification], cursor: null, hasMore: false),
      act: (bloc) => bloc.add(const NotificationsPageLoaded()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockNotificationRepository.listNotifications(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'refreshes notifications on NotificationsRefreshed',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      seed: () => NotificationState.loaded(notifications: [sampleNotification], cursor: 'old-cursor', hasMore: true),
      setUp: () {
        final newNotification = testNotification(
          uri: 'at://did:plc:new/app.bsky.feed.post/new',
          cid: 'cid-new',
          author: const ProfileView(did: 'did:plc:new', handle: 'new.bsky.social'),
          reason: bsky.KnownNotificationReason.repost,
          record: const {},
          indexedAt: DateTime.utc(2026, 3, 16),
        );
        when(
          () => mockNotificationRepository.listNotifications(limit: any(named: 'limit')),
        ).thenAnswer((_) async => NotificationListResult(notifications: [newNotification], cursor: 'new-cursor'));
      },
      act: (bloc) => bloc.add(const NotificationsRefreshed()),
      expect: () => [
        predicate<NotificationState>((state) => state.isRefreshing),
        predicate<NotificationState>(
          (state) =>
              state.status == NotificationStatus.loaded &&
              state.notifications.length == 1 &&
              state.cursor == 'new-cursor' &&
              !state.isRefreshing,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'calls updateSeen on NotificationsMarkedRead',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      setUp: () {
        when(() => mockNotificationRepository.updateSeen()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const NotificationsMarkedRead()),
      expect: () => [],
      verify: (_) {
        verify(() => mockNotificationRepository.updateSeen()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'marks loaded notifications as read after NotificationsMarkedRead succeeds',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      seed: () => NotificationState.loaded(notifications: [sampleNotification], cursor: null, hasMore: false),
      setUp: () {
        when(() => mockNotificationRepository.updateSeen()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const NotificationsMarkedRead()),
      expect: () => [
        predicate<NotificationState>(
          (state) =>
              state.status == NotificationStatus.loaded &&
              state.notifications.length == 1 &&
              state.notifications.first.isRead,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'handles updateSeen failure silently',
      build: () => NotificationBloc(notificationRepository: mockNotificationRepository),
      setUp: () {
        when(() => mockNotificationRepository.updateSeen()).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const NotificationsMarkedRead()),
      expect: () => [],
    );
  });
}
