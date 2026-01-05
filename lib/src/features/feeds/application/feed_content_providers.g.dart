// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_content_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedContentRepository)
final feedContentRepositoryProvider = FeedContentRepositoryProvider._();

final class FeedContentRepositoryProvider
    extends
        $FunctionalProvider<
          FeedContentRepository,
          FeedContentRepository,
          FeedContentRepository
        >
    with $Provider<FeedContentRepository> {
  FeedContentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedContentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedContentRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedContentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeedContentRepository create(Ref ref) {
    return feedContentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedContentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedContentRepository>(value),
    );
  }
}

String _$feedContentRepositoryHash() =>
    r'2a56c50c1bfb039e006652ce656ec261adb4d12d';
