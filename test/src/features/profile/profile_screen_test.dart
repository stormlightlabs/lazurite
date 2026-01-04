import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/presentation/profile_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('ProfileScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpApp(const ProfileScreen());

      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('renders person icon', (tester) async {
      await tester.pumpApp(const ProfileScreen());

      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    });

    testWidgets('renders profile placeholder text', (tester) async {
      await tester.pumpApp(const ProfileScreen());

      expect(find.text('Your Profile'), findsOneWidget);
      expect(find.text('View and edit your profile'), findsOneWidget);
    });
  });
}
