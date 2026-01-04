import 'package:drift/drift.dart';

class Posts extends Table {
  TextColumn get uri => text()();
  TextColumn get cid => text()();
  TextColumn get authorDid => text()();
  TextColumn get record => text()();
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
