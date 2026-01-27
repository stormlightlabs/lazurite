import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'performance_monitor_notifier.g.dart';

/// State of performance metrics for the debug dashboard.
class PerformanceState {
  const PerformanceState({
    this.fps = 0.0,
    this.rebuildCounts = const {},
    this.queryTimes = const [],
    this.imageCacheLiveCount = 0,
    this.imageCachePendingCount = 0,
    this.imageCacheByteCount = 0,
  });

  /// Approximate current frames per second.
  final double fps;

  /// Counts of rebuilds for specific widgets (monitored via RebuildTracker).
  final Map<String, int> rebuildCounts;

  /// Recent database query durations in milliseconds.
  final List<double> queryTimes;

  /// Number of images currently in the live cache.
  final int imageCacheLiveCount;

  /// Number of images currently being loaded.
  final int imageCachePendingCount;

  /// Estimated bytes used by the image cache.
  final int imageCacheByteCount;

  PerformanceState copyWith({
    double? fps,
    Map<String, int>? rebuildCounts,
    List<double>? queryTimes,
    int? imageCacheLiveCount,
    int? imageCachePendingCount,
    int? imageCacheByteCount,
  }) {
    return PerformanceState(
      fps: fps ?? this.fps,
      rebuildCounts: rebuildCounts ?? this.rebuildCounts,
      queryTimes: queryTimes ?? this.queryTimes,
      imageCacheLiveCount: imageCacheLiveCount ?? this.imageCacheLiveCount,
      imageCachePendingCount: imageCachePendingCount ?? this.imageCachePendingCount,
      imageCacheByteCount: imageCacheByteCount ?? this.imageCacheByteCount,
    );
  }
}

/// Notifier that monitors and provides real-time performance metrics.
@riverpod
class PerformanceMonitor extends _$PerformanceMonitor {
  Timer? _pollingTimer;
  final List<Duration> _frameTimestamps = [];
  static const _fpsWindowSize = Duration(seconds: 1);

  @override
  PerformanceState build() {
    _startFpsTracking();
    _startMetricsPolling();

    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return const PerformanceState();
  }

  void _startFpsTracking() {
    if (kReleaseMode || kTestMode) return;

    SchedulerBinding.instance.addPersistentFrameCallback((timestamp) {
      if (!ref.exists(performanceMonitorProvider)) return;

      _frameTimestamps.add(timestamp);
      final cutoff = timestamp - _fpsWindowSize;

      while (_frameTimestamps.isNotEmpty && _frameTimestamps.first < cutoff) {
        _frameTimestamps.removeAt(0);
      }
    });
  }

  void _startMetricsPolling() {
    if (kReleaseMode || kTestMode) return;

    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final cache = PaintingBinding.instance.imageCache;
      state = state.copyWith(
        fps: _frameTimestamps.length.toDouble(),
        imageCacheLiveCount: cache.liveImageCount,
        imageCachePendingCount: cache.pendingImageCount,
        imageCacheByteCount: cache.currentSizeBytes,
      );
    });
  }

  /// Whether we are currently running in a test environment.
  static bool get kTestMode => Platform.environment.containsKey('FLUTTER_TEST');

  /// Increments the rebuild count for a named widget.
  void recordRebuild(String widgetName) {
    final counts = Map<String, int>.from(state.rebuildCounts);
    counts[widgetName] = (counts[widgetName] ?? 0) + 1;
    state = state.copyWith(rebuildCounts: counts);
  }

  /// Records a database query duration.
  void recordQueryTime(double ms) {
    final times = List<double>.from(state.queryTimes)..add(ms);
    if (times.length > 50) {
      times.removeAt(0);
    }
    state = state.copyWith(queryTimes: times);
  }

  /// Clears all accumulated rebuild counts.
  void resetRebuildCounts() {
    state = state.copyWith(rebuildCounts: const {});
  }
}

/// A widget that tracks rebuilds of its children in the [PerformanceMonitor].
class RebuildTracker extends ConsumerWidget {
  const RebuildTracker({required this.name, required this.child, super.key});

  /// Identifier for the widget(s) being tracked.
  final String name;

  /// The widget tree to wrap.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(performanceMonitorProvider.notifier).recordRebuild(name);
      }
    });
    return child;
  }
}
