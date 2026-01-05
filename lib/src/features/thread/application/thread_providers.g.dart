// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(threadRepository)
final threadRepositoryProvider = ThreadRepositoryProvider._();

final class ThreadRepositoryProvider
    extends
        $FunctionalProvider<
          ThreadRepository,
          ThreadRepository,
          ThreadRepository
        >
    with $Provider<ThreadRepository> {
  ThreadRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'threadRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$threadRepositoryHash();

  @$internal
  @override
  $ProviderElement<ThreadRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThreadRepository create(Ref ref) {
    return threadRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThreadRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThreadRepository>(value),
    );
  }
}

String _$threadRepositoryHash() => r'cd0ceeed0f8b07eed6b2a8e93431e7780a704902';

@ProviderFor(threadCache)
final threadCacheProvider = ThreadCacheFamily._();

final class ThreadCacheProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedPost>>,
          List<FeedPost>,
          Stream<List<FeedPost>>
        >
    with $FutureModifier<List<FeedPost>>, $StreamProvider<List<FeedPost>> {
  ThreadCacheProvider._({
    required ThreadCacheFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'threadCacheProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$threadCacheHash();

  @override
  String toString() {
    return r'threadCacheProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FeedPost>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedPost>> create(Ref ref) {
    final argument = this.argument as String;
    return threadCache(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ThreadCacheProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$threadCacheHash() => r'310780d1a52f20ec5d8752ce4ec6c687c8eb2226';

final class ThreadCacheFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FeedPost>>, String> {
  ThreadCacheFamily._()
    : super(
        retry: null,
        name: r'threadCacheProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ThreadCacheProvider call(String postUri) =>
      ThreadCacheProvider._(argument: postUri, from: this);

  @override
  String toString() => r'threadCacheProvider';
}
