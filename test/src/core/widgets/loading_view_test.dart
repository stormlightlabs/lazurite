import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('LoadingView', () {
    testWidgets('renders circular progress indicator', (tester) async {
      await tester.pumpApp(const LoadingView());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders without message by default', (tester) async {
      await tester.pumpApp(const LoadingView());
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders optional message when provided', (tester) async {
      const message = 'Loading your timeline...';
      await tester.pumpApp(const LoadingView(message: message));
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('centers content vertically and horizontally', (tester) async {
      await tester.pumpApp(const LoadingView());
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('message is displayed below indicator', (tester) async {
      const message = 'Please wait';
      await tester.pumpApp(const LoadingView(message: message));
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });
  });
}
