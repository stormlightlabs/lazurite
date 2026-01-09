import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
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

/// Provides the list of collections for the current user's repository.
///
/// Returns null if not authenticated.
/// Caches the result until invalidated.
@riverpod
Future<List<RepoCollection>?> collections(Ref ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthStateAuthenticated) {
    return null;
  }

  final repo = ref.watch(devtoolsRepositoryProvider);
  return repo.describeRepo(authState.session.did);
}

/// Provides a filtered list of collections based on a search query.
///
/// [query] is the search string to filter collections by NSID.
/// Returns collections whose NSID contains the query (case-insensitive).
@riverpod
Future<List<RepoCollection>> filteredCollections(Ref ref, String query) async {
  final allCollections = await ref.watch(collectionsProvider.future);
  if (allCollections == null) {
    return [];
  }

  if (query.isEmpty) {
    return allCollections;
  }

  final lowerQuery = query.toLowerCase();
  return allCollections.where((c) => c.nsid.toLowerCase().contains(lowerQuery)).toList();
}

/// Provides a stream of pinned collections/records from the database.
@riverpod
Stream<List<String>> pinnedUris(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.devToolsDao.watchPins().map((pins) => pins.map((p) => p.uri).toList());
}

/// State class for managing paginated records.
class RecordsState {
  const RecordsState({
    this.records = const [],
    this.cursor,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  final List<RepoRecord> records;
  final String? cursor;
  final bool isLoading;
  final bool hasMore;
  final Object? error;

  RecordsState copyWith({
    List<RepoRecord>? records,
    String? cursor,
    bool? isLoading,
    bool? hasMore,
    Object? error,
  }) {
    return RecordsState(
      records: records ?? this.records,
      cursor: cursor ?? this.cursor,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

/// Provides paginated records for a specific collection.
///
/// Manages infinite scroll with cursor-based pagination.
/// [did] is the repository DID to query.
/// [collection] is the collection NSID.
@riverpod
class Records extends _$Records {
  static const int _pageSize = 50;

  @override
  Future<RecordsState> build(String did, String collection) async {
    return _loadInitialRecords();
  }

  Future<RecordsState> _loadInitialRecords() async {
    try {
      final repo = ref.read(devtoolsRepositoryProvider);
      final result = await repo.listRecords(repo: did, collection: collection, limit: _pageSize);

      final records = result['records'] as List<RepoRecord>;
      final cursor = result['cursor'] as String?;

      return RecordsState(
        records: records,
        cursor: cursor,
        isLoading: false,
        hasMore: cursor != null,
      );
    } catch (e) {
      return RecordsState(error: e, isLoading: false, hasMore: false);
    }
  }

  /// Loads the next page of records.
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoading ||
        !currentState.hasMore ||
        currentState.cursor == null) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repo = ref.read(devtoolsRepositoryProvider);
      final result = await repo.listRecords(
        repo: did,
        collection: collection,
        limit: _pageSize,
        cursor: currentState.cursor,
      );

      final newRecords = result['records'] as List<RepoRecord>;
      final newCursor = result['cursor'] as String?;

      final allRecords = [...currentState.records, ...newRecords];

      state = AsyncValue.data(
        RecordsState(
          records: allRecords,
          cursor: newCursor,
          isLoading: false,
          hasMore: newCursor != null,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isLoading: false, error: e));
    }
  }

  /// Refreshes the records list from the beginning.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadInitialRecords());
  }
}
