// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_monitor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier that monitors and provides real-time performance metrics.

@ProviderFor(PerformanceMonitor)
final performanceMonitorProvider = PerformanceMonitorProvider._();

/// Notifier that monitors and provides real-time performance metrics.
final class PerformanceMonitorProvider
    extends $NotifierProvider<PerformanceMonitor, PerformanceState> {
  /// Notifier that monitors and provides real-time performance metrics.
  PerformanceMonitorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performanceMonitorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performanceMonitorHash();

  @$internal
  @override
  PerformanceMonitor create() => PerformanceMonitor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformanceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformanceState>(value),
    );
  }
}

String _$performanceMonitorHash() => r'd3f1a2fd848cdf8f83d3180eaaa898217a579722';

/// Notifier that monitors and provides real-time performance metrics.

abstract class _$PerformanceMonitor extends $Notifier<PerformanceState> {
  PerformanceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PerformanceState, PerformanceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PerformanceState, PerformanceState>,
              PerformanceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
