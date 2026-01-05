// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_content_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Supports refresh, load more, and clear operations.

@ProviderFor(FeedContentNotifier)
final feedContentProvider = FeedContentNotifierProvider._();

/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Supports refresh, load more, and clear operations.
final class FeedContentNotifierProvider
    extends $StreamNotifierProvider<FeedContentNotifier, List<FeedPost>> {
  /// Notifier for managing feed content (posts from the active feed).
  ///
  /// Watches the active feed and provides a stream of posts from that feed.
  /// Supports refresh, load more, and clear operations.
  FeedContentNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedContentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedContentNotifierHash();

  @$internal
  @override
  FeedContentNotifier create() => FeedContentNotifier();
}

String _$feedContentNotifierHash() => r'25bee0959689eb1234073456f48d7b6c37abacfa';

/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Supports refresh, load more, and clear operations.

abstract class _$FeedContentNotifier extends $StreamNotifier<List<FeedPost>> {
  Stream<List<FeedPost>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FeedPost>>, List<FeedPost>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FeedPost>>, List<FeedPost>>,
              AsyncValue<List<FeedPost>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
