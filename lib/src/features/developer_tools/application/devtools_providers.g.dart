// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devtools_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the DevtoolsRepository instance.

@ProviderFor(devtoolsRepository)
final devtoolsRepositoryProvider = DevtoolsRepositoryProvider._();

/// Provides the DevtoolsRepository instance.

final class DevtoolsRepositoryProvider
    extends $FunctionalProvider<DevtoolsRepository, DevtoolsRepository, DevtoolsRepository>
    with $Provider<DevtoolsRepository> {
  /// Provides the DevtoolsRepository instance.
  DevtoolsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devtoolsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devtoolsRepositoryHash();

  @$internal
  @override
  $ProviderElement<DevtoolsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DevtoolsRepository create(Ref ref) {
    return devtoolsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevtoolsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevtoolsRepository>(value),
    );
  }
}

String _$devtoolsRepositoryHash() => r'f85a5046ed302093e62d1a41b5493b280787527b';

/// Provides the list of collections for the current user's repository.
///
/// Returns null if not authenticated.
/// Caches the result until invalidated.

@ProviderFor(collections)
final collectionsProvider = CollectionsProvider._();

/// Provides the list of collections for the current user's repository.
///
/// Returns null if not authenticated.
/// Caches the result until invalidated.

final class CollectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RepoCollection>?>,
          List<RepoCollection>?,
          FutureOr<List<RepoCollection>?>
        >
    with $FutureModifier<List<RepoCollection>?>, $FutureProvider<List<RepoCollection>?> {
  /// Provides the list of collections for the current user's repository.
  ///
  /// Returns null if not authenticated.
  /// Caches the result until invalidated.
  CollectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsHash();

  @$internal
  @override
  $FutureProviderElement<List<RepoCollection>?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<RepoCollection>?> create(Ref ref) {
    return collections(ref);
  }
}

String _$collectionsHash() => r'9502cc102bd1e291cf428a95b151f690556668bf';

/// Provides a filtered list of collections based on a search query.
///
/// [query] is the search string to filter collections by NSID.
/// Returns collections whose NSID contains the query (case-insensitive).

@ProviderFor(filteredCollections)
final filteredCollectionsProvider = FilteredCollectionsFamily._();

/// Provides a filtered list of collections based on a search query.
///
/// [query] is the search string to filter collections by NSID.
/// Returns collections whose NSID contains the query (case-insensitive).

