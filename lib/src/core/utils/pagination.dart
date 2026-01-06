/// Generic result type for paginated API responses.
///
/// Provides a consistent interface for cursor-based pagination across
/// different features (search, feeds, profiles, etc.).
class PaginatedResult<T> {
  const PaginatedResult({required this.items, this.cursor});

  /// The items in this page of results.
  final List<T> items;

  /// The cursor for fetching the next page, or null if no more pages.
  final String? cursor;

  /// Whether there are more results to fetch.
  bool get hasMore => cursor != null;
}

/// Mixin providing cursor-based pagination state for Riverpod notifiers.
///
/// Use to standardize pagination across notifiers:
/// ```dart
/// class MyNotifier extends _$MyNotifier with CursorPaginationMixin<MyItem> {
///   @override
///   Future<List<MyItem>> build() async {
///     return _fetch();
///   }
///
///   Future<List<MyItem>> _fetch({bool loadMore = false}) async {
///     final result = await repository.getItems(cursor: loadMore ? cursor : null);
///     updatePagination(result);
///     return result.items;
///   }
///
///   Future<void> loadMore() async {
///     if (!canLoadMore || state.isLoading) return;
///     state = AsyncData(await _fetch(loadMore: true));
///   }
/// }
/// ```
mixin CursorPaginationMixin<T> {
  String? _cursor;
  bool _hasMore = true;

  /// The current cursor for fetching the next page.
  String? get cursor => _cursor;

  /// Whether there are more results to fetch.
  bool get hasMore => _hasMore;

  /// Whether a loadMore operation can be performed.
  bool get canLoadMore => _hasMore;

  /// Updates pagination state from a result.
  void updatePagination(PaginatedResult<T> result) {
    _cursor = result.cursor;
    _hasMore = result.hasMore;
  }

  /// Resets pagination state for a fresh fetch.
  void resetPagination() {
    _cursor = null;
    _hasMore = true;
  }
}
