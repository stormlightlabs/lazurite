import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/cubit/message_unread_count_cubit.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  late MockConvoRepository mockConvoRepository;

  setUp(() {
    mockConvoRepository = MockConvoRepository();
  });

  group('MessageUnreadCountCubit', () {
    blocTest<MessageUnreadCountCubit, MessageUnreadCountState>(
      'emits initial unread message count',
      build: () {
        when(() => mockConvoRepository.getUnreadCount()).thenAnswer((_) async => 4);
        return MessageUnreadCountCubit(convoRepository: mockConvoRepository);
      },
      expect: () => [const MessageUnreadCountState(4)],
    );

    blocTest<MessageUnreadCountCubit, MessageUnreadCountState>(
      'refresh updates unread count',
      build: () {
        when(() => mockConvoRepository.getUnreadCount()).thenAnswer((_) async => 1);
        return MessageUnreadCountCubit(convoRepository: mockConvoRepository);
      },
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        when(() => mockConvoRepository.getUnreadCount()).thenAnswer((_) async => 6);
        await cubit.refresh();
      },
      expect: () => [const MessageUnreadCountState(1), const MessageUnreadCountState(6)],
    );

    blocTest<MessageUnreadCountCubit, MessageUnreadCountState>(
      'silently fails when unread count polling throws',
      build: () {
        when(() => mockConvoRepository.getUnreadCount()).thenThrow(Exception('network'));
        return MessageUnreadCountCubit(convoRepository: mockConvoRepository);
      },
      expect: () => [],
    );
  });
}
