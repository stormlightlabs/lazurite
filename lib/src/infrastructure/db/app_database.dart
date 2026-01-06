import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/drafts_dao.dart';
import 'daos/feed_content_dao.dart';
import 'daos/follows_dao.dart';
import 'daos/preference_sync_queue_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/profile_relationship_dao.dart';
import 'daos/saved_feeds_dao.dart';
import 'daos/search_cache_dao.dart';
import 'daos/search_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Posts,
    Profiles,
    FeedContentItems,
    Accounts,
    FeedCursors,
    RecentSearches,
    SearchCacheItems,
    SearchCacheCursors,
    Follows,
    SavedFeeds,
    PreferenceSyncQueue,
    Drafts,
    DraftMedia,
    ProfileRelationships,
  ],
  daos: [
    FeedContentDao,
    ProfileDao,
    ProfileRelationshipDao,
    SearchDao,
    SearchCacheDao,
    FollowsDao,
    SavedFeedsDao,
    PreferenceSyncQueueDao,
    DraftsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 5) {
        await m.createTable(preferenceSyncQueue);
      }
      if (from < 6) {
        await m.createTable(drafts);
        await m.createTable(draftMedia);
      }
      if (from < 7) {
        await customStatement('ALTER TABLE timeline_items RENAME TO feed_content_items');
        await customStatement('DROP INDEX IF EXISTS timeline_sort_idx');
        await customStatement(
          'CREATE INDEX feed_content_sort_idx ON feed_content_items (feed_key, sort_key)',
        );
      }
      if (from < 8) {
        await customStatement('ALTER TABLE saved_feeds ADD COLUMN local_updated_at INTEGER');
      }
      if (from < 9) {
        await m.createTable(searchCacheItems);
        await m.createTable(searchCacheCursors);
      }
      if (from < 10) {
        await customStatement('PRAGMA foreign_keys = OFF');
        await customStatement('ALTER TABLE posts RENAME TO posts_old');
        await m.createTable(posts);
        await customStatement(
          'INSERT INTO posts (uri, cid, author_did, record, embed, indexed_at, reply_count, repost_count, like_count) '
          'SELECT uri, cid, author_did, record, embed, indexed_at, reply_count, repost_count, like_count FROM posts_old',
        );
        await customStatement('DROP TABLE posts_old');

        await customStatement('ALTER TABLE saved_feeds RENAME TO saved_feeds_old');
        await m.createTable(savedFeeds);
        await customStatement(
          'INSERT INTO saved_feeds (uri, display_name, description, avatar, creator_did, like_count, sort_order, is_pinned, last_synced, local_updated_at) '
          'SELECT uri, display_name, description, avatar, creator_did, like_count, sort_order, is_pinned, last_synced, local_updated_at FROM saved_feeds_old',
        );
        await customStatement('DROP TABLE saved_feeds_old');
        await customStatement('PRAGMA foreign_keys = ON');
      }
      if (from < 11) {
        await m.addColumn(profiles, profiles.pronouns);
        await m.addColumn(profiles, profiles.website);
        await m.addColumn(profiles, profiles.createdAt);
        await m.addColumn(profiles, profiles.verificationStatus);
        await m.addColumn(profiles, profiles.labels);
        await m.addColumn(profiles, profiles.pinnedPostUri);
        await m.createTable(profileRelationships);
      }
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return NativeDatabase.createInBackground(File(p.join(dbFolder.path, 'db.sqlite')));
});
