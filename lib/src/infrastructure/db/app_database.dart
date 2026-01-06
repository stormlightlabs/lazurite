import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/drafts_dao.dart';
import 'daos/feed_content_dao.dart';
import 'daos/follows_dao.dart';
import 'daos/post_interactions_dao.dart';
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
    PostInteractions,
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
    PostInteractionsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      /*
        While the application is unreleased, migrations are removed for simplicity.
        When released, the schema version will be incremented and migrations will be added here.
        In development, database changes require a full app reset, i.e. deleting the app from the
        device or simulator.
      */
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return NativeDatabase.createInBackground(File(p.join(dbFolder.path, 'db.sqlite')));
});
