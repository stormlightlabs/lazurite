import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lazurite/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    CachedProfiles,
    CachedPosts,
    Settings,
    SavedFeeds,
    SearchHistory,
    Drafts,
    SavedPosts,
    LabelerCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
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
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'lazurite_db',
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    );
  }

  Future<Account?> getAccount(String did) => (select(accounts)..where((a) => a.did.equals(did))).getSingleOrNull();

  Future<Account?> getActiveAccount() async {
    final all = await (select(accounts)..orderBy([(a) => OrderingTerm.desc(a.updatedAt)])).get();
    return all.isNotEmpty ? all.first : null;
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

  Future<void> replaceSavedFeeds(String accountDid, List<SavedFeedsCompanion> feeds) async {
    await transaction(() async {
      await deleteAllSavedFeeds(accountDid);
      for (final feed in feeds) {
        await insertSavedFeed(feed);
      }
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

  Future<int> deleteDraft(int id) async {
    return (delete(drafts)..where((d) => d.id.equals(id))).go();
  }

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

  Future<int> savePost(SavedPostsCompanion post) async {
    return into(savedPosts).insert(post);
  }

  Future<int> unsavePost(String accountDid, String postUri) async {
    return (delete(savedPosts)..where((s) => s.accountDid.equals(accountDid) & s.postUri.equals(postUri))).go();
  }

  Future<int> unsavePostById(int id) async {
    return (delete(savedPosts)..where((s) => s.id.equals(id))).go();
  }

  Future<int> deleteAllSavedPosts(String accountDid) async {
    return (delete(savedPosts)..where((s) => s.accountDid.equals(accountDid))).go();
  }

  Future<bool> updateSaveType(String accountDid, String postUri, String saveType) async {
    final query = update(savedPosts)..where((s) => s.accountDid.equals(accountDid) & s.postUri.equals(postUri));
    final rowsAffected = await query.write(SavedPostsCompanion(saveType: Value(saveType)));
    return rowsAffected > 0;
  }

  Stream<List<SavedPostEntry>> watchSavedPosts(String accountDid) {
    return (select(savedPosts)
          ..where((s) => s.accountDid.equals(accountDid))
          ..orderBy([(s) => OrderingTerm.desc(s.savedAt)]))
        .watch();
  }

  Stream<bool> watchIsPostSaved(String accountDid, String postUri) {
    return (select(savedPosts)..where((s) => s.accountDid.equals(accountDid) & s.postUri.equals(postUri)))
        .watchSingleOrNull()
        .map((saved) => saved != null);
  }

  Stream<Set<String>> watchSavedPostUris(String accountDid) {
    return (select(
      savedPosts,
    )..where((s) => s.accountDid.equals(accountDid))).watch().map((posts) => posts.map((p) => p.postUri).toSet());
  }

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
}
