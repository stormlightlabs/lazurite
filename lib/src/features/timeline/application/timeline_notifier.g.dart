// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimelineNotifier)
final timelineProvider = TimelineNotifierProvider._();

final class TimelineNotifierProvider
    extends $StreamNotifierProvider<TimelineNotifier, List<TimelineFeedItem>> {
  TimelineNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineNotifierHash();

  @$internal
  @override
  TimelineNotifier create() => TimelineNotifier();
}

String _$timelineNotifierHash() => r'53ed6dc549673c17a958982bbaea7088a10bc329';

abstract class _$TimelineNotifier
    extends $StreamNotifier<List<TimelineFeedItem>> {
  Stream<List<TimelineFeedItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<TimelineFeedItem>>, List<TimelineFeedItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TimelineFeedItem>>,
                List<TimelineFeedItem>
              >,
              AsyncValue<List<TimelineFeedItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
