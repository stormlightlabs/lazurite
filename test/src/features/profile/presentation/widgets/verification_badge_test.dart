import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/verification_badge.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('VerificationBadge', () {
    testWidgets('renders nothing when verificationStatus is null', (tester) async {
      await tester.pumpApp(const VerificationBadge(verificationStatus: null));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renders default badge for unknown status', (tester) async {
      await tester.pumpApp(const VerificationBadge(verificationStatus: 'dummy'));
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byTooltip('Verified Account'), findsOneWidget);
    });

    testWidgets('renders official badge for "official" status', (tester) async {
      await tester.pumpApp(const VerificationBadge(verificationStatus: 'official'));
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byTooltip('Official Account'), findsOneWidget);
    });

    testWidgets('renders business badge for "business" status', (tester) async {
      await tester.pumpApp(const VerificationBadge(verificationStatus: 'business'));
      await tester.pump();

      expect(find.byIcon(Icons.business), findsOneWidget);
      expect(find.byTooltip('Business Account'), findsOneWidget);
    });
  });
}
