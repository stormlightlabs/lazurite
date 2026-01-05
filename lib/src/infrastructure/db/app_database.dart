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
import 'daos/saved_feeds_dao.dart';
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
    Follows,
    SavedFeeds,
    PreferenceSyncQueue,
    Drafts,
    DraftMedia,
  ],
  daos: [
    FeedContentDao,
    ProfileDao,
    SearchDao,
    FollowsDao,
    SavedFeedsDao,
    PreferenceSyncQueueDao,
    DraftsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 7;

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
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return NativeDatabase.createInBackground(File(p.join(dbFolder.path, 'db.sqlite')));
});
