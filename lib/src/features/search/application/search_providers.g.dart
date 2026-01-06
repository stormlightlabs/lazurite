// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends $FunctionalProvider<SearchRepository, SearchRepository, SearchRepository>
    with $Provider<SearchRepository> {
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'29255e3b3504388c42730a5d7af777347b983e90';

@ProviderFor(SearchNotifier)
final searchProvider = SearchNotifierFamily._();

final class SearchNotifierProvider
    extends $AsyncNotifierProvider<SearchNotifier, List<SearchPostItem>> {
  SearchNotifierProvider._({
    required SearchNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchNotifierHash();

  @override
  String toString() {
    return r'searchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchNotifier create() => SearchNotifier();

  @override
  bool operator ==(Object other) {
    return other is SearchNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchNotifierHash() => r'fae1ada9ad3fa7cb3b48ea549a570f132f718126';

final class SearchNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchNotifier,
          AsyncValue<List<SearchPostItem>>,
          List<SearchPostItem>,
          FutureOr<List<SearchPostItem>>,
          String
        > {
  SearchNotifierFamily._()
    : super(
        retry: null,
        name: r'searchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchNotifierProvider call(String query) =>
      SearchNotifierProvider._(argument: query, from: this);

  @override
  String toString() => r'searchProvider';
}

abstract class _$SearchNotifier extends $AsyncNotifier<List<SearchPostItem>> {
  late final _$args = ref.$arg as String;
  String get query => _$args;

  FutureOr<List<SearchPostItem>> build(String query);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SearchPostItem>>, List<SearchPostItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SearchPostItem>>, List<SearchPostItem>>,
              AsyncValue<List<SearchPostItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(RecentSearchesNotifier)
final recentSearchesProvider = RecentSearchesNotifierProvider._();

final class RecentSearchesNotifierProvider
    extends $StreamNotifierProvider<RecentSearchesNotifier, List<RecentSearchItem>> {
  RecentSearchesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesNotifierHash();

  @$internal
  @override
  RecentSearchesNotifier create() => RecentSearchesNotifier();
}

String _$recentSearchesNotifierHash() => r'16416df13f8cbad592124d9a2a230f273be0743f';

abstract class _$RecentSearchesNotifier extends $StreamNotifier<List<RecentSearchItem>> {
  Stream<List<RecentSearchItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<RecentSearchItem>>, List<RecentSearchItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<RecentSearchItem>>, List<RecentSearchItem>>,
              AsyncValue<List<RecentSearchItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier for searching actors with pagination.

@ProviderFor(ActorSearchNotifier)
final actorSearchProvider = ActorSearchNotifierFamily._();

/// Notifier for searching actors with pagination.
final class ActorSearchNotifierProvider
    extends $AsyncNotifierProvider<ActorSearchNotifier, List<SearchActorItem>> {
  /// Notifier for searching actors with pagination.
  ActorSearchNotifierProvider._({
    required ActorSearchNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorSearchNotifierHash();

  @override
  String toString() {
    return r'actorSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActorSearchNotifier create() => ActorSearchNotifier();

  @override
  bool operator ==(Object other) {
    return other is ActorSearchNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorSearchNotifierHash() => r'dfeef83484f52fde100ccf5425fb5450211bfba2';

/// Notifier for searching actors with pagination.

final class ActorSearchNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ActorSearchNotifier,
          AsyncValue<List<SearchActorItem>>,
          List<SearchActorItem>,
          FutureOr<List<SearchActorItem>>,
          String
        > {
  ActorSearchNotifierFamily._()
    : super(
        retry: null,
        name: r'actorSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for searching actors with pagination.

  ActorSearchNotifierProvider call(String query) =>
      ActorSearchNotifierProvider._(argument: query, from: this);

  @override
  String toString() => r'actorSearchProvider';
}

/// Notifier for searching actors with pagination.

abstract class _$ActorSearchNotifier extends $AsyncNotifier<List<SearchActorItem>> {
  late final _$args = ref.$arg as String;
  String get query => _$args;

  FutureOr<List<SearchActorItem>> build(String query);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SearchActorItem>>, List<SearchActorItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SearchActorItem>>, List<SearchActorItem>>,
              AsyncValue<List<SearchActorItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
