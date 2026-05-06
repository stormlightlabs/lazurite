import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/cache/local_cache_maintenance_service.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/objectbox.g.dart';

var _storeCounter = 0;

ObjectBoxStore _makeInMemoryStore() {
  final store = Store(getObjectBoxModel(), directory: 'memory:cache-maintenance-${_storeCounter++}');
  return ObjectBoxStore.forTesting(store);
}

EmbeddedPost _post({required String postUri, required String accountDid}) {
  return EmbeddedPost(
    postUri: postUri,
    accountDid: accountDid,
    source: 'saved',
    indexedText: 'cached text',
    embedding: Float32List(384),
    embeddedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late AppDatabase database;
  late ObjectBoxStore objectBoxStore;
  late EmbeddingRepository embeddingRepository;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    objectBoxStore = _makeInMemoryStore();
    embeddingRepository = EmbeddingRepository(objectBoxStore);
  });

  tearDown(() async {
    objectBoxStore.close();
    await database.close();
  });

  test('clearCaches clears database caches, semantic index, and image caches', () async {
    var diskImageCleared = false;
    var memoryImageCleared = false;
    final service = LocalCacheMaintenanceService(
      database: database,
      objectBoxStore: objectBoxStore,
      clearImageDiskCache: () async {
        diskImageCleared = true;
      },
      clearImageMemoryCache: () {
        memoryImageCleared = true;
      },
    );

    await database.cacheProfile(did: 'did:plc:user', handle: 'user.bsky.social', payload: '{}');
    embeddingRepository.upsert(_post(postUri: 'at://did:plc:user/app.bsky.feed.post/1', accountDid: 'did:plc:user'));

    await service.clearCaches();

    expect(await database.select(database.cachedProfiles).get(), isEmpty);
    expect(embeddingRepository.countByAccount('did:plc:user'), 0);
    expect(diskImageCleared, isTrue);
    expect(memoryImageCleared, isTrue);
  });
}
