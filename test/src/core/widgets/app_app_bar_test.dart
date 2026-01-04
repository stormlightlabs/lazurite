import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/app_app_bar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppAppBar', () {
    testWidgets('renders title', (tester) async {
      const title = 'Home';
      await tester.pumpApp(const Scaffold(appBar: AppAppBar(title: title)));

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpApp(
        Scaffold(
          appBar: AppAppBar(
            title: 'Home',
            actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})],
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('does not render actions when null', (tester) async {
      await tester.pumpApp(const Scaffold(appBar: AppAppBar(title: 'Home')));

      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('renders leading widget when provided', (tester) async {
      await tester.pumpApp(
        Scaffold(
          appBar: AppAppBar(
            title: 'Details',
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('implements PreferredSizeWidget', (tester) async {
      const appBar = AppAppBar(title: 'Home');

      expect(appBar, isA<PreferredSizeWidget>());
      expect(appBar.preferredSize, equals(const Size.fromHeight(kToolbarHeight)));
    });

    testWidgets('can set centerTitle', (tester) async {
      await tester.pumpApp(
        const Scaffold(appBar: AppAppBar(title: 'Centered', centerTitle: true)),
      );

      expect(find.text('Centered'), findsOneWidget);
    });

    testWidgets('renders multiple actions', (tester) async {
      await tester.pumpApp(
        Scaffold(
          appBar: AppAppBar(
            title: 'Home',
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
