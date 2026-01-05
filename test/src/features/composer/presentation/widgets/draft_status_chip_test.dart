import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/draft_status_chip.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DraftStatusChip', () {
    testWidgets('renders Draft status with edit icon', (tester) async {
      await tester.pumpApp(const DraftStatusChip(status: DraftStatus.draft));
      expect(find.text('Draft'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('renders Publishing status with spinner', (tester) async {
      await tester.pumpApp(const DraftStatusChip(status: DraftStatus.publishing));
      expect(find.text('Publishing'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders Failed status with error icon', (tester) async {
      await tester.pumpApp(const DraftStatusChip(status: DraftStatus.failed));
      expect(find.text('Failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders Posted status with check icon', (tester) async {
      await tester.pumpApp(const DraftStatusChip(status: DraftStatus.posted));
      expect(find.text('Posted'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}
