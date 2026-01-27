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

/// Provides the list of collections for a given repository DID.

@ProviderFor(collections)
final collectionsProvider = CollectionsFamily._();

/// Provides the list of collections for a given repository DID.

final class CollectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RepoCollection>?>,
          List<RepoCollection>?,
          FutureOr<List<RepoCollection>?>
        >
    with $FutureModifier<List<RepoCollection>?>, $FutureProvider<List<RepoCollection>?> {
  /// Provides the list of collections for a given repository DID.
  CollectionsProvider._({required CollectionsFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'collectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsHash();

  @override
  String toString() {
    return r'collectionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RepoCollection>?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<RepoCollection>?> create(Ref ref) {
    final argument = this.argument as String;
    return collections(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionsHash() => r'24fbc2fecc101a1c4da3edc9cef65897d1a97740';

/// Provides the list of collections for a given repository DID.

final class CollectionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RepoCollection>?>, String> {
  CollectionsFamily._()
    : super(
        retry: null,
        name: r'collectionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the list of collections for a given repository DID.

  CollectionsProvider call(String did) => CollectionsProvider._(argument: did, from: this);

  @override
  String toString() => r'collectionsProvider';
}

/// Provides a filtered list of collections based on a search query.

@ProviderFor(filteredCollections)
final filteredCollectionsProvider = FilteredCollectionsFamily._();

/// Provides a filtered list of collections based on a search query.

final class FilteredCollectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RepoCollection>>,
          List<RepoCollection>,
          FutureOr<List<RepoCollection>>
        >
    with $FutureModifier<List<RepoCollection>>, $FutureProvider<List<RepoCollection>> {
  /// Provides a filtered list of collections based on a search query.
  FilteredCollectionsProvider._({
    required FilteredCollectionsFamily super.from,
    required (String, String) super.argument,
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
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<RepoCollection>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<RepoCollection>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return filteredCollections(ref, argument.$1, argument.$2);
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

String _$filteredCollectionsHash() => r'4387c599ffd7c631d32321c74a39b132c718ebde';

/// Provides a filtered list of collections based on a search query.

final class FilteredCollectionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RepoCollection>>, (String, String)> {
  FilteredCollectionsFamily._()
    : super(
        retry: null,
        name: r'filteredCollectionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides a filtered list of collections based on a search query.

  FilteredCollectionsProvider call(String did, String query) =>
      FilteredCollectionsProvider._(argument: (did, query), from: this);

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

/// Provides a stream of recently viewed records from the database.

@ProviderFor(recentRecords)
final recentRecordsProvider = RecentRecordsProvider._();

/// Provides a stream of recently viewed records from the database.

final class RecentRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecentRecord>>,
          List<RecentRecord>,
          Stream<List<RecentRecord>>
        >
    with $FutureModifier<List<RecentRecord>>, $StreamProvider<List<RecentRecord>> {
  /// Provides a stream of recently viewed records from the database.
  RecentRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentRecordsHash();

  @$internal
  @override
  $StreamProviderElement<List<RecentRecord>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<RecentRecord>> create(Ref ref) {
    return recentRecords(ref);
  }
}

String _$recentRecordsHash() => r'835b53a09b1358b7ca7466697ab4102f5b1c8026';

/// Provides a single record by collection and rkey for a given repository DID.

@ProviderFor(recordDetail)
final recordDetailProvider = RecordDetailFamily._();

/// Provides a single record by collection and rkey for a given repository DID.

final class RecordDetailProvider
    extends $FunctionalProvider<AsyncValue<RepoRecord?>, RepoRecord?, FutureOr<RepoRecord?>>
    with $FutureModifier<RepoRecord?>, $FutureProvider<RepoRecord?> {
  /// Provides a single record by collection and rkey for a given repository DID.
  RecordDetailProvider._({
    required RecordDetailFamily super.from,
    required (String, String, String) super.argument,
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
    final argument = this.argument as (String, String, String);
    return recordDetail(ref, argument.$1, argument.$2, argument.$3);
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

String _$recordDetailHash() => r'7bf0f283f9c0260bffcf4e78a06c8859fc3b2ffd';

/// Provides a single record by collection and rkey for a given repository DID.

final class RecordDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RepoRecord?>, (String, String, String)> {
  RecordDetailFamily._()
    : super(
        retry: null,
        name: r'recordDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides a single record by collection and rkey for a given repository DID.

  RecordDetailProvider call(String did, String collection, String rkey) =>
      RecordDetailProvider._(argument: (did, collection, rkey), from: this);

  @override
  String toString() => r'recordDetailProvider';
}

/// Notifier for managing paginated records in a collection.
///
/// Follows established patterns from search_providers.dart and profile_providers.dart.

@ProviderFor(Records)
final recordsProvider = RecordsFamily._();

/// Notifier for managing paginated records in a collection.
///
/// Follows established patterns from search_providers.dart and profile_providers.dart.
final class RecordsProvider extends $AsyncNotifierProvider<Records, List<RepoRecord>> {
  /// Notifier for managing paginated records in a collection.
  ///
  /// Follows established patterns from search_providers.dart and profile_providers.dart.
  RecordsProvider._({
    required RecordsFamily super.from,
    required (String, String, String?, bool, bool) super.argument,
  }) : super(
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

String _$recordsHash() => r'67986741504dc8bbcc8d359ff2b502259834415c';

/// Notifier for managing paginated records in a collection.
///
/// Follows established patterns from search_providers.dart and profile_providers.dart.

final class RecordsFamily extends $Family
    with
        $ClassFamilyOverride<
          Records,
          AsyncValue<List<RepoRecord>>,
          List<RepoRecord>,
          FutureOr<List<RepoRecord>>,
          (String, String, String?, bool, bool)
        > {
  RecordsFamily._()
    : super(
        retry: null,
        name: r'recordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for managing paginated records in a collection.
  ///
  /// Follows established patterns from search_providers.dart and profile_providers.dart.

  RecordsProvider call(
    String did,
    String collection,
    String? rkeyStart,
    bool reverse,
    bool hasBlob,
  ) => RecordsProvider._(argument: (did, collection, rkeyStart, reverse, hasBlob), from: this);

  @override
  String toString() => r'recordsProvider';
}

/// Notifier for managing paginated records in a collection.
///
/// Follows established patterns from search_providers.dart and profile_providers.dart.

abstract class _$Records extends $AsyncNotifier<List<RepoRecord>> {
  late final _$args = ref.$arg as (String, String, String?, bool, bool);
  String get did => _$args.$1;
  String get collection => _$args.$2;
  String? get rkeyStart => _$args.$3;
  bool get reverse => _$args.$4;
  bool get hasBlob => _$args.$5;

  FutureOr<List<RepoRecord>> build(
    String did,
    String collection,
    String? rkeyStart,
    bool reverse,
    bool hasBlob,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<RepoRecord>>, List<RepoRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<RepoRecord>>, List<RepoRecord>>,
              AsyncValue<List<RepoRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2, _$args.$3, _$args.$4, _$args.$5));
  }
}

/// Resolves a handle or DID to a valid DID.

@ProviderFor(resolvedDid)
final resolvedDidProvider = ResolvedDidFamily._();

/// Resolves a handle or DID to a valid DID.

final class ResolvedDidProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Resolves a handle or DID to a valid DID.
  ResolvedDidProvider._({required ResolvedDidFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'resolvedDidProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resolvedDidHash();

  @override
  String toString() {
    return r'resolvedDidProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return resolvedDid(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ResolvedDidProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resolvedDidHash() => r'fb544c5d2a18f59a1c360762171c747b54ede923';

/// Resolves a handle or DID to a valid DID.

final class ResolvedDidFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  ResolvedDidFamily._()
    : super(
        retry: null,
        name: r'resolvedDidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves a handle or DID to a valid DID.

  ResolvedDidProvider call(String handleOrDid) =>
      ResolvedDidProvider._(argument: handleOrDid, from: this);

  @override
  String toString() => r'resolvedDidProvider';
}
