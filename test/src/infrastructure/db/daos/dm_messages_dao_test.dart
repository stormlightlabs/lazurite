import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dm_messages_dao.dart';

void main() {
  late AppDatabase database;
  late DmMessagesDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.dmMessagesDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('DmMessagesDao', () {
    group('insertMessagesBatch', () {
      test('inserts messages and profiles', () async {
        final profiles = [
          ProfilesCompanion.insert(
            did: 'did:plc:sender1',
            handle: 'sender1.bsky.social',
            displayName: const Value('Sender One'),
          ),
        ];

        final messages = [
          DmMessagesCompanion.insert(
            messageId: 'msg1',
            convoId: 'convo1',
            senderDid: 'did:plc:sender1',
            content: 'Hello!',
            sentAt: DateTime.now(),
            status: 'sent',
            cachedAt: DateTime.now(),
          ),
        ];

        await dao.insertMessagesBatch(newMessages: messages, newProfiles: profiles);

        final results = await dao.watchMessagesByConvo('convo1').first;
        expect(results, hasLength(1));
        expect(results.first.message.content, 'Hello!');
        expect(results.first.sender.handle, 'sender1.bsky.social');
      });

      test('upserts existing messages', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:sender1', handle: 'sender1.bsky.social'),
        ];

        final msg1 = DmMessagesCompanion.insert(
          messageId: 'msg1',
          convoId: 'convo1',
          senderDid: 'did:plc:sender1',
          content: 'Original',
          sentAt: DateTime.now(),
          status: 'pending',
          cachedAt: DateTime.now(),
        );

        await dao.insertMessagesBatch(newMessages: [msg1], newProfiles: profiles);

        final msg2 = DmMessagesCompanion.insert(
          messageId: 'msg1',
          convoId: 'convo1',
          senderDid: 'did:plc:sender1',
          content: 'Updated',
          sentAt: DateTime.now(),
          status: 'sent',
          cachedAt: DateTime.now(),
        );

        await dao.insertMessagesBatch(newMessages: [msg2], newProfiles: profiles);

        final results = await dao.watchMessagesByConvo('convo1').first;
        expect(results, hasLength(1));
        expect(results.first.message.content, 'Updated');
        expect(results.first.message.status, 'sent');
      });
    });

    group('watchMessagesByConvo', () {
      test('returns messages sorted by sentAt ascending', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:sender1', handle: 'sender1.bsky.social'),
        ];

        final now = DateTime.now();
        final messages = [
          DmMessagesCompanion.insert(
            messageId: 'msg3',
            convoId: 'convo1',
            senderDid: 'did:plc:sender1',
            content: 'Third',
            sentAt: now,
            status: 'sent',
            cachedAt: now,
          ),
          DmMessagesCompanion.insert(
            messageId: 'msg1',
            convoId: 'convo1',
            senderDid: 'did:plc:sender1',
            content: 'First',
            sentAt: now.subtract(const Duration(hours: 2)),
            status: 'sent',
            cachedAt: now,
          ),
          DmMessagesCompanion.insert(
            messageId: 'msg2',
            convoId: 'convo1',
            senderDid: 'did:plc:sender1',
            content: 'Second',
            sentAt: now.subtract(const Duration(hours: 1)),
            status: 'sent',
            cachedAt: now,
          ),
        ];

        await dao.insertMessagesBatch(newMessages: messages, newProfiles: profiles);

        final results = await dao.watchMessagesByConvo('convo1').first;
        expect(results, hasLength(3));
        expect(results[0].message.content, 'First');
        expect(results[1].message.content, 'Second');
        expect(results[2].message.content, 'Third');
      });

      test('filters by convoId', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:sender1', handle: 'sender1.bsky.social'),
        ];

        await dao.insertMessagesBatch(
          newMessages: [
            DmMessagesCompanion.insert(
              messageId: 'msg1',
              convoId: 'convo1',
              senderDid: 'did:plc:sender1',
              content: 'Convo 1 message',
              sentAt: DateTime.now(),
              status: 'sent',
              cachedAt: DateTime.now(),
            ),
            DmMessagesCompanion.insert(
              messageId: 'msg2',
              convoId: 'convo2',
              senderDid: 'did:plc:sender1',
              content: 'Convo 2 message',
              sentAt: DateTime.now(),
              status: 'sent',
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        final results = await dao.watchMessagesByConvo('convo1').first;
        expect(results, hasLength(1));
        expect(results.first.message.content, 'Convo 1 message');
      });
    });

    group('updateMessageStatus', () {
      test('updates status for a message', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:sender1', handle: 'sender1.bsky.social'),
        ];

        await dao.insertMessagesBatch(
          newMessages: [
            DmMessagesCompanion.insert(
              messageId: 'msg1',
              convoId: 'convo1',
              senderDid: 'did:plc:sender1',
              content: 'Test',
              sentAt: DateTime.now(),
              status: 'pending',
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        await dao.updateMessageStatus(messageId: 'msg1', status: 'sent');

        final results = await dao.watchMessagesByConvo('convo1').first;
        expect(results.first.message.status, 'sent');
      });
    });

    group('getLatestMessage', () {
      test('returns most recent message in conversation', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:sender1', handle: 'sender1.bsky.social'),
        ];

        final now = DateTime.now();
        await dao.insertMessagesBatch(
          newMessages: [
            DmMessagesCompanion.insert(
              messageId: 'msg1',
              convoId: 'convo1',
              senderDid: 'did:plc:sender1',
              content: 'Old',
              sentAt: now.subtract(const Duration(hours: 1)),
              status: 'sent',
              cachedAt: now,
            ),
            DmMessagesCompanion.insert(
              messageId: 'msg2',
              convoId: 'convo1',
              senderDid: 'did:plc:sender1',
              content: 'Latest',
              sentAt: now,
              status: 'sent',
              cachedAt: now,
            ),
          ],
          newProfiles: profiles,
        );

        final result = await dao.getLatestMessage('convo1');
        expect(result, isNotNull);
        expect(result!.content, 'Latest');
      });

      test('returns null for empty conversation', () async {
        final result = await dao.getLatestMessage('nonexistent');
        expect(result, isNull);
      });
    });

    group('deleteMessagesByConvo', () {
      test('removes all messages for a conversation', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:sender1', handle: 'sender1.bsky.social'),
        ];

        await dao.insertMessagesBatch(
          newMessages: [
            DmMessagesCompanion.insert(
              messageId: 'msg1',
              convoId: 'convo1',
              senderDid: 'did:plc:sender1',
              content: 'Test1',
              sentAt: DateTime.now(),
              status: 'sent',
              cachedAt: DateTime.now(),
            ),
            DmMessagesCompanion.insert(
              messageId: 'msg2',
              convoId: 'convo1',
              senderDid: 'did:plc:sender1',
              content: 'Test2',
              sentAt: DateTime.now(),
              status: 'sent',
              cachedAt: DateTime.now(),
            ),
            DmMessagesCompanion.insert(
              messageId: 'msg3',
              convoId: 'convo2',
              senderDid: 'did:plc:sender1',
              content: 'Other convo',
              sentAt: DateTime.now(),
              status: 'sent',
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        final deletedCount = await dao.deleteMessagesByConvo('convo1');
        expect(deletedCount, 2);

        final convo1Results = await dao.watchMessagesByConvo('convo1').first;
        expect(convo1Results, isEmpty);

        final convo2Results = await dao.watchMessagesByConvo('convo2').first;
        expect(convo2Results, hasLength(1));
      });
    });

    group('clearMessages', () {
      test('removes all messages', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:sender1', handle: 'sender1.bsky.social'),
        ];

        await dao.insertMessagesBatch(
          newMessages: [
            DmMessagesCompanion.insert(
              messageId: 'msg1',
              convoId: 'convo1',
              senderDid: 'did:plc:sender1',
              content: 'Test',
              sentAt: DateTime.now(),
              status: 'sent',
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        await dao.clearMessages();

        final results = await dao.watchMessagesByConvo('convo1').first;
        expect(results, isEmpty);
      });
    });
  });
}
