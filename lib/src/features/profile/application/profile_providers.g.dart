// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends $FunctionalProvider<ProfileRepository, ProfileRepository, ProfileRepository>
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'ec881f45142b9ecac2a527877fc40c33cf59193d';

@ProviderFor(pinnedPost)
final pinnedPostProvider = PinnedPostFamily._();

final class PinnedPostProvider
    extends $FunctionalProvider<AsyncValue<FeedItem?>, FeedItem?, FutureOr<FeedItem?>>
    with $FutureModifier<FeedItem?>, $FutureProvider<FeedItem?> {
  PinnedPostProvider._({required PinnedPostFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'pinnedPostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedPostHash();

  @override
  String toString() {
    return r'pinnedPostProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FeedItem?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FeedItem?> create(Ref ref) {
    final argument = this.argument as String;
    return pinnedPost(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PinnedPostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pinnedPostHash() => r'65082b94fb3fdbd13cfd9b0cf97f5f1c714831ec';

final class PinnedPostFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FeedItem?>, String> {
  PinnedPostFamily._()
    : super(
        retry: null,
        name: r'pinnedPostProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PinnedPostProvider call(String uri) => PinnedPostProvider._(argument: uri, from: this);

  @override
  String toString() => r'pinnedPostProvider';
}

@ProviderFor(ProfileNotifier)
final profileProvider = ProfileNotifierFamily._();

final class ProfileNotifierProvider extends $AsyncNotifierProvider<ProfileNotifier, ProfileData> {
  ProfileNotifierProvider._({
    required ProfileNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @override
  String toString() {
    return r'profileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();

  @override
  bool operator ==(Object other) {
    return other is ProfileNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileNotifierHash() => r'7ccce6122fcf09098774583f7a1568dc94d50343';

final class ProfileNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileNotifier,
          AsyncValue<ProfileData>,
          ProfileData,
          FutureOr<ProfileData>,
          String
        > {
  ProfileNotifierFamily._()
    : super(
        retry: null,
        name: r'profileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileNotifierProvider call(String actor) =>
      ProfileNotifierProvider._(argument: actor, from: this);

  @override
  String toString() => r'profileProvider';
}

abstract class _$ProfileNotifier extends $AsyncNotifier<ProfileData> {
  late final _$args = ref.$arg as String;
  String get actor => _$args;

  FutureOr<ProfileData> build(String actor);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ProfileData>, ProfileData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProfileData>, ProfileData>,
              AsyncValue<ProfileData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(AuthorFeedNotifier)
final authorFeedProvider = AuthorFeedNotifierFamily._();

final class AuthorFeedNotifierProvider
    extends $AsyncNotifierProvider<AuthorFeedNotifier, List<FeedItem>> {
  AuthorFeedNotifierProvider._({
    required AuthorFeedNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'authorFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authorFeedNotifierHash();

  @override
  String toString() {
    return r'authorFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AuthorFeedNotifier create() => AuthorFeedNotifier();

  @override
  bool operator ==(Object other) {
    return other is AuthorFeedNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authorFeedNotifierHash() => r'b241402d3ec7ba5ca64908fd166bbfa3d3b126c7';

final class AuthorFeedNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AuthorFeedNotifier,
          AsyncValue<List<FeedItem>>,
          List<FeedItem>,
          FutureOr<List<FeedItem>>,
          String
        > {
  AuthorFeedNotifierFamily._()
    : super(
        retry: null,
        name: r'authorFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuthorFeedNotifierProvider call(String actor) =>
      AuthorFeedNotifierProvider._(argument: actor, from: this);

  @override
  String toString() => r'authorFeedProvider';
}

abstract class _$AuthorFeedNotifier extends $AsyncNotifier<List<FeedItem>> {
  late final _$args = ref.$arg as String;
  String get actor => _$args;

  FutureOr<List<FeedItem>> build(String actor);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FeedItem>>, List<FeedItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FeedItem>>, List<FeedItem>>,
              AsyncValue<List<FeedItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Notifier for managing follow/unfollow mutations.

@ProviderFor(FollowNotifier)
final followProvider = FollowNotifierProvider._();

/// Notifier for managing follow/unfollow mutations.
final class FollowNotifierProvider extends $NotifierProvider<FollowNotifier, AsyncValue<void>> {
  /// Notifier for managing follow/unfollow mutations.
  FollowNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followNotifierHash();

  @$internal
  @override
  FollowNotifier create() => FollowNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$followNotifierHash() => r'e09f5c13a62d4bb0585962eab95c6505a1f0fdb3';

/// Notifier for managing follow/unfollow mutations.

abstract class _$FollowNotifier extends $Notifier<AsyncValue<void>> {
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

/// Notifier for managing followers list with cursor pagination.

@ProviderFor(FollowersNotifier)
final followersProvider = FollowersNotifierFamily._();

/// Notifier for managing followers list with cursor pagination.
final class FollowersNotifierProvider
    extends $AsyncNotifierProvider<FollowersNotifier, List<ActorBasic>> {
  /// Notifier for managing followers list with cursor pagination.
  FollowersNotifierProvider._({
    required FollowersNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followersNotifierHash();

  @override
  String toString() {
    return r'followersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowersNotifier create() => FollowersNotifier();

  @override
  bool operator ==(Object other) {
    return other is FollowersNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followersNotifierHash() => r'780708982a3a4207b47f22e314705befeeb13ab0';

/// Notifier for managing followers list with cursor pagination.

final class FollowersNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowersNotifier,
          AsyncValue<List<ActorBasic>>,
          List<ActorBasic>,
          FutureOr<List<ActorBasic>>,
          String
        > {
  FollowersNotifierFamily._()
    : super(
        retry: null,
        name: r'followersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for managing followers list with cursor pagination.

  FollowersNotifierProvider call(String actor) =>
      FollowersNotifierProvider._(argument: actor, from: this);

  @override
  String toString() => r'followersProvider';
}

/// Notifier for managing followers list with cursor pagination.

abstract class _$FollowersNotifier extends $AsyncNotifier<List<ActorBasic>> {
  late final _$args = ref.$arg as String;
  String get actor => _$args;

  FutureOr<List<ActorBasic>> build(String actor);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ActorBasic>>, List<ActorBasic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ActorBasic>>, List<ActorBasic>>,
              AsyncValue<List<ActorBasic>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Notifier for managing following list with cursor pagination.

@ProviderFor(FollowingNotifier)
final followingProvider = FollowingNotifierFamily._();

/// Notifier for managing following list with cursor pagination.
final class FollowingNotifierProvider
    extends $AsyncNotifierProvider<FollowingNotifier, List<ActorBasic>> {
  /// Notifier for managing following list with cursor pagination.
  FollowingNotifierProvider._({
    required FollowingNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followingNotifierHash();

  @override
  String toString() {
    return r'followingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowingNotifier create() => FollowingNotifier();

  @override
  bool operator ==(Object other) {
    return other is FollowingNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followingNotifierHash() => r'bd2e177823a3055aa5653f03fd3e593198651111';

/// Notifier for managing following list with cursor pagination.

final class FollowingNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowingNotifier,
          AsyncValue<List<ActorBasic>>,
          List<ActorBasic>,
          FutureOr<List<ActorBasic>>,
          String
        > {
  FollowingNotifierFamily._()
    : super(
        retry: null,
        name: r'followingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for managing following list with cursor pagination.

  FollowingNotifierProvider call(String actor) =>
      FollowingNotifierProvider._(argument: actor, from: this);

  @override
  String toString() => r'followingProvider';
}

/// Notifier for managing following list with cursor pagination.

abstract class _$FollowingNotifier extends $AsyncNotifier<List<ActorBasic>> {
  late final _$args = ref.$arg as String;
  String get actor => _$args;

  FutureOr<List<ActorBasic>> build(String actor);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ActorBasic>>, List<ActorBasic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ActorBasic>>, List<ActorBasic>>,
              AsyncValue<List<ActorBasic>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
