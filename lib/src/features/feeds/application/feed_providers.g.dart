// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedRepository)
final feedRepositoryProvider = FeedRepositoryProvider._();

final class FeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  FeedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return feedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$feedRepositoryHash() => r'2203b996ff1bcfe004d6e4f661090bf4f53bda1c';

/// Notifier for watching all saved feeds reactively.

@ProviderFor(AllFeedsNotifier)
final allFeedsProvider = AllFeedsNotifierProvider._();

/// Notifier for watching all saved feeds reactively.
final class AllFeedsNotifierProvider
    extends $StreamNotifierProvider<AllFeedsNotifier, List<SavedFeedData>> {
  /// Notifier for watching all saved feeds reactively.
  AllFeedsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allFeedsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allFeedsNotifierHash();

  @$internal
  @override
  AllFeedsNotifier create() => AllFeedsNotifier();
}

String _$allFeedsNotifierHash() => r'26e8c1b497541ae6b47ef11db4a9e2923710986e';

/// Notifier for watching all saved feeds reactively.

abstract class _$AllFeedsNotifier extends $StreamNotifier<List<SavedFeedData>> {
  Stream<List<SavedFeedData>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SavedFeedData>>, List<SavedFeedData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SavedFeedData>>, List<SavedFeedData>>,
              AsyncValue<List<SavedFeedData>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier for watching pinned feeds reactively.

@ProviderFor(PinnedFeedsNotifier)
final pinnedFeedsProvider = PinnedFeedsNotifierProvider._();

/// Notifier for watching pinned feeds reactively.
final class PinnedFeedsNotifierProvider
    extends $StreamNotifierProvider<PinnedFeedsNotifier, List<SavedFeedData>> {
  /// Notifier for watching pinned feeds reactively.
  PinnedFeedsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedFeedsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedFeedsNotifierHash();

  @$internal
  @override
  PinnedFeedsNotifier create() => PinnedFeedsNotifier();
}

String _$pinnedFeedsNotifierHash() => r'042b4477bb79cfdbd28b02edca0d6d23df571434';

/// Notifier for watching pinned feeds reactively.

abstract class _$PinnedFeedsNotifier extends $StreamNotifier<List<SavedFeedData>> {
  Stream<List<SavedFeedData>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SavedFeedData>>, List<SavedFeedData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SavedFeedData>>, List<SavedFeedData>>,
              AsyncValue<List<SavedFeedData>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier for syncing saved feeds from remote preferences.

@ProviderFor(SavedFeedsNotifier)
final savedFeedsProvider = SavedFeedsNotifierProvider._();

/// Notifier for syncing saved feeds from remote preferences.
final class SavedFeedsNotifierProvider
    extends $NotifierProvider<SavedFeedsNotifier, AsyncValue<void>> {
  /// Notifier for syncing saved feeds from remote preferences.
  SavedFeedsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedFeedsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedFeedsNotifierHash();

  @$internal
  @override
  SavedFeedsNotifier create() => SavedFeedsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$savedFeedsNotifierHash() => r'68a14844d9eb86981133d500f484d9353db677b1';

/// Notifier for syncing saved feeds from remote preferences.

abstract class _$SavedFeedsNotifier extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier for feed mutations (save, remove, pin).

@ProviderFor(FeedMutationNotifier)
final feedMutationProvider = FeedMutationNotifierProvider._();

/// Notifier for feed mutations (save, remove, pin).
final class FeedMutationNotifierProvider
    extends $NotifierProvider<FeedMutationNotifier, AsyncValue<void>> {
  /// Notifier for feed mutations (save, remove, pin).
  FeedMutationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedMutationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedMutationNotifierHash();

  @$internal
  @override
  FeedMutationNotifier create() => FeedMutationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$feedMutationNotifierHash() => r'0461e118b7eb62385b9cdaf729671538d4936df7';

/// Notifier for feed mutations (save, remove, pin).

abstract class _$FeedMutationNotifier extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier for discovering trending feeds.

@ProviderFor(DiscoverFeedsNotifier)
final discoverFeedsProvider = DiscoverFeedsNotifierProvider._();

/// Notifier for discovering trending feeds.
final class DiscoverFeedsNotifierProvider
    extends $NotifierProvider<DiscoverFeedsNotifier, AsyncValue<List<Map<String, dynamic>>>> {
  /// Notifier for discovering trending feeds.
  DiscoverFeedsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverFeedsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverFeedsNotifierHash();

  @$internal
  @override
  DiscoverFeedsNotifier create() => DiscoverFeedsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Map<String, dynamic>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Map<String, dynamic>>>>(value),
    );
  }
}

String _$discoverFeedsNotifierHash() => r'b72bee4db40bfc4f140ae6056d047e8ae20ec7c5';

/// Notifier for discovering trending feeds.

abstract class _$DiscoverFeedsNotifier extends $Notifier<AsyncValue<List<Map<String, dynamic>>>> {
  AsyncValue<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              AsyncValue<List<Map<String, dynamic>>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                AsyncValue<List<Map<String, dynamic>>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Notifier for tracking the currently active feed.
///
/// This notifier maintains the URI of the currently selected feed and allows
/// switching between feeds. The feed content will reactively update based on this value.
///
/// For authenticated users, defaults to their top pinned feed (by sort order).
/// Falls back to home feed if no pinned feeds exist.
/// For unauthenticated users, defaults to the Discover (What's Hot) feed.

@ProviderFor(ActiveFeed)
final activeFeedProvider = ActiveFeedProvider._();

/// Notifier for tracking the currently active feed.
///
/// This notifier maintains the URI of the currently selected feed and allows
/// switching between feeds. The feed content will reactively update based on this value.
///
/// For authenticated users, defaults to their top pinned feed (by sort order).
/// Falls back to home feed if no pinned feeds exist.
/// For unauthenticated users, defaults to the Discover (What's Hot) feed.
final class ActiveFeedProvider extends $NotifierProvider<ActiveFeed, String> {
  /// Notifier for tracking the currently active feed.
  ///
  /// This notifier maintains the URI of the currently selected feed and allows
  /// switching between feeds. The feed content will reactively update based on this value.
  ///
  /// For authenticated users, defaults to their top pinned feed (by sort order).
  /// Falls back to home feed if no pinned feeds exist.
  /// For unauthenticated users, defaults to the Discover (What's Hot) feed.
  ActiveFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeFeedHash();

  @$internal
  @override
  ActiveFeed create() => ActiveFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String>(value));
  }
}

String _$activeFeedHash() => r'b9ed5333846f3c60e39d025ad528618be03002b2';

/// Notifier for tracking the currently active feed.
///
/// This notifier maintains the URI of the currently selected feed and allows
/// switching between feeds. The feed content will reactively update based on this value.
///
/// For authenticated users, defaults to their top pinned feed (by sort order).
/// Falls back to home feed if no pinned feeds exist.
/// For unauthenticated users, defaults to the Discover (What's Hot) feed.

abstract class _$ActiveFeed extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FeedSearch)
final feedSearchProvider = FeedSearchProvider._();

final class FeedSearchProvider extends $NotifierProvider<FeedSearch, FeedSearchState> {
  FeedSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedSearchHash();

  @$internal
  @override
  FeedSearch create() => FeedSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedSearchState>(value),
    );
  }
}

String _$feedSearchHash() => r'0210fcdcb3337bc2d33ba918e280acdea5caf5d2';

abstract class _$FeedSearch extends $Notifier<FeedSearchState> {
  FeedSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FeedSearchState, FeedSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedSearchState, FeedSearchState>,
              FeedSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
