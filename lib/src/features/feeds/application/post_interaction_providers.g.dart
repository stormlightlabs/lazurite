// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_interaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postInteractionRepository)
final postInteractionRepositoryProvider = PostInteractionRepositoryProvider._();

final class PostInteractionRepositoryProvider
    extends
        $FunctionalProvider<
          PostInteractionRepository,
          PostInteractionRepository,
          PostInteractionRepository
        >
    with $Provider<PostInteractionRepository> {
  PostInteractionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postInteractionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postInteractionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PostInteractionRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostInteractionRepository create(Ref ref) {
    return postInteractionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostInteractionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostInteractionRepository>(value),
    );
  }
}

String _$postInteractionRepositoryHash() => r'1b78f513934cb5a5d8634fa72f1f59ee8744232a';

@ProviderFor(postInteractionState)
final postInteractionStateProvider = PostInteractionStateFamily._();

final class PostInteractionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<PostInteractionData?>,
          PostInteractionData?,
          Stream<PostInteractionData?>
        >
    with $FutureModifier<PostInteractionData?>, $StreamProvider<PostInteractionData?> {
  PostInteractionStateProvider._({
    required PostInteractionStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postInteractionStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postInteractionStateHash();

  @override
  String toString() {
    return r'postInteractionStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PostInteractionData?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<PostInteractionData?> create(Ref ref) {
    final argument = this.argument as String;
    return postInteractionState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostInteractionStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postInteractionStateHash() => r'7bee7e79699aa2f5295dd1bcee5d207634b9a6eb';

final class PostInteractionStateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PostInteractionData?>, String> {
  PostInteractionStateFamily._()
    : super(
        retry: null,
        name: r'postInteractionStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostInteractionStateProvider call(String postUri) =>
      PostInteractionStateProvider._(argument: postUri, from: this);

  @override
  String toString() => r'postInteractionStateProvider';
}
