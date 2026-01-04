import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('database can be created and opened', () async {
    final version = await database.customSelect('SELECT sqlite_version()').get();
    expect(version, isNotEmpty);
  });

  test('can insert and read profiles', () async {
    final profile = ProfilesCompanion.insert(
      did: 'did:plc:123',
      handle: 'alice.bsky.social',
      displayName: const Value('Alice'),
    );

    await database.into(database.profiles).insert(profile);

    final result = await database.select(database.profiles).getSingle();
    expect(result.did, 'did:plc:123');
    expect(result.handle, 'alice.bsky.social');
    expect(result.displayName, 'Alice');
  });

  test('can insert and read posts', () async {
    final post = PostsCompanion.insert(
      uri: 'at://did:plc:123/app.bsky.feed.post/123',
      cid: 'bafyreidc',
      authorDid: 'did:plc:123',
      record: '{}',
      indexedAt: const Value(null),
    );

    await database.into(database.posts).insert(post);

    final result = await database.select(database.posts).getSingle();
    expect(result.uri, 'at://did:plc:123/app.bsky.feed.post/123');
    expect(result.cid, 'bafyreidc');
  });
}
