import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/search/presentation/widgets/search_bar_widget.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('SearchBarWidget', () {
    testWidgets('renders with hint text', (tester) async {
      await tester.pumpApp(const Material(child: SearchBarWidget(hintText: 'Search posts...')));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search posts...'), findsOneWidget);
    });

    testWidgets('renders with initial query', (tester) async {
      await tester.pumpApp(const Material(child: SearchBarWidget(initialQuery: 'flutter')));

      expect(find.text('flutter'), findsOneWidget);
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      await tester.pumpApp(const Material(child: SearchBarWidget()));

      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears text when clear button is pressed', (tester) async {
      var cleared = false;

      await tester.pumpApp(
        Material(
          child: SearchBarWidget(initialQuery: 'test', onClear: () => cleared = true),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(cleared, isTrue);
    });

    testWidgets('invokes onSubmitted when search is submitted', (tester) async {
      String? submittedQuery;

      await tester.pumpApp(
        Material(child: SearchBarWidget(onSubmitted: (query) => submittedQuery = query)),
      );

      await tester.enterText(find.byType(TextField), 'flutter development');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedQuery, 'flutter development');
    });

    testWidgets('trims whitespace on submit', (tester) async {
      String? submittedQuery;

      await tester.pumpApp(
        Material(child: SearchBarWidget(onSubmitted: (query) => submittedQuery = query)),
      );

      await tester.enterText(find.byType(TextField), '  flutter  ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedQuery, 'flutter');
    });

    testWidgets('does not submit empty query', (tester) async {
      String? submittedQuery;

      await tester.pumpApp(
        Material(child: SearchBarWidget(onSubmitted: (query) => submittedQuery = query)),
      );

      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedQuery, isNull);
    });

    testWidgets('invokes onChanged when text changes', (tester) async {
      final changes = <String>[];

      await tester.pumpApp(Material(child: SearchBarWidget(onChanged: changes.add)));

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();

      expect(changes, contains('a'));
      expect(changes, contains('ab'));
    });

    testWidgets('shows search icon', (tester) async {
      await tester.pumpApp(const Material(child: SearchBarWidget()));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('autofocuses when autofocus is true', (tester) async {
      await tester.pumpApp(const Material(child: SearchBarWidget(autofocus: true)));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });
  });
}
