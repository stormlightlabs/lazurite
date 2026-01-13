// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(facetParser)
final facetParserProvider = FacetParserProvider._();

final class FacetParserProvider extends $FunctionalProvider<FacetParser, FacetParser, FacetParser>
    with $Provider<FacetParser> {
  FacetParserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facetParserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facetParserHash();

  @$internal
  @override
  $ProviderElement<FacetParser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FacetParser create(Ref ref) {
    return facetParser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacetParser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacetParser>(value),
    );
  }
}

String _$facetParserHash() => r'3df8a0ee99ce1cb7149075e5f25aa4535ad7d2bf';

@ProviderFor(linkMetadataService)
final linkMetadataServiceProvider = LinkMetadataServiceProvider._();

final class LinkMetadataServiceProvider
    extends $FunctionalProvider<LinkMetadataService, LinkMetadataService, LinkMetadataService>
    with $Provider<LinkMetadataService> {
  LinkMetadataServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkMetadataServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkMetadataServiceHash();

  @$internal
  @override
  $ProviderElement<LinkMetadataService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkMetadataService create(Ref ref) {
    return linkMetadataService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkMetadataService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkMetadataService>(value),
    );
  }
}

String _$linkMetadataServiceHash() => r'f6d106408351a8efbea835eb1b18b52d0b5ef8e2';

@ProviderFor(videoUploadService)
final videoUploadServiceProvider = VideoUploadServiceProvider._();

final class VideoUploadServiceProvider
    extends $FunctionalProvider<VideoUploadService, VideoUploadService, VideoUploadService>
    with $Provider<VideoUploadService> {
  VideoUploadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoUploadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoUploadServiceHash();

  @$internal
  @override
  $ProviderElement<VideoUploadService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VideoUploadService create(Ref ref) {
    return videoUploadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoUploadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoUploadService>(value),
    );
  }
}

String _$videoUploadServiceHash() => r'f4739f93c433b95adbe78575e69f14ff4381d5e6';

@ProviderFor(draftRepository)
final draftRepositoryProvider = DraftRepositoryProvider._();

final class DraftRepositoryProvider
    extends $FunctionalProvider<DraftRepository, DraftRepository, DraftRepository>
    with $Provider<DraftRepository> {
  DraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftRepositoryHash();

  @$internal
  @override
  $ProviderElement<DraftRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DraftRepository create(Ref ref) {
    return draftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftRepository>(value),
    );
  }
}

String _$draftRepositoryHash() => r'3c2ea07655cc70badea069ca6cd086ac98058596';

@ProviderFor(drafts)
final draftsProvider = DraftsProvider._();

final class DraftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<composer.Draft>>,
          List<composer.Draft>,
          Stream<List<composer.Draft>>
        >
    with $FutureModifier<List<composer.Draft>>, $StreamProvider<List<composer.Draft>> {
  DraftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftsHash();

  @$internal
  @override
  $StreamProviderElement<List<composer.Draft>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<composer.Draft>> create(Ref ref) {
    return drafts(ref);
  }
}

String _$draftsHash() => r'73fc235cfabb2c75918a369263c0e97c92b37119';

@ProviderFor(draft)
final draftProvider = DraftFamily._();

final class DraftProvider
    extends
        $FunctionalProvider<AsyncValue<composer.Draft?>, composer.Draft?, Stream<composer.Draft?>>
    with $FutureModifier<composer.Draft?>, $StreamProvider<composer.Draft?> {
  DraftProvider._({required DraftFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'draftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftHash();

  @override
  String toString() {
    return r'draftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<composer.Draft?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<composer.Draft?> create(Ref ref) {
    final argument = this.argument as String;
    return draft(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$draftHash() => r'841f55556364815f261e5395aff1c80a71e73687';

final class DraftFamily extends $Family
    with $FunctionalFamilyOverride<Stream<composer.Draft?>, String> {
  DraftFamily._()
    : super(
        retry: null,
        name: r'draftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DraftProvider call(String id) => DraftProvider._(argument: id, from: this);

  @override
  String toString() => r'draftProvider';
}
