import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/report_dialog.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ReportDialog', () {
    testWidgets('renders all reason options', (tester) async {
      await tester.pumpApp(const ReportDialog(actorDid: 'did:example'));

      for (final reason in ReportReason.values) {
        expect(find.text(reason.label), findsOneWidget);
      }
    });

    testWidgets('submit button is disabled initially', (tester) async {
      await tester.pumpApp(const ReportDialog(actorDid: 'did:example'));

      final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Report'));
      expect(button.onPressed, isNull);
    });

    testWidgets('returns ReportRequest when submitted', (tester) async {
      ReportRequest? result;

      await tester.pumpApp(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showDialog<ReportRequest>(
                context: context,
                builder: (_) => const ReportDialog(actorDid: 'did:example'),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ReportReason.spam.label));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'This is spam');
      await tester.pump();

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.reasonType, ReportReason.spam.value);
      expect(result!.reason, 'This is spam');
    });
  });
}
