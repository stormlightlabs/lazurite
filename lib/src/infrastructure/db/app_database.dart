import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/follows_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/saved_feeds_dao.dart';
import 'daos/search_dao.dart';
import 'daos/timeline_dao.dart';
import 'tables.dart';

import 'daos/preference_sync_queue_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Posts,
    Profiles,
    TimelineItems,
    Accounts,
    FeedCursors,
    RecentSearches,
    Follows,
    SavedFeeds,
    PreferenceSyncQueue,
  ],
  daos: [TimelineDao, ProfileDao, SearchDao, FollowsDao, SavedFeedsDao, PreferenceSyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 5) {
          await m.createTable(preferenceSyncQueue);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
