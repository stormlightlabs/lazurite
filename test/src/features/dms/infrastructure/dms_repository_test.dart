import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/dms/infrastructure/dms_repository.dart';
import 'package:lazurite/src/infrastructure/db/daos/dm_convos_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/dm_messages_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockDmConvosDao extends Mock implements DmConvosDao {}

class MockDmMessagesDao extends Mock implements DmMessagesDao {}

void main() {
  late MockXrpcClient mockApi;
  late MockDmConvosDao mockConvosDao;
  late MockDmMessagesDao mockMessagesDao;
  late MockLogger mockLogger;
  late DmsRepository repository;
  const ownerDid = 'did:web:tester';

  setUp(() {
    mockApi = MockXrpcClient();
    mockConvosDao = MockDmConvosDao();
    mockMessagesDao = MockDmMessagesDao();
    mockLogger = MockLogger();
    repository = DmsRepository(mockApi, mockConvosDao, mockMessagesDao, mockLogger);

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
  });

  group('DmsRepository', () {
    group('fetchConversations', () {
      test('calls listConvos API with default limit', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'convos': [], 'cursor': null});
        when(
          () => mockConvosDao.insertConvosBatch(
            newConvos: any(named: 'newConvos'),
            newProfiles: any(named: 'newProfiles'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchConversations(ownerDid: ownerDid);

        verify(
          () => mockApi.call(
            'chat.bsky.convo.listConvos',
            params: any(named: 'params', that: containsPair('limit', 50)),
          ),
        ).called(1);
      });

      test('includes cursor in API call when provided', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'convos': [], 'cursor': null});
        when(
          () => mockConvosDao.insertConvosBatch(
            newConvos: any(named: 'newConvos'),
            newProfiles: any(named: 'newProfiles'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchConversations(ownerDid: ownerDid, cursor: 'test_cursor');

        verify(
          () => mockApi.call(
            'chat.bsky.convo.listConvos',
            params: any(named: 'params', that: containsPair('cursor', 'test_cursor')),
          ),
        ).called(1);
      });

      test('parses and caches conversations with members', () async {
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'convos': [
              {
                'id': 'convo1',
                'members': [
                  {
                    'did': 'did:plc:member1',
                    'handle': 'member1.bsky.social',
                    'displayName': 'Member One',
                  },
                ],
                'lastMessage': {'text': 'Hello!', 'sentAt': '2026-01-08T12:00:00.000Z'},
                'unreadCount': 2,
                'muted': false,
              },
            ],
            'cursor': 'next_cursor',
          },
        );

        List? capturedConvos;
        List? capturedProfiles;
        when(
          () => mockConvosDao.insertConvosBatch(
            newConvos: any(named: 'newConvos'),
            newProfiles: any(named: 'newProfiles'),
          ),
        ).thenAnswer((invocation) async {
          capturedConvos = invocation.namedArguments[#newConvos] as List;
          capturedProfiles = invocation.namedArguments[#newProfiles] as List;
        });

        final cursor = await repository.fetchConversations(ownerDid: ownerDid);

        expect(cursor, 'next_cursor');
        expect(capturedConvos, hasLength(1));
        expect(capturedProfiles, hasLength(1));
      });

      test('skips conversations without members', () async {
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'convos': [
              {'id': 'convo1', 'members': []},
            ],
            'cursor': null,
          },
        );

        List? capturedConvos;
        when(
          () => mockConvosDao.insertConvosBatch(
            newConvos: any(named: 'newConvos'),
            newProfiles: any(named: 'newProfiles'),
          ),
        ).thenAnswer((invocation) async {
          capturedConvos = invocation.namedArguments[#newConvos] as List;
        });

        await repository.fetchConversations(ownerDid: ownerDid);

        expect(capturedConvos, isEmpty);
      });

      test('rethrows errors from API', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenThrow(Exception('Network error'));

        expect(() => repository.fetchConversations(ownerDid: ownerDid), throwsException);

        verify(() => mockLogger.error(any(), any(), any())).called(1);
      });
    });

    group('fetchMessages', () {
      test('calls getMessages API with convoId', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'messages': [], 'cursor': null});
        when(
          () => mockMessagesDao.insertMessagesBatch(
            newMessages: any(named: 'newMessages'),
            newProfiles: any(named: 'newProfiles'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchMessages('convo1', ownerDid: ownerDid);

        verify(
          () => mockApi.call(
            'chat.bsky.convo.getMessages',
            params: any(named: 'params', that: containsPair('convoId', 'convo1')),
          ),
        ).called(1);
      });

      test('parses and caches messages', () async {
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'messages': [
              {
                'id': 'msg1',
                'text': 'Hello!',
                'sender': {'did': 'did:plc:sender1', 'handle': 'sender1.bsky'},
                'sentAt': '2026-01-08T12:00:00.000Z',
              },
            ],
            'cursor': 'next_cursor',
          },
        );

        List? capturedMessages;
        when(
          () => mockMessagesDao.insertMessagesBatch(
            newMessages: any(named: 'newMessages'),
            newProfiles: any(named: 'newProfiles'),
          ),
        ).thenAnswer((invocation) async {
          capturedMessages = invocation.namedArguments[#newMessages] as List;
        });

        final cursor = await repository.fetchMessages('convo1', ownerDid: ownerDid);

        expect(cursor, 'next_cursor');
        expect(capturedMessages, hasLength(1));
      });
    });

    group('acceptConversation', () {
      test('calls acceptConvo API and updates DAO', () async {
        when(() => mockApi.call(any(), body: any(named: 'body'))).thenAnswer((_) async => {});
        when(() => mockConvosDao.acceptConvo(any(), any())).thenAnswer((_) async {});

        await repository.acceptConversation('convo1', ownerDid);

        verify(
          () => mockApi.call('chat.bsky.convo.acceptConvo', body: {'convoId': 'convo1'}),
        ).called(1);
        verify(() => mockConvosDao.acceptConvo('convo1', ownerDid)).called(1);
      });
    });

    group('updateReadState', () {
      test('calls updateRead API and updates DAO', () async {
        when(() => mockApi.call(any(), body: any(named: 'body'))).thenAnswer((_) async => {});
        when(
          () => mockConvosDao.updateReadState(
            ownerDid: any(named: 'ownerDid'),
            convoId: any(named: 'convoId'),
            lastReadMessageId: any(named: 'lastReadMessageId'),
            unreadCount: any(named: 'unreadCount'),
          ),
        ).thenAnswer((_) async {});

        await repository.updateReadState(
          convoId: 'convo1',
          messageId: 'msg123',
          ownerDid: ownerDid,
        );

        verify(
          () => mockApi.call(
            'chat.bsky.convo.updateRead',
            body: {'convoId': 'convo1', 'messageId': 'msg123'},
          ),
        ).called(1);
        verify(
          () => mockConvosDao.updateReadState(
            ownerDid: ownerDid,
            convoId: 'convo1',
            lastReadMessageId: 'msg123',
            unreadCount: 0,
          ),
        ).called(1);
      });
    });

    group('watchConversations', () {
      test('returns stream from DAO mapped to domain models', () async {
        when(() => mockConvosDao.watchConversations(any())).thenAnswer((_) => Stream.value([]));

        final stream = repository.watchConversations(ownerDid);
        final result = await stream.first;

        expect(result, isEmpty);
        verify(() => mockConvosDao.watchConversations(ownerDid)).called(1);
      });
    });

    group('watchMessages', () {
      test('returns stream from DAO mapped to domain models', () async {
        when(
          () => mockMessagesDao.watchMessagesByConvo(any(), any()),
        ).thenAnswer((_) => Stream.value([]));

        final stream = repository.watchMessages('convo1', ownerDid);
        final result = await stream.first;

        expect(result, isEmpty);
        verify(() => mockMessagesDao.watchMessagesByConvo('convo1', ownerDid)).called(1);
      });
    });

    group('clearAll', () {
      test('clears messages and conversations', () async {
        when(() => mockMessagesDao.clearMessages(any())).thenAnswer((_) async {
          return 0;
        });
        when(() => mockConvosDao.clearConversations(any())).thenAnswer((_) async {});

        await repository.clearAll(ownerDid);

        verify(() => mockMessagesDao.clearMessages(ownerDid)).called(1);
        verify(() => mockConvosDao.clearConversations(ownerDid)).called(1);
      });
    });
  });
}
