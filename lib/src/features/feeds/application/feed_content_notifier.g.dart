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
/// Applies user preference filters (muted words, hide replies/reposts/quotes).
/// Supports refresh, load more, and clear operations.

@ProviderFor(FeedContentNotifier)
final feedContentProvider = FeedContentNotifierFamily._();

/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Applies user preference filters (muted words, hide replies/reposts/quotes).
/// Supports refresh, load more, and clear operations.
final class FeedContentNotifierProvider
    extends $StreamNotifierProvider<FeedContentNotifier, List<FeedPost>> {
  /// Notifier for managing feed content (posts from the active feed).
  ///
  /// Watches the active feed and provides a stream of posts from that feed.
  /// Applies user preference filters (muted words, hide replies/reposts/quotes).
  /// Supports refresh, load more, and clear operations.
  FeedContentNotifierProvider._({
    required FeedContentNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'feedContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedContentNotifierHash();

  @override
  String toString() {
    return r'feedContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FeedContentNotifier create() => FeedContentNotifier();

  @override
  bool operator ==(Object other) {
    return other is FeedContentNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedContentNotifierHash() => r'7cacaa3328b52126a1d3b51bd439f3d1c7e896ee';

/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Applies user preference filters (muted words, hide replies/reposts/quotes).
/// Supports refresh, load more, and clear operations.

final class FeedContentNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          FeedContentNotifier,
          AsyncValue<List<FeedPost>>,
          List<FeedPost>,
          Stream<List<FeedPost>>,
          String
        > {
  FeedContentNotifierFamily._()
    : super(
        retry: null,
        name: r'feedContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for managing feed content (posts from the active feed).
  ///
  /// Watches the active feed and provides a stream of posts from that feed.
  /// Applies user preference filters (muted words, hide replies/reposts/quotes).
  /// Supports refresh, load more, and clear operations.

  FeedContentNotifierProvider call(String feedUri) =>
      FeedContentNotifierProvider._(argument: feedUri, from: this);

  @override
  String toString() => r'feedContentProvider';
}

/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Applies user preference filters (muted words, hide replies/reposts/quotes).
/// Supports refresh, load more, and clear operations.

abstract class _$FeedContentNotifier extends $StreamNotifier<List<FeedPost>> {
  late final _$args = ref.$arg as String;
  String get feedUri => _$args;

  Stream<List<FeedPost>> build(String feedUri);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
