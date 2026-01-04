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
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
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
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

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

String _$profileRepositoryHash() => r'4a5451dcb14bab06d8f4aa74b24602cae850aff5';

@ProviderFor(ProfileNotifier)
final profileProvider = ProfileNotifierFamily._();

final class ProfileNotifierProvider
    extends $AsyncNotifierProvider<ProfileNotifier, ProfileData> {
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

String _$profileNotifierHash() => r'64dd55fec0d7c7189141790373270bc9eb244789';

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

String _$authorFeedNotifierHash() =>
    r'905cb265b01479bfbfcd45bfe6f88573a6357a1a';

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
