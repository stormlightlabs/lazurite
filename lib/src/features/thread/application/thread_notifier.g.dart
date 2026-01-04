// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThreadNotifier)
final threadProvider = ThreadNotifierFamily._();

final class ThreadNotifierProvider
    extends $AsyncNotifierProvider<ThreadNotifier, ThreadViewPost> {
  ThreadNotifierProvider._({
    required ThreadNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'threadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$threadNotifierHash();

  @override
  String toString() {
    return r'threadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ThreadNotifier create() => ThreadNotifier();

  @override
  bool operator ==(Object other) {
    return other is ThreadNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$threadNotifierHash() => r'acb87e725d16f18afdd4e7e4f65be411ee23664e';

final class ThreadNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ThreadNotifier,
          AsyncValue<ThreadViewPost>,
          ThreadViewPost,
          FutureOr<ThreadViewPost>,
          String
        > {
  ThreadNotifierFamily._()
    : super(
        retry: null,
        name: r'threadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ThreadNotifierProvider call(String postUri) =>
      ThreadNotifierProvider._(argument: postUri, from: this);

  @override
  String toString() => r'threadProvider';
}

abstract class _$ThreadNotifier extends $AsyncNotifier<ThreadViewPost> {
  late final _$args = ref.$arg as String;
  String get postUri => _$args;

  FutureOr<ThreadViewPost> build(String postUri);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThreadViewPost>, ThreadViewPost>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThreadViewPost>, ThreadViewPost>,
              AsyncValue<ThreadViewPost>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
