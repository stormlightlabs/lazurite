// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(timelineRepository)
final timelineRepositoryProvider = TimelineRepositoryProvider._();

final class TimelineRepositoryProvider
    extends $FunctionalProvider<TimelineRepository, TimelineRepository, TimelineRepository>
    with $Provider<TimelineRepository> {
  TimelineRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineRepositoryHash();

  @$internal
  @override
  $ProviderElement<TimelineRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimelineRepository create(Ref ref) {
    return timelineRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimelineRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimelineRepository>(value),
    );
  }
}

String _$timelineRepositoryHash() => r'8d3030173e5f8b599de955cf3b0d4c6da8cfe88d';
