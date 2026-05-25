import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:lazurite/core/database/tables.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class KeywordPostMatch {
  const KeywordPostMatch({required this.postUri, required this.source, required this.rank});

  final String postUri;
  final String source;
  final double rank;
}

@DriftDatabase(
  tables: [
    Accounts,
    CachedProfiles,
    CachedPosts,
    Settings,
    SavedFeeds,
    CachedFeedPages,
    CachedFeedPosts,
    CachedThreadRoots,
    SearchHistory,
    Drafts,
    SavedPosts,
    LabelerCache,
    NotificationDeliveries,
    LikedPosts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  static const activeAccountDidSettingKey = 'active_account_did';
  static const _authRefreshLockSettingPrefix = 'auth_refresh_lock::';
  Future<void> _serializedWriteTail = Future.value();

  @override
  int get schemaVersion => 24;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createPostSearchFtsSchema();
      await _rebuildPostSearchFts();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_notification_deliveries_notification_uri '
        'ON notification_deliveries(notification_uri)',
      );
      await customStatement("INSERT OR IGNORE INTO settings (key, value) VALUES ('typeahead_provider', 'bluesky')");
      await customStatement("INSERT OR IGNORE INTO settings (key, value) VALUES ('appview_provider', 'bluesky')");
      await customStatement(
        "INSERT OR IGNORE INTO settings (key, value) VALUES ('cross_provider_fallback_enabled', 'false')",
      );
      await customStatement(
        "INSERT OR IGNORE INTO settings (key, value) VALUES ('slingshot_identity_fallback_enabled', 'false')",
      );
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(accounts, accounts.service);
        await migrator.addColumn(accounts, accounts.dpopPublicKey);
        await migrator.addColumn(accounts, accounts.dpopNonce);
        await migrator.createTable(cachedProfiles);
        await migrator.createTable(cachedPosts);
      }
      if (from < 3) {
        await migrator.createTable(savedFeeds);
      }
      if (from < 4) {
        await migrator.createTable(searchHistory);
      }
      if (from < 5) {
        await migrator.createTable(drafts);
      }
      if (from < 6) {
        await migrator.createTable(savedPosts);
      }
      if (from < 7) {
        await migrator.addColumn(savedPosts, savedPosts.saveType);
      }
      if (from < 8) {
        await migrator.addColumn(cachedPosts, cachedPosts.accountDid);
      }
      if (from < 9) {
        await migrator.createTable(labelerCache);
      }
      if (from < 10) {
        await customStatement("INSERT OR IGNORE INTO settings (key, value) VALUES ('feed_architecture', 'grid')");
      }
      if (from < 11) {
        /*
          The thread auto-collapse setting is nullable and represented by
          the presence or absence of a row in the existing settings table.
        */
      }
      if (from < 12) {
        await migrator.createTable(cachedFeedPages);
      }
      if (from < 13) {
        await customStatement("DELETE FROM settings WHERE key = 'ui_density'");
      }
      if (from < 14) {
        await customStatement('''
          INSERT OR IGNORE INTO settings (key, value, updated_at)
          SELECT
            'feed_layout',
            CASE value
              WHEN 'grid' THEN 'card'
              WHEN 'linear' THEN 'compact'
              ELSE value
            END,
            updated_at
          FROM settings
          WHERE key = 'feed_architecture'
        ''');
        await customStatement('''
          UPDATE settings
          SET value = CASE value
            WHEN 'grid' THEN 'card'
            WHEN 'linear' THEN 'compact'
            ELSE value
          END
          WHERE key = 'feed_layout'
        ''');
        await customStatement("DELETE FROM settings WHERE key = 'feed_architecture'");
      }
      if (from < 15) {
        await migrator.createTable(likedPosts);
      }
      if (from < 16) {
        await migrator.addColumn(accounts, accounts.oauthService);
        await customStatement('''
          UPDATE accounts
          SET oauth_service = 'bsky.social'
          WHERE oauth_service IS NULL
            AND dpop_public_key IS NOT NULL
            AND dpop_private_key IS NOT NULL
        ''');
      }
      if (from < 17) {
        await customStatement("INSERT OR IGNORE INTO settings (key, value) VALUES ('typeahead_provider', 'bluesky')");
      }
      if (from < 18) {
        await customStatement("INSERT OR IGNORE INTO settings (key, value) VALUES ('appview_provider', 'bluesky')");
      }
      if (from < 19) {
        await customStatement(
          "INSERT OR IGNORE INTO settings (key, value) VALUES ('cross_provider_fallback_enabled', 'false')",
        );
        await customStatement(
          "INSERT OR IGNORE INTO settings (key, value) VALUES ('slingshot_identity_fallback_enabled', 'false')",
        );
      }
      if (from < 20) {
        await migrator.createTable(cachedFeedPosts);
        await migrator.createTable(cachedThreadRoots);
      }
      if (from < 21) {
        await migrator.createTable(notificationDeliveries);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_notification_deliveries_notification_uri '
          'ON notification_deliveries(notification_uri)',
        );
      }
      if (from < 22) {
        await _createPostSearchFtsSchema();
        await _rebuildPostSearchFts();
      }
      if (from < 23) {
        await migrator.addColumn(accounts, accounts.oauthClientId);
      }
      if (from < 24) {
        await customStatement("UPDATE settings SET value = 'comfortable' WHERE key = 'feed_layout' AND value = 'card'");
      }
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'lazurite_db',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
      shareAcrossIsolates: true,
      setup: _configureNativeDatabaseConnection,
    ),
  );

  /// Serializes read-modify-write database operations issued through this
  /// [AppDatabase] instance so callers do not compute writes from stale reads.
  Future<T> runSerializedWrite<T>(Future<T> Function() operation) {
    final previousTail = _serializedWriteTail;
    final completion = Completer<void>();
    _serializedWriteTail = completion.future;

    return previousTail.then((_) async {
      try {
        return await operation();
      } finally {
        completion.complete();
      }
    });
  }

  Future<Account?> getAccount(String did) => (select(accounts)..where((a) => a.did.equals(did))).getSingleOrNull();

  Future<Account?> getActiveAccount() async {
    final activeDid = await getSetting(activeAccountDidSettingKey);
    if (activeDid == null) {
      return null;
    }

    return getAccount(activeDid);
  }

  Future<List<Account>> getAllAccounts() => select(accounts).get();

  Future<int> insertAccount(AccountsCompanion account) => into(accounts).insert(account, mode: InsertMode.replace);

  Future<int> deleteAccount(String did) => (delete(accounts)..where((a) => a.did.equals(did))).go();

  Future<int> deleteAllAccounts() => delete(accounts).go();

  Future<bool> updateAccountTokens(
    String did, {
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? dpopNonce,
  }) async {
    final query = update(accounts)..where((a) => a.did.equals(did));
    final rowsAffected = await query.write(
      AccountsCompanion(
        accessToken: Value(accessToken),
        refreshToken: refreshToken != null ? Value(refreshToken) : const Value.absent(),
        expiresAt: expiresAt != null ? Value(expiresAt) : const Value.absent(),
        dpopNonce: dpopNonce != null ? Value(dpopNonce) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return rowsAffected > 0;
  }

  Future<bool> updateAccountSessionIfRefreshTokenMatches(
    String did, {
    required String expectedRefreshToken,
    required String handle,
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
    String? displayName,
    String? service,
    String? oauthService,
    String? oauthClientId,
    String? dpopNonce,
    String? dpopPublicKey,
    String? dpopPrivateKey,
  }) async {
    final query = update(accounts)..where((a) => a.did.equals(did) & a.refreshToken.equals(expectedRefreshToken));
    final rowsAffected = await query.write(
      AccountsCompanion(
        handle: Value(handle),
        displayName: displayName != null ? Value(displayName) : const Value.absent(),
        service: service != null ? Value(service) : const Value.absent(),
        oauthService: oauthService != null ? Value(oauthService) : const Value.absent(),
        oauthClientId: oauthClientId != null ? Value(oauthClientId) : const Value.absent(),
        accessToken: Value(accessToken),
        refreshToken: Value(refreshToken),
        dpopNonce: dpopNonce != null ? Value(dpopNonce) : const Value.absent(),
        dpopPublicKey: dpopPublicKey != null ? Value(dpopPublicKey) : const Value.absent(),
        dpopPrivateKey: dpopPrivateKey != null ? Value(dpopPrivateKey) : const Value.absent(),
        expiresAt: expiresAt != null ? Value(expiresAt) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return rowsAffected > 0;
  }

  Future<int> cacheProfile({
    required String did,
    required String handle,
    required String payload,
    DateTime? fetchedAt,
  }) => into(cachedProfiles).insert(
    CachedProfilesCompanion(
      did: Value(did),
      handle: Value(handle),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt ?? DateTime.now()),
    ),
    mode: InsertMode.replace,
  );

  Future<int> cachePost({
    required String uri,
    required String authorDid,
    required String payload,
    DateTime? createdAt,
    DateTime? fetchedAt,
  }) => into(cachedPosts).insert(
    CachedPostsCompanion(
      uri: Value(uri),
      authorDid: Value(authorDid),
      payload: Value(payload),
      createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      fetchedAt: Value(fetchedAt ?? DateTime.now()),
    ),
    mode: InsertMode.replace,
  );

  Future<String?> getSetting(String key) async {
    final setting = await (select(settings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<int> setSetting(String key, String value) => into(settings).insert(
    SettingsCompanion(key: Value(key), value: Value(value), updatedAt: Value(DateTime.now())),
    mode: InsertMode.replace,
  );

  Future<int> deleteSetting(String key) => (delete(settings)..where((s) => s.key.equals(key))).go();

  Future<bool> acquireAuthRefreshLock(String did, {required String owner, required DateTime expiresAt}) async {
    final rowsAffected = await customUpdate(
      '''
      INSERT INTO settings (key, value, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(key) DO UPDATE SET
        value = excluded.value,
        updated_at = excluded.updated_at
      WHERE settings.updated_at < ?
      ''',
      variables: [
        Variable.withString(_authRefreshLockKey(did)),
        Variable.withString(owner),
        Variable.withDateTime(expiresAt.toUtc()),
        Variable.withDateTime(DateTime.now().toUtc()),
      ],
      updates: {settings},
    );
    return rowsAffected > 0;
  }

  Future<bool> isAuthRefreshLockActive(String did) async {
    final setting = await (select(settings)..where((s) => s.key.equals(_authRefreshLockKey(did)))).getSingleOrNull();
    return setting != null && setting.updatedAt.toUtc().isAfter(DateTime.now().toUtc());
  }

  Future<int> releaseAuthRefreshLock(String did, {required String owner}) {
    return (delete(settings)..where((s) => s.key.equals(_authRefreshLockKey(did)) & s.value.equals(owner))).go();
  }

  static String _authRefreshLockKey(String did) => '$_authRefreshLockSettingPrefix$did';

  Future<void> clearLocalCaches() async {
    await runSerializedWrite(() async {
      await transaction(() async {
        await delete(cachedProfiles).go();
        await delete(cachedPosts).go();
        await delete(cachedFeedPages).go();
        await delete(cachedFeedPosts).go();
        await delete(cachedThreadRoots).go();
        await delete(labelerCache).go();
        await customStatement("DELETE FROM settings WHERE key LIKE 'moderation_preferences::%'");
      });
    });
  }

  Future<List<SavedFeedEntry>> getSavedFeeds(String accountDid) =>
      (select(savedFeeds)
            ..where((f) => f.accountDid.equals(accountDid))
            ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
          .get();

  Future<int> insertSavedFeed(SavedFeedsCompanion feed) => into(savedFeeds).insert(feed, mode: InsertMode.replace);

  Future<int> deleteSavedFeed(String id, String accountDid) =>
      (delete(savedFeeds)..where((f) => f.id.equals(id) & f.accountDid.equals(accountDid))).go();

  Future<int> deleteAllSavedFeeds(String accountDid) =>
      (delete(savedFeeds)..where((f) => f.accountDid.equals(accountDid))).go();

  Future<int> cacheFeedPage({
    required String accountDid,
    required String feedKey,
    required String payload,
    DateTime? fetchedAt,
  }) => into(cachedFeedPages).insert(
    CachedFeedPagesCompanion(
      accountDid: Value(accountDid),
      feedKey: Value(feedKey),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt ?? DateTime.now()),
    ),
    mode: InsertMode.replace,
  );

  Future<CachedFeedPage?> getCachedFeedPage(String accountDid, String feedKey) {
    return (select(
      cachedFeedPages,
    )..where((entry) => entry.accountDid.equals(accountDid) & entry.feedKey.equals(feedKey))).getSingleOrNull();
  }

  Future<int> deleteCachedFeedPage(String accountDid, String feedKey) {
    return (delete(
      cachedFeedPages,
    )..where((entry) => entry.accountDid.equals(accountDid) & entry.feedKey.equals(feedKey))).go();
  }

  Future<void> upsertCachedFeedPosts({
    required String accountDid,
    required String feedKey,
    required Iterable<CachedFeedPostsCompanion> posts,
  }) async {
    await batch((batch) {
      for (final post in posts) {
        batch.insert(cachedFeedPosts, post, mode: InsertMode.replace);
      }
    });
  }

  Future<List<CachedFeedPost>> getCachedFeedPosts(String accountDid, String feedKey) {
    return (select(cachedFeedPosts)
          ..where((entry) => entry.accountDid.equals(accountDid) & entry.feedKey.equals(feedKey))
          ..orderBy([(entry) => OrderingTerm.desc(entry.sortOrder)]))
        .get();
  }

  Future<int> deleteCachedFeedPostsForFeed(String accountDid, String feedKey) {
    return (delete(
      cachedFeedPosts,
    )..where((entry) => entry.accountDid.equals(accountDid) & entry.feedKey.equals(feedKey))).go();
  }

  Future<void> pruneCachedFeedPosts({
    required String accountDid,
    required String feedKey,
    required int maxCount,
  }) async {
    final all =
        await (select(cachedFeedPosts)
              ..where((entry) => entry.accountDid.equals(accountDid) & entry.feedKey.equals(feedKey))
              ..orderBy([(entry) => OrderingTerm.desc(entry.sortOrder)]))
            .get();
    if (all.length <= maxCount) {
      return;
    }

    final toDelete = all.skip(maxCount);
    await batch((batch) {
      for (final entry in toDelete) {
        batch.deleteWhere(
          cachedFeedPosts,
          (tbl) =>
              tbl.accountDid.equals(entry.accountDid) &
              tbl.feedKey.equals(entry.feedKey) &
              tbl.postUri.equals(entry.postUri),
        );
      }
    });
  }

  Future<int> cacheThreadRoot({
    required String accountDid,
    required String rootUri,
    required String payload,
    DateTime? fetchedAt,
  }) => into(cachedThreadRoots).insert(
    CachedThreadRootsCompanion(
      accountDid: Value(accountDid),
      rootUri: Value(rootUri),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt ?? DateTime.now()),
    ),
    mode: InsertMode.replace,
  );

  Future<CachedThreadRoot?> getCachedThreadRoot(String accountDid, String rootUri) {
    return (select(
      cachedThreadRoots,
    )..where((entry) => entry.accountDid.equals(accountDid) & entry.rootUri.equals(rootUri))).getSingleOrNull();
  }

  Future<int> deleteCachedThreadRoot(String accountDid, String rootUri) {
    return (delete(
      cachedThreadRoots,
    )..where((entry) => entry.accountDid.equals(accountDid) & entry.rootUri.equals(rootUri))).go();
  }

  Future<void> pruneCachedThreadRoots(String accountDid, int maxCount) async {
    final all =
        await (select(cachedThreadRoots)
              ..where((entry) => entry.accountDid.equals(accountDid))
              ..orderBy([(entry) => OrderingTerm.desc(entry.fetchedAt)]))
            .get();
    if (all.length <= maxCount) {
      return;
    }

    final toDelete = all.skip(maxCount);
    await batch((batch) {
      for (final entry in toDelete) {
        batch.deleteWhere(
          cachedThreadRoots,
          (tbl) => tbl.accountDid.equals(entry.accountDid) & tbl.rootUri.equals(entry.rootUri),
        );
      }
    });
  }

  Future<void> replaceSavedFeeds(String accountDid, List<SavedFeedsCompanion> feeds) async {
    await runSerializedWrite(() async {
      await transaction(() async {
        await deleteAllSavedFeeds(accountDid);
        for (final feed in feeds) {
          await insertSavedFeed(feed);
        }
      });
    });
  }

  Future<List<SearchHistoryEntry>> getSearchHistory(String accountDid, {int limit = 50}) =>
      (select(searchHistory)
            ..where((h) => h.accountDid.equals(accountDid))
            ..orderBy([(h) => OrderingTerm.desc(h.searchedAt)])
            ..limit(limit))
          .get();

  Future<int> insertSearchHistory(SearchHistoryCompanion entry) => into(searchHistory).insert(entry);

  Future<int> deleteSearchHistoryEntry(int id) => (delete(searchHistory)..where((h) => h.id.equals(id))).go();

  Future<int> clearSearchHistory(String accountDid) =>
      (delete(searchHistory)..where((h) => h.accountDid.equals(accountDid))).go();

  Future<void> addSearchHistoryEntry({required String query, required String type, required String accountDid}) async {
    await insertSearchHistory(
      SearchHistoryCompanion(
        query: Value(query),
        type: Value(type),
        accountDid: Value(accountDid),
        searchedAt: Value(DateTime.now()),
      ),
    );

    final entries = await getSearchHistory(accountDid, limit: 100);
    if (entries.length > 50) {
      final toDelete = entries.skip(50);
      for (final entry in toDelete) {
        await deleteSearchHistoryEntry(entry.id);
      }
    }
  }

  Future<List<DraftEntry>> getDrafts(String accountDid) async {
    return (select(drafts)
          ..where((d) => d.accountDid.equals(accountDid))
          ..orderBy([
            (d) => OrderingTerm(expression: d.scheduledAt, mode: OrderingMode.desc),
            (d) => OrderingTerm(expression: d.updatedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<DraftEntry?> getDraft(int id) async {
    return (select(drafts)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Future<int> saveDraft(DraftsCompanion draft) async {
    if (draft.id.present) {
      await updateDraft(draft.id.value, draft);
      return draft.id.value;
    }
    return into(drafts).insert(draft);
  }

  Future<int> updateDraft(int id, DraftsCompanion draft) async {
    final query = update(drafts)..where((d) => d.id.equals(id));
    return query.write(draft.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteDraft(int id) async => (delete(drafts)..where((d) => d.id.equals(id))).go();

  Future<int> deleteAllDrafts(String accountDid) async {
    return (delete(drafts)..where((d) => d.accountDid.equals(accountDid))).go();
  }

  Future<List<SavedPostEntry>> getSavedPosts(String accountDid) async {
    return (select(savedPosts)
          ..where((s) => s.accountDid.equals(accountDid))
          ..orderBy([(s) => OrderingTerm.desc(s.savedAt)]))
        .get();
  }

  Future<SavedPostEntry?> getSavedPost(String accountDid, String postUri) async {
    return (select(
      savedPosts,
    )..where((s) => s.accountDid.equals(accountDid) & s.postUri.equals(postUri))).getSingleOrNull();
  }

  Future<bool> isPostSaved(String accountDid, String postUri) async {
    final saved = await getSavedPost(accountDid, postUri);
    return saved != null;
  }

  Future<int> savePost(SavedPostsCompanion post) async => into(savedPosts).insert(post);

  Future<int> unsavePost(String accountDid, String postUri) async {
    return (delete(savedPosts)..where((s) => s.accountDid.equals(accountDid) & s.postUri.equals(postUri))).go();
  }

  Future<int> unsavePostById(int id) async => (delete(savedPosts)..where((s) => s.id.equals(id))).go();

  Future<int> deleteAllSavedPosts(String accountDid) async =>
      (delete(savedPosts)..where((s) => s.accountDid.equals(accountDid))).go();

  Future<bool> updateSaveType(String accountDid, String postUri, String saveType) async {
    final query = update(savedPosts)..where((s) => s.accountDid.equals(accountDid) & s.postUri.equals(postUri));
    final rowsAffected = await query.write(SavedPostsCompanion(saveType: Value(saveType)));
    return rowsAffected > 0;
  }

  Stream<List<SavedPostEntry>> watchSavedPosts(String accountDid) =>
      (select(savedPosts)
            ..where((s) => s.accountDid.equals(accountDid))
            ..orderBy([(s) => OrderingTerm.desc(s.savedAt)]))
          .watch();

  Stream<bool> watchIsPostSaved(String accountDid, String postUri) =>
      (select(savedPosts)..where((s) => s.accountDid.equals(accountDid) & s.postUri.equals(postUri)))
          .watchSingleOrNull()
          .map((saved) => saved != null);

  Stream<Set<String>> watchSavedPostUris(String accountDid) => (select(
    savedPosts,
  )..where((s) => s.accountDid.equals(accountDid))).watch().map((posts) => posts.map((p) => p.postUri).toSet());

  Stream<Map<String, String>> watchSavedPostsWithType(String accountDid) {
    return (select(savedPosts)..where((s) => s.accountDid.equals(accountDid))).watch().map(
      (posts) => {for (final p in posts) p.postUri: p.saveType},
    );
  }

  Future<LabelerCacheEntry?> getLabelerCache(String labelerDid) =>
      (select(labelerCache)..where((l) => l.labelerDid.equals(labelerDid))).getSingleOrNull();

  Future<List<LabelerCacheEntry>> getAllLabelerCache() => select(labelerCache).get();

  Future<int> upsertLabelerCache(String labelerDid, String policiesJson) => into(labelerCache).insert(
    LabelerCacheCompanion(
      labelerDid: Value(labelerDid),
      policiesJson: Value(policiesJson),
      fetchedAt: Value(DateTime.now()),
    ),
    mode: InsertMode.replace,
  );

  Future<int> deleteLabelerCache(String labelerDid) =>
      (delete(labelerCache)..where((l) => l.labelerDid.equals(labelerDid))).go();

  Future<List<LikedPostEntry>> getLikedPosts(String accountDid, {int limit = 50, int offset = 0}) =>
      (select(likedPosts)
            ..where((l) => l.accountDid.equals(accountDid))
            ..orderBy([(l) => OrderingTerm.desc(l.likedAt), (l) => OrderingTerm.desc(l.postUri)])
            ..limit(limit, offset: offset))
          .get();

  Future<LikedPostEntry?> getLikedPost(String accountDid, String postUri) =>
      (select(likedPosts)..where((l) => l.accountDid.equals(accountDid) & l.postUri.equals(postUri))).getSingleOrNull();

  Future<int> upsertLikedPost(LikedPostsCompanion post) =>
      into(likedPosts).insert(post, mode: InsertMode.insertOrIgnore);

  Future<int> updateLikedPost(int id, {required String postJson, required DateTime likedAt}) => (update(
    likedPosts,
  )..where((l) => l.id.equals(id))).write(LikedPostsCompanion(postJson: Value(postJson), likedAt: Value(likedAt)));

  Future<int> removeLikedPost(String accountDid, String postUri) =>
      (delete(likedPosts)..where((l) => l.accountDid.equals(accountDid) & l.postUri.equals(postUri))).go();

  Future<int> countLikedPosts(String accountDid) async {
    final count = await (select(likedPosts)..where((l) => l.accountDid.equals(accountDid))).get();
    return count.length;
  }

  Future<void> evictOldestLikedPosts(String accountDid, int maxCount) async {
    final all =
        await (select(likedPosts)
              ..where((l) => l.accountDid.equals(accountDid))
              ..orderBy([(l) => OrderingTerm.desc(l.likedAt)]))
            .get();
    if (all.length > maxCount) {
      final toDelete = all.skip(maxCount);
      for (final entry in toDelete) {
        await (delete(likedPosts)..where((l) => l.id.equals(entry.id))).go();
      }
    }
  }

  Future<int> deleteAllLikedPosts(String accountDid) =>
      (delete(likedPosts)..where((l) => l.accountDid.equals(accountDid))).go();

  Future<List<KeywordPostMatch>> searchPostsByKeyword({
    required String accountDid,
    required String query,
    String? source,
    int limit = 20,
  }) async {
    final ftsQuery = _buildFtsQuery(query);
    if (ftsQuery == null || limit <= 0) {
      return const [];
    }

    final sourceFilter = source == 'saved' || source == 'liked' ? source : null;
    final rows = await customSelect(
      '''
      SELECT post_uri, source, bm25(post_search_fts, 8.0, 1.0) AS rank
      FROM post_search_fts
      WHERE account_did = ?
        ${sourceFilter == null ? '' : 'AND source = ?'}
        AND post_search_fts MATCH ?
      ORDER BY rank ASC
      LIMIT ?
      ''',
      variables: [
        Variable(accountDid),
        if (sourceFilter != null) Variable(sourceFilter),
        Variable(ftsQuery),
        Variable(limit),
      ],
    ).get();
    return _mapKeywordPostMatches(rows);
  }

  List<KeywordPostMatch> _mapKeywordPostMatches(List<QueryRow> rows) => rows
      .map(
        (row) => KeywordPostMatch(
          postUri: row.read<String>('post_uri'),
          source: row.read<String>('source'),
          rank: row.read<double>('rank'),
        ),
      )
      .toList(growable: false);

  Future<void> _createPostSearchFtsSchema() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS post_search_fts USING fts5(
        account_did UNINDEXED,
        source UNINDEXED,
        post_uri UNINDEXED,
        handle,
        content,
        tokenize = 'unicode61'
      )
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS saved_posts_ai
      AFTER INSERT ON saved_posts BEGIN
        INSERT INTO post_search_fts(account_did, source, post_uri, handle, content)
        VALUES (
          new.account_did,
          'saved',
          new.post_uri,
          coalesce(json_extract(new.post_json, '\$.author.handle'), ''),
          coalesce(json_extract(new.post_json, '\$.record.text'), '')
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS saved_posts_au
      AFTER UPDATE ON saved_posts BEGIN
        DELETE FROM post_search_fts
        WHERE account_did = old.account_did AND source = 'saved' AND post_uri = old.post_uri;
        INSERT INTO post_search_fts(account_did, source, post_uri, handle, content)
        VALUES (
          new.account_did,
          'saved',
          new.post_uri,
          coalesce(json_extract(new.post_json, '\$.author.handle'), ''),
          coalesce(json_extract(new.post_json, '\$.record.text'), '')
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS saved_posts_ad
      AFTER DELETE ON saved_posts BEGIN
        DELETE FROM post_search_fts
        WHERE account_did = old.account_did AND source = 'saved' AND post_uri = old.post_uri;
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS liked_posts_ai
      AFTER INSERT ON liked_posts BEGIN
        INSERT INTO post_search_fts(account_did, source, post_uri, handle, content)
        VALUES (
          new.account_did,
          'liked',
          new.post_uri,
          coalesce(json_extract(new.post_json, '\$.post.author.handle'), coalesce(json_extract(new.post_json, '\$.author.handle'), '')),
          coalesce(json_extract(new.post_json, '\$.post.record.text'), coalesce(json_extract(new.post_json, '\$.record.text'), ''))
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS liked_posts_au
      AFTER UPDATE ON liked_posts BEGIN
        DELETE FROM post_search_fts
        WHERE account_did = old.account_did AND source = 'liked' AND post_uri = old.post_uri;
        INSERT INTO post_search_fts(account_did, source, post_uri, handle, content)
        VALUES (
          new.account_did,
          'liked',
          new.post_uri,
          coalesce(json_extract(new.post_json, '\$.post.author.handle'), coalesce(json_extract(new.post_json, '\$.author.handle'), '')),
          coalesce(json_extract(new.post_json, '\$.post.record.text'), coalesce(json_extract(new.post_json, '\$.record.text'), ''))
        );
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS liked_posts_ad
      AFTER DELETE ON liked_posts BEGIN
        DELETE FROM post_search_fts
        WHERE account_did = old.account_did AND source = 'liked' AND post_uri = old.post_uri;
      END
    ''');
  }

  Future<void> _rebuildPostSearchFts() async {
    await customStatement('DELETE FROM post_search_fts');
    await customStatement('''
      INSERT INTO post_search_fts(account_did, source, post_uri, handle, content)
      SELECT
        account_did,
        'saved',
        post_uri,
        coalesce(json_extract(post_json, '\$.author.handle'), ''),
        coalesce(json_extract(post_json, '\$.record.text'), '')
      FROM saved_posts
    ''');
    await customStatement('''
      INSERT INTO post_search_fts(account_did, source, post_uri, handle, content)
      SELECT
        account_did,
        'liked',
        post_uri,
        coalesce(json_extract(post_json, '\$.post.author.handle'), coalesce(json_extract(post_json, '\$.author.handle'), '')),
        coalesce(json_extract(post_json, '\$.post.record.text'), coalesce(json_extract(post_json, '\$.record.text'), ''))
      FROM liked_posts
    ''');
  }

  static String? _buildFtsQuery(String rawQuery) {
    final tokens = RegExp(r'[A-Za-z0-9_]+').allMatches(rawQuery.toLowerCase()).map((m) => m.group(0)!).toList();
    if (tokens.isEmpty) {
      return null;
    }
    return tokens.map((token) => '$token*').join(' AND ');
  }

  Future<bool> recordNotificationDelivery({
    required String accountDid,
    required String notificationUri,
    String? notificationCid,
    required String reason,
    required DateTime indexedAt,
    required String source,
    DateTime? deliveredAt,
  }) async {
    final existing = await getNotificationDelivery(accountDid, notificationUri);
    if (existing == null) {
      await into(notificationDeliveries).insert(
        NotificationDeliveriesCompanion.insert(
          accountDid: accountDid,
          notificationUri: notificationUri,
          notificationCid: Value(notificationCid),
          reason: reason,
          indexedAt: indexedAt,
          source: source,
          deliveredAt: Value(deliveredAt ?? DateTime.now()),
        ),
      );
      return true;
    }

    await (update(
      notificationDeliveries,
    )..where((entry) => entry.accountDid.equals(accountDid) & entry.notificationUri.equals(notificationUri))).write(
      NotificationDeliveriesCompanion(
        notificationCid: notificationCid != null ? Value(notificationCid) : const Value.absent(),
        reason: Value(reason),
        indexedAt: Value(indexedAt),
        source: Value(source),
      ),
    );

    return false;
  }

  Future<NotificationDeliveryEntry?> getNotificationDelivery(String accountDid, String notificationUri) =>
      (select(notificationDeliveries)
            ..where((entry) => entry.accountDid.equals(accountDid) & entry.notificationUri.equals(notificationUri)))
          .getSingleOrNull();

  Future<int> countNotificationDeliveries(String accountDid) async {
    final rows = await (select(notificationDeliveries)..where((entry) => entry.accountDid.equals(accountDid))).get();
    return rows.length;
  }
}

void _configureNativeDatabaseConnection(dynamic database) {
  database.execute('PRAGMA busy_timeout = 5000');
  database.execute('PRAGMA journal_mode = WAL');
  database.execute('PRAGMA synchronous = NORMAL');
  database.execute('PRAGMA foreign_keys = ON');
}
