import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('PullToRefreshWrapper', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpApp(
        PullToRefreshWrapper(
          onRefresh: () async {},
          child: ListView(children: const [Text('Item 1'), Text('Item 2')]),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('wraps child in RefreshIndicator', (tester) async {
      await tester.pumpApp(
        PullToRefreshWrapper(
          onRefresh: () async {},
          child: ListView(children: const [Text('Item')]),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('triggers onRefresh callback on pull down', (tester) async {
      var refreshCalled = false;
      await tester.pumpApp(
        PullToRefreshWrapper(
          onRefresh: () async {
            refreshCalled = true;
          },
          child: ListView(children: const [SizedBox(height: 200, child: Text('Content'))]),
        ),
      );

      // Perform a fling down gesture to trigger refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
    });

    testWidgets('uses primary color by default', (tester) async {
      await tester.pumpApp(
        PullToRefreshWrapper(
          onRefresh: () async {},
          child: ListView(children: const [Text('Item')]),
        ),
      );

      final refreshIndicator = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
      expect(refreshIndicator.color, isNotNull);
    });

    testWidgets('uses custom color when provided', (tester) async {
      const customColor = Colors.orange;
      await tester.pumpApp(
        PullToRefreshWrapper(
          onRefresh: () async {},
          color: customColor,
          child: ListView(children: const [Text('Item')]),
        ),
      );

      final refreshIndicator = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
      expect(refreshIndicator.color, equals(customColor));
    });

    testWidgets('completes refresh correctly', (tester) async {
      final completer = Completer<void>();
      await tester.pumpApp(
        PullToRefreshWrapper(
          onRefresh: () => completer.future,
          child: ListView(children: const [SizedBox(height: 200, child: Text('Content'))]),
        ),
      );

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Content'), findsOneWidget);
    });
  });
}
