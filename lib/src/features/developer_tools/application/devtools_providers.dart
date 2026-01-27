import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/core/utils/pagination.dart';
import 'package:lazurite/src/features/developer_tools/domain/recent_record.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_collection.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';
import 'package:lazurite/src/features/developer_tools/infrastructure/devtools_repository.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'devtools_providers.g.dart';

/// Provides the DevtoolsRepository instance.
@Riverpod(keepAlive: true)
DevtoolsRepository devtoolsRepository(Ref ref) {
  return DevtoolsRepository(
    ref.watch(xrpcClientProvider),
    ref.watch(loggerProvider('DevtoolsRepository')),
  );
}

/// Provides the list of collections for a given repository DID.
@riverpod
Future<List<RepoCollection>?> collections(Ref ref, String did) async {
  final repo = ref.watch(devtoolsRepositoryProvider);
  return repo.describeRepo(did);
}

/// Provides a filtered list of collections based on a search query.
@riverpod
Future<List<RepoCollection>> filteredCollections(Ref ref, String did, String query) async {
  final allCollections = await ref.watch(collectionsProvider(did).future);
  if (allCollections == null) return [];
  if (query.isEmpty) return allCollections;
  final lowerQuery = query.toLowerCase();
  return allCollections.where((c) => c.nsid.toLowerCase().contains(lowerQuery)).toList();
}

/// Provides a stream of pinned collections/records from the database.
@riverpod
Stream<List<String>> pinnedUris(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.devToolsDao.watchPins().map((pins) => pins.map((p) => p.uri).toList());
}

/// Provides a stream of recently viewed records from the database.
@riverpod
Stream<List<RecentRecord>> recentRecords(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.devToolsDao.watchRecentRecords().map((records) {
    return records
        .map(
          (r) => RecentRecord(
            uri: r.uri,
            did: r.did,
            collection: r.collection,
            rkey: r.rkey,
            cid: r.cid,
            indexedAt: r.indexedAt,
            viewedAt: r.viewedAt,
          ),
        )
        .toList();
  });
}

/// Provides a single record by collection and rkey for a given repository DID.
@riverpod
Future<RepoRecord?> recordDetail(Ref ref, String did, String collection, String rkey) async {
  final repo = ref.watch(devtoolsRepositoryProvider);
  return repo.getRecord(repo: did, collection: collection, rkey: rkey);
}

/// Notifier for managing paginated records in a collection.
///
/// Follows established patterns from search_providers.dart and profile_providers.dart.
@riverpod
class Records extends _$Records with CursorPaginationMixin<RepoRecord> {
  @override
  Future<List<RepoRecord>> build(
    String did,
    String collection,
    String? rkeyStart,
    bool reverse,
    bool hasBlob,
  ) async {
    return _fetchRecords();
  }

  Future<List<RepoRecord>> _fetchRecords({bool loadMore = false}) async {
    final repo = ref.read(devtoolsRepositoryProvider);

    final result = await repo.listRecords(
      repo: did,
      collection: collection,
      cursor: loadMore ? cursor : null,
      rkeyStart: rkeyStart,
      reverse: reverse,
    );

    updatePagination(result);

    var items = result.items;

    if (hasBlob) {
      items = items.where((r) => r.hasBlob == true).toList();
    }

    if (loadMore) {
      final current = state.value ?? [];
      return [...current, ...items];
    }
    return items;
  }

  /// Loads next page of records.
  Future<void> loadMore() async {
    if (!canLoadMore || state.isLoading) return;
    state = AsyncData(await _fetchRecords(loadMore: true));
  }

  /// Refreshes records list from beginning.
  Future<void> refresh() async {
    resetPagination();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchRecords());
  }
}

/// Resolves a handle or DID to a valid DID.
@riverpod
Future<String?> resolvedDid(Ref ref, String handleOrDid) async {
  if (handleOrDid.startsWith('did:')) return handleOrDid;
  final repo = ref.watch(devtoolsRepositoryProvider);
  try {
    return await repo.resolveHandle(handleOrDid);
  } catch (e) {
    return null;
  }
}
