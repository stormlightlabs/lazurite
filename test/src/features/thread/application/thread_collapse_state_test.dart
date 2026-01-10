import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/application/thread_collapse_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('ThreadCollapseState', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty map', () {
      final state = container.read(threadCollapseStateProvider);
      expect(state, isEmpty);
    });

    group('isCollapsed', () {
      test('returns false for posts not in state', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        expect(notifier.isCollapsed('at://user/post/1'), false);
      });

      test('returns true for collapsed posts', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapse('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), true);
      });

      test('returns false for expanded posts', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.expand('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), false);
      });
    });

    group('toggle', () {
      test('collapses expanded post', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.toggle('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), true);
      });

      test('expands collapsed post', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapse('at://user/post/1');
        notifier.toggle('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), false);
      });

      test('toggles multiple posts independently', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.toggle('at://user/post/1');
        notifier.toggle('at://user/post/2');

        expect(notifier.isCollapsed('at://user/post/1'), true);
        expect(notifier.isCollapsed('at://user/post/2'), true);

        notifier.toggle('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), false);
        expect(notifier.isCollapsed('at://user/post/2'), true);
      });
    });

    group('collapse', () {
      test('collapses post', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapse('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), true);
      });

      test('keeps post collapsed when called multiple times', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapse('at://user/post/1');
        notifier.collapse('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), true);
      });
    });

    group('expand', () {
      test('expands post', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapse('at://user/post/1');
        notifier.expand('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), false);
      });

      test('keeps post expanded when called multiple times', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.expand('at://user/post/1');
        notifier.expand('at://user/post/1');
        expect(notifier.isCollapsed('at://user/post/1'), false);
      });
    });

    group('collapseAll', () {
      test('collapses all posts in list', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapseAll(['at://user/post/1', 'at://user/post/2', 'at://user/post/3']);

        expect(notifier.isCollapsed('at://user/post/1'), true);
        expect(notifier.isCollapsed('at://user/post/2'), true);
        expect(notifier.isCollapsed('at://user/post/3'), true);
      });

      test('preserves state of posts not in list', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapse('at://user/post/existing');

        notifier.collapseAll(['at://user/post/1', 'at://user/post/2']);

        expect(notifier.isCollapsed('at://user/post/existing'), true);
        expect(notifier.isCollapsed('at://user/post/1'), true);
        expect(notifier.isCollapsed('at://user/post/2'), true);
      });

      test('handles empty list', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapse('at://user/post/1');
        notifier.collapseAll([]);

        expect(notifier.isCollapsed('at://user/post/1'), true);
      });
    });

    group('expandAll', () {
      test('clears all collapse state', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.collapseAll(['at://user/post/1', 'at://user/post/2', 'at://user/post/3']);

        notifier.expandAll();

        expect(notifier.isCollapsed('at://user/post/1'), false);
        expect(notifier.isCollapsed('at://user/post/2'), false);
        expect(notifier.isCollapsed('at://user/post/3'), false);
      });

      test('works when state is already empty', () {
        final notifier = container.read(threadCollapseStateProvider.notifier);
        notifier.expandAll();

        final state = container.read(threadCollapseStateProvider);
        expect(state, isEmpty);
      });
    });

    test('state updates trigger rebuilds', () {
      var buildCount = 0;
      container.listen(threadCollapseStateProvider, (previous, next) => buildCount++);

      final notifier = container.read(threadCollapseStateProvider.notifier);

      notifier.toggle('at://user/post/1');
      expect(buildCount, 1);

      notifier.collapse('at://user/post/2');
      expect(buildCount, 2);

      notifier.expandAll();
      expect(buildCount, 3);
    });
  });
}
