import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dm_convos_dao.dart';

void main() {
  late AppDatabase database;
  late DmConvosDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.dmConvosDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('DmConvosDao', () {
    group('insertConvosBatch', () {
      test('inserts conversations and profiles', () async {
        final profiles = [
          ProfilesCompanion.insert(
            did: 'did:plc:member1',
            handle: 'member1.bsky.social',
            displayName: const Value('Member One'),
          ),
        ];

        final convos = [
          DmConvosCompanion.insert(
            convoId: 'convo1',
            membersJson: '["did:plc:member1"]',
            lastMessageText: const Value('Hello!'),
            lastMessageAt: Value(DateTime.now()),
            cachedAt: DateTime.now(),
          ),
        ];

        await dao.insertConvosBatch(newConvos: convos, newProfiles: profiles);

        final results = await dao.watchConversations().first;
        expect(results, hasLength(1));
        expect(results.first.convo.convoId, 'convo1');
        expect(results.first.convo.lastMessageText, 'Hello!');
        expect(results.first.members, hasLength(1));
        expect(results.first.members.first.handle, 'member1.bsky.social');
      });

      test('upserts existing conversations', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:member1', handle: 'member1.bsky.social'),
        ];

        final convo1 = DmConvosCompanion.insert(
          convoId: 'convo1',
          membersJson: '["did:plc:member1"]',
          lastMessageText: const Value('First message'),
          unreadCount: const Value(1),
          cachedAt: DateTime.now(),
        );

        await dao.insertConvosBatch(newConvos: [convo1], newProfiles: profiles);

        final convo2 = DmConvosCompanion.insert(
          convoId: 'convo1',
          membersJson: '["did:plc:member1"]',
          lastMessageText: const Value('Updated message'),
          unreadCount: const Value(3),
          cachedAt: DateTime.now(),
        );

        await dao.insertConvosBatch(newConvos: [convo2], newProfiles: profiles);

        final results = await dao.watchConversations().first;
        expect(results, hasLength(1));
        expect(results.first.convo.lastMessageText, 'Updated message');
        expect(results.first.convo.unreadCount, 3);
      });
    });

    group('watchConversations', () {
      test('returns conversations sorted by lastMessageAt descending', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:member1', handle: 'member1.bsky.social'),
        ];

        final now = DateTime.now();
        final convos = [
          DmConvosCompanion.insert(
            convoId: 'convo1',
            membersJson: '["did:plc:member1"]',
            lastMessageAt: Value(now.subtract(const Duration(hours: 2))),
            cachedAt: now,
          ),
          DmConvosCompanion.insert(
            convoId: 'convo2',
            membersJson: '["did:plc:member1"]',
            lastMessageAt: Value(now),
            cachedAt: now,
          ),
          DmConvosCompanion.insert(
            convoId: 'convo3',
            membersJson: '["did:plc:member1"]',
            lastMessageAt: Value(now.subtract(const Duration(hours: 1))),
            cachedAt: now,
          ),
        ];

        await dao.insertConvosBatch(newConvos: convos, newProfiles: profiles);

        final results = await dao.watchConversations().first;
        expect(results, hasLength(3));
        expect(results[0].convo.convoId, 'convo2');
        expect(results[1].convo.convoId, 'convo3');
        expect(results[2].convo.convoId, 'convo1');
      });
    });

    group('getConvo', () {
      test('returns conversation by ID', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:member1', handle: 'member1.bsky.social'),
        ];

        await dao.insertConvosBatch(
          newConvos: [
            DmConvosCompanion.insert(
              convoId: 'convo1',
              membersJson: '["did:plc:member1"]',
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        final result = await dao.getConvo('convo1');
        expect(result, isNotNull);
        expect(result!.convo.convoId, 'convo1');
      });

      test('returns null for non-existent conversation', () async {
        final result = await dao.getConvo('nonexistent');
        expect(result, isNull);
      });
    });

    group('updateReadState', () {
      test('updates lastReadMessageId and unreadCount', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:member1', handle: 'member1.bsky.social'),
        ];

        await dao.insertConvosBatch(
          newConvos: [
            DmConvosCompanion.insert(
              convoId: 'convo1',
              membersJson: '["did:plc:member1"]',
              unreadCount: const Value(5),
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        await dao.updateReadState(convoId: 'convo1', lastReadMessageId: 'msg123', unreadCount: 0);

        final result = await dao.getConvo('convo1');
        expect(result!.convo.lastReadMessageId, 'msg123');
        expect(result.convo.unreadCount, 0);
      });
    });

    group('acceptConvo', () {
      test('marks conversation as accepted', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:member1', handle: 'member1.bsky.social'),
        ];

        await dao.insertConvosBatch(
          newConvos: [
            DmConvosCompanion.insert(
              convoId: 'convo1',
              membersJson: '["did:plc:member1"]',
              isAccepted: const Value(false),
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        await dao.acceptConvo('convo1');

        final result = await dao.getConvo('convo1');
        expect(result!.convo.isAccepted, isTrue);
      });
    });

    group('clearConversations', () {
      test('removes all conversations', () async {
        final profiles = [
          ProfilesCompanion.insert(did: 'did:plc:member1', handle: 'member1.bsky.social'),
        ];

        await dao.insertConvosBatch(
          newConvos: [
            DmConvosCompanion.insert(
              convoId: 'convo1',
              membersJson: '["did:plc:member1"]',
              cachedAt: DateTime.now(),
            ),
            DmConvosCompanion.insert(
              convoId: 'convo2',
              membersJson: '["did:plc:member1"]',
              cachedAt: DateTime.now(),
            ),
          ],
          newProfiles: profiles,
        );

        await dao.clearConversations();

        final results = await dao.watchConversations().first;
        expect(results, isEmpty);
      });
    });
  });
}
