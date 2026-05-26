import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';

import '../../../helpers/widget_harness.dart';

void main() {
  Widget buildSubject(Widget child) => testScaffoldApp(child);

  testWidgets('renders title and message', (tester) async {
    await tester.pumpWidget(
      buildSubject(ErrorState(title: 'Failed to load', message: 'Request timed out', onRetry: () {})),
    );

    expect(find.text('Failed to load'), findsOneWidget);
    expect(find.text('Request timed out'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('invokes retry callback', (tester) async {
    var retried = false;
    await tester.pumpWidget(buildSubject(ErrorState(message: 'Failed', onRetry: () => retried = true)));
    await tapAndSettle(tester, find.text('Retry'));
    expect(retried, isTrue);
  });
}
