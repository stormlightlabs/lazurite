import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';

void main() {
  late AppDatabase database;

  const testAccountDid = 'did:plc:testuser123';
  const testPostUri1 = 'at://did:plc:author1/app.bsky.feed.post/abc123';
  const testPostUri2 = 'at://did:plc:author2/app.bsky.feed.post/def456';
  const testPostJson1 = '{"uri": "$testPostUri1", "text": "Post 1"}';
  const testPostJson2 = '{"uri": "$testPostUri2", "text": "Post 2"}';

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('SavedPostsCubit', () {
    test('initial state has correct values', () {
      final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

      expect(cubit.state.status, SavedPostsStatus.initial);
      expect(cubit.state.savedPosts, isEmpty);
      expect(cubit.state.savedUris, isEmpty);
      expect(cubit.state.error, isNull);
    });

    group('loadSavedPosts', () {
      test('loads empty list when no saved posts', () async {
        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.loadSavedPosts();

        expect(cubit.state.status, SavedPostsStatus.loaded);
        expect(cubit.state.savedPosts, isEmpty);
      });

      test('loads saved posts from database', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            savedAt: Value(DateTime.now()),
          ),
        );

        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.loadSavedPosts();

        expect(cubit.state.status, SavedPostsStatus.loaded);
        expect(cubit.state.savedPosts.length, 1);
        expect(cubit.state.savedUris.contains(testPostUri1), isTrue);
      });
    });

    group('toggleSave', () {
      test('saves post when not saved', () async {
        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.toggleSave(postUri: testPostUri1, postJson: testPostJson1);

        expect(cubit.state.savedPosts.length, 1);
        expect(cubit.state.isSaved(testPostUri1), isTrue);
      });

      test('unsaves post when already saved', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            savedAt: Value(DateTime.now()),
          ),
        );

        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.loadSavedPosts();
        expect(cubit.state.savedPosts.length, 1);

        await cubit.toggleSave(postUri: testPostUri1, postJson: testPostJson1);

        expect(cubit.state.savedPosts.length, 0);
        expect(cubit.state.isSaved(testPostUri1), isFalse);
      });
    });

    group('savePost', () {
      test('saves post when not already saved', () async {
        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        final result = await cubit.savePost(postUri: testPostUri1, postJson: testPostJson1);

        expect(result, isTrue);
        expect(cubit.state.savedPosts.length, 1);
      });

      test('returns true when already saved', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            savedAt: Value(DateTime.now()),
          ),
        );

        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.loadSavedPosts();
        final result = await cubit.savePost(postUri: testPostUri1, postJson: testPostJson1);

        expect(result, isTrue);
      });
    });

    group('unsavePost', () {
      test('removes saved post', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            savedAt: Value(DateTime.now()),
          ),
        );

        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.loadSavedPosts();
        expect(cubit.state.savedPosts.length, 1);

        await cubit.unsavePost(testPostUri1);

        expect(cubit.state.savedPosts.length, 0);
      });
    });

    group('unsavePostById', () {
      test('removes post by id', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            savedAt: Value(DateTime.now()),
          ),
        );

        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.loadSavedPosts();
        final posts = await database.getSavedPosts(testAccountDid);

        await cubit.unsavePostById(posts.first.id);

        expect(cubit.state.savedPosts.length, 0);
      });
    });

    group('clearAllSaved', () {
      test('removes all saved posts', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            savedAt: Value(DateTime.now()),
          ),
        );
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri2),
            postJson: const Value(testPostJson2),
            savedAt: Value(DateTime.now()),
          ),
        );

        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.loadSavedPosts();
        expect(cubit.state.savedPosts.length, 2);

        await cubit.clearAllSaved();

        expect(cubit.state.savedPosts.length, 0);
        expect(cubit.state.savedUris.length, 0);
      });
    });

    group('isSaved', () {
      test('returns true when post is saved', () async {
        final cubit = SavedPostsCubit(database: database, accountDid: testAccountDid);

        await cubit.savePost(postUri: testPostUri1, postJson: testPostJson1);

        expect(cubit.state.isSaved(testPostUri1), isTrue);
        expect(cubit.state.isSaved(testPostUri2), isFalse);
      });
    });

    group('SavedPostsState', () {
      test('props includes all fields', () {
        const state1 = SavedPostsState(
          status: SavedPostsStatus.loaded,
          savedPosts: [],
          savedUris: {},
          error: 'test error',
        );

        const state2 = SavedPostsState(
          status: SavedPostsStatus.loaded,
          savedPosts: [],
          savedUris: {},
          error: 'test error',
        );

        expect(state1, equals(state2));
      });

      test('copyWith creates new instance with updated values', () {
        const state = SavedPostsState(status: SavedPostsStatus.initial, savedPosts: []);

        final copied = state.copyWith(status: SavedPostsStatus.loaded, error: 'New error');

        expect(copied.status, SavedPostsStatus.loaded);
        expect(copied.error, 'New error');
        expect(copied.savedPosts, isEmpty);
      });

      test('isSaved returns correct value', () {
        const state = SavedPostsState(status: SavedPostsStatus.loaded, savedUris: {'uri1', 'uri2'});

        expect(state.isSaved('uri1'), isTrue);
        expect(state.isSaved('uri3'), isFalse);
      });
    });
  });
}
