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

String _$threadRepositoryHash() => r'5ecebedf27c147e6f689dc66d63141de0823b6d7';

@ProviderFor(threadCache)
final threadCacheProvider = ThreadCacheFamily._();

final class ThreadCacheProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TimelineFeedItem>>,
          List<TimelineFeedItem>,
          Stream<List<TimelineFeedItem>>
        >
    with
        $FutureModifier<List<TimelineFeedItem>>,
        $StreamProvider<List<TimelineFeedItem>> {
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
  $StreamProviderElement<List<TimelineFeedItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TimelineFeedItem>> create(Ref ref) {
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

String _$threadCacheHash() => r'a4ee0dbdad659bceb5027f127586f401526e11ca';

final class ThreadCacheFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TimelineFeedItem>>, String> {
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
