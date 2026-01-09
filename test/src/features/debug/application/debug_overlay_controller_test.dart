import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/debug/application/debug_overlay_controller.dart';

void main() {
  group('DebugOverlayState', () {
    test('default state has isVisible false and activeTabIndex 0', () {
      const state = DebugOverlayState();

      expect(state.isVisible, false);
      expect(state.activeTabIndex, 0);
    });

    test('copyWith creates a copy with updated values', () {
      const state = DebugOverlayState();

      final copy = state.copyWith(isVisible: true, activeTabIndex: 1);

      expect(copy.isVisible, true);
      expect(copy.activeTabIndex, 1);
    });

    test('copyWith preserves original values when not specified', () {
      const state = DebugOverlayState(isVisible: true, activeTabIndex: 2);

      final copy = state.copyWith();

      expect(copy.isVisible, true);
      expect(copy.activeTabIndex, 2);
    });

    test('equality works correctly', () {
      const state1 = DebugOverlayState(isVisible: true, activeTabIndex: 1);
      const state2 = DebugOverlayState(isVisible: true, activeTabIndex: 1);
      const state3 = DebugOverlayState(isVisible: false, activeTabIndex: 1);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('hashCode is consistent with equality', () {
      const state1 = DebugOverlayState(isVisible: true, activeTabIndex: 1);
      const state2 = DebugOverlayState(isVisible: true, activeTabIndex: 1);

      expect(state1.hashCode, equals(state2.hashCode));
    });
  });

  group('DebugOverlayController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is not visible', () {
      final state = container.read(debugOverlayControllerProvider);

      expect(state.isVisible, false);
    });

    test('show() sets isVisible to true', () {
      container.read(debugOverlayControllerProvider.notifier).show();

      final state = container.read(debugOverlayControllerProvider);

      expect(state.isVisible, true);
    });

    test('hide() sets isVisible to false', () {
      container.read(debugOverlayControllerProvider.notifier).show();
      container.read(debugOverlayControllerProvider.notifier).hide();

      final state = container.read(debugOverlayControllerProvider);

      expect(state.isVisible, false);
    });

    test('toggle() toggles visibility from false to true', () {
      container.read(debugOverlayControllerProvider.notifier).toggle();

      final state = container.read(debugOverlayControllerProvider);

      expect(state.isVisible, true);
    });

    test('toggle() toggles visibility from true to false', () {
      container.read(debugOverlayControllerProvider.notifier).show();
      container.read(debugOverlayControllerProvider.notifier).toggle();

      final state = container.read(debugOverlayControllerProvider);

      expect(state.isVisible, false);
    });

    test('setTab() sets the active tab index', () {
      container.read(debugOverlayControllerProvider.notifier).setTab(1);

      final state = container.read(debugOverlayControllerProvider);

      expect(state.activeTabIndex, 1);
    });

    test('setTab() preserves visibility', () {
      container.read(debugOverlayControllerProvider.notifier).show();
      container.read(debugOverlayControllerProvider.notifier).setTab(1);

      final state = container.read(debugOverlayControllerProvider);

      expect(state.isVisible, true);
      expect(state.activeTabIndex, 1);
    });
  });
}
