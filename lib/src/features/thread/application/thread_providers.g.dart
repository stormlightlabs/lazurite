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
