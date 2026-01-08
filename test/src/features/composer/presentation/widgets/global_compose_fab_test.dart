import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/global_compose_fab.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('GlobalComposeFab', () {
    testWidgets('renders extended FAB with Post label', (tester) async {
      await tester.pumpApp(const GlobalComposeFab());

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders with edit icon', (tester) async {
      await tester.pumpApp(const GlobalComposeFab());
      expect(find.byIcon(CupertinoIcons.pencil_ellipsis_rectangle), findsOneWidget);
    });

    testWidgets('navigates to compose route when tapped', (tester) async {
      final navigatedRoutes = <String>[];
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, _) => const GlobalComposeFab()),
          GoRoute(
            path: AppRoutes.compose,
            builder: (_, state) {
              navigatedRoutes.add(state.matchedLocation);
              return const Scaffold(body: Text('Composer'));
            },
          ),
        ],
      );

      await tester.pumpRouterApp(router: router);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(navigatedRoutes, contains(AppRoutes.compose));
      expect(find.text('Composer'), findsOneWidget);
    });

    testWidgets('uses primary color scheme', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
              ),
              child: const GlobalComposeFab(),
            );
          },
        ),
      );

      final fabWidget = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));

      expect(fabWidget.backgroundColor, Colors.blue);
      expect(fabWidget.foregroundColor, Colors.white);
    });

    testWidgets('has elevation of 6', (tester) async {
      await tester.pumpApp(const GlobalComposeFab());

      final fabWidget = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));

      expect(fabWidget.elevation, 6);
    });
  });
}
