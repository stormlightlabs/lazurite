import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';

void main() {
  Widget buildSubject({required Future<void> Function(BuildContext context) onPressed}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: FilledButton(onPressed: () => onPressed(context), child: const Text('open')),
            );
          },
        ),
      ),
    );
  }

  testWidgets('returns true when confirmed', (tester) async {
    var confirmed = false;

    await tester.pumpWidget(
      buildSubject(
        onPressed: (context) async {
          confirmed = await showConfirmationDialog(
            context: context,
            title: const Text('Delete post?'),
            content: const Text('This cannot be undone.'),
            confirmLabel: 'Delete',
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete post?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('returns false when cancelled', (tester) async {
    var confirmed = true;

    await tester.pumpWidget(
      buildSubject(
        onPressed: (context) async {
          confirmed = await showConfirmationDialog(
            context: context,
            title: const Text('Discard changes?'),
            content: const Text('Unsaved changes will be lost.'),
            confirmLabel: 'Discard',
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);
  });
}
