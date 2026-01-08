// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the Bluesky preferences repository.

@ProviderFor(blueskyPreferencesRepository)
final blueskyPreferencesRepositoryProvider = BlueskyPreferencesRepositoryProvider._();

/// Provides the Bluesky preferences repository.

final class BlueskyPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          BlueskyPreferencesRepository,
          BlueskyPreferencesRepository,
          BlueskyPreferencesRepository
        >
    with $Provider<BlueskyPreferencesRepository> {
  /// Provides the Bluesky preferences repository.
  BlueskyPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blueskyPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blueskyPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<BlueskyPreferencesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BlueskyPreferencesRepository create(Ref ref) {
    return blueskyPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlueskyPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlueskyPreferencesRepository>(value),
    );
  }
}

String _$blueskyPreferencesRepositoryHash() => r'4d37d3f4f146597a54d3bf90fbc4326051162325';

/// Watches the adult content preference.

@ProviderFor(adultContentPref)
final adultContentPrefProvider = AdultContentPrefProvider._();

/// Watches the adult content preference.

final class AdultContentPrefProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdultContentPref>,
          AdultContentPref,
          Stream<AdultContentPref>
        >
    with $FutureModifier<AdultContentPref>, $StreamProvider<AdultContentPref> {
  /// Watches the adult content preference.
  AdultContentPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adultContentPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adultContentPrefHash();

  @$internal
  @override
  $StreamProviderElement<AdultContentPref> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AdultContentPref> create(Ref ref) {
    return adultContentPref(ref);
  }
}

String _$adultContentPrefHash() => r'6175521bfb2e3f424fabc4f455b711f5acd2c30a';

/// Watches content label preferences.

@ProviderFor(contentLabelPrefs)
final contentLabelPrefsProvider = ContentLabelPrefsProvider._();

/// Watches content label preferences.

final class ContentLabelPrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContentLabelPrefs>,
          ContentLabelPrefs,
          Stream<ContentLabelPrefs>
        >
    with $FutureModifier<ContentLabelPrefs>, $StreamProvider<ContentLabelPrefs> {
  /// Watches content label preferences.
  ContentLabelPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentLabelPrefsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentLabelPrefsHash();

  @$internal
  @override
  $StreamProviderElement<ContentLabelPrefs> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<ContentLabelPrefs> create(Ref ref) {
    return contentLabelPrefs(ref);
  }
}

String _$contentLabelPrefsHash() => r'64a76573483e6a43e306451a16ec7251396d3197';

/// Watches the labelers preference.

@ProviderFor(labelersPref)
final labelersPrefProvider = LabelersPrefProvider._();

/// Watches the labelers preference.

final class LabelersPrefProvider
    extends $FunctionalProvider<AsyncValue<LabelersPref>, LabelersPref, Stream<LabelersPref>>
    with $FutureModifier<LabelersPref>, $StreamProvider<LabelersPref> {
  /// Watches the labelers preference.
  LabelersPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelersPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelersPrefHash();

  @$internal
  @override
  $StreamProviderElement<LabelersPref> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<LabelersPref> create(Ref ref) {
    return labelersPref(ref);
  }
}

String _$labelersPrefHash() => r'683933f67c7717d800c5f563b2f23e33e89ba904';

/// Watches the feed view preference.

@ProviderFor(feedViewPref)
final feedViewPrefProvider = FeedViewPrefProvider._();

/// Watches the feed view preference.

final class FeedViewPrefProvider
    extends $FunctionalProvider<AsyncValue<FeedViewPref>, FeedViewPref, Stream<FeedViewPref>>
    with $FutureModifier<FeedViewPref>, $StreamProvider<FeedViewPref> {
  /// Watches the feed view preference.
  FeedViewPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedViewPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedViewPrefHash();

  @$internal
  @override
  $StreamProviderElement<FeedViewPref> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<FeedViewPref> create(Ref ref) {
    return feedViewPref(ref);
  }
}

String _$feedViewPrefHash() => r'6cbee61f1a6e3bb8170f5394539d29ecb6023f5b';

/// Watches the thread view preference.

@ProviderFor(threadViewPref)
final threadViewPrefProvider = ThreadViewPrefProvider._();

/// Watches the thread view preference.

final class ThreadViewPrefProvider
    extends $FunctionalProvider<AsyncValue<ThreadViewPref>, ThreadViewPref, Stream<ThreadViewPref>>
    with $FutureModifier<ThreadViewPref>, $StreamProvider<ThreadViewPref> {
  /// Watches the thread view preference.
  ThreadViewPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'threadViewPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$threadViewPrefHash();

  @$internal
  @override
  $StreamProviderElement<ThreadViewPref> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<ThreadViewPref> create(Ref ref) {
    return threadViewPref(ref);
  }
}

String _$threadViewPrefHash() => r'c75e582075530962cb5683ae0035e73c1c9570c0';

/// Watches the muted words preference.

@ProviderFor(mutedWordsPref)
final mutedWordsPrefProvider = MutedWordsPrefProvider._();

/// Watches the muted words preference.

final class MutedWordsPrefProvider
    extends $FunctionalProvider<AsyncValue<MutedWordsPref>, MutedWordsPref, Stream<MutedWordsPref>>
    with $FutureModifier<MutedWordsPref>, $StreamProvider<MutedWordsPref> {
  /// Watches the muted words preference.
  MutedWordsPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mutedWordsPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mutedWordsPrefHash();

  @$internal
  @override
  $StreamProviderElement<MutedWordsPref> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<MutedWordsPref> create(Ref ref) {
    return mutedWordsPref(ref);
  }
}

String _$mutedWordsPrefHash() => r'9052fd9aaba1911f28a132c9ed46467fd80ac132';
