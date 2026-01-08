import 'dart:async';

import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/core/utils/pagination.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

@riverpod
SearchRepository searchRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  final logger = ref.watch(loggerProvider('SearchRepository'));
  return SearchRepository(api, db.searchDao, db.searchCacheDao, sessionStorage, logger);
}

@riverpod
class SearchNotifier extends _$SearchNotifier with CursorPaginationMixin<Post> {
  @override
  Future<List<Post>> build(String query) async {
    if (query.isEmpty) return [];
    return _search(query);
  }

  Future<List<Post>> _search(String query, {bool loadMore = false}) async {
    final repository = ref.read(searchRepositoryProvider);

    if (!loadMore) {
      await repository.saveRecentSearch(query);
    }

    final result = await repository.searchPosts(query, cursor: loadMore ? cursor : null);
    updatePagination(result);

    if (loadMore) {
      final current = state.value ?? [];
      return [...current, ...result.items];
    }
    return result.items;
  }

  Future<void> loadMore() async {
    if (!canLoadMore || state.isLoading) return;
    state = AsyncData(await _search(query, loadMore: true));
  }

  Future<void> refresh() async {
    resetPagination();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _search(query));
  }
}

/// A simple domain model for recent searches.
class RecentSearchItem {
  RecentSearchItem({required this.query, required this.searchedAt});

  final String query;
  final DateTime searchedAt;
}

@riverpod
class RecentSearchesNotifier extends _$RecentSearchesNotifier {
  @override
  Stream<List<RecentSearchItem>> build() {
    final repository = ref.watch(searchRepositoryProvider);
    return repository.watchRecentSearches().map(
      (list) =>
          list.map((e) => RecentSearchItem(query: e.query, searchedAt: e.searchedAt)).toList(),
    );
  }

  Future<void> remove(String query) async {
    final repository = ref.read(searchRepositoryProvider);
    await repository.removeRecentSearch(query);
  }

  Future<void> clearAll() async {
    final repository = ref.read(searchRepositoryProvider);
    await repository.clearAllRecentSearches();
  }
}

/// Notifier for searching actors with pagination.
@riverpod
class ActorSearchNotifier extends _$ActorSearchNotifier
    with CursorPaginationMixin<SearchActorItem> {
  Timer? _debounceTimer;

  @override
  Future<List<SearchActorItem>> build(String query) async {
    ref.onDispose(() => _debounceTimer?.cancel());
    if (query.isEmpty) return [];
    return _search(query);
  }

  Future<List<SearchActorItem>> _search(String query, {bool loadMore = false}) async {
    final repository = ref.read(searchRepositoryProvider);

    if (!loadMore) {
      await repository.saveRecentSearch(query);
    }

    final result = await repository.searchActors(query, cursor: loadMore ? cursor : null);
    updatePagination(result);

    if (loadMore) {
      final current = state.value ?? [];
      return [...current, ...result.items];
    }
    return result.items;
  }

  Future<void> loadMore() async {
    if (!canLoadMore || state.isLoading) return;
    state = AsyncData(await _search(query, loadMore: true));
  }

  Future<void> refresh() async {
    resetPagination();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _search(query));
  }
}
