import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/paged_list_footer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('PagedListFooter', () {
    group('loading state', () {
      testWidgets('shows circular progress indicator', (tester) async {
        await tester.pumpApp(
          const Column(children: [PagedListFooter(state: PagedListState.loading)]),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('indicator has small size', (tester) async {
        await tester.pumpApp(
          const Column(children: [PagedListFooter(state: PagedListState.loading)]),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          ),
        );
        expect(sizedBox.width, equals(24));
        expect(sizedBox.height, equals(24));
      });
    });

    group('end state', () {
      testWidgets('shows default end message', (tester) async {
        await tester.pumpApp(const Column(children: [PagedListFooter(state: PagedListState.end)]));

        expect(find.text("You've reached the end"), findsOneWidget);
      });

      testWidgets('shows custom end message when provided', (tester) async {
        const customMessage = 'No more posts';
        await tester.pumpApp(
          const Column(
            children: [PagedListFooter(state: PagedListState.end, endMessage: customMessage)],
          ),
        );

        expect(find.text(customMessage), findsOneWidget);
        expect(find.text("You've reached the end"), findsNothing);
      });
    });

    group('error state', () {
      testWidgets('shows error icon', (tester) async {
        await tester.pumpApp(
          const Column(children: [PagedListFooter(state: PagedListState.error)]),
        );

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('shows default error message', (tester) async {
        await tester.pumpApp(
          const Column(children: [PagedListFooter(state: PagedListState.error)]),
        );

        expect(find.text('Failed to load more'), findsOneWidget);
      });

      testWidgets('shows custom error message when provided', (tester) async {
        const customError = 'Network error';
        await tester.pumpApp(
          const Column(
            children: [PagedListFooter(state: PagedListState.error, errorMessage: customError)],
          ),
        );

        expect(find.text(customError), findsOneWidget);
        expect(find.text('Failed to load more'), findsNothing);
      });

      testWidgets('shows retry button when onRetry is provided', (tester) async {
        await tester.pumpApp(
          Column(
            children: [PagedListFooter(state: PagedListState.error, onRetry: () {})],
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('does not show retry button when onRetry is null', (tester) async {
        await tester.pumpApp(
          const Column(children: [PagedListFooter(state: PagedListState.error)]),
        );

        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('calls onRetry when retry button is tapped', (tester) async {
        var retryCalled = false;
        await tester.pumpApp(
          Column(
            children: [
              PagedListFooter(state: PagedListState.error, onRetry: () => retryCalled = true),
            ],
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(retryCalled, isTrue);
      });
    });

    testWidgets('centers content', (tester) async {
      await tester.pumpApp(
        const Column(children: [PagedListFooter(state: PagedListState.loading)]),
      );

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('applies vertical padding', (tester) async {
      await tester.pumpApp(
        const Column(children: [PagedListFooter(state: PagedListState.loading)]),
      );

      expect(find.byType(Padding), findsWidgets);
    });
  });

  group('PagedListState', () {
    test('has loading value', () {
      expect(PagedListState.loading, isNotNull);
    });

    test('has end value', () {
      expect(PagedListState.end, isNotNull);
    });

    test('has error value', () {
      expect(PagedListState.error, isNotNull);
    });
  });
}
