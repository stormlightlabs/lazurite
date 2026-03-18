import 'package:drift/drift.dart';

@DataClassName('Account')
class Accounts extends Table {
  TextColumn get did => text()();
  TextColumn get handle => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get service => text().nullable()();
  TextColumn get accessToken => text()();
  TextColumn get refreshToken => text().nullable()();
  TextColumn get dpopPublicKey => text().nullable()();
  TextColumn get dpopPrivateKey => text().nullable()();
  TextColumn get dpopNonce => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {did};
}

@DataClassName('CachedProfile')
class CachedProfiles extends Table {
  TextColumn get did => text()();
  TextColumn get handle => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {did};
}

@DataClassName('CachedPost')
class CachedPosts extends Table {
  TextColumn get uri => text()();
  TextColumn get authorDid => text()();
  TextColumn get accountDid => text().nullable()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {uri};
}

@DataClassName('SettingsEntry')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('SavedFeedEntry')
class SavedFeeds extends Table {
  TextColumn get id => text()();
  TextColumn get accountDid => text()();
  TextColumn get type => text()();
  TextColumn get value => text()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id, accountDid};
}

@DataClassName('SearchHistoryEntry')
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  TextColumn get type => text()();
  DateTimeColumn get searchedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get accountDid => text()();
}

@DataClassName('DraftEntry')
class Drafts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountDid => text()();
  TextColumn get content => text()();
  TextColumn get replyUri => text().nullable()();
  TextColumn get replyCid => text().nullable()();
  TextColumn get rootUri => text().nullable()();
  TextColumn get rootCid => text().nullable()();
  TextColumn get embedJson => text().nullable()();
  TextColumn get mediaPaths => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
}

@DataClassName('SavedPostEntry')
class SavedPosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountDid => text()();
  TextColumn get postUri => text()();
  TextColumn get postJson => text()();
  TextColumn get saveType => text().withDefault(const Constant('local'))();
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => ['UNIQUE (account_did, post_uri)'];
}

@DataClassName('LabelerCacheEntry')
class LabelerCache extends Table {
  TextColumn get labelerDid => text()();
  TextColumn get policiesJson => text()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {labelerDid};
}
