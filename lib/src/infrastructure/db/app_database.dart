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
  ],
  daos: [TimelineDao, ProfileDao, SearchDao, FollowsDao, SavedFeedsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
