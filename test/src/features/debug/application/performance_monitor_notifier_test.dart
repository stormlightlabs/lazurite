import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/debug/application/performance_monitor_notifier.dart';

void main() {
  test('kTestMode returns true in test environment', () {
    expect(PerformanceMonitor.kTestMode, true);
  });

  group('PerformanceMonitor', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(performanceMonitorProvider);
      expect(state.fps, 0.0);
      expect(state.rebuildCounts, isEmpty);
      expect(state.queryTimes, isEmpty);
      expect(state.imageCacheLiveCount, 0);
    });

    test('records rebuild counts', () {
      final notifier = container.read(performanceMonitorProvider.notifier);

      notifier.recordRebuild('TestWidget');
      expect(container.read(performanceMonitorProvider).rebuildCounts['TestWidget'], 1);

      notifier.recordRebuild('TestWidget');
      expect(container.read(performanceMonitorProvider).rebuildCounts['TestWidget'], 2);

      notifier.recordRebuild('OtherWidget');
      expect(container.read(performanceMonitorProvider).rebuildCounts['OtherWidget'], 1);
    });

    test('resets rebuild counts', () {
      final notifier = container.read(performanceMonitorProvider.notifier);

      notifier.recordRebuild('TestWidget');
      notifier.resetRebuildCounts();

      expect(container.read(performanceMonitorProvider).rebuildCounts, isEmpty);
    });

    test('records query times and limits to 50', () {
      final notifier = container.read(performanceMonitorProvider.notifier);

      notifier.recordQueryTime(10.5);
      expect(container.read(performanceMonitorProvider).queryTimes, [10.5]);

      for (var i = 0; i < 60; i++) {
        notifier.recordQueryTime(i.toDouble());
      }

      final state = container.read(performanceMonitorProvider);
      expect(state.queryTimes.length, 50);
      expect(state.queryTimes.last, 59.0);
    });
  });

  group('PerformanceMonitor', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(performanceMonitorProvider);
      expect(state.fps, 0.0);
      expect(state.rebuildCounts, isEmpty);
      expect(state.queryTimes, isEmpty);
      expect(state.imageCacheLiveCount, 0);
    });

    test('records rebuild counts', () {
      final notifier = container.read(performanceMonitorProvider.notifier);

      notifier.recordRebuild('TestWidget');
      expect(container.read(performanceMonitorProvider).rebuildCounts['TestWidget'], 1);

      notifier.recordRebuild('TestWidget');
      expect(container.read(performanceMonitorProvider).rebuildCounts['TestWidget'], 2);

      notifier.recordRebuild('OtherWidget');
      expect(container.read(performanceMonitorProvider).rebuildCounts['OtherWidget'], 1);
    });

    test('resets rebuild counts', () {
      final notifier = container.read(performanceMonitorProvider.notifier);

      notifier.recordRebuild('TestWidget');
      notifier.resetRebuildCounts();

      expect(container.read(performanceMonitorProvider).rebuildCounts, isEmpty);
    });

    test('records query times and limits to 50', () {
      final notifier = container.read(performanceMonitorProvider.notifier);

      notifier.recordQueryTime(10.5);
      expect(container.read(performanceMonitorProvider).queryTimes, [10.5]);

      for (var i = 0; i < 60; i++) {
        notifier.recordQueryTime(i.toDouble());
      }

      final state = container.read(performanceMonitorProvider);
      expect(state.queryTimes.length, 50);
      expect(state.queryTimes.last, 59.0);
    });
  });
}
