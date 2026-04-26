import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';

void main() {
  Widget buildSubject(void Function(BuildContext context) onPressed) => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: FilledButton(onPressed: () => onPressed(context), child: const Text('show')),
        ),
      ),
    ),
  );

  testWidgets('shows message', (tester) async {
    await tester.pumpWidget(buildSubject((context) => showAppSnackBar(context, 'Saved')));

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('shows action and invokes callback', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      buildSubject(
        (context) => showAppSnackBar(context, 'Failed', actionLabel: 'Retry', onAction: () => retried = true),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();
    expect(find.text('Retry'), findsOneWidget);

    final action = tester.widget<SnackBarAction>(find.byType(SnackBarAction));
    action.onPressed.call();

    expect(retried, isTrue);
  });
}
