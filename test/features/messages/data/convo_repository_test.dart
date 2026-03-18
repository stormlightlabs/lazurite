import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  group('ConvoListResult', () {
    test('stores convos and cursor', () {
      final convo = _makeConvoView('c1');
      final result = ConvoListResult(convos: [convo], cursor: 'cursor-1');

      expect(result.convos.length, 1);
      expect(result.convos.first.id, 'c1');
      expect(result.cursor, 'cursor-1');
    });

    test('cursor is nullable', () {
      final result = ConvoListResult(convos: []);
      expect(result.cursor, isNull);
    });
  });

  group('MessageListResult', () {
    test('stores messages and cursor', () {
      final result = MessageListResult(messages: [], cursor: 'cursor-1');

      expect(result.messages, isEmpty);
      expect(result.cursor, 'cursor-1');
    });

    test('cursor is nullable', () {
      final result = MessageListResult(messages: []);
      expect(result.cursor, isNull);
    });
  });

  group('ConvoRepository interface', () {
    late MockConvoRepository mockRepo;

    setUp(() {
      mockRepo = MockConvoRepository();
    });

    test('listConvos returns ConvoListResult', () async {
      final expected = ConvoListResult(convos: [_makeConvoView('c1')], cursor: 'cursor-1');
      when(
        () => mockRepo.listConvos(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => expected);

      final result = await mockRepo.listConvos();

      expect(result.convos.length, 1);
      expect(result.cursor, 'cursor-1');
    });

    test('getMessages returns MessageListResult', () async {
      final expected = MessageListResult(messages: [], cursor: null);
      when(
        () => mockRepo.getMessages(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => expected);

      final result = await mockRepo.getMessages('convo-1');

      expect(result.messages, isEmpty);
      expect(result.cursor, isNull);
    });

    test('muteConvo returns ConvoView', () async {
      final expected = _makeConvoView('c1');
      when(() => mockRepo.muteConvo(any())).thenAnswer((_) async => expected);

      final result = await mockRepo.muteConvo('c1');

      expect(result.id, 'c1');
    });

    test('unmuteConvo returns ConvoView', () async {
      final expected = _makeConvoView('c1');
      when(() => mockRepo.unmuteConvo(any())).thenAnswer((_) async => expected);

      final result = await mockRepo.unmuteConvo('c1');

      expect(result.id, 'c1');
    });

    test('updateRead completes', () async {
      when(() => mockRepo.updateRead(any())).thenAnswer((_) async {});

      await mockRepo.updateRead('c1');

      verify(() => mockRepo.updateRead('c1')).called(1);
    });

    test('sendMessage returns MessageView', () async {
      final expected = _makeMessageView('msg-1', 'Hello');
      when(() => mockRepo.sendMessage(any(), any())).thenAnswer((_) async => expected);

      final result = await mockRepo.sendMessage('c1', 'Hello');

      expect(result.id, 'msg-1');
      expect(result.text, 'Hello');
    });
  });
}

ConvoView _makeConvoView(String id) => ConvoView(id: id, rev: 'rev-1', members: [], muted: false, unreadCount: 0);

MessageView _makeMessageView(String id, String text) => MessageView(
  id: id,
  rev: 'rev-1',
  text: text,
  sender: const MessageViewSender(did: 'did:plc:user'),
  sentAt: DateTime.utc(2026, 3, 15),
);
