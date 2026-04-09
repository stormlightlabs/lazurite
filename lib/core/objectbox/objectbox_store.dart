import 'package:flutter/foundation.dart';
import 'package:lazurite/objectbox.g.dart';

/// Singleton wrapper around the ObjectBox [Store].
///
/// Initialized once at app startup (after Drift init) and exposed via
/// [RepositoryProvider] for the embedding pipeline.
class ObjectBoxStore {
  ObjectBoxStore._(this.store);

  /// Creates an [ObjectBoxStore] wrapping an already-opened [Store].
  ///
  /// Intended for tests that provide their own in-memory store.
  @visibleForTesting
  factory ObjectBoxStore.forTesting(Store store) => ObjectBoxStore._(store);

  final Store store;

  /// Opens the ObjectBox store in the default Flutter app directory.
  static Future<ObjectBoxStore> open() async {
    final store = await openStore();
    return ObjectBoxStore._(store);
  }

  void close() => store.close();
}
