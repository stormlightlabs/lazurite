import 'package:drift/drift.dart';

class Posts extends Table {
  TextColumn get uri => text()();
  TextColumn get cid => text()();
  TextColumn get authorDid => text()();
  TextColumn get record => text()();
  TextColumn get embed => text().nullable()();
  DateTimeColumn get indexedAt => dateTime().nullable()();
  IntColumn get replyCount => integer().withDefault(const Constant(0))();
  IntColumn get repostCount => integer().withDefault(const Constant(0))();
  IntColumn get likeCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {uri};

  @override
  List<String> get customConstraints => [];
}

class Profiles extends Table {
  TextColumn get did => text()();
  TextColumn get handle => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get banner => text().nullable()();
  DateTimeColumn get indexedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {did};
}

class TimelineItems extends Table {
  TextColumn get feedKey => text()();
  TextColumn get postUri => text().references(Posts, #uri)();
  TextColumn get reason => text().nullable()();
  TextColumn get sortKey => text()();

  @override
  Set<Column> get primaryKey => {feedKey, postUri};

  // TODO: Add composite index for timeline queries
  // @override
  // List<Index> get indexes => [Index('timeline_sort_idx', 'feedKey, sortKey')];
}

class Accounts extends Table {
  TextColumn get did => text()();
  TextColumn get handle => text()();
  TextColumn get pdsUrl => text()();

  @override
  Set<Column> get primaryKey => {did};
}

class FeedCursors extends Table {
  TextColumn get feedKey => text()();
  TextColumn get cursor => text()();
  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {feedKey};
}

class RecentSearches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text().unique()();
  DateTimeColumn get searchedAt => dateTime()();
}

/// Stores follow relationships for caching viewer state.
class Follows extends Table {
  /// The DID of the user doing the following.
  TextColumn get actorDid => text()();

  /// The DID of the user being followed.
  TextColumn get subjectDid => text()();

  /// The AT URI of the follow record (at://did:plc:xxx/app.bsky.graph.follow/yyy).
  TextColumn get uri => text()();

  /// When the follow was created.
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {actorDid, subjectDid};
}

/// Stores saved feed generators with metadata.
///
/// This table caches user preferences from app.bsky.actor.getPreferences
/// (savedFeedsPref) and enriches them with metadata from app.bsky.feed.getFeedGenerator.
class SavedFeeds extends Table {
  /// Feed generator AT URI (at://did:plc:xxx/app.bsky.feed.generator/yyy).
  TextColumn get uri => text()();

  /// Display name of the feed.
  TextColumn get displayName => text()();

  /// Feed description.
  TextColumn get description => text().nullable()();

  /// Feed avatar URL.
  TextColumn get avatar => text().nullable()();

  /// DID of the feed creator.
  TextColumn get creatorDid => text()();

  /// Number of likes the feed has received.
  IntColumn get likeCount => integer().withDefault(const Constant(0))();

  /// Sort order for display (lower values appear first).
  IntColumn get sortOrder => integer()();

  /// Whether the feed is pinned by the user.
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  /// When the feed metadata was last synced from remote.
  DateTimeColumn get lastSynced => dateTime()();

  @override
  Set<Column> get primaryKey => {uri};
}
