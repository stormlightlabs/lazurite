import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/follows_dao.dart';

void main() {
  late AppDatabase database;
  late FollowsDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.followsDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('FollowsDao', () {
    group('upsertFollow', () {
      test('inserts a new follow relationship', () async {
        final follow = FollowsCompanion.insert(
          actorDid: 'did:plc:actor1',
          subjectDid: 'did:plc:subject1',
          uri: 'at://did:plc:actor1/app.bsky.graph.follow/abc123',
          createdAt: Value(DateTime(2024, 1, 1)),
        );

        await dao.upsertFollow(follow);

        final result = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        expect(result, isNotNull);
        expect(result!.actorDid, 'did:plc:actor1');
        expect(result.subjectDid, 'did:plc:subject1');
        expect(result.uri, 'at://did:plc:actor1/app.bsky.graph.follow/abc123');
        expect(result.createdAt, DateTime(2024, 1, 1));
      });

      test('updates an existing follow relationship', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/old',
          ),
        );

        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/new',
          ),
        );

        final result = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        expect(result, isNotNull);
        expect(result!.uri, 'at://did:plc:actor1/app.bsky.graph.follow/new');
      });
    });

    group('getFollow', () {
      test('returns null when follow does not exist', () async {
        final result = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        expect(result, isNull);
      });

      test('returns follow when it exists', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/abc123',
          ),
        );

        final result = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        expect(result, isNotNull);
        expect(result!.actorDid, 'did:plc:actor1');
      });

      test('distinguishes between different actor-subject pairs', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/a',
          ),
        );
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor2',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor2/app.bsky.graph.follow/b',
          ),
        );

        final result1 = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        final result2 = await dao.getFollow('did:plc:actor2', 'did:plc:subject1');
        final result3 = await dao.getFollow('did:plc:actor1', 'did:plc:subject2');

        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result3, isNull);
      });
    });

    group('deleteFollow', () {
      test('deletes an existing follow relationship', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/abc123',
          ),
        );

        final deleted = await dao.deleteFollow('did:plc:actor1', 'did:plc:subject1');
        expect(deleted, 1);

        final result = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        expect(result, isNull);
      });

      test('returns 0 when follow does not exist', () async {
        final deleted = await dao.deleteFollow('did:plc:actor1', 'did:plc:subject1');
        expect(deleted, 0);
      });

      test('only deletes the specified relationship', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/a',
          ),
        );
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject2',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/b',
          ),
        );

        await dao.deleteFollow('did:plc:actor1', 'did:plc:subject1');

        final result1 = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        final result2 = await dao.getFollow('did:plc:actor1', 'did:plc:subject2');

        expect(result1, isNull);
        expect(result2, isNotNull);
      });
    });

    group('deleteFollowByUri', () {
      test('deletes follow by URI', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/abc123',
          ),
        );

        final deleted = await dao.deleteFollowByUri(
          'at://did:plc:actor1/app.bsky.graph.follow/abc123',
        );
        expect(deleted, 1);

        final result = await dao.getFollow('did:plc:actor1', 'did:plc:subject1');
        expect(result, isNull);
      });

      test('returns 0 when URI does not exist', () async {
        final deleted = await dao.deleteFollowByUri('at://nonexistent/abc123');
        expect(deleted, 0);
      });
    });

    group('watchFollow', () {
      test('emits null when follow does not exist', () async {
        final result = await dao.watchFollow('did:plc:actor1', 'did:plc:subject1').first;
        expect(result, isNull);
      });

      test('emits follow when it exists', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/abc123',
          ),
        );

        final result = await dao.watchFollow('did:plc:actor1', 'did:plc:subject1').first;
        expect(result, isNotNull);
        expect(result!.uri, 'at://did:plc:actor1/app.bsky.graph.follow/abc123');
      });

      test('emits updated follow after upsert', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/old',
          ),
        );
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/new',
          ),
        );

        final result = await dao.watchFollow('did:plc:actor1', 'did:plc:subject1').first;
        expect(result!.uri, 'at://did:plc:actor1/app.bsky.graph.follow/new');
      });
    });

    group('getFollowsByActor', () {
      test('returns empty list when actor has no follows', () async {
        final follows = await dao.getFollowsByActor('did:plc:actor1');
        expect(follows, isEmpty);
      });

      test('returns all follows for actor', () async {
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/a',
          ),
        );
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor1',
            subjectDid: 'did:plc:subject2',
            uri: 'at://did:plc:actor1/app.bsky.graph.follow/b',
          ),
        );
        await dao.upsertFollow(
          FollowsCompanion.insert(
            actorDid: 'did:plc:actor2',
            subjectDid: 'did:plc:subject1',
            uri: 'at://did:plc:actor2/app.bsky.graph.follow/c',
          ),
        );

        final follows = await dao.getFollowsByActor('did:plc:actor1');

        expect(follows, hasLength(2));
        expect(
          follows.map((f) => f.subjectDid),
          containsAll(['did:plc:subject1', 'did:plc:subject2']),
        );
      });
    });
  });
}
