import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
  });

  group('UnreadCountCubit', () {
    blocTest<UnreadCountCubit, UnreadCountState>(
      'emits initial state with count',
      build: () {
        when(() => mockNotificationRepository.getUnreadCount()).thenAnswer((_) async => 5);
        return UnreadCountCubit(notificationRepository: mockNotificationRepository);
      },
      expect: () => [const UnreadCountState(5)],
    );

    blocTest<UnreadCountCubit, UnreadCountState>(
      'polls unread count on initialization',
      build: () {
        when(() => mockNotificationRepository.getUnreadCount()).thenAnswer((_) async => 0);
        return UnreadCountCubit(notificationRepository: mockNotificationRepository);
      },
      expect: () => [const UnreadCountState(0)],
    );

    blocTest<UnreadCountCubit, UnreadCountState>(
      'refresh updates unread count when count changes',
      build: () {
        when(() => mockNotificationRepository.getUnreadCount()).thenAnswer((_) async => 3);
        return UnreadCountCubit(notificationRepository: mockNotificationRepository);
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        when(() => mockNotificationRepository.getUnreadCount()).thenAnswer((_) async => 7);
        await cubit.refresh();
      },
      expect: () => [const UnreadCountState(3), const UnreadCountState(7)],
    );

    blocTest<UnreadCountCubit, UnreadCountState>(
      'refresh does not emit when count stays the same',
      build: () {
        when(() => mockNotificationRepository.getUnreadCount()).thenAnswer((_) async => 3);
        return UnreadCountCubit(notificationRepository: mockNotificationRepository);
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        await cubit.refresh();
      },
      expect: () => [const UnreadCountState(3)],
    );

    blocTest<UnreadCountCubit, UnreadCountState>(
      'silently fails when getUnreadCount throws',
      build: () {
        when(() => mockNotificationRepository.getUnreadCount()).thenThrow(Exception('Network error'));
        return UnreadCountCubit(notificationRepository: mockNotificationRepository);
      },
      expect: () => [],
    );

    test('hasUnread returns true when count > 0', () {
      const state = UnreadCountState(5);
      expect(state.hasUnread, true);
    });

    test('hasUnread returns false when count is 0', () {
      const state = UnreadCountState(0);
      expect(state.hasUnread, false);
    });

    test('state equality works correctly', () {
      expect(const UnreadCountState(5), const UnreadCountState(5));
      expect(const UnreadCountState(5), isNot(const UnreadCountState(3)));
    });

    test('cancels polling timer on close', () async {
      when(() => mockNotificationRepository.getUnreadCount()).thenAnswer((_) async => 0);

      final cubit = UnreadCountCubit(notificationRepository: mockNotificationRepository);

      await Future.delayed(const Duration(milliseconds: 100));
      await cubit.close();

      expect(cubit.isClosed, true);
    });
  });
}
