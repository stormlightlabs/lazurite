import 'dart:typed_data';

import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/objectbox.g.dart';

/// CRUD operations on [EmbeddedPost] in the ObjectBox store.
class EmbeddingRepository {
  EmbeddingRepository(ObjectBoxStore objectBoxStore) : _box = Box<EmbeddedPost>(objectBoxStore.store);

  final Box<EmbeddedPost> _box;

  /// Insert or update an [EmbeddedPost].
  ///
  /// ObjectBox matches on the [EmbeddedPost.postUri] unique index and updates
  /// the existing entry if one is found; otherwise inserts a new one.
  void upsert(EmbeddedPost post) {
    final existing = _box.query(EmbeddedPost_.postUri.equals(post.postUri)).build().findFirst();
    if (existing != null) {
      post.id = existing.id;
    }
    _box.put(post);
  }

  /// Delete the entry for [postUri], if any.
  void deleteByUri(String postUri) {
    final query = _box.query(EmbeddedPost_.postUri.equals(postUri)).build();
    final ids = query.findIds();
    query.close();
    _box.removeMany(ids);
  }

  /// Return all [EmbeddedPost] entries for [accountDid], optionally filtered
  /// by [source] ('saved' or 'liked').
  List<EmbeddedPost> queryByAccount(String accountDid, {String? source}) {
    QueryBuilder<EmbeddedPost> builder = _box.query(EmbeddedPost_.accountDid.equals(accountDid));
    if (source != null) {
      builder = _box.query(EmbeddedPost_.accountDid.equals(accountDid) & EmbeddedPost_.source.equals(source));
    }
    final query = builder.build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Return the nearest-neighbour [EmbeddedPost] entries for [accountDid],
  /// ordered by ascending cosine distance to [queryVector].
  ///
  /// [source] optionally filters to 'saved' or 'liked'.
  /// [maxResults] caps the number of candidates returned by HNSW.
  List<ObjectWithScore<EmbeddedPost>> nearestNeighbors(
    Float32List queryVector,
    String accountDid, {
    String? source,
    int maxResults = 20,
  }) {
    final hnswCondition = EmbeddedPost_.embedding.nearestNeighborsF32(queryVector, maxResults);
    final accountCondition = EmbeddedPost_.accountDid.equals(accountDid);

    final condition = source != null
        ? hnswCondition.and(accountCondition).and(EmbeddedPost_.source.equals(source))
        : hnswCondition.and(accountCondition);

    final query = _box.query(condition).build();
    final results = query.findWithScores();
    query.close();
    return results;
  }

  /// Return the number of indexed posts for [accountDid].
  int countByAccount(String accountDid) {
    final query = _box.query(EmbeddedPost_.accountDid.equals(accountDid)).build();
    final count = query.count();
    query.close();
    return count;
  }
}
