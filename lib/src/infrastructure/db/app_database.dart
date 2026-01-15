import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/animation_preferences_dao.dart';
import 'daos/bluesky_preferences_dao.dart';
import 'daos/custom_theme_dao.dart';
import 'daos/dev_tools_dao.dart';
import 'daos/dm_convos_dao.dart';
import 'daos/dm_messages_dao.dart';
import 'daos/dm_outbox_dao.dart';
import 'daos/drafts_dao.dart';
import 'daos/feed_content_dao.dart';
import 'daos/follows_dao.dart';
import 'daos/local_settings_dao.dart';
import 'daos/notifications_dao.dart';
import 'daos/notifications_sync_queue_dao.dart';
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
    LocalSettings,
    BlueskyPreferences,
    CustomThemes,
    AnimationPreferencesTable,
    Notifications,
    NotificationCursors,
    NotificationsSyncQueue,
    DmConvos,
    DmMessages,
    DmOutbox,
    DevSettings,
    DevNetworkLogs,
    DevPins,
    DevRecentRecords,
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
    LocalSettingsDao,
    BlueskyPreferencesDao,
    CustomThemeDao,
    AnimationPreferencesDao,
    NotificationsDao,
    NotificationsSyncQueueDao,
    DmConvosDao,
    DmMessagesDao,
    DmOutboxDao,
    DevToolsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(draftMedia, draftMedia.durationSeconds);
        await m.addColumn(draftMedia, draftMedia.aspectRatio);
      }
      if (from < 3) {
        await m.addColumn(drafts, drafts.cachedMediaJson);
      }
      if (from < 4) {
        await m.addColumn(drafts, drafts.langsJson);
        await m.addColumn(drafts, drafts.labelsJson);
        await m.addColumn(drafts, drafts.threadGateType);
        await m.addColumn(drafts, drafts.quoteDisabled);
      }
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return NativeDatabase.createInBackground(File(p.join(dbFolder.path, 'db.sqlite')));
});
