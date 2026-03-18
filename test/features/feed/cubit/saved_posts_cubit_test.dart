import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_bookmark_defs.dart';
import 'package:bluesky/app_bsky_bookmark_getbookmarks.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPostActionRepository extends Mock implements PostActionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:test/app.bsky.feed.post/fallback'));
  });

  late AppDatabase database;
  late MockPostActionRepository mockRepository;

  const testAccountDid = 'did:plc:testuser123';
  const testPostUri1 = 'at://did:plc:author1/app.bsky.feed.post/abc123';
  const testPostUri2 = 'at://did:plc:author2/app.bsky.feed.post/def456';
  const testPostJson1 = '{"uri": "$testPostUri1", "text": "Post 1"}';
  const testPostJson2 = '{"uri": "$testPostUri2", "text": "Post 2"}';

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
    mockRepository = MockPostActionRepository();
    when(
      () => mockRepository.getBookmarks(
        limit: any(named: 'limit'),
        cursor: any(named: 'cursor'),
      ),
    ).thenAnswer((_) async => const BookmarkGetBookmarksOutput(bookmarks: []));
  });

  tearDown(() async {
    await database.close();
  });

  group('SavedPostsCubit', () {
    test('initial state has correct values', () {
      final cubit = SavedPostsCubit(
        database: database,
        accountDid: testAccountDid,
        postActionRepository: mockRepository,
      );

      expect(cubit.state.status, SavedPostsStatus.initial);
      expect(cubit.state.savedPosts, isEmpty);
      expect(cubit.state.savedUris, isEmpty);
      expect(cubit.state.error, isNull);
    });

    group('loadSavedPosts', () {
      test('loads empty list when no saved posts', () async {
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

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

        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        await cubit.loadSavedPosts();

        expect(cubit.state.status, SavedPostsStatus.loaded);
        expect(cubit.state.savedPosts.length, 1);
        expect(cubit.state.savedUris.contains(testPostUri1), isTrue);
      });
    });

    group('toggleSave', () {
      test('saves post when not saved', () async {
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

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

        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        await cubit.loadSavedPosts();
        expect(cubit.state.savedPosts.length, 1);

        await cubit.toggleSave(postUri: testPostUri1, postJson: testPostJson1);

        expect(cubit.state.savedPosts.length, 0);
        expect(cubit.state.isSaved(testPostUri1), isFalse);
      });
    });

    group('savePost', () {
      test('saves post when not already saved', () async {
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

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

        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

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

        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

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

        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

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

        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        await cubit.loadSavedPosts();
        expect(cubit.state.savedPosts.length, 2);

        await cubit.clearAllSaved();

        expect(cubit.state.savedPosts.length, 0);
        expect(cubit.state.savedUris.length, 0);
      });
    });

    group('isSaved', () {
      test('returns true when post is saved', () async {
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

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

      test('saveTypeForUri returns correct save type', () {
        const state = SavedPostsState(
          status: SavedPostsStatus.loaded,
          savedUris: {'uri1'},
          saveTypeByUri: {'uri1': 'local'},
        );

        expect(state.saveTypeForUri('uri1'), equals('local'));
        expect(state.saveTypeForUri('uri2'), isNull);
      });

      test('saveTypeByUri is included in props', () {
        const state1 = SavedPostsState(
          status: SavedPostsStatus.loaded,
          savedUris: {'uri1'},
          saveTypeByUri: {'uri1': 'local'},
        );
        const state2 = SavedPostsState(
          status: SavedPostsStatus.loaded,
          savedUris: {'uri1'},
          saveTypeByUri: {'uri1': 'cloud'},
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('saveType', () {
      test('toggleSave saves post with local saveType', () async {
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        await cubit.toggleSave(postUri: testPostUri1, postJson: testPostJson1);

        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts.length, 1);
        expect(posts.first.saveType, equals('local'));
      });

      test('saveTypeForUri returns local after saving', () async {
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        await cubit.toggleSave(postUri: testPostUri1, postJson: testPostJson1);
        await cubit.loadSavedPosts();

        expect(cubit.state.saveTypeForUri(testPostUri1), equals('local'));
        expect(cubit.state.saveTypeForUri(testPostUri2), isNull);
      });
    });

    group('cloudSave', () {
      test('inserts post with cloud saveType when not saved', () async {
        when(
          () => mockRepository.createBookmark(
            uri: any(named: 'uri'),
            cid: any(named: 'cid'),
          ),
        ).thenAnswer((_) async {});
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        final result = await cubit.cloudSave(postUri: testPostUri1, cid: 'cid1', postJson: testPostJson1);

        expect(result, isTrue);
        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts.length, 1);
        expect(posts.first.saveType, equals('cloud'));
      });

      test('upgrades local save to both when already locally saved', () async {
        when(
          () => mockRepository.createBookmark(
            uri: any(named: 'uri'),
            cid: any(named: 'cid'),
          ),
        ).thenAnswer((_) async {});
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );
        await cubit.toggleSave(postUri: testPostUri1, postJson: testPostJson1);
        await cubit.loadSavedPosts();

        final result = await cubit.cloudSave(postUri: testPostUri1, cid: 'cid1', postJson: testPostJson1);

        expect(result, isTrue);
        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts.first.saveType, equals('both'));
      });

      test('returns true without API call when already cloud saved', () async {
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            saveType: const Value('cloud'),
            savedAt: Value(DateTime.now()),
          ),
        );
        await cubit.loadSavedPosts();

        final result = await cubit.cloudSave(postUri: testPostUri1, cid: 'cid1', postJson: testPostJson1);

        expect(result, isTrue);
        verifyNever(
          () => mockRepository.createBookmark(
            uri: any(named: 'uri'),
            cid: any(named: 'cid'),
          ),
        );
      });

      test('reverts and emits error on API failure', () async {
        when(
          () => mockRepository.createBookmark(
            uri: any(named: 'uri'),
            cid: any(named: 'cid'),
          ),
        ).thenThrow(Exception('network error'));
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        final result = await cubit.cloudSave(postUri: testPostUri1, cid: 'cid1', postJson: testPostJson1);

        expect(result, isFalse);
        expect(cubit.state.error, isNotNull);
        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts, isEmpty);
      });
    });

    group('cloudUnsave', () {
      test('removes cloud-only save from DB', () async {
        when(() => mockRepository.deleteBookmark(uri: any(named: 'uri'))).thenAnswer((_) async {});
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            saveType: const Value('cloud'),
            savedAt: Value(DateTime.now()),
          ),
        );
        await cubit.loadSavedPosts();

        final result = await cubit.cloudUnsave(testPostUri1);

        expect(result, isTrue);
        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts, isEmpty);
      });

      test('downgrades both to local when save type is both', () async {
        when(() => mockRepository.deleteBookmark(uri: any(named: 'uri'))).thenAnswer((_) async {});
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            saveType: const Value('both'),
            savedAt: Value(DateTime.now()),
          ),
        );
        await cubit.loadSavedPosts();

        final result = await cubit.cloudUnsave(testPostUri1);

        expect(result, isTrue);
        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts.first.saveType, equals('local'));
      });

      test('reverts and emits error on API failure for both saveType', () async {
        when(() => mockRepository.deleteBookmark(uri: any(named: 'uri'))).thenThrow(Exception('network error'));
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            saveType: const Value('both'),
            savedAt: Value(DateTime.now()),
          ),
        );
        await cubit.loadSavedPosts();

        final result = await cubit.cloudUnsave(testPostUri1);

        expect(result, isFalse);
        expect(cubit.state.error, isNotNull);
        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts.first.saveType, equals('both'));
      });
    });

    group('syncCloudBookmarks', () {
      test('inserts cloud bookmarks not in DB', () async {
        final testUri = AtUri.parse(testPostUri1);
        when(
          () => mockRepository.getBookmarks(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          ),
        ).thenAnswer(
          (_) async => BookmarkGetBookmarksOutput(
            bookmarks: [
              BookmarkView(
                subject: RepoStrongRef(uri: testUri, cid: 'cid1'),
                item: UBookmarkViewItem.unknown(data: {}),
              ),
            ],
          ),
        );
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        await cubit.syncCloudBookmarks();

        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts.length, 1);
        expect(posts.first.saveType, equals('cloud'));
        expect(posts.first.postUri, equals(testPostUri1));
      });

      test('upgrades existing local save to both during sync', () async {
        await database.savePost(
          SavedPostsCompanion(
            accountDid: const Value(testAccountDid),
            postUri: const Value(testPostUri1),
            postJson: const Value(testPostJson1),
            saveType: const Value('local'),
            savedAt: Value(DateTime.now()),
          ),
        );
        final testUri = AtUri.parse(testPostUri1);
        when(
          () => mockRepository.getBookmarks(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          ),
        ).thenAnswer(
          (_) async => BookmarkGetBookmarksOutput(
            bookmarks: [
              BookmarkView(
                subject: RepoStrongRef(uri: testUri, cid: 'cid1'),
                item: UBookmarkViewItem.unknown(data: {}),
              ),
            ],
          ),
        );
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        await cubit.syncCloudBookmarks();

        final posts = await database.getSavedPosts(testAccountDid);
        expect(posts.first.saveType, equals('both'));
      });

      test('handles sync API errors gracefully', () async {
        when(
          () => mockRepository.getBookmarks(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          ),
        ).thenThrow(Exception('network error'));
        final cubit = SavedPostsCubit(
          database: database,
          accountDid: testAccountDid,
          postActionRepository: mockRepository,
        );

        expect(() => cubit.syncCloudBookmarks(), returnsNormally);
      });
    });
  });
}