final class FilteredCollectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RepoCollection>>,
          List<RepoCollection>,
          FutureOr<List<RepoCollection>>
        >
    with $FutureModifier<List<RepoCollection>>, $FutureProvider<List<RepoCollection>> {
  /// Provides a filtered list of collections based on a search query.
  ///
  /// [query] is the search string to filter collections by NSID.
  /// Returns collections whose NSID contains the query (case-insensitive).
  FilteredCollectionsProvider._({
    required FilteredCollectionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filteredCollectionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredCollectionsHash();

  @override
  String toString() {
    return r'filteredCollectionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RepoCollection>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<RepoCollection>> create(Ref ref) {
    final argument = this.argument as String;
    return filteredCollections(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredCollectionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredCollectionsHash() => r'aad6d547902b80209d4cd9190c6aad53d91361b1';

/// Provides a filtered list of collections based on a search query.
///
/// [query] is the search string to filter collections by NSID.
/// Returns collections whose NSID contains the query (case-insensitive).

final class FilteredCollectionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RepoCollection>>, String> {
  FilteredCollectionsFamily._()
    : super(
        retry: null,
        name: r'filteredCollectionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides a filtered list of collections based on a search query.
  ///
  /// [query] is the search string to filter collections by NSID.
  /// Returns collections whose NSID contains the query (case-insensitive).

  FilteredCollectionsProvider call(String query) =>
      FilteredCollectionsProvider._(argument: query, from: this);

  @override
  String toString() => r'filteredCollectionsProvider';
}

/// Provides a stream of pinned collections/records from the database.

@ProviderFor(pinnedUris)
final pinnedUrisProvider = PinnedUrisProvider._();

/// Provides a stream of pinned collections/records from the database.

final class PinnedUrisProvider
    extends $FunctionalProvider<AsyncValue<List<String>>, List<String>, Stream<List<String>>>
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Provides a stream of pinned collections/records from the database.
  PinnedUrisProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedUrisProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedUrisHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return pinnedUris(ref);
  }
}

String _$pinnedUrisHash() => r'dbe9bd345d2600ce0cd40c65deceba8141a827c6';

/// Provides a single record by collection and rkey for the current user.
///
/// [collection] is the NSID of the collection (e.g., "app.bsky.feed.post").
/// [rkey] is the record key.
/// Returns null if not authenticated or record not found.

@ProviderFor(recordDetail)
final recordDetailProvider = RecordDetailFamily._();

/// Provides a single record by collection and rkey for the current user.
///
/// [collection] is the NSID of the collection (e.g., "app.bsky.feed.post").
/// [rkey] is the record key.
/// Returns null if not authenticated or record not found.

final class RecordDetailProvider
    extends $FunctionalProvider<AsyncValue<RepoRecord?>, RepoRecord?, FutureOr<RepoRecord?>>
    with $FutureModifier<RepoRecord?>, $FutureProvider<RepoRecord?> {
  /// Provides a single record by collection and rkey for the current user.
  ///
  /// [collection] is the NSID of the collection (e.g., "app.bsky.feed.post").
  /// [rkey] is the record key.
  /// Returns null if not authenticated or record not found.
  RecordDetailProvider._({
    required RecordDetailFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'recordDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recordDetailHash();

  @override
  String toString() {
    return r'recordDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<RepoRecord?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RepoRecord?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return recordDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recordDetailHash() => r'34d48a10bfaae231d25dcc6a1d6d175b007cb906';

/// Provides a single record by collection and rkey for the current user.
///
/// [collection] is the NSID of the collection (e.g., "app.bsky.feed.post").
/// [rkey] is the record key.
/// Returns null if not authenticated or record not found.

final class RecordDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RepoRecord?>, (String, String)> {
  RecordDetailFamily._()
    : super(
        retry: null,
        name: r'recordDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides a single record by collection and rkey for the current user.
  ///
  /// [collection] is the NSID of the collection (e.g., "app.bsky.feed.post").
  /// [rkey] is the record key.
  /// Returns null if not authenticated or record not found.

  RecordDetailProvider call(String collection, String rkey) =>
      RecordDetailProvider._(argument: (collection, rkey), from: this);

  @override
  String toString() => r'recordDetailProvider';
}

/// Provides paginated records for a specific collection.
///
/// Manages infinite scroll with cursor-based pagination.
/// [did] is the repository DID to query.
/// [collection] is the collection NSID.

@ProviderFor(Records)
final recordsProvider = RecordsFamily._();

/// Provides paginated records for a specific collection.
///
/// Manages infinite scroll with cursor-based pagination.
/// [did] is the repository DID to query.
/// [collection] is the collection NSID.
final class RecordsProvider extends $AsyncNotifierProvider<Records, RecordsState> {
  /// Provides paginated records for a specific collection.
  ///
  /// Manages infinite scroll with cursor-based pagination.
  /// [did] is the repository DID to query.
  /// [collection] is the collection NSID.
  RecordsProvider._({required RecordsFamily super.from, required (String, String) super.argument})
    : super(
        retry: null,
        name: r'recordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordsHash();

  @override
  String toString() {
    return r'recordsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  Records create() => Records();

  @override
  bool operator ==(Object other) {
    return other is RecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recordsHash() => r'276711cc187ecfe00faa0c8340ab6394d498beef';

/// Provides paginated records for a specific collection.
///
/// Manages infinite scroll with cursor-based pagination.
/// [did] is the repository DID to query.
/// [collection] is the collection NSID.

final class RecordsFamily extends $Family
    with
        $ClassFamilyOverride<
          Records,
          AsyncValue<RecordsState>,
          RecordsState,
          FutureOr<RecordsState>,
          (String, String)
        > {
  RecordsFamily._()
    : super(
        retry: null,
        name: r'recordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides paginated records for a specific collection.
  ///
  /// Manages infinite scroll with cursor-based pagination.
  /// [did] is the repository DID to query.
  /// [collection] is the collection NSID.

  RecordsProvider call(String did, String collection) =>
      RecordsProvider._(argument: (did, collection), from: this);

  @override
  String toString() => r'recordsProvider';
}

/// Provides paginated records for a specific collection.
///
/// Manages infinite scroll with cursor-based pagination.
/// [did] is the repository DID to query.
/// [collection] is the collection NSID.

abstract class _$Records extends $AsyncNotifier<RecordsState> {
  late final _$args = ref.$arg as (String, String);
  String get did => _$args.$1;
  String get collection => _$args.$2;

  FutureOr<RecordsState> build(String did, String collection);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RecordsState>, RecordsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecordsState>, RecordsState>,
              AsyncValue<RecordsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
