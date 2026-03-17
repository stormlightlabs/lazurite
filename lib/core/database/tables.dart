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
